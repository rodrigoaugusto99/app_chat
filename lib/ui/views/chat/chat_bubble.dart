// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/ui/utils/helpers.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  const ChatBubble({
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
      color: Colors.grey[800],
      child: Column(
        children: [
          Row(
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
        ],
      ),
    );
  }
}
