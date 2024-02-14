import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/palette.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ChatPage extends StatefulWidget {
  String? selectedUserID;
  ChatPage(this.selectedUserID);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> 
{
  final FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference _messagesRef;
  late DatabaseReference _usersRef;
  late DatabaseReference _messagesHelpRef;
  final TextEditingController _textController = TextEditingController();
  List<Message> _messages = [];
  Set<User> _users = Set<User>();
  String _currentUser = "";
  User? _selectedUser;


  @override
  void initState() {
    super.initState();
    // Get current user's ID
    _currentUser = FirebaseAuth.instance.currentUser!.email!.hashCode.toString();
    _messagesRef = database.ref().child("messages").child(_currentUser);
    _messagesHelpRef = database.ref().child("messagesHelp").child(_currentUser);
    _usersRef = database.ref().child("users");
    _initializeUsers();
    _setSelectedUser();
  }

  User? _getUser(String userID)
  {
      for(User u in _users)
      {
          if(u.ID == userID)
          {
            return u;
          }
      }
      return null;
  }

  void _setSelectedUser()
  {
    if(widget.selectedUserID == null)
    {
      return;
    }
    _createUserMessageList(widget.selectedUserID!);
    User? user = _getUser(widget.selectedUserID);
    if(user == null)
    {
      print("User [${widget.selectedUserID}] is null");
    }
    _selectedUser = user!;
    setState((){});
  }

  void _changeUserReadMessages(String userID, bool value)
  {
      _messagesHelpRef.child(userID).push().update({"
      ": value});
      User? user = _getUser(userID);
      if(user == null)
      {
        print("Unable to find user [${userID}]");
        return;
      }
      user!.hasUnreadMessages = value;
  }

  void _onUserMessageAdded(DatabaseEvent event)
  {
      String message = event.snapshot.child("message").value.toString();
      print("On User Message Add");
      String? userID = event.snapshot.ref.parent!.key;
      if(_selectedUser != null && userID == _selectedUser.ID)
      {

        _messagesHelpRef.child(_selectedUser.ID).update()
        _addNewMessageToList(event);
        return;
      }
      setState(() {_changeUserReadMessages(userID!, true);});
      
  }


  void _addNewMessageToList(DatabaseEvent event)
  {
    String message = event.snapshot.child("message").value.toString();
    String sender = event.snapshot.child("sender").value.toString();

    print("Received [$message] from $sender");

    String timestampString = event.snapshot.child("timestamp").value.toString();
    DateTime timestamp = DateTime.parse(timestampString);
    int timestampInt = timestamp.millisecondsSinceEpoch;

    print("${_messages.length}");

    _messages.insert(0,Message(
        message: message,
        sender: sender,
        timestamp: timestampInt));
    setState(() {});
  }

  Future<void> _initializeUsers() async
  {
    print("Initializing Users");
    await _usersRef.once().then((DatabaseEvent event) 
    {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? usersData = snapshot.value as Map<dynamic, dynamic>?;
      if (usersData == null) 
      {
        return;
      }
      usersData.forEach((key, value) 
      {
          
        String userRole = value["userType"];
        String fullname = value["first name"] + " " + value["last name"];
        print(fullname);
        String checkStringID = key;
        if(checkStringID == _currentUser)
        {
          return;
        }
        bool hasUnreadMessages;
        try
        {
          hasUnreadMessages = _messagesHelpRef.child(checkStringID).child("hasUnreadMessages") as bool;
        }
        catch (e)
        {
          hasUnreadMessages = false;
          _messagesHelpRef.child(checkStringID).push().set({"hasUnreadMessages": false, "lastMessage" : ""});
        }
        _messagesRef.child(checkStringID).onChildAdded.listen(_onUserMessageAdded);

        setState(() 
        {
          _users.add(User(Name: fullname, ID: checkStringID, userType: userRole, hasUnreadMessages: hasUnreadMessages!));
        });
      });
    });
  }

  void _sendMessage(String message) {
    print("Sending Message [$message]");
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    _messagesRef.child(_selectedUser!.ID).push().set({
      "message": message,
      "sender": _currentUser,
      "timestamp": formattedDate,
    });
    _messagesRef.parent
        ?.child(_selectedUser!.ID)
        .child(_currentUser)
        .push()
        .set({
      "message": message,
      "sender": _currentUser,
      "timestamp": formattedDate,
    });
    _messagesHelpRef.parent?.child(_selectedUser!.ID).child(_currentUser).push().set({"hasUnreadMessages": true,"lastMessage": message});
    _messagesHelpRef.child(_selectedUser!.ID).push().set({"lastMessage": message}, {merge: true});
    setState(() {});
    
    _textController.clear();
  }

  Future<String> _getUserLastMessage(User? u) async {
    if (u == null) {
      return "";
    }

    String lastMessage = "";    
    try
    {
      lastMessage = _messagesHelpRef.child(u.ID).child("lastMessage");
    }
    catch (e)
    {
      lastMessage = "";
    }
    return lastMessage;
  }

  Future<void> _createUserMessageList(String userID) async
  {
    _messages.clear();
    await _messagesRef.child(userID).once().then((e) 
    {
        if (e.snapshot.value != null) 
        {
          Map<dynamic, dynamic> values = e.snapshot.value as Map;
          values.forEach((id, messages) 
          {
            String message = messages["message"];
            String sender = messages["sender"];
            DateTime timestamp = DateTime.parse(messages["timestamp"]);
            int timestampInt = timestamp.millisecondsSinceEpoch;

            _messages.insert(0,Message(
                  message: message,
                  sender: sender,
                  timestamp: timestampInt));
          });
        }
    });
  }

  Widget _buildMessage(Message message) {
    bool isCurrentUser = message.sender == _currentUser;
    final now = DateTime.now();
    final messageTime = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
    final isSameDay = messageTime.day == now.day &&
        messageTime.month == now.month &&
        messageTime.year == now.year;
    final dateFormat = isSameDay ? 'h:mm a' : 'MMM d, h:mm a';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            Icon(
              Icons.person,
              color: Colors.grey[300],
            ),
          if (!isCurrentUser) SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                SizedBox(height: 5.0),
                Text(
                  DateFormat(dateFormat).format(messageTime),
                  style: TextStyle(
                    color: isCurrentUser
                        ? Color.fromARGB(179, 166, 166, 166)
                        : Colors.black54,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(User user) {
    return ListTile(
      title: Row(
        children: [
          Text(user.Name),
          if (user.hasUnreadMessages)
            Icon(
              Icons.brightness_1,
              color: Colors.red,
              size: 10.0,
            ),
        ],
      ),
      // subtitle: Text(user.userType),
      subtitle: FutureBuilder<String>(
        future: _getUserLastMessage(user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("");
          } else if (snapshot.hasError) {
            return Text("");
          } else {
            String lastMessage = snapshot.data ?? "";
            return Text('$lastMessage');
          }
        },
      ),
      tileColor: _selectedUser == user ? Colors.grey[300] : Colors.white,
      onTap: () {
        setState(() {
          _selectedUser = user;
          _changeUserReadMessages(_selectedUser!.ID, false);
          setState((){_createUserMessageList(_selectedUser!.ID);});
        });
      },
    );
  }

  Widget _buildUserList() {
    return Container(
  decoration: BoxDecoration(
    // border: Border.all(color: Palette.ktoCrimson, width: 3),
    border: Border(right : BorderSide(color: Palette.ktoCrimson, width: 3)),
  ),
      width: 250.0,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (BuildContext context, int index) {
          
          if (_users.elementAt(index).ID != _currentUser) {
            return _buildUserTile(_users.elementAt(index));
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedUser != null ? _selectedUser!.Name : 'Chat', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Palette.ktoCrimson,
      ),
      body: Row(
        children: [
          _buildUserList(),

          Expanded(
            child: _selectedUser != null ? Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildMessage(_messages[index]);
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                          ),
                          onSubmitted: (String message) {
                            _sendMessage(message);
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          _sendMessage(_textController.text);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )
           : Container(
            // padding: EdgeInsets.all(16.0),  
            color: Colors.white, 
            
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.message,size: 64
                ),
                SizedBox(width: 8.0), 
                Text(
                  'Your messages',
                  style: TextStyle(
                    color: Colors.black, // Set the text color
                    fontSize: 64.0, // Set the font size
                    fontWeight: FontWeight.bold, // Set the font weight
                  ),
                ),
              ],
            ),
          )
          )
        ],
      ),
    );
  }
}

class Message {
  final String message;
  final String sender;
  final int timestamp;

  Message(
      {required this.message,
      required this.sender,
      required this.timestamp,
      });
}

class User {
  final String Name;
  final String ID;
  final String userType;
  bool hasUnreadMessages;

  User({
    required this.Name,
    required this.ID,
    required this.userType,
    this.hasUnreadMessages = false,
  });
}



