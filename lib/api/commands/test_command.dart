import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_code/api/command.dart';

class TestCommand extends Command {
  TestCommand(
      {required super.id,
      required super.name,
      super.desc =
          'This is a simple command to test the command api, this desc is long to see how it would look, lulz.'});

  @override
  List getArguments() {
    return [];
  }

  @override
  Future<void> onDeploy(BuildContext context) async {
    Get.log('command deployed');
  }
}
