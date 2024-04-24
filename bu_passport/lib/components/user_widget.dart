import 'package:bu_passport/classes/user.dart';
import 'package:flutter/material.dart';

class UserRankWidget extends StatelessWidget {
  final int rank;
  final Users user;

  const UserRankWidget({Key? key, required this.rank, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sizedBoxHeight = screenHeight * 0.05;
    double sizedBoxWidth = screenWidth * 0.02;

    double edgeInsets = (MediaQuery.of(context).size.width * 0.02);

    double imageHeight = screenHeight * 0.05;
    double imageWidth = screenWidth * 0.05;

    return Container(
      padding: EdgeInsets.all(edgeInsets),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0), // Set border radius
        color: Color.fromARGB(204, 235, 242, 250), // Set background color
      ),
      child: Row(
        children: [
          Text(
            "$rank",
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
              color: rank <= 3 ? const Color(0xFFCC0000) : Colors.black,
            ),
          ),
          SizedBox(width: 16), // Adjust spacing between rank and avatar
          CircleAvatar(
            backgroundImage: NetworkImage(user.userProfileURL),
            radius: 30.0,
          ),
          SizedBox(width: 16), // Adjust spacing between avatar and name
          Text(
            "${user.firstName} ${user.lastName}",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
              color: rank <= 3 ? const Color(0xFFCC0000) : Colors.black,
            ),
          ),
          Spacer(), // This pushes the next widget to the right
          Image(
            image: AssetImage('assets/images/leaderboard/ticket.png'),
            width: imageWidth,
            height: imageHeight,
          ),
          SizedBox(
              width:
                  sizedBoxWidth), // Adjust spacing between ticket image and text
          Text(
            // if only 1 ticket, display "1 Ticket" else display "x Tickets"
            "${user.userPoints ~/ 100} ${user.userPoints ~/ 100 == 1 ? 'Ticket' : 'Tickets'}",
            style: TextStyle(
              fontSize: 14.0,
              color: const Color(0xFFCC0000),
            ),
          ),
        ],
      ),
    );
  }
}
