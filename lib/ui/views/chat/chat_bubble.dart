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
    const datePattern = 'dd MMM yyyy, HH:mm';
    final timestampFormatted = DateFormat('dd MMM yyyy, HH:mm', 'pt_BR')
        .format(message.createdAt.toDate());
    return decContainer(
      allPadding: 10,
      radius: 12,
      color: Colors.grey,
      child: Column(
        children: [
          Row(
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
          styledText(text: timestampFormatted)
        ],
      ),
    );
  }
}
