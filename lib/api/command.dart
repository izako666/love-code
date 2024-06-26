import 'package:flutter/material.dart';
import 'package:love_code/api/commands/test_command.dart';

abstract class Command {
  final String id;
  final String name;
  final String desc;
  Command({required this.id, required this.name, required this.desc});

  Future<void> onDeploy(BuildContext context);

  List<dynamic> getArguments();

  static List<Command> commands = [
    TestCommand(id: 'test_1', name: 'Test 1'),
    TestCommand(id: 'test_2', name: 'Test 2'),
    TestCommand(id: 'test_3', name: 'Test 3'),
    TestCommand(id: 'test_4', name: 'Test 4'),
  ];
}
