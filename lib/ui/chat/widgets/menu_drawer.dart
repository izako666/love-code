import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/navigation/routes.dart';
import 'package:love_code/portable_api/auth/auth.dart';
import 'package:love_code/portable_api/chat/state/chat_controller.dart';
import 'package:love_code/portable_api/emoji_manager.dart';
import 'package:love_code/portable_api/ui/bottom_sheet.dart';
import 'package:love_code/portable_api/ui/image_worker.dart';
import 'package:love_code/resources.dart';
import 'package:love_code/ui/helper/ui_helper.dart';
import 'package:love_code/ui/theme.dart';
import 'package:love_code/ui/util/lc_button.dart';
import 'package:love_code/ui/util/lc_dialog.dart';
import 'package:love_code/ui/util/lc_mood.dart';
import 'package:photo_manager/photo_manager.dart';

class LcMenuDrawer extends StatefulWidget {
  const LcMenuDrawer({super.key});

  @override
  State<LcMenuDrawer> createState() => _LcMenuDrawerState();
}

class _LcMenuDrawerState extends State<LcMenuDrawer> {
  bool isEditingName = false;
  late TextEditingController nameController;
  late FocusNode nameNode;
  DocumentSnapshot<Map<String, dynamic>>? originalData;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    nameNode = FocusNode();
    Auth.instance().getUserDoc().then((val) {
      originalData = val;
      setState(() {});
    });
  }

  @override
  void dispose() {
    nameNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor,
      child: (Auth.instance().user.value == null)
          ? Container()
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 228.h,
                  child: DrawerHeader(
                      decoration: BoxDecoration(color: primaryColor.darken(0.3)),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    Resources.heartLogo,
                                    width: 40,
                                    height: 40,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(Localization.appTitle,
                                      style: Theme.of(context).textTheme.headlineLarge!.copyWith(wordSpacing: 1.2, color: Colors.white)),
                                  const SizedBox(
                                    width: 50,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Obx(() {
                                if (Auth.instance().user.value == null) return Container();
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ProfilePictureWidget(
                                      userId: Auth.instance().user.value!.uid,
                                      onTapEmoji: () {
                                        showLcDialog(width: 500, height: 300, body: const LcMoodSetter(), barrierDismissible: true);
                                      },
                                      onTap: () {
                                        showIzBottomSheet(
                                            context: context,
                                            height: MediaQuery.of(context).size.height * 0.5,
                                            child: Column(
                                              children: [
                                                LcButton(
                                                  text: 'Update Profile Pic',
                                                  onPressed: () async {
                                                    final PermissionState ps = await PhotoManager
                                                        .requestPermissionExtend(); // the method can use optional param `permission`.
                                                    if (ps.isAuth) {
                                                      // Granted
                                                      // You can to get assets here.
                                                    } else if (ps.hasAccess) {
                                                      // Access will continue, but the amount visible depends on the user's selection.
                                                    } else {
                                                      return;
                                                      // Limited(iOS) or Rejected, use `==` for more precise judgements.
                                                      // You can call `PhotoManager.openSetting()` to open settings for further steps.
                                                    }
                                                    if (!context.mounted) {
                                                      Get.back();
                                                      return;
                                                    }

                                                    Get.back();
                                                    imagePickerBottomSheet(context, onImageTap: (path, asset) async {
                                                      Uint8List data = await (await asset.file)!.readAsBytes();
                                                      Uint8List? croppedImage = await showLcDialog<Uint8List?>(
                                                          title: 'Crop your Image',
                                                          width: 400.w,
                                                          height: 0.7.sh,
                                                          alignment: Alignment.topCenter,
                                                          body: ImageCropper(image: data));
                                                      if (croppedImage != null) {
                                                        Auth.instance().setProfilePicture(croppedImage);
                                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                                          Get.back();
                                                        });
                                                      }
                                                    });
                                                  },
                                                )
                                              ],
                                            ));
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TapRegion(
                                            onTapInside: (evt) {
                                              bool shouldSetState = !isEditingName;
                                              isEditingName = true;
                                              nameController.text = Auth.instance().userData.value != null
                                                  ? Auth.instance().userData.value!.data()!['userName']
                                                  : '';

                                              if (shouldSetState) {
                                                setState(() {});
                                                nameNode.requestFocus();
                                              }
                                            },
                                            onTapOutside: (evt) async {
                                              bool shouldSetState = isEditingName;
                                              isEditingName = false;
                                              if (shouldSetState) {
                                                if ((Auth.instance().userData.value?.data()?['userName'] ?? '') != nameController.text) {
                                                  await Auth.instance().setName(nameController.text);
                                                }
                                                setState(() {});
                                              }
                                            },
                                            child: isEditingName
                                                ? Container(
                                                    width: 180,
                                                    //height: 25.w,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(16),
                                                      color: backgroundColor.withAlpha(120),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                                      child: TextField(
                                                        controller: nameController,
                                                        focusNode: nameNode,
                                                        style: Theme.of(context).textTheme.headlineSmall,
                                                        maxLength: 16,
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 180,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(16),
                                                      color: backgroundColor.withAlpha(120),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                                      child: Text(
                                                        Auth.instance().userData.value?.data()?['userName'] ?? '',
                                                        softWrap: true,
                                                        style: Theme.of(context).textTheme.headlineMedium,
                                                      ),
                                                    ))),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                          child: SizedBox(
                                            width: 150,
                                            child: Text(
                                              Auth.instance().userData.value?.data()?['mood_message'] ?? '',
                                              style: Theme.of(context).textTheme.bodyMedium,
                                              softWrap: true,
                                              maxLines: 4,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      )),
                ),
                const SizedBox(height: 32),
                Obx(() {
                  if (Auth.instance().user.value == null) return Container();
                  return !Auth.instance().user.value!.emailVerified
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 16),
                          child: ListTile(
                              leading: const Icon(Icons.email),
                              title: const Text(Localization.verifyEmail),
                              onTap: () async {
                                await Auth.instance().reload();
                                if (Auth.instance().user.value!.emailVerified) {
                                  Get.snackbar(Localization.oops, 'Email already verified.', snackPosition: SnackPosition.BOTTOM);
                                } else {
                                  Auth.instance().sendEmailVerification().whenComplete(() {
                                    Get.snackbar(Localization.success, 'Email verification email sent.',
                                        snackPosition: SnackPosition.BOTTOM);
                                  });
                                }
                              }),
                        )
                      : Container();
                }),
                if (ChatController.instance().chatRoom.value != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 16),
                    child: ListTile(
                      leading: const Icon(Icons.close),
                      title: const Text(Localization.disconnectChat),
                      onTap: () {
                        showLcDialog(title: Localization.disconnectChat, desc: Localization.confirmDecision, actions: [
                          LcButton(
                            width: 100.w,
                            height: 35.w,
                            text: Localization.disconnect,
                            onPressed: () {
                              ChatController.instance().deleteChat();

                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 16),
                          LcButton(
                            width: 100.w,
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
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 16),
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text(Localization.signOut),
                    onTap: () {
                      showLcDialog(title: Localization.signOut, desc: Localization.confirmDecision, actions: [
                        LcButton(
                          width: 100.w,
                          height: 35.w,
                          text: Localization.signOut,
                          onPressed: () {
                            Navigator.pop(context);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Get.delete<ChatController>();
                              Auth.instance().signOut();
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        LcButton(
                          width: 100.w,
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
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 16),
                  child: ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text(Localization.deleteAccount),
                    onTap: () {
                      showLcDialog(title: Localization.deleteAccount, desc: Localization.confirmDecision, actions: [
                        LcButton(
                          width: 100.w,
                          height: 35.w,
                          text: Localization.deleteAccount,
                          onPressed: () {
                            Navigator.pop(context);
                            WidgetsBinding.instance.addPostFrameCallback((_) async {
                              dynamic success = await Get.toNamed(RouteConstants.reAuth);
                              if (success != null && success) {
                                await Auth.instance().deleteAccount();
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        LcButton(
                          width: 100.w,
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

class ProfilePictureWidget extends StatelessWidget {
  const ProfilePictureWidget({
    super.key,
    this.onTap,
    required this.userId,
    this.onTapEmoji,
    this.width,
    this.height,
  });
  final Function()? onTap;
  final Function()? onTapEmoji;
  final String userId;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    dynamic userData =
        userId == Auth.instance().user.value!.uid ? Auth.instance().userData.value : ChatController.instance().recipientData.value;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(48),
            child: userData != null && userData!.data()!['profile_url'] != null && userData!.data()!['profile_url'] != ''
                ? CachedNetworkImage(
                    imageUrl: userData != null ? userData!.data()!['profile_url'] ?? '' : '',
                    width: width ?? 48.w,
                    height: height ?? 48.w,
                    placeholder: (a, b) {
                      return Icon(Icons.person, size: width ?? 32.w);
                    },
                    errorWidget: (ctx, o, trace) {
                      return Icon(Icons.person, size: width ?? 32.w);
                    },
                  )
                : Icon(Icons.person, size: width ?? 32.w),
          ),
        ),
        Positioned(
          right: width != null ? -(width! / 32) : -12,
          bottom: height != null ? -(height! / 32) : -12,
          child: (userData != null &&
                  userData!.data() != null &&
                  userData!.data()!['mood_emoji'] != null &&
                  userData!.data()!['mood_emoji'] != '')
              ? GestureDetector(
                  onTap: onTapEmoji,
                  child: Image.asset(Emojis.fromName(userData!.data()!['mood_emoji'])!.image,
                      scale: 0.4,
                      filterQuality: FilterQuality.none,
                      width: width != null ? width! / 4 : 32,
                      height: height != null ? height! / 4 : 32),
                )
              : IconButton(
                  icon: Icon(Icons.add, size: width != null ? width! / 5 : 24),
                  onPressed: onTapEmoji,
                ),
        )
      ],
    );
  }
}
