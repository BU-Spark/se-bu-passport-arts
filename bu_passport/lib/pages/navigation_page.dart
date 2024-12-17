import 'package:bu_passport/pages/explore_page.dart';
import 'package:bu_passport/pages/leaderboard_page.dart'; // Uncomment this line
import 'package:bu_passport/pages/calendar_page.dart';
import 'package:bu_passport/pages/passport_page.dart';
import 'package:bu_passport/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

// NavigationPage is a StatelessWidget that constructs the main navigation structure.
class NavigationPage extends StatelessWidget {
  const NavigationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // It simply returns an instance of NavigationPageContent.
    return NavigationPageContent();
  }
}

// NavigationPageContent is a StatefulWidget that handles changing between pages.
class NavigationPageContent extends StatefulWidget {
  const NavigationPageContent({Key? key}) : super(key: key);

  @override
  _NavigationPageContentState createState() => _NavigationPageContentState();
}

// The state for NavigationPageContent handles the current user session and navigation logic.
class _NavigationPageContentState extends State<NavigationPageContent> {
  final user = FirebaseAuth.instance.currentUser!; // Current logged-in user instance.
  int _selectedIndex = 0; // Index of the currently selected page in the bottom navigation.

  // Static list of all pages in the bottom navigation bar.
  static List<Widget> _pages = <Widget>[
    ExplorePage(), // Page for exploring events.
    CalendarPage(), // Calendar page.
    LeaderboardPage(), // Leaderboard page.
    PassportPage(), // User passport page.
    ProfilePage(), // User profile page.
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the index of the selected page.
    });
  }

  @override
  Widget build(BuildContext context) {
    // Builds the scaffold of the app with navigation.
    return Scaffold(
      body: Center(
        child: _pages[_selectedIndex], // Displays the selected page.
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Events', // Label for the explore/events page.
          ),

          // Calendar icon
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar', // Label for the calendar page.
          ),

          // Leaderboard icon
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Leaderboard', // Label for the leaderboard page.
          ),

          // Passport icon
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book_fill),
            label: 'Passport', // Label for the passport page.
          ),

          // Profile icon
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile', // Label for the profile page.
          ),
        ],
      ),
    );
  }
}
