import 'package:flutter/material.dart';
import 'package:ihl/constants/vitalUI.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/ScUtil.dart';

String getStr(String m) {
  if (m == 'm' || m == 'M' || m == 'male' || m == 'Male') {
    return 'Male';
  }
  if (m == 'f' || m == 'F' || m == 'female' || m == 'Female') {
    return 'Female';
  }
  return 'Other';
}

Image getImage(String m) {
  if (m == 'm' || m == 'M' || m == 'male' || m == 'Male') {
    return maleAvatar;
  }
  if (m == 'f' || m == 'F' || m == 'female' || m == 'Female') {
    return femaleAvatar;
  }
  return defAvatar;
}

///Gender Selector 👨 👩
class GenderSelector extends StatelessWidget {
  bool isEditing;
  String current;
  Function change;
  GenderSelector({this.change, this.current, this.isEditing});
  //const GenderSelector({Key key}) : super(key: key);
  Widget gen(String g) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: getStr(current) == getStr(g)
              ? AppColors.primaryAccentColor
              : Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              child: ClipOval(
                  child: ColorFiltered(
                      colorFilter: getStr(current) == getStr(g)
                          ? ColorFilter.mode(
                              Colors.transparent, BlendMode.saturation)
                          : ColorFilter.mode(Colors.grey, BlendMode.saturation),
                      child: getImage(g))),
              radius: 15,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              getStr(g),
              style: TextStyle(
                color: Colors.white,
                fontSize: ScUtil().setSp(14),
              ),
            )
          ],
        ),
        onPressed: () {
          change(g);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 320, height: 640, allowFontScaling: true);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 8, right: 8),
      child: Wrap(
        spacing: 10,
        children: ['m', 'f'].map((e) => gen(e)).toList(),
      ),
    );
  }
}
