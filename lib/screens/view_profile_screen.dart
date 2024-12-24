import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_hin/helper/my_date_util.dart';
import 'package:chat_app_hin/main.dart';
import 'package:chat_app_hin/models/chat_user.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // appbar
        appBar: AppBar(
          title: Text(
            widget.user.name,
          ),
        ),

        floatingActionButton: // user about label
            Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Joined On: ',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 15.0,
              ),
            ),
            Text(
              MyDateUtil.getLastMessageTime(
                context: context,
                time: widget.user.createdAt,
                showYear: true,
              ),
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15.0,
                // fontSize: 16.0,
              ),
            ),
          ],
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: mq.width * .05,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // for adding some space
                SizedBox(
                  width: mq.width,
                  height: mq.height * .03,
                ),
                // user profile picture
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: CachedNetworkImage(
                    height: mq.height * .2,
                    width: mq.height * .2,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image,
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(
                        CupertinoIcons.person,
                      ),
                    ),
                  ),
                ),
                // for adding some space
                SizedBox(
                  height: mq.height * .03,
                ),
                // user email label
                Text(
                  widget.user.email,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 19.0,
                    // fontSize: 16.0,
                  ),
                ),
                // for adding some space
                SizedBox(
                  height: mq.height * .02,
                ),
                // user about label
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'About: ',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      widget.user.about,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                        // fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
