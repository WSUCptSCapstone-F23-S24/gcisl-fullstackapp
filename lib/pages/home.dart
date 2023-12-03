import 'dart:math';
import 'dart:html';
import 'dart:async';
import 'package:gcisl_app/pages/CommentsPage.dart';
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
  final List _postList = [];
  String? emailHash;
  String? username;
  String? currentEmail;
  String? currentUserType;
  bool isAdmin = false;
  int _displayedPosts = 30;
  bool _showEmojiPicker = false;
  var downloadUrl = null;
  bool isLiked = false;

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
     FirebaseDatabase.instance.reference().child('users').once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? usersData = snapshot.value as Map<dynamic, dynamic>?;
      if (usersData != null) {
        usersData.forEach((key, value) {
          if(value['email'] != currentEmail)
            return;
          bool tempisAdmin = value['isAdmin'] != null ? value['isAdmin'] as bool : false;
          currentUserType = value["userType"];
          isAdmin = tempisAdmin;
        });
      }
    });
    
  }

  void _onNewPostAdded(DatabaseEvent event) {
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
    print("UT - $userType");
    if(userType == "null")
    {
      userType = null;
    }
    if (userName == "null") {
      userName = "anonymous";
    }

    if (likes == null) {
      likes = [];
    }

    if (comments == null) {
      comments = <String, dynamic>{};
    }

    if (mounted) {
      setState(() {
        _postList.insert(0, [
          newPost,
          userName,
          timestamp,
          image,
          email,
          uniquePostId,
          uniquePostImageId,
          likes,
          comments,
          userType,
        ]);
        _localPostListSort();
      });
    }
  }

  void _localPostListSort()
  {
    PostSorting.sortPostList(_postList, _selectedSortOption);
    setState(() {});
  }
  // void _sortPostList() {
  //   switch (_selectedSortOption) {
  //     case PostSortOption.newest:
  //       _postList.sort((a, b) => b[2].compareTo(a[2]));
  //       break;
  //     case PostSortOption.oldest:
  //       _postList.sort((a, b) => a[2].compareTo(b[2]));
  //       break;
  //     case PostSortOption.alphabetical:
  //       _postList.sort((a, b) => (a[0] as String).compareTo(b[0] as String));
  //       break;
  //   }
  //   setState(() {});
  // }

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
    _postList.removeAt(postIndex);
  }

  Future<String?> getCurrentUser() async {
    String? name;
    await FirebaseDatabase.instance
        .ref('users')
        .get()
        // ignore: avoid_function_literals_in_foreach_calls
        .then((snapshot) => snapshot.children.forEach((element) {
              if (element.key.toString() == emailHash) {
                name = element.child("first name").value.toString() +
                    " " +
                    element.child("last name").value.toString();
              }
            }));
    return name;
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
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
                color: Palette.ktoCrimson,
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
                        left: 845,
                        top: 65,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.emoji_emotions,
                                color: Palette.ktoCrimson,
                              ),
                              onPressed: _toggleEmojiPicker,
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              downloadUrl == null
                  ? const Text('No image selected.')
                  : SizedBox(
                      height: 300,
                      child: Image.network(
                        downloadUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
              const SizedBox(height: 6),
              FloatingActionButton(
                onPressed: () => _pickImage(),
                tooltip: 'Pick from gallery',
                child: const Icon(Icons.photo_library),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final newPost = _post.text.trim();
                  if (newPost.isNotEmpty || downloadUrl != null) {
                    final timestamp =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    _database.push().set({
                      'text': newPost,
                      'user_name': username,
                      'timestamp': timestamp,
                      'image': downloadUrl,
                      'email': currentEmail,
                      'likes': [],
                      'comments': {},
                      'userType' : currentUserType,
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
                  backgroundColor:
                      Palette.ktoCrimson, // replace with your desired color
                ),
                child: const Text(
                  'Post',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              DropdownButton<PostSortOption>(
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
                    child: Text('Most Recent'),
                  ),
                  DropdownMenuItem(
                    value: PostSortOption.oldest,
                    child: Text('Oldest'),
                  ),
                  DropdownMenuItem(
                    value: PostSortOption.alphabetical,
                    child: Text('Alphabetical (A-Z)'),
                  ),
                  DropdownMenuItem(
                    value: PostSortOption.likes,
                    child: Text('Likes'),
                  ),
                ],
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
                        final likes = _postList[index][7] as List;
                        final comments =
                            _postList[index][8] as Map<String, dynamic>;
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
                                  Column(
                                    children:[
                                        Row(
                                    children: [
                                      TextButton(
                                        child: Text(
                                          _postList[index][1] ?? "anonymous",
                                          style: const TextStyle(
                                            // decoration: TextDecoration.underline,
                                            // color: Palette.ktoCrimson,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => ProfilePage1(_postList[index][4].hashCode.toString(), true))
                                          );
                                          //ProfilePage1(_postList[index][4].hashCode.toString());
                                        }
                                      ),
                                      if(_postList[index][9] != "null" && _postList[index][9] != null)
                                        Text(
                                          '-  ${_postList[index][9]}',
                                          style: const TextStyle(
                                            // decoration: TextDecoration.underline,
                                            // color: Palette.ktoCrimson,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          ),
                                        ),
                                    ]
                                  ),
                                  Row(
                                    children:[
                                      Padding(
                                        padding: EdgeInsets.only(left: 15.0), 
                                        child:Tooltip(
                                        message:  DateFormat('MM/dd/yyyy hh:mm a').format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(_postList[index][2]))),
                                        child: SelectableText(
                                        '${DateFormat('MMM d').format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(_postList[index][2])))}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                            ),
                                        ))   
                                      ),
                                      
                                    ]
                                  )
                                      
                                    ]
                                  ),
                                  if (_postList[index][4] == currentEmail || isAdmin)

                                    Container(
                                        width: 75,
                                        height: 15,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            deletePost(
                                                index,
                                                _postList[index][5],
                                                _postList[index][3]);
                                            setState(() {});
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 3),
                                            primary: Colors.red,
                                          ),
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(fontSize: 9),
                                          ),
                                        )),
                                  _postList[index][0] == ""
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
                                                      _postList[index][0],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                  _postList[index][3] == "null"
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
                                                                [3]),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                //const SizedBox(height: 2),
                                                SizedBox(
                                                  child: Image.network(
                                                    _postList[index][3],
                                                    fit: BoxFit.scaleDown,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  const SizedBox(height: 8),
                                ]),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    LikeButton(
                                      isLiked: likes.contains(username),
                                      onTap: (isLiked) async {
                                        setState(() {
                                          if (isLiked) {
                                            likes.remove(username);
                                          } else {
                                            likes.add(username);
                                          }
                                        });
                                        await _updateLikesInDatabase(
                                            _postList[index][5], likes);
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
                                                    CommentsPage(
                                                      postId: _postList[index]
                                                          [5],
                                                      username: username,
                                                      commentMap: comments,
                                                    )));
                                      },
                                      child: Icon(
                                        Icons.add_comment_sharp,
                                        color: Colors.grey,
                                      ),
                                    ),
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
                                    child: Text('Comments: ${comments.length}'),
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
