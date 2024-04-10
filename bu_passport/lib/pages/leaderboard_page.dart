import 'package:bu_passport/classes/user.dart';
import 'package:bu_passport/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Users> topUsers = [];
  int userPoints = 0;
  int userTickets = 0;

  @override
  void initState() {
    super.initState();
    fetchTopUsers();
    fetchUserPointsAndTickets();
  }

  Future<void> fetchTopUsers() async {
    try {
      List<Users> users = await FirebaseService.fetchTopUsers();
      setState(() {
        topUsers = users;
      });
    } catch (error) {
      print("Failed to fetch top users: $error");
    }
  }

  Future<void> fetchUserPointsAndTickets() async {
    try {
      String userUID = FirebaseAuth.instance.currentUser?.uid ?? "";
      Users? user = await FirebaseService.fetchUser(userUID);
      if (user != null) {
        setState(() {
          userPoints = user.userPoints;
          userTickets = userPoints ~/ 100; // Calculate tickets
        });
      }
    } catch (error) {
      print("Failed to fetch user details: $error");
    }
  }

  String calculateLeague(int points) {
    if (points >= 1000) {
      return "Diamond League";
    } else if (points >= 500) {
      return "Gold League";
    } else if (points >= 300) {
      return "Silver League";
    } else {
      return "Bronze League";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leaderboard"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Your Points: $userPoints",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Your Tickets: $userTickets",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Your League: ${calculateLeague(userPoints)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Top 10 Users:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: topUsers.length,
              itemBuilder: (context, index) {
                Users user = topUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.userProfileURL),
                  ),
                  title: Text(user.firstName + " " + user.lastName),
                  subtitle: Text("Points: ${user.userPoints}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
