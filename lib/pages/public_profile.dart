import 'package:flutter/material.dart';

import 'dart:html';

import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:gcisl_app/pages/profile.dart';
import 'package:geocode/geocode.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gcisl_app/pages/messaging.dart';

import 'dart:math';
import 'dart:async';
import 'package:uuid/uuid.dart';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'image.dart';
import "../helper_functions/post_sorting.dart";
export "../helper_functions/post_sorting.dart";
import '../palette.dart';

class ProfilePage1 extends StatefulWidget {
  String? emailHashString = "";
  bool isOtherPage = false;
  ProfilePage1(this.emailHashString, this.isOtherPage);
  @override
  _ProfilePage1State createState() => _ProfilePage1State();
}

class _ProfilePage1State extends State<ProfilePage1> {
  String? _firstName,
      _lastName,
      _phone,
      _address,
      cityValue,
      stateValue,
      countryValue,
      zipValue,
      _company,
      _position;
  String? emailHash;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _zipcodeController = TextEditingController();
  TextEditingController _companyController = TextEditingController();
  TextEditingController _companyPositionController = TextEditingController();
  TextEditingController _countryAddressController = TextEditingController();

  DatabaseReference ref = FirebaseDatabase.instance.ref("users");

  getCurrentUser() async {
    await FirebaseDatabase.instance
        .ref('users')
        .get()
        // ignore: avoid_function_literals_in_foreach_calls
        .then((snapshot) => snapshot.children.forEach((element) {
              if (element.key.toString() == widget.emailHashString) {
                _nameController.text =
                    element.child("first name").value.toString() +
                        " " +
                        element.child("last name").value.toString();
                _companyPositionController.text =
                    element.child("position").value.toString();
                _phoneController.text = element.child("phone").value.toString();
                _zipcodeController.text =
                    element.child("zip address").value.toString();
                _companyController.text =
                    element.child("company").value.toString();
                _companyPositionController.text =
                    element.child("position").value.toString();
                _countryAddressController.text =
                    element.child("country address").value.toString();
              }
            }));
  }

  @override
  void initState() {
    getCurrentUser();
    super.initState();
    // Check if user is logged in using Firebase Authentication
    final user = FirebaseAuth.instance.currentUser;

    emailHash = FirebaseAuth.instance.currentUser?.email?.hashCode.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    readOnly: true,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (widget.isOtherPage)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 16.0),
                        FloatingActionButton.extended(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          heroTag: 'back',
                          elevation: 0,
                          backgroundColor: Colors.red,
                          label: const Text("Go Back"),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 16.0),
                        if(widget.emailHashString != emailHash)
                        FloatingActionButton.extended(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChatPage(widget.emailHashString))
                            );
                          },
                          heroTag: 'message',
                          elevation: 0,
                          backgroundColor: Colors.red,
                          label: const Text("Message"),
                          icon: const Icon(Icons.message),
                        )
                      ],
                    ),
                  const SizedBox(height: 16),
                  _ProfileInfoRow(
                      _companyPositionController,
                      _companyController,
                      _countryAddressController,
                      _phoneController),
                  PostPortion(widget.emailHashString!)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatefulWidget {
  TextEditingController companyPositionController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  _ProfileInfoRow(this.companyPositionController, this.companyController,
      this.countryController, this.phoneController);

  final List<ProfileInfoItem> _items = const [
    ProfileInfoItem("Company", 1),
    ProfileInfoItem("Company Position", 2),
    ProfileInfoItem("Country", 3),
    ProfileInfoItem("Phone Number", 4)
  ];

  TextEditingController getController(int value) {
    if (value == 1) {
      return companyController;
    } else if (value == 2) {
      return companyPositionController;
    } else if (value == 3) {
      return countryController;
    } else if (value == 4) {
      return phoneController;
    } else {
      return companyController;
    }
  }

  @override
  _ProfileInfoRowState createState() => _ProfileInfoRowState();
}

class _ProfileInfoRowState extends State<_ProfileInfoRow> {
  //const _ProfileInfoRowState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget._items
            .map((item) => Expanded(
                    child: Row(
                  children: [
                    if (widget._items.indexOf(item) != 0)
                      const VerticalDivider(),
                    Expanded(child: _singleItem(context, item)),
                  ],
                )))
            .toList(),
      ),
    );
  }

  Widget _singleItem(BuildContext context, ProfileInfoItem item) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              //item.value.toString(),
              controller: widget.getController(item.value),
              readOnly: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Text(
            item.title,
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
}

class ProfileInfoItem {
  final String title;
  final int value;
  const ProfileInfoItem(this.title, this.value);
}

class PostPortion extends StatefulWidget {
  @override
  final String emailHashcode;
  const PostPortion(this.emailHashcode);
  State<PostPortion> createState() => _PostPortionState();
}

class _PostPortionState extends State<PostPortion> {
  PostSortOption? _selectedSortOption = PostSortOption.newest;
  final List _postList = [];
  String? emailHash;
  String? username;
  String? currentEmail;
  int _displayedPosts = 30;

  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('posts');

  void _localPostListSort() {
    PostSorting.sortPostList(_postList, _selectedSortOption);
    setState(() {});
  }
  // void _sortPostList()
  // {
  //   print("sorting\n");
  //     switch (_selectedSortOption) {
  //       case PostSortOption.newest:
  //         _postList.sort((a, b) => b[2].compareTo(a[2]));
  //         break;
  //       case PostSortOption.oldest:
  //         _postList.sort((a, b) => a[2].compareTo(b[2]));
  //         break;
  //       case PostSortOption.alphabetical:
  //         _postList.sort((a, b) => (a[0] as String).compareTo(b[0] as String));
  //         break;
  //   }
  //   setState(() {});
  // }

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
  }

  void _onNewPostAdded(DatabaseEvent event) {
    String? uniquePostId = event.snapshot.key;
    String? uniquePostImageId = event.snapshot.child("image").key;
    final newPost = event.snapshot.child("text").value.toString();
    String? userName = event.snapshot.child("user_name").value.toString();
    String? timestamp = event.snapshot.child("timestamp").value.toString();
    String? image = event.snapshot.child("image").value.toString();
    String? email = event.snapshot.child("email").value.toString();
    if (userName == "null") {
      userName = "anonymous";
    }
    if (mounted && email.hashCode.toString() == widget.emailHashcode) {
      setState(() {
        _postList.insert(0, [
          newPost,
          userName,
          timestamp,
          image,
          email,
          uniquePostId,
          uniquePostImageId
        ]);
        _localPostListSort();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: Text('Edit Profile'),
            ),
            const SizedBox(height: 16),
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
                                TextButton(
                                    child: Text(
                                      _postList[index][1] ?? "anonymous",
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Palette.ktoCrimson,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfilePage1(
                                                      _postList[index][4]
                                                          .hashCode
                                                          .toString(),
                                                      true)));
                                      //ProfilePage1(_postList[index][4].hashCode.toString());
                                    }),
                                _postList[index][0] == ""
                                    ? Container(
                                        constraints:
                                            const BoxConstraints(minHeight: 75),
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
                                              builder: (context) => ImageDialog(
                                                  imageUrl: _postList[index]
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
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                  ),
                                  child: SelectableText(
                                    DateFormat('MM/dd/yyyy hh:mm a').format(
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
                            style: TextStyle(color: Colors.white, fontSize: 19),
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
    );
  }
}
