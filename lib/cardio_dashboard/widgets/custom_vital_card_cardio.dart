import 'package:flutter/material.dart';
import '../../new_design/app/utils/constLists.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// ignore: must_be_immutable
class CustomVitalCard extends StatelessWidget {
  CustomVitalCard({
    Key key,
    @required this.name,
    @required this.imagePath,
    @required this.value,
    @required this.color,
    @required this.onGraphTap,
    @required this.onTileTap,
  }) : super(key: key);
  String name, value, imagePath;
  Color color;
  VoidCallback onGraphTap, onTileTap;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTileTap,
        child: Container(
          width: size.width > 340 ? 43.w : 42.w,
          // height: 40.w,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(1, 1),
                  blurRadius: 8,
                  color: Colors.grey.shade400,
                )
              ]),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  // child: Icon(Icons.auto_graph_rounded),
                  child: InkWell(
                    onTap: onGraphTap,
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.asset("assets/icons/Icon metro-chart-dots.png"),
                    ),
                  ),
                ),
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          offset: const Offset(1, 1), color: Colors.grey.shade400, blurRadius: 16)
                    ],
                    border: Border.all(color: color, width: 3),
                    borderRadius: BorderRadius.circular(250),
                  ),
                  child: Center(
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.asset(imagePath),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '$value ${ProgramLists.vitalsUnitHHM[name]}',
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                ),
                Text(
                  name,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
