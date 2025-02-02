import 'dart:math';
import 'dart:html';
import 'dart:async';
import 'package:gcisl_app/pages/CommentsPage.dart' as CommentsPage;
import 'package:uuid/uuid.dart';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'image.dart';
import 'package:like_button/like_button.dart';
// import '../helper_functions/post_sorting.dart';
import 'public_profile.dart';

import '../palette.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PostSortOption? _selectedSortOption = PostSortOption.newest;
  final _post = TextEditingController();
  List _postList = [];
  final List _allPosts = [];
  String? searchBarText = null;
  String? emailHash;
  String? username;
  String? currentEmail;
  String? currentUserType;
  bool isAdmin = false;
  int _displayedPosts = 30;
  bool _showEmojiPicker = false;
  var downloadUrl = null;
  bool isLiked = false;
  final _commentController = TextEditingController();
  List<String> _filteredUsers = []; // Declare filtered users list

  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('posts');

  @override
  void initState() {
    super.initState();
    emailHash = FirebaseAuth.instance.currentUser?.email?.hashCode.toString();
    getCurrentUser().then((value) {
      setState(() {
        username = value;
      });
    });
    currentEmail = FirebaseAuth.instance.currentUser?.email;
    _database.onChildAdded.listen(_onNewPostAdded);
    FirebaseDatabase.instance
        .reference()
        .child('users')
        .once()
        .then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? usersData =
          snapshot.value as Map<dynamic, dynamic>?;
      if (usersData != null) {
        usersData.forEach((key, value) {
          if (value['email'] != currentEmail) return;
          bool tempisAdmin = value['isAdmin'] != null ? value['isAdmin'] as bool : false;
          currentUserType = value["userType"];
          isAdmin = tempisAdmin;
        });
      }
    });
  }

  void _onNewPostAdded(DatabaseEvent event) async {
    String? uniquePostId = event.snapshot.key;
    String? uniquePostImageId = event.snapshot.child("image").key;
    final newPost = event.snapshot.child("text").value.toString();
    String? userName = event.snapshot.child("user_name").value.toString();
    String? timestamp = event.snapshot.child("timestamp").value.toString();
    String? image = event.snapshot.child("image").value.toString();
    String? email = event.snapshot.child("email").value.toString();
    var likes = event.snapshot.child("likes").value;
    var comments = event.snapshot.child("comments").value;
    String? userType = event.snapshot.child("userType").value.toString();

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

    // if (event.snapshot.child("comments").value != null) {
    //   setState(() {
    //     commentPreview = findMostLikedComment(comments);
    //   });
    // }

    if (mounted) {
      setState(() {
        _allPosts.insert(0, {
          "post body": newPost,
          "full name": "$firstName $lastName",
          "timestamp": timestamp,
          "image": image,
          "email": email,
          "post id": uniquePostId,
          "image id": uniquePostImageId,
          "likes": likes,
          "comments": comments,
          "userType": userType,
          "commentPreview": commentPreview,
          "profile picture": profilePicture,
          "initials": initials,
          "textController": TextEditingController(),
        });
        updatePostList();
      });
    }
  }

  void _sendComment(
      TextEditingController textCon, String postID, Map comments) {
    String text = textCon.text;
    print("entered send comments - ${text} - ${postID}");
    final DatabaseReference _commentRef = _database
        .child(postID)
        .child('comments'); // references the comments in the database
    final timestamp = DateTime.now().toString();
    String commentID = _commentRef.push().key.toString();
    if (emailHash == null) {
      print("No email hash");
      return;
    }
    if (text.length == 0) {
      return;
    }
    _commentRef.child(commentID).set({
      'text': text,
      'likes': [],
      'sender': emailHash.toString(),
      'timestamp': timestamp,
      'replies': [],
    });
    comments[commentID] = text;
    textCon.clear();
  }

  void updatePostList() {
    _postList = PostFiltering.filterPosts(_allPosts, searchBarText);
    _localPostListSort();
  }

  void _localPostListSort() {
    PostSorting.sortPostList(_postList, _selectedSortOption);
    setState(() {});
  }

  void deletePost(int postIndex, String postID, String maybeURL) {
    DatabaseReference postRef = _database.child(postID);
    print(maybeURL);
    if (maybeURL != "null") {
      print("Removing image");
      int lastIndex = maybeURL.lastIndexOf('/');
      int questionMarkIndex = maybeURL.indexOf('?', lastIndex);

      String imageId = maybeURL
          .substring(lastIndex + 1, questionMarkIndex)
          .replaceAll("%2F", "/");
      Reference storageReference =
          FirebaseStorage.instance.ref().child(imageId);
      try {
        storageReference.delete();
        print('File deleted successfully');
      } catch (e) {
        print('Error deleting file: $e');
      }
    }
    postRef.set(null).then((_) {
      print("Post Deleted");
    }).catchError((error) {
      print("Error: $error");
    });
    _allPosts.remove(_postList[postIndex]);
    updatePostList();
  }

  Future<String?> getCurrentUser() async {
    String? name;
    await FirebaseDatabase.instance
        .ref('users')
        .get()
        // ignore: avoid_function_literals_in_foreach_calls
        .then((snapshot) => snapshot.children.forEach((element) {
              if (element.key.toString() == emailHash) {
                name =
                    "${element.child("first name").value.toString()} ${element.child("last name").value.toString()}";
              }
            }));
    return name;
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  String? findMostLikedComment(commentList) {
    int likeCount = 0;
    String commentContents = "";
    for (var key in commentList.keys) {
      if (commentList[key]['likes'] != null) {
        List likeList = commentList[key]['likes'];
        if (likeList.length > likeCount) {
          likeCount = likeList.length;
          commentContents = commentList[key]['text'];
        }
      } else if (likeCount == 0) {
        commentContents = commentList[key]['text'];
      }
    }

    return commentContents;
  }

  // Function to open image picker
  Future<void> _pickImage() async {
    final completer = Completer<void>();
    InputElement input = FileUploadInputElement() as InputElement
      ..accept = 'image/*';
    FirebaseStorage fs = FirebaseStorage.instance;
    input.click();
    input.onChange.listen((event) {
      final file = input.files!.first;
      if (file.type.startsWith('image/')) {
        final reader = FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((event) async {
          String filename = Uuid().v1() + file.type.toString();
          var snapshot = await fs.ref().child(filename).putBlob(file);
          var imageUrl = await snapshot.ref.getDownloadURL();

          setState(() {
            downloadUrl = imageUrl;
          });

          completer.complete();
        });
      } else {
        // Show an error message or perform any other action for non-image files
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Please pick an image file.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
    return completer.future;
  }

  Future<void> _updateLikesInDatabase(String postID, List likes) async {
    final postRef = _database.child(postID);
    await postRef.child('likes').set(likes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Palette.ktoGray,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 5),
              child: Image.asset(
                'assets/GCISL_logo.png',
                height: 50,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 900,
                  child: Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          TextField(
                            maxLines: 4,
                            controller: _post,
                            decoration: InputDecoration(
                              hintText: username != null
                                  ? 'What\'s on your mind, $username?'
                                  : 'Create a new post',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          if (_showEmojiPicker)
                            SizedBox(
                              height: 200,
                              child: EmojiPicker(
                                config: const Config(
                                  columns: 10,
                                  emojiSizeMax: 20,
                                  checkPlatformCompatibility: true,
                                ),
                                onEmojiSelected: (category, emoji) {
                                  final em = emoji.emoji;
                                  final cursorPosition =
                                      _post.selection.base.offset;
                                  final textBeforeCursor =
                                      _post.text.substring(0, cursorPosition);
                                  final textAfterCursor =
                                      _post.text.substring(cursorPosition);
                                  final newText =
                                      '$textBeforeCursor$em$textAfterCursor';
                                  setState(() {
                                    _post.text = newText;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                      Positioned.fill(
                        left: 350,
                        top: 65,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.photo_library,
                                color: Palette.ktoCrimson,
                              ),
                              onPressed: _pickImage,
                              splashRadius: 20,
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(
                                Icons.emoji_emotions,
                                color: Palette.ktoCrimson,
                              ),
                              onPressed: _toggleEmojiPicker,
                              splashRadius: 20,
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                final newPost = _post.text.trim();
                                if (newPost.isNotEmpty || downloadUrl != null) {
                                  final timestamp = DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString();
                                  _database.push().set({
                                    'text': newPost,
                                    'user_name': username,
                                    'timestamp': timestamp,
                                    'image': downloadUrl,
                                    'email': currentEmail,
                                    'likes': [],
                                    'comments': {},
                                    'userType': currentUserType,
                                  }).then((_) {
                                    setState(() {
                                      _post.text = '';
                                      downloadUrl = null;
                                      _showEmojiPicker = false;
                                    });
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Palette.ktoCrimson,
                              ),
                              child: const Text(
                                'Post',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              downloadUrl == null
                  ? const Text('')
                  : SizedBox(
                      height: 300,
                      child: Image.network(
                        downloadUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
              const SizedBox(height: 20),
              SizedBox(
                width: 900,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4, // 75% of available space
                      child: SizedBox(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Search',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            searchBarText = value;
                            setState(() {
                              updatePostList();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Small horizontal gap
                    Expanded(
                      flex: 1, // 25% of available space
                      child: DropdownButton<PostSortOption>(
                        value: _selectedSortOption,
                        onChanged: (newSortOption) {
                          setState(() {
                            _selectedSortOption = newSortOption;
                            // Sort the post list based on the selected option
                            _localPostListSort();
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            value: PostSortOption.newest,
                            child: Center(child: Text('Most Recent')),
                          ),
                          DropdownMenuItem(
                            value: PostSortOption.oldest,
                            child: Center(child: Text('Oldest')),
                          ),
                          DropdownMenuItem(
                            value: PostSortOption.alphabetical,
                            child: Center(child: Text('Alphabetical (A-Z)')),
                          ),
                          DropdownMenuItem(
                            value: PostSortOption.likes,
                            child: Center(child: Text('Likes')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_postList.isNotEmpty)
                Column(children: [
                  Container(
                    width: 900,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: min(_postList.length, _displayedPosts),
                      itemBuilder: (BuildContext context, int index) {
                        final likes = _postList[index]["likes"] as List;
                        final comments = _postList[index]["comments"]
                            as Map<String, dynamic>;
                        print(comments);
                        return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                            child: Column(children: [
                              Card(
                                child: Column(children: [
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Row(
                                      children: [
                                        _postList[index]["profile picture"] ==
                                                "null"
                                            ? CircleAvatar(
                                                child: Text(
                                                  _postList[index]["initials"],
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Color.fromARGB(
                                                          255, 130, 125, 125)),
                                                ),
                                                radius: 25,
                                              )
                                            : CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    _postList[index]
                                                        ["profile picture"]),
                                                radius: 25,
                                              ),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(children: [
                                                TextButton(
                                                    child: Text(
                                                      _postList[index]
                                                              ["full name"] ??
                                                          "anonymous",
                                                      style: const TextStyle(
                                                        // decoration: TextDecoration.underline,
                                                        // color: Palette.ktoCrimson,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => ProfilePage1(
                                                                  _postList[index]
                                                                          [
                                                                          "email"]
                                                                      .hashCode
                                                                      .toString(),
                                                                  true)));
                                                      //ProfilePage1(_postList[index][4].hashCode.toString());
                                                    }),
                                                if (_postList[index]
                                                            ["userType"] !=
                                                        "null" &&
                                                    _postList[index]
                                                            ["userType"] !=
                                                        null)
                                                  Text(
                                                    '-  ${_postList[index]["userType"]}',
                                                    style: const TextStyle(
                                                      // decoration: TextDecoration.underline,
                                                      // color: Palette.ktoCrimson,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                              ]),
                                              Row(children: [
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15.0),
                                                    child: Tooltip(
                                                        message: DateFormat(
                                                                'MM/dd/yyyy hh:mm a')
                                                            .format(DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                                    int.parse(_postList[
                                                                            index]
                                                                        [
                                                                        "timestamp"]))),
                                                        child: SelectableText(
                                                          '${DateFormat('MMM d').format(DateTime.fromMillisecondsSinceEpoch(int.parse(_postList[index]["timestamp"])))}',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                        ))),
                                              ])
                                            ]),
                                      ],
                                    ),
                                  ),
                                  _postList[index]["post body"] == ""
                                      ? Container(
                                          constraints: const BoxConstraints(
                                              minHeight: 75),
                                        )
                                      : Column(
                                          children: [
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Container(
                                              constraints: const BoxConstraints(
                                                  minHeight: 75),
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    title: SelectableText(
                                                      _postList[index]
                                                          ["post body"],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                  _postList[index]["image"] == "null"
                                      ? const SizedBox(height: 0)
                                      : MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    ImageDialog(
                                                        imageUrl:
                                                            _postList[index]
                                                                ["image"]),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                //const SizedBox(height: 2),
                                                SizedBox(
                                                  child: Image.network(
                                                    _postList[index]["image"],
                                                    fit: BoxFit.scaleDown,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextField(
                                          controller: _postList[index]
                                              ["textController"],
                                          decoration: InputDecoration(
                                            hintText: 'Leave a comment',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Palette.ktoCrimson),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          onPressed: () {
                                            _sendComment(
                                                _postList[index]
                                                    ["textController"],
                                                _postList[index]['post id'],
                                                _postList[index]['comments']);
                                            setState(() {});
                                          },
                                          child: Text('Leave Comment',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ),
                                      SizedBox(width: 10)
                                    ],
                                  ),
                                ]),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    LikeButton(
                                      isLiked: likes.contains(emailHash),
                                      onTap: (isLiked) async {
                                        setState(() {
                                          if (isLiked) {
                                            likes.remove(emailHash);
                                          } else {
                                            likes.add(emailHash);
                                          }
                                        });
                                        await _updateLikesInDatabase(
                                            _postList[index]["post id"], likes);
                                        return Future.value(!isLiked);
                                      },
                                      //likeCount: numLikes,
                                      //countPostion: CountPostion.bottom,
                                      likeBuilder: (isLiked) {
                                        return Icon(
                                          Icons.thumb_up_sharp,
                                          color: isLiked
                                              ? Colors.blue
                                              : Colors.grey,
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CommentsPage.CommentsPage(
                                                      postId: _postList[index]
                                                          ["post id"],
                                                      commentMap: comments,
                                                    )));
                                      },
                                      child: Icon(
                                        Icons.add_comment_sharp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (_postList[index]["email"] ==
                                            currentEmail ||
                                        isAdmin)
                                      SizedBox(
                                        width: 25,
                                      ),
                                    if (_postList[index]["email"] ==
                                            currentEmail ||
                                        isAdmin)
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          deletePost(
                                              index,
                                              _postList[index]["post id"],
                                              _postList[index]["image"]);
                                          setState(() {});
                                        },
                                      ),
                                    SizedBox(
                                      width: 60,
                                    ),
                                    // if (_postList[index]["comments"].length > 0)
                                    //   Card(
                                    //     child: SizedBox(
                                    //         width: 200,
                                    //         child: Text(_postList[index]
                                    //             ["commentPreview"])),
                                    //   ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Likes: ${likes.length}'),
                                  ),
                                  SizedBox(
                                    width: 25,
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        'View Comments: ${comments.length}'),
                                  ),
                                ],
                              )
                            ]));
                      },
                    ),
                  ),
                  if (_postList.length > _displayedPosts)
                    SizedBox(
                      width: 125,
                      height: 65,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Card(
                          color: Palette.ktoCrimson,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _displayedPosts += 30;
                              });
                            },
                            child: const Text(
                              'Load More',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 19),
                            ),
                          ),
                        ),
                      ),
                    ),
                ]),
              if (_postList.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'No posts yet.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'You Have Reached the End \u{1F60A}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
