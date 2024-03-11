import 'package:ihl/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// tiles on dashboard 👀👀
class DashboardTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final Function onTap;
  final Widget trailing;
  DashboardTile(
      {Key key, this.icon, this.text, this.color, this.onTap, this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: AppColors.cardColor,
      color: FitnessAppTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,
      borderOnForeground: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.0),
        onTap: onTap,
        splashColor: color.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: ListTile(
            title: Text(
              text,
              style: TextStyle(
                fontSize: 20,
                // fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            leading: Icon(
              icon,
              color: color,
            ),
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}
