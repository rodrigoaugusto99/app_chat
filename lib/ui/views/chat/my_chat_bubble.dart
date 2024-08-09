import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/ui/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyChatBubble extends StatelessWidget {
  final MessageModel message;
  const MyChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const datePattern = /*'dd MMM yyyy, */ 'HH:mm';
    final timestampFormatted =
        DateFormat('HH:mm', 'pt_BR').format(message.createdAt.toDate());
    return decContainer(
      allPadding: 10,
      radius: 12,
      color: const Color(0xff128c7e),
      child: Container(
        // color: Colors.orange,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            styledText(
                text: message.message, color: Colors.white, fontSize: 18),
            widthSeparator(10),
            Align(
              alignment: Alignment.bottomCenter,
              child: styledText(
                text: timestampFormatted,
                color: Colors.white70,
              ),
            )
            // if (message.user!.photoUrl == '')
            //   const Icon(
            //     Icons.person,
            //     size: 40,
            //   ),
            // if (message.user!.photoUrl != '')
            //   ClipRRect(
            //     borderRadius: BorderRadius.circular(12),
            //     child: Image.network(
            //       message.user!.photoUrl,
            //       height: 50,
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
