import 'dart:js_interop';

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
import 'package:image_picker/image_picker.dart';

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
import "../helper_functions/post_filtering.dart";
export "../helper_functions/post_filtering.dart";
import "../helper_functions/formating.dart";
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
  String initials = "";
  bool isCurrentUserProfile = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _zipcodeController = TextEditingController();
  TextEditingController _companyController = TextEditingController();
  TextEditingController _companyPositionController = TextEditingController();
  TextEditingController _countryAddressController = TextEditingController();
  TextEditingController _userBioController = TextEditingController();

  DatabaseReference ref = FirebaseDatabase.instance.ref("users");

  String? _profilePictureUrl; // New field to hold profile picture URL

  // List of all the users work experience information
  List<WorkExperience> workExperiences = [];

  Future<void> _pickImage() async {
    print("Entered _pickImage");
    final completer = Completer<void>();
    InputElement input = FileUploadInputElement() as InputElement
      ..accept = 'image/*';
    input.click();
    input.onChange.listen((event) async {
      final file = input.files!.first;
      if (file.type.startsWith('image/')) {
        final reader = FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((event) async {
          String filename = Uuid().v1() + file.type.toString();
          var snapshot = await FirebaseStorage.instance
              .ref()
              .child(filename)
              .putBlob(file);
          var imageUrl = await snapshot.ref.getDownloadURL();

          // Get the current user's ID
          //String? userId = FirebaseAuth.instance.currentUser.uid;
          // Reference to the user's profile data in the database
          DatabaseReference userRef = FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(widget.emailHashString.toString());
          // Update the profile data with the image URL
          await userRef.child('profile picture').set(imageUrl);

          // Trigger a rebuild to update the profile picture display
          setState(() {
            // Update the profile picture display with the selected image
            _profilePictureUrl = imageUrl;
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

  getCurrentUser() {
    ref.get().then((snapshot) => snapshot.children.forEach((element) {
          if (element.key.toString() == widget.emailHashString) {
            setState(() {
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
              _profilePictureUrl =
                  element.child("profile picture").value.toString();
              _emailController.text = element.child("email").value.toString();
              var bioSnapshot = element.child("bio");
              if (bioSnapshot.exists) {
                _userBioController.text = bioSnapshot.value.toString();
              } else {
                _userBioController.text = "";
              }
              workExperiences.clear(); // Clear existing work experiences
              var workExpSnapshot = element.child("workExperiences");
              if (workExpSnapshot.exists) {
                Map<dynamic, dynamic> workExpData =
                    workExpSnapshot.value as Map;
                workExpData.forEach((key, value) {
                  WorkExperience workExp = WorkExperience(
                    workExperienceID: key.toString(),
                    company: value['company'],
                    jobTitle: value['jobTitle'],
                    //employmentType: value['employmentType'],
                    location: value['location'],
                    //locationType: value['locationType'],
                    isCurrentJob: value['isCurrentJob'],
                    startDate: value['startDate'],
                    endDate:
                        value['endDate'] != null ? value['endDate'] : "Current",
                    description: value['description'],
                    //skills: List<String>.from(value['skills']),
                  );
                  workExperiences.add(workExp);
                  print("Work exp id: " + workExp.workExperienceID);
                });
              }
            });
          }
        }));
  }

  void _setUserBio(String bio) {
    if (emailHash == null) {
      return;
    }
    if (bio.length > 500) {
      bio = bio.substring(0, 500);
    }
    ref.child(emailHash!).update({"bio": bio});
  }

  void getInitials() {
    // Gets the initials of the users name
    String fullName = _nameController.text;
    print("fullName: " + fullName);
    List<String> nameParts = fullName.split(" ");
    initials = "";
    for (int i = 0; i < nameParts.length; i++) {
      if (nameParts[i].isNotEmpty) {
        String initial = nameParts[i][0];
        initials += initial;
      }
    }
    setState(() {
      initials = initials.toUpperCase();
    });
    print("initials: " + initials);
  }

  // Function that adds a new work experrience to the list of work experiences
  void addWorkExperience(WorkExperience workExp) {
    setState(() {
      workExperiences.add(workExp);
    });
    saveWorkExperience(emailHash.toString(), workExp); // Save to Firebase
  }

  // Function that shows a dialog box with a form to fill out a new work experience
  void showAddWorkExperienceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Work Experience'),
          content: SingleChildScrollView(
            child: WorkExperienceForm(
              onSave: addWorkExperience,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Center(child: Text('Cancel')),
            ),
          ],
        );
      },
    );
  }

  // Function to show dialog box that has a form filled out from a previous work experience to edit
  void showEditWorkExperienceDialog(WorkExperience workExp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Work Experience'),
          content: SingleChildScrollView(
            child: WorkExperienceForm(
              onSave: (editedWorkExp) {
                updateWorkExperience(emailHash.toString(), workExp);
                // Replace the original work experience with the edited one
                int index = workExperiences.indexOf(workExp);
                setState(() {
                  workExperiences[index] = editedWorkExp;
                });
                //Navigator.of(context).pop();
              },
              initialWorkExperience:
                  workExp, // Pass the work experience to edit
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to show dialog box to confirm confirmation of delteing work experience
  void showDeleteWorkExperienceConfirmation(WorkExperience workExp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Work Experience'),
          content:
              Text('Are you sure you want to delete this work experience?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteWorkExperience(
                    emailHash.toString(), workExp.workExperienceID);
                // Remove the work experience from the list
                setState(() {
                  workExperiences.remove(workExp);
                });
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // Adds work experience to the realtime database
  Future<void> saveWorkExperience(String userId, WorkExperience workExp) async {
    try {
      await ref.child(userId).child('workExperiences').push().set({
        'company': workExp.company,
        'jobTitle': workExp.jobTitle,
        //'employmentType': workExp.employmentType,
        'location': workExp.location,
        //'locationType': workExp.locationType,
        'isCurrentJob': workExp.isCurrentJob,
        'startDate': workExp.startDate,
        'endDate': workExp.endDate,
        'description': workExp.description,
        //'skills': workExp.skills,
      });
    } catch (error) {
      print('Error saving work experience: $error');
    }
  }

  // Updates work experience when editing to the realtime database
  Future<void> updateWorkExperience(
      String userId, WorkExperience workExp) async {
    try {
      await ref
          .child(userId)
          .child('workExperiences')
          .child(workExp.workExperienceID)
          .set({
        'company': workExp.company,
        'jobTitle': workExp.jobTitle,
        //'employmentType': workExp.employmentType,
        'location': workExp.location,
        //'locationType': workExp.locationType,
        'isCurrentJob': workExp.isCurrentJob,
        'startDate': workExp.startDate,
        'endDate': workExp.endDate,
        'description': workExp.description,
        //'skills': workExp.skills,
      });
    } catch (error) {
      print('Error saving work experience: $error');
    }
  }

  // Deletes work experience from the realtime database
  void deleteWorkExperience(String userId, String workExperienceId) {
    // Remove the work experience from Firebase
    ref
        .child(userId)
        .child('workExperiences')
        .child(workExperienceId)
        .remove()
        .then((_) {
      print('Work experience deleted from database');
    }).catchError((error) {
      print('Error deleting work experience: $error');
    });
  }

  @override
  void initState() {
    super.initState();
    // Check if user is logged in using Firebase Authentication

    emailHash = FirebaseAuth.instance.currentUser?.email?.hashCode.toString();
    isCurrentUserProfile = emailHash == widget.emailHashString;
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    // Gets the initials of the users name
    getInitials();

    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          if (widget.isOtherPage)
            Row(
              children: [
                const SizedBox(width: 16.0),
                FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  heroTag: 'back',
                  elevation: 0,
                  backgroundColor: Colors.grey,
                  label: const Text("Go Back"),
                  icon: const Icon(Icons.arrow_back),
                ),
              ],
            ),
          const SizedBox(height: 20),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _profilePictureUrl.toString() == "null"
                          ? CircleAvatar(
                              backgroundColor: Palette.ktoCrimson,
                              child: Text(
                                initials,
                                style: TextStyle(
                                    fontSize: 50, color: Colors.white),
                              ),
                              radius: 100,
                            )
                          : CircleAvatar(
                              backgroundImage:
                                  NetworkImage(_profilePictureUrl!),
                              radius: 100,
                            ),
                      SizedBox(
                        height: 16,
                      ),
                      if (emailHash == widget.emailHashString)
                        ElevatedButton(
                          onPressed: () {
                            _pickImage(); // Call the image picker function here
                          },
                          child: Text(
                            'Edit Profile Picture',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Palette.ktoCrimson,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(
                                _nameController.text,
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              if (isCurrentUserProfile)
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfilePage()));
                                    },
                                    child: Text(
                                      'Edit Profile',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Palette.ktoCrimson,
                                    ))
                              else
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                  widget.emailHashString)));
                                    },
                                    child: Text(
                                      'Message User',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Palette.ktoCrimson,
                                    ))
                            ]),
                            Text(
                              "${_companyController.text} - ${_companyPositionController.text}",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Text(
                              "Email - ${_emailController.text}",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "Phone - ${Formatting.formatPhoneString(_phoneController.text)}",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Text(
                            "Bio",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          if (isCurrentUserProfile)
                            ElevatedButton(
                                onPressed: () {
                                  _setUserBio(_userBioController.text);
                                },
                                child: Text(
                                  'Update Bio',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Palette.ktoCrimson,
                                )),
                        ]),
                        SizedBox(height: 10),
                        Expanded(
                          child: TextFormField(
                            // initialValue: _userBioController.text,
                            controller: _userBioController,
                            maxLines: null,
                            readOnly: !isCurrentUserProfile,
                            decoration: InputDecoration(
                              hintText: isCurrentUserProfile
                                  ? "Enter your bio..."
                                  : "This user has not entered a bio yet",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        )
                        // SizedBox(height: 10),
                        //
                        // SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // New container for work experience
          Container(
            padding: EdgeInsets.all(20.0),
            margin: EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Work Experience',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (emailHash == widget.emailHashString)
                      ElevatedButton(
                        onPressed: showAddWorkExperienceDialog,
                        child: Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Palette.ktoCrimson,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10.0),
                // Display added work experiences
                if (workExperiences.isNotEmpty)
                  Column(
                    children: [
                      for (int i = 0; i < workExperiences.length; i++)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  workExperiences[i].jobTitle,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (emailHash == widget.emailHashString)
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          // Implement editing functionality
                                          showEditWorkExperienceDialog(
                                              workExperiences[i]);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          // Implement deletion functionality
                                          showDeleteWorkExperienceConfirmation(
                                              workExperiences[i]);
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            Text(
                              workExperiences[i].company,
                              style: const TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                            Text(
                              workExperiences[i].location,
                              style: const TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                            Text(
                              workExperiences[i].startDate +
                                  ' - ' +
                                  workExperiences[i].endDate,
                              style: const TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              workExperiences[i].description,
                              style: const TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                            // Add other details here
                            const Divider(),
                          ],
                        ),
                    ],
                  ),

                if (workExperiences.isEmpty)
                  const Text(
                    'No work experience added yet.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          PostPortion(widget.emailHashString!),
        ]),
      ),
    ));
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

  void _onNewPostAdded(DatabaseEvent event) async {
    String? uniquePostId = event.snapshot.key;
    String? uniquePostImageId = event.snapshot.child("image").key;
    final newPost = event.snapshot.child("text").value.toString();
    String? userName = event.snapshot.child("user_name").value.toString();
    String? timestamp = event.snapshot.child("timestamp").value.toString();
    String? image = event.snapshot.child("image").value.toString();
    String? email = event.snapshot.child("email").value.toString();

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

    if (userName == "null") {
      userName = "anonymous";
    }
    if (mounted && email.hashCode.toString() == widget.emailHashcode) {
      setState(() {
        _postList.insert(0, [
          newPost,
          "$firstName $lastName",
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
            const SizedBox(
              height: 16,
            ),
            const SizedBox(
              height: 16,
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

class WorkExperience {
  String workExperienceID = '';
  String company = '';
  String jobTitle = '';
  String employmentType = '';
  String location = '';
  String locationType = '';
  bool isCurrentJob = false;
  String startDate = '';
  String endDate = '';
  String description = '';
  List<String> skills = [];

  // Constructor
  WorkExperience({
    required this.workExperienceID,
    required this.company,
    required this.jobTitle,
    //required this.employmentType,
    required this.location,
    //required this.locationType,
    required this.isCurrentJob,
    required this.startDate,
    required this.endDate,
    required this.description,
    //required this.skills,
  });
}

class WorkExperienceForm extends StatefulWidget {
  final Function(WorkExperience) onSave;
  final WorkExperience? initialWorkExperience; // Add this line

  const WorkExperienceForm(
      {Key? key, required this.onSave, this.initialWorkExperience})
      : super(key: key);

  @override
  _WorkExperienceFormState createState() => _WorkExperienceFormState();
}

class _WorkExperienceFormState extends State<WorkExperienceForm> {
  final _formKey = GlobalKey<FormState>();
  late WorkExperience workExperience;
  bool isCurrentJob = false;
  TextEditingController companyController = TextEditingController();
  TextEditingController jobTitleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    workExperience = widget.initialWorkExperience ??
        WorkExperience(
          workExperienceID: '',
          company: '',
          jobTitle: '',
          //employmentType: '',
          location: '',
          //locationType: '',
          isCurrentJob: false,
          startDate: '',
          endDate: '',
          description: '',
          //skills: [],
        );

    isCurrentJob = workExperience.isCurrentJob;

    companyController.text = workExperience.company;
    jobTitleController.text = workExperience.jobTitle;
    locationController.text = workExperience.location;
    startDateController.text = workExperience.startDate;
    endDateController.text = workExperience.endDate;
    descriptionController.text = workExperience.description;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: companyController,
            decoration: const InputDecoration(labelText: 'Company'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter company';
              }
              return null;
            },
            onSaved: (value) {
              workExperience.company = value!;
            },
          ),
          // Add other form fields here
          TextFormField(
            controller: jobTitleController,
            decoration: const InputDecoration(labelText: 'Job Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your job title';
              }
              return null;
            },
            onSaved: (value) {
              workExperience.jobTitle = value!;
            },
          ),
          TextFormField(
            controller: locationController,
            decoration: const InputDecoration(labelText: 'Location'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your location';
              }
              return null;
            },
            onSaved: (value) {
              workExperience.location = value!;
            },
          ),
          CheckboxListTile(
            title: const Text("Current Job"),
            value: isCurrentJob,
            onChanged: (value) {
              setState(() {
                isCurrentJob = value!;
                workExperience.isCurrentJob = value;
              });
            },
          ),
          TextFormField(
            controller: startDateController,
            decoration: const InputDecoration(
                labelText: 'Start Date', hintText: 'month, year'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter start date';
              }
              return null;
            },
            onSaved: (value) {
              workExperience.startDate = value!;
            },
          ),
          if (!isCurrentJob)
            TextFormField(
              controller: endDateController,
              decoration: const InputDecoration(
                  labelText: 'End Date', hintText: 'month, year'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter end date';
                }
                return null;
              },
              onSaved: (value) {
                workExperience.endDate = value!;
              },
            ),
          TextFormField(
            controller: descriptionController,
            maxLines: null,
            decoration: const InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your job description';
              }
              return null;
            },
            onSaved: (value) {
              workExperience.description = value!;
            },
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (isCurrentJob) {
                  workExperience.endDate = "Current";
                }
                widget.onSave(workExperience);
                Navigator.of(context).pop();
              }
            },
            child: const Center(child: Text('Save')),
          ),
        ],
      ),
    );
  }
}
