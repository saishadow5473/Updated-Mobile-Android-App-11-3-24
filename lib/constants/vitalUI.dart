import 'package:flutter/material.dart';

/* 
🐦🐦 LIST AND MAP OF ALL UI SPECIFIC DATA NOT AVAILABLE IN THE API🐦🐦
 
 */
Image maleAvatar = Image.asset('assets/images/maleaAva.png');
Image defAvatar = Image.asset('assets/images/defAva.png');
Image femaleAvatar = Image.asset('assets/images/femaleAv.png');

///list of all heathly statuses (please append)🚀🚀
List healthyStatuses = [
  'low',
  'Normal',
  'normal',
  'Normal Sinus Rhythm',
  'Healthy',
  'healthy',
  'Norm',
  'Acceptable',
  'Unknown',
  'unkn',
];

///list of all unhealthy statuses (please append)
List unhealthyStatuses = [
  'Isolated Diastolic Hypertension',
  'High',
  'At risk',
  'Obese',
  'Overweight',
  'Underweight',
  'N/A',
  'Beyond range , Please Check with health care provider',
  'It’s beyond range please check with health provider',
  'High Fever',
  'Fever'
];

/// vitals to show on dashboard🏠
List<String> vitalsOnHome = [
  'bmi',
  'weightKG',
  // 'heightMeters',
  'temperature',
  'pulseBpm',
  'fatRatio',
  'ECGBpm',
  'bp',
  'spo2',
  'protien',
  'extra_cellular_water',
  'intra_cellular_water',
  'mineral',
  'skeletal_muscle_mass',
  'body_fat_mass',
  'body_cell_mass',
  'waist_hip_ratio',
  'percent_body_fat',
  'waist_height_ratio',
  'visceral_fat',
  'basal_metabolic_rate',
  'bone_mineral_content',
  'Cholesterol'
];

/// 👀vitals on dashboard to be converted to decimal
List<String> decimalVitals = [
  'bmi',
  'weightKG',
  'heightMeters',
  'temperature',
  'fatRatio',
];

/// 👀 Map with keys as json key of each vital, each value has a map containing acronym, name,icon,unit,tip
final Map vitalsUI = {
  'ECGBpm': {
    'acr': 'ECG',
    'name': 'Electronic Cardio Graph',
    'icon': 'assets/icons/ecg.png',
    'color': Color(0xff0bbcd4),
    'unit': 'bpm',
    'tip': 'A healthy ECG value ranges from 60bpm to 100bpm',
  },
  'bmi': {
    'unit': '',
    'acr': 'BMI',
    'name': 'Body Mass Index',
    'icon': 'assets/icons/bmi.png',
    'color': Color(0xfffec73a),
    'tip':
        'A healthy BMI value ranges from 18.5 to 23, an unhealthy BMI may point to underweight, overweight and even obesity'
  },
  'weightKG': {
    'acr': 'WEIGHT',
    'name': 'Weight',
    'tip':
        'The healthy weight range varies from person to person according to their height and other factors.',
    'icon': 'assets/icons/weight.png',
    'color': Color(0xffab6cad),
    'unit': 'kg'
  },
  // mycode
  // 'heightCMS': {
  //   'acr': 'HEIGHT',
  //   'name': 'height',
  //   'tip':
  //       'The healthy weight range varies from person to person according to their height and other factors.',
  //   'icon': 'assets/icons/weight.png',
  //   'color': Color(0xffab6cad),
  //   'unit': 'cms'
  // },
  // end
  'fatRatio': {
    'tip':
        'BMC is indicative of fat in your body,a healthy bmc ranges from 2% to 18% for male and upto 25% for female',
    'acr': 'FAT',
    'name': 'Body Mass Composition',
    'icon': 'assets/icons/bmc.png',
    'unit': '%'
  },
  'pulseBpm': {
    'acr': 'PULSE',
    'tip': 'A healthy pulse value ranges from 60bpm to 100bpm',
    'name': 'Pulse',
    'icon': 'assets/icons/pulse.png',
    'unit': 'bpm'
  },
  'temperature': {
    'acr': 'TEMP',
    'tip':
        'A healthy temperature value ranges from 97°F to 99°F, higher temperature may indicate fever',
    'icon': 'assets/icons/temp.png',
    'name': 'Temperature',
    'unit': '°F',
  },
  'bp': {
    'tip':
        'A healthy blood pressure is about 120 for systole and 80 for diastole, higher blood pressure may indicate hypertension',
    'acr': 'BP',
    'name': 'Blood Pressure',
    'icon': 'assets/icons/bp.png',
    'unit': 'mmHg'
  },
  'spo2': {
    'tip': 'A healthy Oxygen Saturation value ranges from 96% to 100%',
    'acr': 'SPO2',
    'name': 'Oxygen Saturation',
    'icon': 'assets/icons/spo2.png',
    'unit': '%'
  },
  'protien': {
    'unit': 'kg',
    'acr': 'PROTEIN',
    'name': 'Protein',
    'icon': 'assets/icons/bmc.png',
    'tip': 'A healthy Protien ranges from 80 to 120kgs for male and 90 to 110kgs for female'
  },
  'extra_cellular_water': {
    'unit': 'Ltr',
    'acr': 'ECW',
    'name': 'Extra Cellular Water',
    'icon': 'assets/icons/bmc.png',
    'tip': 'A healthy ECW value ranges from 90 to 110 Liters'
  },
  'intra_cellular_water': {
    'unit': 'Ltr',
    'acr': 'ICW',
    'name': 'Intra Cellular Water',
    'icon': 'assets/icons/bmc.png',
    'tip': 'A healthy ICW value ranges from 85 to 125 Liters'
  },
  'mineral': {
    'unit': 'kg',
    'acr': 'MINERAL',
    'name': 'Mineral',
    'icon': 'assets/icons/bmc.png',
    'tip': 'A healthy Mineral value ranges from 17-23% of your total body composition.'
  },
  'skeletal_muscle_mass': {
    'unit': 'kg',
    'acr': 'SMM',
    'name': 'Skeletal Muscle Mass',
    'icon': 'assets/icons/bmc.png',
    'tip': 'A healthy SMM value ranges from 12-19% of your total body composition'
  },
  'body_fat_mass': {
    'unit': 'kg',
    'acr': 'BFM',
    'name': 'Body Fat Mass',
    'icon': 'assets/icons/bmc.png',
    'tip': 'A healthy BFM value ranges from 21-36% of your total body composition'
  },
  'body_cell_mass': {
    'unit': 'kg',
    'acr': 'BCM',
    'name': 'Body Cell Mass',
    'icon': 'assets/icons/bmc.png',
    'tip':
        'A healthy Body Cell Mass value ranges from 12-23% of your total cell tissue compostition'
  },
  'waist_hip_ratio': {
    'unit': '',
    'acr': 'WAIST HIP',
    'name': 'Waist Hip Ratio',
    'icon': 'assets/icons/bmc.png',
    'tip':
        'Waist Hip ratio depends on your Body compostition which varies from person to person and case to case. Typically in range of 20-35%'
  },
  'percent_body_fat': {
    'unit': '%',
    'acr': 'PBF',
    'name': 'Percent Body Fat',
    'icon': 'assets/icons/bmc.png',
    'tip': 'A healthy Body Fat Percentage value ranges from 17-23% of your total body composition'
  },
  'waist_height_ratio': {
    'unit': '',
    'acr': 'WtHR',
    'name': 'Waist Height Ratio',
    'icon': 'assets/icons/bmc.png',
    'tip':
        'Waist Height ratio depends on your Body compostition which varies from person to person and case to case. Typically in the range of 20-40%'
  },
  'visceral_fat': {
    'unit': 'cm.sq',
    'acr': 'VF',
    'name': 'Visceral Fat',
    'icon': 'assets/icons/bmc.png',
    'tip': 'A healthy Visceral value ranges from 10-16% of your total body composition per sq.cms'
  },
  'basal_metabolic_rate': {
    'unit': 'Cal',
    'acr': 'BMR',
    'name': 'Basal Metabolic Rate',
    'icon': 'assets/icons/bmc.png',
    'tip':
        'BMR is indicative of energy expended in your body,a healthy BMR ranges from 26 to 32kCal for male and 21 to 29kCal for female'
  },
  'bone_mineral_content': {
    'unit': 'kg',
    'acr': 'BMC',
    'name': 'Bone Mineral Content',
    'icon': 'assets/icons/bmc.png',
    'tip':
        'BMC is indicative of mineral content in your bones, a healthy BMC ranges from 24% to 28% of the Body composition per Fat for male and upto 35% of the Body composition per Fat for female'
  },
  'calorie': {
    'tip': 'A healthy calorie consumption value ranges from 1800 to 2000',
    'acr': 'Calories',
    'name': 'Calories',
    'icon': 'assets/icons/spo2.png',
    'unit': 'Cal'
  },
  'Cholesterol': {
    'tip': 'A healthy cholesterol value ranges from 200 to 239',
    'acr': 'Cholesterol',
    'name': 'Cholesterol',
    'icon': 'assets/icons/spo2.png',
    'unit': 'mg/dL'
  }
};
ThemeData themeData = ThemeData();
