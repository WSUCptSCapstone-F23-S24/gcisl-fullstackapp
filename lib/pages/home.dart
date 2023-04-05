import 'dart:io';
import 'dart:math';
import 'dart:html';
import 'dart:async';
import 'package:uuid/uuid.dart';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_sorted_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../palette.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _post = TextEditingController();
  final List _postList = [];
  String? emailHash;
  String? username;
  int _displayedPosts = 30;
  bool _showEmojiPicker = false;
  var downloadUrl = null;

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
    _database.onChildAdded.listen(_onNewPostAdded);
  }

  void _onNewPostAdded(DatabaseEvent event) {
    final newPost = event.snapshot.child("text").value.toString();
    String? userName = event.snapshot.child("user_name").value.toString();
    String? timestamp = event.snapshot.child("timestamp").value.toString();
    String? image = event.snapshot.child("image").value.toString();
    if (userName == "null") {
      userName = "anonymous";
    }
    if (mounted) {
      setState(() {
        _postList.insert(0, [newPost, userName, timestamp, image]);
      });
    }
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
    });
    return completer.future;
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
                      'image': downloadUrl
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
                                  Text(
                                    _postList[index][1] ?? "anonymous",
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Palette.ktoCrimson,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                    constraints:
                                        const BoxConstraints(minHeight: 75),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Text(
                                            _postList[index][0],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _postList[index][3] == "null"
                                      ? const SizedBox(height: 0)
                                      : Column(
                                          children: [
                                            const SizedBox(height: 2),
                                            SizedBox(
                                              child: Image.network(
                                                _postList[index][3],
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                    ),
                                    child: Text(
                                      DateFormat('MM/dd/yyyy HH:mm').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(_postList[index][2]))),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
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
