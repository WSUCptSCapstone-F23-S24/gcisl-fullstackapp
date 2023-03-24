// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';

import '../palette.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ignore: prefer_final_fields
  var _post = TextEditingController();
  // ignore: prefer_final_fields
  List<String> _postList = [];
  //int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Palette.ktoGray,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 5),
              child: Image.asset(
                'assets/GCISL_logo.png',
                height: 50,
                color: Palette.ktoCrimson,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        alignment: Alignment.topCenter,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(),
            ),
            Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Feed"),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _post,
                        minLines: 4,
                        maxLines: null,
                        cursorColor: Colors.black,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black12,
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          hintStyle: TextStyle(color: Colors.black),
                          hintText: 'Create Post...',
                          suffixIcon: IconButton(
                            splashRadius: 20,
                            onPressed: () => setState(() {
                              if (_post.text.isEmpty) {
                                return;
                              }
                              // _post.text.trim();
                              //_postList.add(_post.text);
                              _postList.insert(0, _post.text);
                              _post.clear();
                            }),
                            icon: Icon(Icons.send_sharp),
                          ),
                        ),
                      ),
                      Divider(),
                      ListView.builder(
                        itemCount: _postList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => ListTile(
                          leading: Icon(Icons.portrait_rounded,
                              color: Palette.ktoCrimson),
                          title: Column(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Palette.ktoCrimson,
                                    ),
                                  ),
                                  child: SelectableText("post " +
                                      index.toString() +
                                      "\n" +
                                      _postList[index].trim()),
                                ),
                              ),
                              Divider(
                                height: 20.0,
                              ) // add value for height or leave it blank for default
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("\u{1F6D1} nothing more to show "),
                    ],
                  ),
                )),
            Expanded(
              flex: 1,
              child: Column(),
            ),
          ],
        ),
      ),
    );
  }
}
