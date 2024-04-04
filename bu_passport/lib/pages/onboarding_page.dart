import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _pages = [
    OnboardingPageWidget(
      image: Image.asset("assets/images/onboarding/onboarding1.png",
          fit: BoxFit.contain),
      title: "Attend events",
      description:
          "When you attend an event, make sure to check in with our app! A pop-up will appear with the options to check-in with a photo for 25 points, check-in without a photo for 20 points, or to let us know you are not attending.",
      color: Colors.white,
    ),
    OnboardingPageWidget(
      image: Image.asset("assets/images/onboarding/onboarding2.png",
          fit: BoxFit.contain),
      title: "Collect Stickers",
      description:
          "Every event you attend can give you up to 2 stickers. Different events mean more chances for new stickers. Try to collect all 9 stickers and complete your collection! A completed collection earns you 5 points.",
      color: Colors.white,
    ),
    OnboardingPageWidget(
      image: Image.asset("assets/images/onboarding/onboarding3.png",
          fit: BoxFit.contain),
      title: "Make new friends",
      description:
          "Friends can add you with your unique QR code, or you can add them by scanning theirs! You can check out their public reviews, and they can check yours. ",
      color: Colors.white,
    ),
    OnboardingPageWidget(
      image: Image.asset("assets/images/onboarding/onboarding4.png",
          fit: BoxFit.contain),
      title: "Leave Feedback",
      description:
          "After attending an event, leave a review for 5 points! Tell us about how you felt about it, any feedback, or anything at all! Reviews can be private or can be made public on your profile page.",
      color: Colors.white,
    ),
    OnboardingPageWidget(
      image: Image.asset("assets/images/onboarding/onboarding5.png",
          fit: BoxFit.contain),
      title: "Your Passport",
      description:
          "Your passport is your personal catalog of every event that you have attended with us. Look back on your past attendances, all of your reviews, and your sticker collection.",
      color: Colors.white,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to your main application screen or perform another action here
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            "assets/images/onboarding/BU art logo.png",
            width: 281,
            fit: BoxFit.contain,
          ),
        ),
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: _pages,
          ),
          Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(5, // Number of pages
                      (int index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: 10,
                      width: _currentPage == index ? 30 : 10,
                      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: _currentPage == index
                            ? Colors.blue
                            : Colors.grey.withOpacity(0.5),
                      ),
                    );
                  })))
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // This aligns the children to both ends
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text(
                "Skip",
                style: TextStyle(fontSize: 20),
              ),
            ),
            TextButton(
              onPressed: _nextPage,
              child: Text(
                "Next",
                style: TextStyle(fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final Image image;
  final String title;
  final String description;
  final Color color;

  const OnboardingPageWidget({
    required this.image,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(image: image.image),
          Text(title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text(description, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
