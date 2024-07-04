import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_code/api/command.dart';

class TestCommand extends Command {
  TestCommand(
      {required super.id,
      required super.name,
      super.desc =
          'This is a simple command to test the command api, this desc is long to see how it would look, lulz.',
      super.commandType = 'text/test'});

  @override
  List getArguments() {
    return [];
  }

  @override
  Future<String?> onDeploy(
      BuildContext context, TextEditingController txtController) async {
    Get.log('command deployed');
    return null;
  }

  @override
  bool overrideMessageSend() {
    return false;
  }
}
