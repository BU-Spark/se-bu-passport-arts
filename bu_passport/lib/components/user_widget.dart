import 'package:bu_passport/classes/user.dart';
import 'package:flutter/material.dart';

class UserRankWidget extends StatelessWidget {
  final int rank;
  final Users user;

  const UserRankWidget({Key? key, required this.rank, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
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
              fontSize: 20.0,
              fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
              color: rank <= 3 ? const Color(0xFFCC0000) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
