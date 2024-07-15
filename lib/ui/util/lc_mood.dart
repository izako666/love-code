import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/emoji_manager.dart';
import 'package:love_code/ui/theme.dart';
import 'package:love_code/ui/util/lc_button.dart';

class LcMoodSetter extends StatefulWidget {
  const LcMoodSetter({super.key});

  @override
  State<LcMoodSetter> createState() => _LcMoodSetterState();
}

class _LcMoodSetterState extends State<LcMoodSetter> {
  Emojis? currentEmoji;
  late TextEditingController messageController;
  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "What's your mood right now?",
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(32), color: backgroundColor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32,
                  child: currentEmoji != null
                      ? GestureDetector(
                          onTap: () {
                            EmojiManager.displaySelection(
                                context: context,
                                onTap: (emoji) {
                                  currentEmoji = emoji;
                                  setState(() {});
                                  Get.back();
                                });
                          },
                          child: Image.asset(
                            currentEmoji!.image,
                            scale: 0.5,
                            width: 32,
                            height: 32,
                            filterQuality: FilterQuality.none,
                          ))
                      : IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.add, size: 32),
                          onPressed: () {
                            EmojiManager.displaySelection(
                                context: context,
                                onTap: (emoji) {
                                  currentEmoji = emoji;
                                  setState(() {});
                                  Get.back();
                                });
                          },
                        ),
                ),
                Expanded(
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: backgroundColor.withAlpha(120),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: messageController,
                        maxLength: 32,
                        decoration: const InputDecoration(
                          hintText: "How are you feeling?",
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 48,
                    ),
                    LcButton(
                      width: 92,
                      height: 32,
                      text: Localization.send,
                      onPressed: () {
                        Auth.instance().setMood(currentEmoji?.name ?? '', messageController.text);
                        Get.back();
                      },
                    ),
                    const SizedBox(height: 16),
                    LcButton(
                      width: 92,
                      height: 32,
                      text: Localization.clear,
                      onPressed: () {
                        Auth.instance().setMood('', '');
                        Get.back();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
