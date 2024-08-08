import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/ui/utils/helpers.dart';
import 'package:flutter/material.dart';

class MyChatBubble extends StatelessWidget {
  final MessageModel message;
  const MyChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.grey,
      child: Row(
        children: [
          styledText(text: message.message),
          widthSeparator(10),
          if (message.user!.photoUrl == '')
            const Icon(
              Icons.person,
              size: 40,
            ),
          if (message.user!.photoUrl != '')
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                message.user!.photoUrl,
                height: 50,
              ),
            ),
        ],
      ),
    );
  }
}
