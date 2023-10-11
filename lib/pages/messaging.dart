import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/palette.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference _messagesRef;
  late DatabaseReference _usersRef;
  final TextEditingController _textController = TextEditingController();
  List<Message> _messages = [];
  Set<User> _users = Set<User>();
  User? _selectedUser;
  String _currentUser = "";

  @override
  void initState() {
    super.initState();
    // Get current user's ID
    _currentUser =
        FirebaseAuth.instance.currentUser!.email!.hashCode.toString();
    //print(_currentUser);

    _messagesRef = database.ref().child("messages").child(_currentUser);
    _usersRef = database.ref().child("users");
    _usersRef.onChildAdded.listen((event) {
      setState(() {
        String firstName = event.snapshot.child("first name").value.toString();
        String lastName = event.snapshot.child("last name").value.toString();
        String userRole = event.snapshot.child("userType").value.toString();
        String fullname = firstName + " " + lastName;
        String checkStringID = event.snapshot.key.toString();
        //print("name: " + fullname + " ID: " + checkStringID);
        _users.add(User(Name: fullname, ID: checkStringID, userType: userRole));
      });
    });
  }

  void _sendMessage(String message) {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    _messagesRef.child(_selectedUser!.ID).push().set({
      "message": message,
      "sender": _currentUser,
      "timestamp": formattedDate
    });
    _messagesRef.parent
        ?.child(_selectedUser!.ID)
        .child(_currentUser)
        .push()
        .set({
      "message": message,
      "sender": _currentUser,
      "timestamp": formattedDate
    });
    setState(() {
      //_messages.add(message);
    });
    _textController.clear();
  }

  Widget _buildMessage(Message message) {
    bool isCurrentUser = message.sender == _currentUser;
    final now = DateTime.now();
    final messageTime = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
    final isSameDay = messageTime.day == now.day &&
        messageTime.month == now.month &&
        messageTime.year == now.year;
    print(message.message);
    print(messageTime.day);
    print(now.day);
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
      title: Text(user.Name),
      subtitle: Text(user.userType),
      tileColor: Colors.white,
      onTap: () {
        setState(() {
          _selectedUser = user;
          _messages.clear();
          _messagesRef.child(_selectedUser!.ID).onChildAdded.listen((event) {
            setState(() {
              String message = event.snapshot.child("message").value.toString();
              String sender = event.snapshot.child("sender").value.toString();
              String timestampString =
                  event.snapshot.child("timestamp").value.toString();
              DateTime timestamp = DateTime.parse(timestampString);
              int timestampInt = timestamp.millisecondsSinceEpoch;
              _messages.add(new Message(
                  message: message, sender: sender, timestamp: timestampInt));
              print(message);
            });
          });
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildUserList() {
    return Drawer(
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (BuildContext context, int index) {
          //print(_users.length);
          //print(index);
          //print("name: " +
          //_users.elementAt(index).Name +
          //" ID: " +
          //_users.elementAt(index).ID);
          // checks to see if the user isn't the current user so you can't self message
          if (_users.elementAt(index).ID != _currentUser) {
            return _buildUserTile(_users.elementAt(index));
          } else {
            return SizedBox(); // return emptybox if its the currentuser
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedUser != null ? _selectedUser!.Name : 'Chat'),
        backgroundColor: Palette.ktoCrimson,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.people),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ],
      ),
      drawer: _buildUserList(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                bool isCurrentUser = _selectedUser == _currentUser;
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
                  offset: Offset(0, 1), // changes position of shadow
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
      ),
    );
  }
}

class Message {
  final String message;
  final String sender;
  final int timestamp;

  Message(
      {required this.message, required this.sender, required this.timestamp});
}

class User {
  final String Name;
  final String ID;
  final String userType;

  User({required this.Name, required this.ID, required this.userType});
}
