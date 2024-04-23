import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gcisl_app/main.dart';
import 'package:gcisl_app/pages/home.dart';
import 'package:gcisl_app/palette.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'image.dart';

class CommentsPage extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> commentMap;
  CommentsPage({required this.postId, required this.commentMap});

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
  String? emailHash;
  Map<String, UserInfo> loadedProfilePictures = <String, UserInfo>{};

  @override
  void initState() {
    super.initState();
    print("Entered Initial State");
    emailHash = FirebaseAuth.instance.currentUser?.email?.hashCode
        .toString(); // gets current User's unique userid
    _loadComments();
  }

  Future<String> _getUserNameHelper(String userid) async {
    // Fetch the user details from the "users" table based on the hashed email
    DataSnapshot userSnapshot = await FirebaseDatabase.instance
        .ref('users')
        .child(userid
            .toString()) // assuming the emailHashCode is stored as the key in the users table
        .get();

    // Extract first name and last name from the user details
    String? firstName = userSnapshot.child("first name").value.toString();
    String? lastName = userSnapshot.child("last name").value.toString();

    return firstName + " " + lastName;
  }

  Future<String> _getUserName(String userid) async {
    String username = await _getUserNameHelper(userid);
    print("Name: " + username);
    return username;
  }

  Widget getCircleAvatar(UserInfo user, double size) {
    if (user.profileImageURL == "null") {
      return CircleAvatar(
        child: Text(
          user.initials,
          style: TextStyle(
              fontSize: size - 10, color: Color.fromARGB(255, 130, 125, 125)),
        ),
        radius: size,
      );
    }
    return CircleAvatar(
      backgroundImage: NetworkImage(user.profileImageURL),
      radius: size,
    );
  }

  Widget loadUserData(DataSnapshot userSnapshot, String senderID, double size) {
    String? firstName = userSnapshot.child("first name").value.toString();
    String? lastName = userSnapshot.child("last name").value.toString();
    String? profilePicture =
        userSnapshot.child("profile picture").value.toString();
    List<String> nameParts = "$firstName $lastName".split(" ");
    String initials = "";
    for (int i = 0; i < nameParts.length; i++) {
      if (nameParts[i].isNotEmpty) {
        String initial = nameParts[i][0];
        initials += initial;
      }
    }
    initials = initials.toUpperCase();
    UserInfo info =
        new UserInfo(profileImageURL: profilePicture, initials: initials);
    loadedProfilePictures[senderID] = info;
    print("Returning box");
    return getCircleAvatar(info, size);
  }

  Future<Widget> loadUserProfilePicture(
      String senderID, double circleSize) async {
    print("Enter load user PFP - $senderID");
    if (loadedProfilePictures.containsKey(senderID)) {
      return getCircleAvatar(loadedProfilePictures[senderID]!, circleSize);
    }
    DatabaseReference users = FirebaseDatabase.instance.ref().child("users");
    Future<DataSnapshot> userSnapshot = users.child(senderID).get();
    return userSnapshot.then((snapshot) {
      print("Loading user data");
      return loadUserData(snapshot, senderID, circleSize);
    }).catchError((error) {
      print("Returning box [$error]");
      return SizedBox.shrink();
    });
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
        var likes = [];

        if (event.snapshot.child('likes').value == null) {
          likes = [];
        } else {
          likes = event.snapshot.child('likes').value as List;
        }

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
      'likes': [],
      'sender': emailHash.toString(),
      'timestamp': timestamp,
      'replies': [],
    });
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
      'sender': emailHash.toString(),
      'timestamp': timestamp,
    });
  }

  // Function that deletes a comment on a post and its replies on them
  void deleteComment(String commentID) {
    final DatabaseReference _commentRef = _database
        .child(widget.postId)
        .child('comments')
        .child(commentID); // references the comments in the database
    _commentRef.remove().then((_) {
      // Remove the comment from the local list
      setState(() {
        _comments.removeWhere((comment) => comment.commentID == commentID);
      });
      print('Comment deleted successfully');
    }).catchError((error) {
      print('Failed to delete comment: $error');
      // Handle error
    });
  }

  // Function that deletes just a reply to a comment
  void deleteReply(String commentID, String replyID) {
    final DatabaseReference _replyRef = _database
        .child(widget.postId)
        .child('comments')
        .child(commentID)
        .child('replies')
        .child(replyID);
    _replyRef.remove().then((_) {
      // Remove the reply from the local list
      setState(() {
        _comments.forEach((comment) {
          if (comment.commentID == commentID) {
            comment.replies.removeWhere((reply) => reply.replyID == replyID);
          }
        });
      });
      print('Reply deleted successfully');
    }).catchError((error) {
      print('Failed to delete reply: $error');
      // Handle error
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

  Future<Map<String, String?>> _retrievePost(DataSnapshot snapshot) async {
    String? uniquePostId = snapshot.key;
    String? uniquePostImageId = snapshot.child("image").key;
    final newPost = snapshot.child("text").value.toString();
    String? userName = snapshot.child("user_name").value.toString();
    String? timestamp = snapshot.child("timestamp").value.toString();
    String? image = snapshot.child("image").value.toString();
    String? email = snapshot.child("email").value.toString();
    var likes = snapshot.child("likes").value;
    var comments = snapshot.child("comments").value;
    String? userType = snapshot.child("userType").value.toString();

    String? commentPreview = "";

    print("UT - $userType");
    if (userType == "null") {
      userType = null;
    }
    if (userName == "null") {
      userName = "anonymous";
    }

    // Hash the email to get the email hashcode
    int emailHashCode = email.hashCode;

    // Fetch the user details from the "users" table based on the hashed email
    DataSnapshot userSnapshot = await FirebaseDatabase.instance
        .ref('users')
        .child(emailHashCode
            .toString()) // assuming the emailHashCode is stored as the key in the users table
        .get();

    // Extract first name and last name from the user details
    String? firstName = userSnapshot.child("first name").value.toString();
    String? lastName = userSnapshot.child("last name").value.toString();
    String? profilePicture =
        userSnapshot.child("profile picture").value.toString();

    // Gets the initials of the users name
    String fullName = "$firstName $lastName";
    List<String> nameParts = fullName.split(" ");
    String initials = "";
    for (int i = 0; i < nameParts.length; i++) {
      if (nameParts[i].isNotEmpty) {
        String initial = nameParts[i][0];
        initials += initial;
      }
    }
    initials = initials.toUpperCase();

    if (likes == null) {
      likes = [];
    }

    if (comments == null) {
      comments = <String, dynamic>{};
    }

    return {
      "post body": newPost,
      "full name": "$firstName $lastName",
      "timestamp": timestamp,
      "image": image,
      "email": email,
      "post id": uniquePostId,
      "image id": uniquePostImageId,
      "userType": userType,
      "commentPreview": commentPreview,
      "profile picture": profilePicture,
      "initials": initials,
    };
  }

  Future<Map<String, String?>?> _loadPost() async {
    final snapshot = await _database.child(widget.postId).get();
    if (!snapshot.exists) {
      print('Post not found');
      return null;
    }
    Future<Map<String, String?>> postMap = _retrievePost(snapshot);
    return postMap;
  }

  Widget buildPost(Map<String, String?>? postData) {
    if (postData == null) {
      print("Null post");
      return SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                postData["profile picture"] == "null"
                    ? CircleAvatar(
                        child: Text(
                          postData["initials"]!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 130, 125, 125),
                          ),
                        ),
                        radius: 25,
                      )
                    : CircleAvatar(
                        backgroundImage:
                            NetworkImage(postData["profile picture"]!),
                        radius: 25,
                      ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          postData["full name"] ?? "anonymous",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (postData["userType"] != "null" &&
                            postData["userType"] != null)
                          Text(
                            ' -  ${postData["userType"]}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Tooltip(
                            message: DateFormat('MM/dd/yyyy hh:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                int.parse(postData["timestamp"]!),
                              ),
                            ),
                            child: SelectableText(
                              '${DateFormat('MMM d').format(DateTime.fromMillisecondsSinceEpoch(int.parse(postData["timestamp"]!)))}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
            postData["post body"] == ""
                ? Container(
                    constraints: const BoxConstraints(minHeight: 75),
                  )
                : Column(
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        constraints: const BoxConstraints(minHeight: 75),
                        child: Column(
                          children: [
                            ListTile(
                              title: SelectableText(
                                postData["post body"]!,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            postData["image"] == "null"
                ? const SizedBox(height: 0)
                : MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => ImageDialog(
                            imageUrl: postData["image"]!,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          SizedBox(
                            child: Image.network(
                              postData["image"]!,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _updateLikesInDatabase(
      String commentID, String postID, List likes) async {
    final postRef = _database.child(postID).child('comments').child(commentID);
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
          FutureBuilder<Map<String, String?>?>(
            future: _loadPost(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // or any other loading indicator
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Text('Post not found');
              } else {
                return buildPost(snapshot.data!);
              }
            },
          ),
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
                  return FutureBuilder(
                      future: _getUserName(comment.commentedBy),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Or any other loading indicator
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final username = snapshot.data ?? '';
                          return Card(
                            elevation:
                                4, // Add elevation for a box-like appearance
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              FutureBuilder<Widget>(
                                                future: loadUserProfilePicture(
                                                    comment.commentedBy, 20),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return CircularProgressIndicator(); // or any other loading indicator
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else if (!snapshot
                                                          .hasData ||
                                                      snapshot.data == null) {
                                                    return Text(
                                                        'Error: COULD NOT LOAD PROFILE');
                                                  } else {
                                                    return snapshot.data!;
                                                  }
                                                },
                                              ),
                                              SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    username.toString(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    comment.commentTime
                                                            .toString() ??
                                                        '',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (comment.commentedBy ==
                                              emailHash) // Show delete button/icon only if the comment was posted by the current user
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                // Call deleteComment function when delete button/icon is pressed
                                                deleteComment(
                                                    comment.commentID);
                                              },
                                            ),
                                        ],
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
                                        isLiked: likes.contains(emailHash!),
                                        onTap: (isLiked) async {
                                          setState(() {
                                            if (isLiked) {
                                              likes.remove(emailHash!);
                                            } else {
                                              likes.add(emailHash!);
                                            }
                                          });
                                          await _updateLikesInDatabase(
                                              _comments[index].commentID,
                                              widget.postId,
                                              likes);
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
                                          _openDialog(
                                              _comments[index].commentID);
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
                                        itemCount: _comments[commentIndex]
                                            .replies
                                            .length,
                                        itemBuilder: ((context, index) {
                                          final reply = _comments[commentIndex]
                                              .replies[index];
                                          return FutureBuilder(
                                              future:
                                                  _getUserName(reply.repliedBy),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return CircularProgressIndicator(); // Or any other loading indicator
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                      'Error: ${snapshot.error}');
                                                } else {
                                                  final replyUsername =
                                                      snapshot.data ?? '';
                                                  print("reply username: " +
                                                      replyUsername.toString());
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                        bottom: 8),
                                                    child: Card(
                                                      elevation: 2,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 2,
                                                          color: Colors.grey,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          FutureBuilder<
                                                                              Widget>(
                                                                            future:
                                                                                loadUserProfilePicture(reply.repliedBy, 15),
                                                                            builder:
                                                                                (context, snapshot) {
                                                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                return CircularProgressIndicator(); // or any other loading indicator
                                                                              } else if (snapshot.hasError) {
                                                                                return Text('Error: ${snapshot.error}');
                                                                              } else if (!snapshot.hasData || snapshot.data == null) {
                                                                                return Text('Error: COULD NOT LOAD PROFILE');
                                                                              } else {
                                                                                return snapshot.data!;
                                                                              }
                                                                            },
                                                                          ),
                                                                          SizedBox(
                                                                              width: 10),
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                replyUsername.toString(),
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                reply.replyTime.toString() ?? '',
                                                                                style: TextStyle(
                                                                                  color: Colors.grey,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      if (reply
                                                                              .repliedBy ==
                                                                          emailHash) // Show delete button/icon only if the comment was posted by the current user
                                                                        IconButton(
                                                                          icon:
                                                                              Icon(
                                                                            Icons.delete,
                                                                            color:
                                                                                Colors.red,
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            // Call deleteComment function when delete button/icon is pressed
                                                                            deleteReply(comment.commentID,
                                                                                reply.replyID);
                                                                          },
                                                                        ),
                                                                    ]),
                                                                Text(reply
                                                                        .replyText ??
                                                                    ''),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              });
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                      });
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

class UserInfo {
  final String profileImageURL;
  final String initials;
  UserInfo({
    required this.profileImageURL,
    required this.initials,
  });
}
