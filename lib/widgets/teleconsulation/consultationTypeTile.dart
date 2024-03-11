import 'package:flutter_svg/svg.dart';
import 'package:ihl/constants/customicons_icons.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Consultation Type Tile (takes image provider as leading, recommended use createImage from image utils) 😃
class ConsultationTypeTile extends StatelessWidget {
  final String text;
  final ImageProvider leading;
  final Color color;
  final Function onTap;
  final Widget trailing;
  final bool visible;
  ConsultationTypeTile(
      {this.color,
      this.leading,
      this.onTap,
      this.text,
      this.trailing,
      this.visible});
  List<String> _list = [
    "Physical Wellbeing",
    "Emotional Wellbeing",
    "Financial Wellbeing",
    "Social Wellbeing",
  ];

  @override
  Widget build(BuildContext context) {
    //Condition to check the page to set icon and there size
    IconData selectedIcon;
    double iconSize;
    if (text.toString() == 'Medical Consultation') {
      selectedIcon = Customicons.user_md_solid;
      iconSize = 25;
    } else if (text.toString() == 'Fitness Class') {
      selectedIcon = Customicons.fitness_class;
      iconSize = 75;
    } else if (text.toString() == 'Ayurvedic Consultation') {
      selectedIcon = Customicons.ayurvedic__consultation;
      iconSize = 75;
    } else if (text.toString() == 'Food and Nutrition') {
      selectedIcon = Customicons.food_nutrition;
      iconSize = 85;
    } else if (text.toString() == 'Diet Consultation') {
      // selectedIcon = Customicons.diet_consultation;
      selectedIcon = Customicons.health_consultant;
      iconSize = 75;
    } else if (text.toString() == 'Cardiology') {
      selectedIcon = Customicons.cardiology;
      iconSize = 20;
    } else if (text.toString() == 'General Medical') {
      selectedIcon = Customicons.general_medical;
      iconSize = 25;
    } else if (text.toString() == 'Pneumologist - Lungs') {
      selectedIcon = Customicons.pneumologist_lungs;
      iconSize = 20;
    } else if ((text.toString() == 'Pediatrics') ||
        (text.toString() == 'Pediatric - Child') ) {
      selectedIcon = Customicons.pediatric_child;
      iconSize = 25;
    } else if (text.toString() == 'Yoga') {
      selectedIcon = Customicons.pilates;
      iconSize = 75;
    } else if (text.toString() == 'Zumba') {
      selectedIcon = Customicons.zumba;
      iconSize = 75;
    } else if (text.toString() == 'Pilates') {
      selectedIcon = Customicons.pilates;
      iconSize = 75;
    } else if (text.toString() == 'Boxing') {
      selectedIcon = Customicons.boxing;
      iconSize = 75;
    } else if (text.toString() == 'Physical Therapy') {
      selectedIcon = Customicons.user_md_solid;
      iconSize = 20;
    } else if (text.toString() == 'Transformation') {
      selectedIcon = Customicons.diet_consultation;
      iconSize = 75;
    } else if (text.toString() == 'Adventure Services') {
      selectedIcon = Customicons.diet_consultation;
      iconSize = 75;
    } else if (text.toString() == 'Diabetology') {
      selectedIcon = Customicons.diabetology;
      iconSize = 75;
    } else if (text.toString() == 'Orthopaedics') {
      selectedIcon = Customicons.bone;
      iconSize = 20;
    } else if (text.toString() == 'Health Consultation') {
      selectedIcon = Customicons.health_consultant;
      iconSize = 75;
    } else {
      selectedIcon = Customicons.general_medical;
      iconSize = 20;
    }
    // return Card(
    //   // color: AppColors.cardColor,
    //   color: FitnessAppTheme.white,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(20.0),
    //   ),
    //   elevation: 2,
    //   borderOnForeground: true,

    return Container(
      margin: const EdgeInsets.only(
        left: 9.0,
        right: 9.0,
        top: 12.0,
      ),
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          bottomLeft: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
          // topRight: Radius.circular(68.0)),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: FitnessAppTheme.grey.withOpacity(0.2),
              offset: Offset(1.1, 1.1),
              blurRadius: 10.0),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.0),
        onTap: onTap,
        splashColor: color.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: ListTile(
            title: Text(
              text.replaceAll('Counsellor', 'Emotional Health Consultant'),
              style: TextStyle(
                fontSize: 20,
                color: AppColors.primaryColor,
              ),
            ),
            leading: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(_list.contains(text)
                        ? 0
                        : MediaQuery.of(context).size.height / 90),
                    child: text == "Physical Wellbeing"
                        ? SvgPicture.asset('assets/svgs/Physical Wellbeing.svg')
                        : text == "Emotional Wellbeing"
                            ? SvgPicture.asset(
                                'assets/svgs/Emotional Wellbeing.svg',
                              )
                            : text == "Financial Wellbeing"
                                ? SvgPicture.asset(
                                    'assets/svgs/Financial Wellbeing.svg')
                                : text == "Social Wellbeing"
                                    ? SvgPicture.asset(
                                        'assets/svgs/Social Wellbeing.svg')
                                    : Icon(
                                        selectedIcon,
                                        size: iconSize,
                                      ),
                  ),
                ),
              ],
            ),
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}
