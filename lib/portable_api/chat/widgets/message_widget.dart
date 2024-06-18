import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:love_code/portable_api/chat/models/message.dart';

class MessageWidget extends StatelessWidget {
  final Message msg;
  const MessageWidget({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.4,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(children: [
        Container(
          width: screenWidth * 0.3,
          child: Text(
            msg.message,
            softWrap: true,
          ),
        ),
        Text("${msg.timeStamp.hour}:${msg.timeStamp.minute}"),
      ]),
    );
  }
}
