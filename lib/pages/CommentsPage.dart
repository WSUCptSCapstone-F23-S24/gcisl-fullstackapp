import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/palette.dart';
import 'package:intl/intl.dart';

class CommentsPage extends StatefulWidget {
  final String postId;
  final String? username;
  final Map<String, dynamic> commentMap;
  CommentsPage(
      {required this.postId, required this.username, required this.commentMap});

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('posts');
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    print("Entered Initial State");
    _loadComments();
  }

  // Function that Loads all the comments on a post from the database
  void _loadComments() {
    print("Entered load comments");
    final DatabaseReference _commentRef =
        _database.child(widget.postId).child('comments');
    _commentRef.onChildAdded.listen((event) {
      setState(() {
        String commentID = event.snapshot.key.toString();
        String text = event.snapshot.child('text').value.toString();
        String sender = event.snapshot.child('sender').value.toString();
        String timeStampString =
            event.snapshot.child('timestamp').value.toString();
        DateTime timestamp = DateTime.parse(timeStampString);
        final formattedTimeStamp =
            DateFormat('MM/dd/yyyy hh:mm a').format(timestamp);
        _comments.add(Comment(
            commentID: commentID,
            commentText: text,
            commentedBy: sender,
            commentTime: formattedTimeStamp));
      });
    });
  }

  // Function that handles sending the meta data of a new comment on a post to the database
  void _sendComment(String text) {
    print("entered send comments");
    final DatabaseReference _commentRef = _database
        .child(widget.postId)
        .child('comments'); // references the comments in the database
    final timestamp = DateTime.now().toString();
    String commentID = _commentRef.push().key.toString();
    _commentRef.child(commentID).set({
      // Generates a unique comment ID
      'text': text,
      'sender': widget.username.toString(),
      'timestamp': timestamp,
    });

    widget.commentMap[commentID] = {
      'text': text,
      'sender': widget.username.toString(),
      'timestamp': timestamp,
    };

    // setState(() {
    //   _comments.add(Comment(
    //       commentID: '',
    //       commentText: text,
    //       commentedBy: widget.username.toString(),
    //       commentTime: timestamp));
    // });
    // Clear the comment input field
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    print("entered build");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.ktoCrimson,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context)
                .pop(); // Pops the current route and goes back to MyHomePage.
          },
        ),
        title: Text('Comments'),
      ),
      body: Column(
        children: <Widget>[
          // Display Comments
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                print("Entered itembuilder");
                print(_comments[index].commentedBy +
                    ": " +
                    _comments[index].commentText);
                final comment = _comments[index];
                if (comment != null) {
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.commentedBy,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          comment.commentTime.toString() ?? '',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        Text(comment.commentText ?? ''),
                      ],
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Handle sending the comment here
                    String commentText = _commentController.text.trim();
                    if (commentText.isNotEmpty) {
                      // Save the comment or send it to the server
                      // Clear the text field after sending the comment
                      _sendComment(commentText);
                    }
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

// This class contains the metadata for each comment
class Comment {
  final String commentID;
  final String commentText;
  final String commentedBy;
  final String commentTime;

  Comment({
    required this.commentID,
    required this.commentText,
    required this.commentedBy,
    required this.commentTime,
  });
}
