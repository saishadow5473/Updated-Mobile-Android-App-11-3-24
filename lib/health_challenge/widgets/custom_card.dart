import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomCardForHealthchallenges extends StatefulWidget {
  CustomCardForHealthchallenges(
      {Key key,
      @required this.title,
      @required this.imageUrl,
      @required this.onTap})
      : super(key: key);
  String title, imageUrl;
  VoidCallback onTap;

  @override
  State<CustomCardForHealthchallenges> createState() =>
      _CustomCardForHealthchallengesState();
}

class _CustomCardForHealthchallengesState
    extends State<CustomCardForHealthchallenges> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Colors.blueGrey.shade50,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: width / 5,
                width: width / 5,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: AssetImage(widget.imageUrl))),
              ),
            ),
            SizedBox(
              width: width / 60,
            ),
            SizedBox(
              width: width / 1.7,
              child: Text(widget.title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: Colors.blueGrey)),
            ),
          ],
        ),
      ),
    );
  }
}
