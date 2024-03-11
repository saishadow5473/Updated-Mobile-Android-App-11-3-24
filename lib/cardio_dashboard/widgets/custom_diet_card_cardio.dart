import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// ignore: must_be_immutable
class CustomDietCard extends StatelessWidget {
  CustomDietCard({Key key, this.name, this.colors, this.imgPath, this.onTap}) : super(key: key);
  String name, imgPath;
  List<Color> colors;
  VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap ?? () {},
        child: SizedBox(
          child: Column(
            children: [
              Container(
                height: 15.w,
                width: 15.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: colors,
                  ),
                  border: Border.all(width: 2.5, color: Colors.white),
                  borderRadius: BorderRadius.circular(250),
                  boxShadow: [
                    BoxShadow(offset: Offset(0, 0), color: colors[1], blurRadius: 8),
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: Image.asset(imgPath),
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  name,
                  style: onTap != null
                      ? TextStyle(color: Colors.black45, fontSize: 16.sp, fontFamily: 'Popins')
                      : TextStyle(
                          fontSize: 18.sp,
                          color: Colors.black54,
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
