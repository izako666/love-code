import 'package:flutter/material.dart';
import 'package:love_code/ui/theme.dart';
import 'package:popover/popover.dart';

class EmojiManager {
  static Future<void> displaySelection(
      {required BuildContext context,
      double width = 180,
      double height = 180,
      Color color = backgroundColor,
      void Function(Emojis emoji)? onTap}) async {
    showPopover(
        width: width,
        height: height,
        context: context,
        contentDyOffset: -50,
        backgroundColor: color,
        direction: PopoverDirection.bottom,
        bodyBuilder: (context) {
          return SizedBox(
            width: width,
            height: height,
            child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
                itemCount: Emojis.emojisList.length,
                itemBuilder: (ctx, index) {
                  return GestureDetector(
                    onTap: () {
                      if (onTap != null) {
                        onTap(Emojis.emojisList[index]);
                      }
                    },
                    child:
                        Image.asset(Emojis.emojisList[index].image, scale: 0.6, filterQuality: FilterQuality.none, width: 20, height: 20),
                  );
                }),
          );
        });
  }
}

class Emojis implements Comparable<Emojis> {
  const Emojis({
    required this.name,
  });

  final String name;
  String get image => 'assets/smileys-and-faces/$name.png';
  static Emojis? fromName(String name) {
    try {
      return emojisList.firstWhere((test) => test.name == name);
    } catch (e) {
      return null;
    }
  }

  @override
  int compareTo(Emojis other) => name.compareTo(other.name);
  static const alert = Emojis(name: 'alert');
  static const alien = Emojis(name: 'alien');
  static const angel = Emojis(name: 'angel');
  static const angry = Emojis(name: 'angry');
  static const angryYellow = Emojis(name: 'angry-yellow');
  static const bigSmile = Emojis(name: 'big-smile');
  static const calm = Emojis(name: 'calm');
  static const confused = Emojis(name: 'confused');
  static const dead = Emojis(name: 'dead');
  static const devilFrown = Emojis(name: 'devil-frown');
  static const devilSmile = Emojis(name: 'devil-smile');
  static const disguise = Emojis(name: 'disguise');
  static const dizzy = Emojis(name: 'dizzy');
  static const drool = Emojis(name: 'drool');
  static const expressionless = Emojis(name: 'expressionless');
  static const eyebrowRaised = Emojis(name: 'eybrow-raised');
  static const eyeroll = Emojis(name: 'eyeroll');
  static const flustered = Emojis(name: 'flustered');
  static const freezing = Emojis(name: 'freezing');
  static const frown = Emojis(name: 'frown');
  static const ghost = Emojis(name: 'ghost');
  static const grimace = Emojis(name: 'grimace');
  static const happy = Emojis(name: 'happy');
  static const hearts = Emojis(name: 'hearts');
  static const injured = Emojis(name: 'injured');
  static const kiss = Emojis(name: 'kiss');
  static const laugh = Emojis(name: 'laughing');
  static const laughSquinting = Emojis(name: 'laugh-squinting');
  static const liar = Emojis(name: 'liar');
  static const love = Emojis(name: 'love');
  static const mask = Emojis(name: 'mask');
  static const meh = Emojis(name: 'meh');
  static const melting = Emojis(name: 'melting');
  static const mindblown = Emojis(name: 'mindblown');
  static const mindful = Emojis(name: 'mindful');
  static const money = Emojis(name: 'money');
  static const monocle = Emojis(name: 'monocle');
  static const moon = Emojis(name: 'moon');
  static const moonFull = Emojis(name: 'moon-full');
  static const mouthless = Emojis(name: 'mouthless');
  static const nerd = Emojis(name: 'nerd');
  static const nervous = Emojis(name: 'nervous');
  static const party = Emojis(name: 'party');
  static const pleading = Emojis(name: 'pleading');
  static const queasy = Emojis(name: 'queasy');
  static const quirky = Emojis(name: 'quirky');
  static const rainbow = Emojis(name: 'rainbow');
  static const relieved = Emojis(name: 'relieved');
  static const robot = Emojis(name: 'robot');
  static const sad = Emojis(name: 'sad');
  static const sadCrying = Emojis(name: 'sad-crying');
  static const satisfied = Emojis(name: 'satisfied');
  static const shaking = Emojis(name: 'shaking');
  static const shocked = Emojis(name: 'shocked');
  static const sick = Emojis(name: 'sick');
  static const skull = Emojis(name: 'skull');
  static const sleeping = Emojis(name: 'sleeping');
  static const smile = Emojis(name: 'smile');
  static const smirk = Emojis(name: 'smirk');
  static const squinting = Emojis(name: 'squinting');
  static const starstruck = Emojis(name: 'starstruck');
  static const sunglasses = Emojis(name: 'sunglasses');
  static const swearing = Emojis(name: 'swearing');
  static const sweating = Emojis(name: 'sweating');
  static const transparent = Emojis(name: 'transparent');
  static const unamused = Emojis(name: 'unamused');
  static const upsideDown = Emojis(name: 'upside-down');
  static const vomit = Emojis(name: 'vomit');
  static const weary = Emojis(name: 'weary');
  static const wholesome = Emojis(name: 'wholesome');
  static const wide = Emojis(name: 'wide');
  static const wink = Emojis(name: 'wink');
  static const woozy = Emojis(name: 'woozy');
  static const yummy = Emojis(name: 'yummy');
  static const zipped = Emojis(name: 'zipped');

  static List<Emojis> emojisList = [
    alert,
    alien,
    angel,
    angry,
    angryYellow,
    bigSmile,
    calm,
    confused,
    dead,
    devilFrown,
    devilSmile,
    disguise,
    dizzy,
    drool,
    expressionless,
    eyebrowRaised,
    eyeroll,
    flustered,
    freezing,
    frown,
    ghost,
    grimace,
    happy,
    hearts,
    injured,
    kiss,
    laugh,
    laughSquinting,
    liar,
    love,
    mask,
    meh,
    melting,
    mindblown,
    mindful,
    money,
    monocle,
    moon,
    moonFull,
    mouthless,
    nerd,
    nervous,
    party,
    pleading,
    queasy,
    quirky,
    rainbow,
    relieved,
    robot,
    sad,
    sadCrying,
    satisfied,
    shaking,
    shocked,
    sick,
    skull,
    sleeping,
    smile,
    smirk,
    squinting,
    starstruck,
    sunglasses,
    swearing,
    sweating,
    transparent,
    unamused,
    upsideDown,
    vomit,
    weary,
    wholesome,
    wide,
    wink,
    woozy,
    yummy,
    zipped
  ];
}
