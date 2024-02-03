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

class _ChatPageState extends State<ChatPage> {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference _messagesRef;
  late DatabaseReference _usersRef;
  late DatabaseReference _messagesHelpRef;
  final TextEditingController _textController = TextEditingController();
  List<Message> _messages = [];
  Set<User> _users = Set<User>();
  String _currentUser = "";
  User? _selectedUser;

  void _addNewMessageListener() {
    _messagesRef.onChildAdded.listen((event) {
      setState(() {
        if (event.snapshot.key! != _currentUser)
          _addMessageListener(event.snapshot.key!);
      });
    });
  }



  void _addMessageListener(String user) {
    _messagesRef.child(user).onChildAdded.listen((event) {
      setState(() {
        String sender = event.snapshot.child("sender").value.toString();
        if (sender == _currentUser) return;

        if (_selectedUser == null || sender != _selectedUser!.ID) {
          
          for (User u in _users) {
            if (u.ID == sender) {
              u.hasUnreadMessages = true;
            }
          }
        }
      });

    });
  }

  @override
  void initState() {
    super.initState();
    // Get current user's ID
    _currentUser =
        FirebaseAuth.instance.currentUser!.email!.hashCode.toString();

    _messagesRef = database.ref().child("messages").child(_currentUser);
    _messagesHelpRef = database.ref().child("messagesHelp").child(_currentUser);
    _usersRef = database.ref().child("users");
    _initializeUsers();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollDown();
    // });
  }

  void _addMessageListenerBackup()
  {
    _messagesRef.child(_selectedUser!.ID).onChildAdded.listen((event) {
    setState(() {
      String message = event.snapshot.child("message").value.toString();
      String sender = event.snapshot.child("sender").value.toString();
      print("Received [$message] from $sender");

      if (_selectedUser == null ||
          (sender != _selectedUser!.ID && sender != _currentUser)) {
        for (User u in _users) {
          if (u.ID == sender) {
            u.hasUnreadMessages = true;
          }
        }
        print("Returning");
        return;
      }

      String timestampString =
          event.snapshot.child("timestamp").value.toString();
      bool isSeen = event.snapshot.child("isSeen").value as bool;
      DateTime timestamp = DateTime.parse(timestampString);
      int timestampInt = timestamp.millisecondsSinceEpoch;
      print("${_messages.length}");
      _messages.insert(0,Message(
          message: message,
          sender: sender,
          timestamp: timestampInt,
          isSeen: isSeen));
      _setUserLastMessage(_selectedUser, message);
      print("${_messages.length}");


    });
  });
  }
  Future<void> _initializeUsers() async
  {
      await _usersRef.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? usersData = snapshot.value as Map<dynamic, dynamic>?;
      if (usersData != null) {
        usersData.forEach((key, value) {
          
          String userRole = value["userType"];
          String fullname = value["first name"] + " " + value["last name"];
          String checkStringID = key;
          DatabaseReference _allUserMessages =
              _messagesRef.child(event.snapshot.child("email").value.hashCode.toString());
          database.ref().child("messages").child(_currentUser).once().then((e) {
            if (e.snapshot.value != null) {
              Map<dynamic, dynamic> values = e.snapshot.value as Map;
              values.forEach((id, messages) {
                if (id != checkStringID) {
                  return;
                }

                dynamic msgs = messages as Map;
                msgs.forEach((msgID, message) {
                  dynamic msg = msgs[msgID] as Map;
                  if (!msg["isSeen"]) {
                    for (User u in _users) {
                      if (u.ID == checkStringID) {
                        if (!u.hasUnreadMessages) {
                          setState(() {
                            u.hasUnreadMessages = true;
                          });
                        }
                      }
                    }
                  }
                });
              });
            }
          });

        setState(() {
            _users.add(User(
                Name: fullname, ID: checkStringID, userType: userRole, hasUnreadMessages: false));
        });
        });
      }
    });

    
    _addNewMessageListener();
      for(User u in _users)
      {
        if(u.ID == widget.selectedUserID)
          setState(() 
          { 
            _selectedUser = u;
            _addMessageListenerBackup(); 
          });
      }
    _messages.clear();
    await _messagesRef.child(_selectedUser!.ID).once().then((e) 
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
                  timestamp: timestampInt,
                  isSeen: true));

                  
          });
        }
    });
    setState(() {});
  }

  void _sendMessage(String message) {
    print("Sending Message [$message]");
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    _messagesRef.child(_selectedUser!.ID).push().set({
      "message": message,
      "sender": _currentUser,
      "timestamp": formattedDate,
      "isSeen": true
    });
    _messagesRef.parent
        ?.child(_selectedUser!.ID)
        .child(_currentUser)
        .push()
        .set({
      "message": message,
      "sender": _currentUser,
      "timestamp": formattedDate,
      "isSeen": false
    });
    setState(() {});
    
    _textController.clear();
  }

  Future<String> _getUserLastMessage(User? u) async {
  if (u == null) {
    return "";
  }

  DatabaseReference reference = _messagesHelpRef.child(u.ID);

  try {
    var e = await reference.once();
    
    if (e.snapshot.value != null) {
      Map<dynamic, dynamic> values = e.snapshot.value as Map;
      print("$values - ${values["lastMessage"]}");
      return values["lastMessage"] ?? "";
    } else {
      print("Snapshot null");
      return "";
    }
  } catch (error) {
    print("Error: $error");
    return "";
  }
}

  void _setUserLastMessage(User? u, String message)
  {
    if(u == null)
    {
      return;
    }
    DatabaseReference reference = _messagesHelpRef.child(u.ID);
    reference.set({"lastMessage": message});
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
          _messages.clear();
          _messagesRef.child(_selectedUser!.ID).onChildAdded.listen((event) {
            setState(() {
              String message = event.snapshot.child("message").value.toString();
              String sender = event.snapshot.child("sender").value.toString();

              if (_selectedUser == null ||
                  (sender != _selectedUser!.ID && sender != _currentUser)) {
                for (User u in _users) {
                  if (u.ID == sender) {
                    u.hasUnreadMessages = true;
                  }
                }
                return;
              }

              String timestampString =
                  event.snapshot.child("timestamp").value.toString();
              bool isSeen = event.snapshot.child("isSeen").value as bool;
              DateTime timestamp = DateTime.parse(timestampString);
              int timestampInt = timestamp.millisecondsSinceEpoch;
              _messages.insert(0,Message(
                  message: message,
                  sender: sender,
                  timestamp: timestampInt,
                  isSeen: isSeen));
              _setUserLastMessage(_selectedUser, message);
                
            });
          });

          DatabaseReference _messagesFromUser = _messagesRef.child(user.ID);
          _messagesRef.once().then((e) {
            setState(() {
              if (e.snapshot.value != null) {
                Map<dynamic, dynamic> values = e.snapshot.value as Map;
                values.forEach((id, messages) {
                  if (id != user.ID) {
                    return;
                  }
                  dynamic msgs = messages as Map;
                  msgs.forEach((msgID, message) {
                    _messagesRef.child(id).child(msgID).child("isSeen").set(true);
                  });
                });
              }
            });
          });
          user.hasUnreadMessages = false;
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
  final bool isSeen;

  Message(
      {required this.message,
      required this.sender,
      required this.timestamp,
      required this.isSeen});
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



