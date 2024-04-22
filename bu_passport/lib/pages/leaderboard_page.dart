import 'package:bu_passport/classes/user.dart';
import 'package:bu_passport/components/user_widget.dart';
import 'package:bu_passport/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  LeaderboardPageState createState() => LeaderboardPageState();
}

class LeaderboardPageState extends State<LeaderboardPage> {
  List<Users> allUsers = []; // List to store all users
  List<Users> topUsers = []; // List to store top 5 users
  int userPoints = 0;
  int userTickets = 0;
  int? userRank; // Variable to store user rank
  FirebaseService firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
    fetchUserPointsAndTickets();
  }

  Future<void> fetchAllUsers() async {
    try {
      List<Users> users = await firebaseService.fetchAllUsers();
      setState(() {
        allUsers = users;
      });
      // Filter top 5 users
      filterTopUsers(5);
      // Find user's rank
      findUserRank();
    } catch (error) {
      print("Failed to fetch all users: $error");
    }
  }

  // Function to filter top 5 users
  void filterTopUsers(int num) {
    // Sort all users by points in descending order
    allUsers.sort((a, b) => b.userPoints.compareTo(a.userPoints));
    // Take top 5 users
    topUsers = allUsers.take(num).toList();
  }

  // Function to find user's rank
  void findUserRank() {
    String userUID = FirebaseAuth.instance.currentUser?.uid ?? "";
    for (int i = 0; i < allUsers.length; i++) {
      if (allUsers[i].userUID == userUID) {
        setState(() {
          userRank = i + 1; // Adding 1 to convert from 0-based index to rank
        });
        break;
      }
    }
  }

  String _getImageAssetPath(String league) {
    switch (league) {
      case 'Diamond League':
        return 'assets/images/leaderboard/diamond.png';
      case 'Emerald League':
        return 'assets/images/leaderboard/emerald.png';
      case 'Gold League':
        return 'assets/images/leaderboard/gold.png';
      case 'Silver League':
        return 'assets/images/leaderboard/silver.png';
      default:
        return 'assets/images/leaderboard/default.png'; // Provide a default image
    }
  }

  Future<void> fetchUserPointsAndTickets() async {
    try {
      String userUID = FirebaseAuth.instance.currentUser?.uid ?? "";
      Users? user = await firebaseService.fetchUser(userUID);
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

  double calculateProgressPercentage(int points) {
    return (points % 100) / 100.0;
  }

  int calculatePointsForNextTicket(int points) {
    return (points % 100);
  }

  String calculateLeague(int points) {
    if (points >= 1000) {
      return "Diamond League";
    } else if (points >= 500) {
      return "Emerald League";
    } else if (points >= 300) {
      return "Gold League";
    } else {
      return "Silver League";
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double edgeInsets = screenWidth * 0.05;
    double sizedBoxHeight = screenHeight * 0.02;
    double imageWidth = screenWidth * 0.1;
    double imageHeight = screenHeight * 0.1;

    return Scaffold(
      appBar: AppBar(
        title: Text("Leaderboard"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(edgeInsets),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(edgeInsets),
                  child: Column(
                    children: [
                      Text(
                        "#${userRank ?? "-"}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFCC0000),
                        ),
                      ),
                      SizedBox(
                          height:
                              sizedBoxHeight), // Add some vertical space between the text and the next widget
                      Text(
                        "Rank",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                // Widget for displaying user league
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      _getImageAssetPath(calculateLeague(userPoints)),
                      width: screenWidth * 0.2, // Adjust width as needed
                      height: screenHeight * 0.2, // Adjust height as needed
                    ),
// Add some vertical space between the image and text
                    Text(
                      calculateLeague(userPoints),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Widget for displaying user tickets
                Padding(
                  padding: EdgeInsets.all(edgeInsets),
                  child: Column(
                    children: [
                      Text(
                        "$userTickets",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFCC0000),
                        ),
                      ),
                      SizedBox(
                          height:
                              sizedBoxHeight), // Add some vertical space between the text and the next widge
                      Icon(Icons.confirmation_number),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: edgeInsets),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: sizedBoxHeight * 0.5),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    LinearProgressIndicator(
                      value: calculateProgressPercentage(userPoints),
                      color: Colors.red[400],
                      backgroundColor: Colors.grey[300],
                      minHeight: screenHeight * 0.03,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: edgeInsets * 0.5),
                      child: Image.asset(
                        'assets/images/leaderboard/ticket.png',
                        width: imageWidth * 1.2,
                        height: imageHeight * 0.6,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${calculatePointsForNextTicket(userPoints)}/100 pts",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(height: sizedBoxHeight),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(edgeInsets * 0.75),
              child: ListView.separated(
                itemCount: topUsers.length,
                // physics: ClampingScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) {
                  // Add vertical space between items
                  return SizedBox(height: screenHeight * 0.02);
                },
                itemBuilder: (context, index) {
                  Users user = topUsers[index];
                  TextStyle nameTextStyle = TextStyle(
                    fontSize: 16.0,
                    fontWeight: index < 3
                        ? FontWeight.bold
                        : FontWeight.normal, // Bold for top 3 users,
                    color: index < 3
                        ? const Color(0xFFCC0000)
                        : Colors.black, // Red for top 3 users
                  );
                  return UserRankWidget(rank: index + 1, user: user);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
