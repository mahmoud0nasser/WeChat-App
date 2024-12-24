import 'dart:developer';

import 'package:chat_app_hin/api/apis.dart';
import 'package:chat_app_hin/main.dart';
import 'package:chat_app_hin/models/chat_user.dart';
import 'package:chat_app_hin/screens/profile_screen.dart';
import 'package:chat_app_hin/widgets/chat_user_card.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for storing all users
  List<ChatUser> _list = [];

  // for storing searched items
  final List<ChatUser> _SearchList = [];

  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    // for setting user status to active
    APIs.updateActiveStatus(true);

    // for updating user active status according to lifecycle events
    // resume -- active or online
    // pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard when a tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        // if search is on & back button is pressed then cloe search
        // or else simple close current screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          // appbar
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email, ...',
                    ),
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 17.0,
                      letterSpacing: 0.5,
                    ),
                    // when search text changes then updated search list
                    onChanged: (val) {
                      // search logic
                      _SearchList.clear();

                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _SearchList.add(i);
                        }
                        setState(() {
                          _SearchList;
                        });
                      }
                    },
                  )
                : Text(
                    'We Chat',
                  ),
            leading: Icon(
              CupertinoIcons.home,
            ),
            actions: [
              // search user button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search,
                ),
              ),
              // more features button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => profileScreen(
                        user: APIs.me,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.more_vert,
                ),
              ),
            ],
          ),
          // floating action button to add new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(
              bottom: 10.0,
            ),
            child: FloatingActionButton(
              onPressed: () async {
                // sign out function
                // await FirebaseAuth.instance.signOut();
                await APIs.auth.signOut();
                await GoogleSignIn().signOut();
              },
              child: Icon(
                Icons.add_comment_rounded,
              ),
            ),
          ),

          body: StreamBuilder(
            stream: APIs.getAllUsers(),
            // stream: APIs.firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                // if data is Loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );

                // if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  // final List = [];

                  // if (snapshot.hasData) {
                  final data = snapshot.data?.docs;
                  _list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];

                  /* for (var i in data!) {
                      // log('Data: ${i.data()}');
                      log('Data: ${jsonEncode(i.data())}');
                      List.add(i.data()['name']);
                    } */
                  // }

                  if (_list.isNotEmpty) {
                    return ListView.builder(
                      itemCount:
                          _isSearching ? _SearchList.length : _list.length,
                      padding: EdgeInsets.only(
                        top: mq.height * .01,
                      ),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        // return Text('Name: ${List[index]}',);
                        return ChatUserCard(
                          user:
                              _isSearching ? _SearchList[index] : _list[index],
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'No Connections Found!',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    );
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
