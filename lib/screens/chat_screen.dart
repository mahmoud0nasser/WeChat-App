/* import 'dart:convert';
import 'dart:developer';

 */
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_hin/api/apis.dart';
import 'package:chat_app_hin/helper/my_date_util.dart';
import 'package:chat_app_hin/main.dart';
import 'package:chat_app_hin/models/chat_user.dart';
import 'package:chat_app_hin/models/message.dart';
import 'package:chat_app_hin/screens/view_profile_screen.dart';
import 'package:chat_app_hin/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({
    super.key,
    required this.user,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // for storing all messages
  List<Message> _list = [];

  // for handling text changes
  final _textController = TextEditingController();

  // showEmoji -- for storing of showing or hiding emoji
  // isUploading -- for checking if image is Uploading or not?
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          // if search is on & back button is pressed then cloe search
          // or else simple close current screen on back button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(
              255,
              234,
              248,
              255,
            ),
            // body
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        // if data is Loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        // if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          // log('Data: ${jsonEncode(data![0].data())}');
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];
                          /*  final _list = [
                                      'hii',
                                      'hello',
                                    ];
                              */
                          /* _list.clear();
            
                          _list.add(
                            Message(
                              msg: 'Hii',
                              read: '',
                              told: 'xyz',
                              type: Type.text,
                              sent: '12:00 PM',
                              fromId: APIs.user.uid,
                            ),
                          );
                          _list.add(
                            Message(
                              msg: 'Hello',
                              read: '',
                              told: APIs.user.uid,
                              type: Type.text,
                              sent: '12:00 PM',
                              fromId: 'xyz',
                            ),
                          ); */

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(
                                top: mq.height * .01,
                              ),
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: _list[index],
                                );
                                // return Text('Name: ${List[index]}',);
                                /* return Text(
                                  'Message: ${_list[index]}',
                                ); */
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'Say Hii! 👋',
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
                // progress indicator for showing uploading
                if (_isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 20.0,
                      ),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),

                _chatInput(),

                // show emojis on keyBoard emoji button click & vice versa
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(
                          255,
                          234,
                          248,
                          255,
                        ),
                        columns: 8,
                        // initCategory: Category.FOODS,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // appbar widget
  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ViewProfileScreen(
                    user: widget.user,
                  )),
        );
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(
          widget.user,
        ),
        builder: ((context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(
            children: [
              // back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black54,
                ),
              ),
              // user profile picture
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .03),
                child: CachedNetworkImage(
                  height: mq.height * .05,
                  width: mq.height * .05,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                  // placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(
                      CupertinoIcons.person,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //username
                  Text(
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: const TextStyle(
                      fontSize: 18.0,
                      // fontSize: 16.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // for adding some space
                  const SizedBox(
                    height: 2,
                  ),
                  // last seen time of user
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                            ? 'Online'
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive,
                              )
                        : MyDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive,
                          ),
                    style: const TextStyle(
                      fontSize: 13.0,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  // bottom Chat input filed
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: mq.height * .01,
        horizontal: mq.width * .025,
      ),
      child: Row(
        children: [
          // input field & buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  15.0,
                ),
              ),
              child: Row(
                children: [
                  // emoji button
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(
                        () => _showEmoji = !_showEmoji,
                      );
                    },
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                      size: 25.0,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji)
                          setState(
                            () => _showEmoji = !_showEmoji,
                          );
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(
                          color: Colors.blueAccent,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  // pick image from gallery button
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      // final XFile? image = await picker.pickImage(
                      //   source: ImageSource.gallery,
                      //   imageQuality: 70,
                      // );

                      // picking multiple images
                      final List<XFile> images = await picker.pickMultiImage(
                        imageQuality: 70,
                      );

                      // uploading & sending image one by one
                      for (var i in images) {
                        log('Image Path: ${i.path}');
                        setState(
                          () => _isUploading = true,
                        );
                        await APIs.sendChatImage(
                          widget.user,
                          File(i.path),
                        );
                        setState(
                          () => _isUploading = false,
                        );
                      }
                    },
                    icon: Icon(
                      Icons.image,
                      color: Colors.blueAccent,
                      size: 26.0,
                    ),
                  ),
                  // take image from camera button
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 70,
                      );
                      if (image != null) {
                        log('Image Path: ${image.path}');
                        setState(
                          () => _isUploading = true,
                        );
                        await APIs.sendChatImage(
                          widget.user,
                          File(image.path),
                        );
                        setState(
                          () => _isUploading = false,
                        );
                      }
                    },
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.blueAccent,
                      size: 26.0,
                    ),
                  ),
                  SizedBox(
                    width: mq.width * .02,
                  ),
                ],
              ),
            ),
          ),
          // send message button
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(
                  widget.user,
                  _textController.text,
                  Type.text,
                );
                _textController.text = '';
              }
            },
            minWidth: 0.0,
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 10.0,
              right: 5.0,
              left: 10.0,
            ),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 28.0,
            ),
          ),
        ],
      ),
    );
  }
}
