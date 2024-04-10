import 'package:bu_passport/pages/explore_page.dart';
import 'package:bu_passport/pages/leaderboard_page.dart'; // Uncomment this line
import 'package:bu_passport/pages/calendar_page.dart';
import 'package:bu_passport/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationPageContent();
  }
}

class NavigationPageContent extends StatefulWidget {
  const NavigationPageContent({Key? key}) : super(key: key);

  @override
  _NavigationPageContentState createState() => _NavigationPageContentState();
}

class _NavigationPageContentState extends State<NavigationPageContent> {
  final user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    ExplorePage(),
    CalendarPage(),
    LeaderboardPage(), // Add LeaderboardPage here
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
