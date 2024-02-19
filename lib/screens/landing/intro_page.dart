import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mahikav/components/buttons/filled_buttons.dart';
import 'package:mahikav/screens/home/first_page.dart';
import 'package:mahikav/screens/home/home_page.dart';

class PushNotification {
  PushNotification({
    this.title,
    this.body,
  });

  String? title;
  String? body;
}

class LogoPage extends StatefulWidget {
  const LogoPage({Key? key}) : super(key: key);

  @override
  State<LogoPage> createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> with TickerProviderStateMixin {
  late final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  late AnimationController logoAnimationController;
  late AnimationController textAnimationController;

  late Animation<double?> logoAnimation;
  late Animation<double> textAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1, milliseconds: 500),
    );
    textAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    Animation<double> curve = CurvedAnimation(
        parent: logoAnimationController, curve: Curves.bounceOut);
    textAnimation =
        Tween<double>(begin: -300, end: 0).animate(textAnimationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {});
    logoAnimation = Tween<double>(begin: 0.3, end: 1).animate(curve)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          initPage();
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => const IntroPage(),
          //   ),
          // );
        }
      });
    textAnimationController.forward();
    logoAnimationController.forward();
  }

  initPage() {
    FirebaseAuth.instance.authStateChanges().listen((event) {
      Get.off((event != null) ? HomePage() : const IntroPage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Transform.scale(
          scale: logoAnimation.value,
          child: SizedBox(
            height: 200,
            child: Image.asset(
              "images/logo.png",
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Opacity(
              opacity: textAnimationController.value,
              child: Transform.translate(
                offset: Offset(0, textAnimation.value),
                child: Text(
                  'MAHIKA',
                  style: GoogleFonts.amita(
                    color: const Color(0xff025b85),
                    fontSize: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  int nextClickedNo = 1;
  PageController controller = PageController();
  List<String> title = [
    'Connects all women and police of your area',
    'Connects you directly with police',
    'Send visual proofs of incidents',
  ];
  List<String> description = [
    'You become a part of women community of your college or locality '
        'where-in you can interact with them regarding any problem faced by the '
        'person. There is a common group which connects all the woman community '
        'of that area. Police has access to all the communities and common group',
    'If you face any kind of abuse or harassment, just tap on the call button or '
        'record button, or simply hit VOLUME UP button or VOLUME DOWN button '
        'twice to record when its emergency. Make sure to add it to home screen '
        'to launch it quickly by sliding the icon. Voice message will automatically '
        'gets recorded and saved to the phone, after 30 seconds it will send automatically '
        'to the police along-with location and name of the person, and they '
        'receive it via. notifications.',
    'If you have any proofs of abuse you recorded by any chance, it can be sent '
        'to the common group, if it is found relevant then it will be notified to police'
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    EdgeInsets padding = MediaQuery.of(context).viewPadding;
    double height = size.height - padding.vertical;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: nextClickedNo == 1
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white),
                splashColor: Colors.white12,
                color: Colors.black,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                ),
                onPressed: () {
                  if (nextClickedNo > 1) {
                    nextClickedNo--;
                    controller.animateToPage(
                      nextClickedNo - 1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
                    setState(() {});
                  }
                },
              ),
            ),
      body: Hero(
        tag: 'logo',
        child: Container(
          height: size.height,
          width: size.width,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/introimage.jpg'),
                  fit: BoxFit.fitHeight)),
          child: Padding(
            padding: padding,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: height * 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: BottomSheet(
        onClosing: () {},
        builder: (_) => Container(
          // height: height - (height * 0.5),
          width: size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.white,
          ),
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: controller,
                    onPageChanged: (value) {
                      nextClickedNo = value + 1;
                      setState(() {});
                    },
                    itemBuilder: (context, i) {
                      return SingleChildScrollView(
                        child: IntroTextsSlider(
                          title: title[i],
                          description: description[i],
                        ),
                      );
                    },
                    itemCount: description.length,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                DotIndicator(
                  nextClickedNo: nextClickedNo,
                  itemCount: description.length,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: CustomOutlineButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const FirstPage()),
                              );
                            },
                            label: 'Skip')),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: CustomFilledButton(
                        onPressed: () {
                          if (nextClickedNo < description.length) {
                            controller.animateToPage(
                              nextClickedNo++,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                            );
                          } else if (nextClickedNo == description.length) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const FirstPage()),
                            );
                          }
                          setState(() {});
                        },
                        label: 'Next',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    required this.nextClickedNo,
    required this.itemCount,
  });

  final int nextClickedNo;
  final int itemCount;

  List<Widget> dots() {
    List<Widget> dot = [];
    for (int i = 1; i <= itemCount; i++) {
      dot.add(Container(
        height: 7,
        width: 7,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: (nextClickedNo == i)
              ? Colors.black
              : Colors.black.withOpacity(0.2),
        ),
      ));
    }
    return dot;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots(),
    );
  }
}

class IntroTextsSlider extends StatelessWidget {
  const IntroTextsSlider({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          description,
        ),
      ],
    );
  }
}
