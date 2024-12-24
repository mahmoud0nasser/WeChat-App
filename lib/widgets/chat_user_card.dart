import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_hin/api/apis.dart';
import 'package:chat_app_hin/helper/my_date_util.dart';
import 'package:chat_app_hin/main.dart';
import 'package:chat_app_hin/models/chat_user.dart';
import 'package:chat_app_hin/models/message.dart';
import 'package:chat_app_hin/screens/chat_screen.dart';
import 'package:chat_app_hin/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({
    super.key,
    required this.user,
  });

  final ChatUser user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info(if null --> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              user: widget.user,
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: mq.width * .04,
          vertical: 4.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            15.0,
          ),
        ),
        // color: Colors.blue.shade100,
        elevation: 0.5,
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: ((context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

            // if (data != null && data.first.exists) {
            if (list.isNotEmpty) {
              _message = list[0];
              // _message = Message.fromJson(data.first.data());
            }

            return ListTile(
              // user Profile Picture
              leading: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ProfileDialog(
                      user: widget.user,
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .03),
                  child: CachedNetworkImage(
                    height: mq.height * .055,
                    width: mq.height * .055,
                    imageUrl: widget.user.image,
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(
                        CupertinoIcons.person,
                      ),
                    ),
                  ),
                ),
              ),
              /* leading: CircleAvatar(
            child: Icon(
              CupertinoIcons.person,
            ),
          ), */
              // Username
              title: Text(
                widget.user.name,
                // 'Demo User',
              ),
              // Last Message
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                        ? 'image'
                        : _message!.msg
                    : widget.user.about,
                // 'Last User message',
                maxLines: 1,
              ),
              // Last Message Time
              trailing: _message == null
                  ? null // show noting when no message is sent
                  /* ? Container(
                      width: 15.0,
                      height: 15.0,
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(
                          10.0,
                        ),
                      ),
                    ) */
                  : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                      ?
                      // show for unread message
                      Container(
                          width: 15.0,
                          height: 15.0,
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            borderRadius: BorderRadius.circular(
                              10.0,
                            ),
                          ),
                        )
                      :
                      // message sent time
                      Text(
                          MyDateUtil.getLastMessageTime(
                            context: context,
                            time: _message!.sent,
                          ),
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
              /* trailing: Text(
            '12:00 PM',
            style: TextStyle(
              color: Colors.black54,
            ),
          ), */
            );
          }),
        ),
      ),
    );
  }
}
