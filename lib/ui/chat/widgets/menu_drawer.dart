import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';
import 'package:love_code/ui/helper/ui_helper.dart';
import 'package:love_code/ui/theme.dart';
import 'package:love_code/ui/util/lc_button.dart';
import 'package:love_code/ui/util/lc_dialog.dart';

class LcMenuDrawer extends StatelessWidget {
  const LcMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: BoxDecoration(color: primaryColor.darken(0.3)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(Localization.menu,
                      style: Theme.of(context).textTheme.headlineLarge),
                ),
              )),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 16),
            child: ListTile(
              leading: Icon(Icons.house),
              title: Text('Example1'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 16),
            child: ListTile(
              leading: Icon(Icons.house),
              title: Text('Example2'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 16),
            child: ListTile(
              leading: Icon(Icons.house),
              title: Text('Example3'),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 16),
            child: ListTile(
              leading: Icon(Icons.close),
              title: Text(Localization.disconnectChat),
              onTap: () {
                showLcDialog(
                    title: Localization.disconnectChat,
                    desc: Localization.confirmDecision,
                    actions: [
                      LcButton(
                        width: 75.w,
                        height: 35.w,
                        text: Localization.disconnect,
                        onPressed: () {
                          ChatController.instance().deleteChat();

                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 16),
                      LcButton(
                        width: 75.w,
                        height: 35.w,
                        text: Localization.cancel,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ]);
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(Localization.signOut),
              onTap: () {
                showLcDialog(
                    title: Localization.signOut,
                    desc: Localization.confirmDecision,
                    actions: [
                      LcButton(
                        width: 75.w,
                        height: 35.w,
                        text: Localization.signOut,
                        onPressed: () {
                          Auth.instance().signOut();

                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 16),
                      LcButton(
                        width: 75.w,
                        height: 35.w,
                        text: 'Cancel',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
