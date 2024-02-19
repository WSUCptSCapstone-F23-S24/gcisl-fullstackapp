import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/main.dart';
import 'package:gcisl_app/pages/home.dart';
import 'package:gcisl_app/palette.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';

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
  final TextEditingController _replyController = TextEditingController();
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('posts');
  List<Comment> _comments = [];
  List<Reply> _replies = [];

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
        var likes = [];
        if(event.snapshot.child('likes').value == null) {
          likes = [];
        } else {
          likes = event.snapshot.child('likes').value as List;
        }
        //var likes = event.snapshot.child('likes').value as List;
        DateTime timestamp = DateTime.parse(timeStampString);
        final formattedTimeStamp =
            DateFormat('MM/dd/yyyy hh:mm a').format(timestamp);

        // Now Get the Replies
        List<Reply> loadReply = _loadReplies(commentID);
        _comments.add(Comment(
            commentID: commentID,
            commentText: text,
            commentedBy: sender,
            commentLikes: likes,
            commentTime: formattedTimeStamp,
            replies: loadReply));

      });
    });
  }

  List<Reply> _loadReplies(String commentID) {
    List<Reply> replies = [];
    final DatabaseReference _replyRef = _database
        .child(widget.postId)
        .child('comments')
        .child(commentID)
        .child('replies');
    _replyRef.onChildAdded.listen((event) {
      setState(() {
        String replyID = event.snapshot.key.toString();
        String text = event.snapshot.child('text').value.toString();
        String sender = event.snapshot.child('sender').value.toString();
        String timeStampString =
            event.snapshot.child('timestamp').value.toString();
        DateTime timestamp = DateTime.parse(timeStampString);
        final formattedTimeStamp =
            DateFormat('MM/dd/yyyy hh:mm a').format(timestamp);

        // Now Get the Replies

        replies.add(Reply(
          replyID: replyID,
          replyText: text,
          repliedBy: sender,
          replyTime: formattedTimeStamp,
        ));
      });
    });
    return replies;
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
      'likes': [],
      'timestamp': timestamp,
      'replies': [],
    });

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

  void _sendReply(String text, String commentID) {
    final DatabaseReference _replyRef = _database
        .child(widget.postId)
        .child('comments')
        .child(commentID)
        .child('replies');
    final timestamp = DateTime.now().toString();
    String replyID = _replyRef.push().key.toString();
    _replyRef.child(replyID).set({
      'text': text,
      'sender': widget.username.toString(),
      'timestamp': timestamp,
    });
  }

  void _openDialog(String commentID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('My Reply'),
          content: TextField(
            controller: _replyController,
            decoration: InputDecoration(
              hintText: 'Write a reply...',
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                // Send the reply in the textfield inside of the dialog box to the database to be stored.
                _sendReply(_replyController.text, commentID);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    _replyController.clear();
  }

    Future<void> _updateLikesInDatabase(String commentID, String postID, List likes) async {
      final postRef = _database
        .child(postID)
        .child('comments')
        .child(commentID);
      await postRef.child('likes').set(likes);
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
            // Navigator.of(context)
            //     .pop(); // Pops the current route and goes back to MyHomePage.
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyApp()));
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
                final likes = _comments[index].commentLikes;
                int commentIndex = index;
                if (comment != null) {
                  return Card(
                    elevation: 4, // Add elevation for a box-like appearance
                    margin: EdgeInsets.all(
                        16), // Add margin for spacing between cards
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
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
                        ),
                        Container(
                          child: Row(
                            children: [
                              LikeButton(
                                likeCount: likes.length,
                                //countPostion: CountPostion.bottom,
                                isLiked: likes.contains(widget.username),

                                onTap: (isLiked) async {
                                  setState(() {
                                    if (isLiked) {
                                      likes.remove(widget.username);
                                    } else {
                                      likes.add(widget.username);
                                    }
                                  });
                                  await _updateLikesInDatabase(
                                      _comments[index].commentID, widget.postId, likes);
                                  return Future.value(!isLiked);
                                },
                                likeBuilder: (isLiked) {
                                  return Icon(
                                    Icons.thumb_up_sharp,
                                    color: isLiked
                                        ? Colors.blue
                                        : Colors.grey,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  // When reply button is pressed it pops up a dialog box for the user to write a comment.
                                  _openDialog(_comments[index].commentID);
                                },
                                
                                child: Text('Reply'),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 2,
                          color: Colors.black,
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(16),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemCount:
                                    _comments[commentIndex].replies.length,
                                itemBuilder: ((context, index) {
                                  final reply =
                                      _comments[commentIndex].replies[index];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 2,
                                          color: Colors.grey,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  reply.repliedBy,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  reply.replyTime.toString() ??
                                                      '',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(reply.replyText ?? ''),
                                              ],
                                              
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
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
  final List commentLikes;
  final String commentTime;
  final List<Reply> replies;

  Comment({
    required this.commentID,
    required this.commentText,
    required this.commentedBy,
    required this.commentLikes,
    required this.commentTime,
    required this.replies,
  });
}

class Reply {
  final String replyID;
  final String replyText;
  final String repliedBy;
  final String replyTime;

  Reply({
    required this.replyID,
    required this.replyText,
    required this.repliedBy,
    required this.replyTime,
  });
}
