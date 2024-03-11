class ProgramLists {
  ProgramLists._();

  // Lists to be shown in dashboard for programs we offer
  static const List<String> homeList = [
    "Home",
    "Challenges",
    "Health Tips",
    "Teleconsultations",
    "Vitals",
    "News Letter",
  ];
  static const List<String> commonList = [
    "Challenges",
    "Health Tips",
    "News Letter",
    "Ask IHL",
    "hPod Locations"
  ];

  static const List<String> teleconsultationList = ["Tele\nconsultation", "Online Classes"];
  static const List<String> vitalsList = ["Vitals", "Health Journal", "Step Counter"];
  static const List<String> healthPrograms = [
    "Heart Health",
    "Weight Management",
    "Diabetic Health"
  ];
  static const List<String> vitalDetails = [
    "BMI",
    "Weight",
    "ECW",
    "ICW",
    "BFM",
    "BCM",
    "Waist Hip",
    "PBF",
    "WtHR",
    "Mineral",
    "TEMP",
    "BP",
    "SPO2",
    "Pulse",
    "ECG",
    "VF",
    "Protein",
    "BMR",
    "BMC",
    "SMM"
  ];
  static const List<String> vitalIcons = [
    "BMI",
    "Weight",
    "Mineral",
    "TEMP",
    "Pulse",
    "ECG",
    "BP",
    "SPO2",
    "Protein",
    "ECW",
    "ICW",
    "BFM",
    "BCM",
    "Waist Hip",
    "PBF",
    "WtHR",
    "VF",
    "BMR",
    "BMC",
    "SMM"
  ];
  static const Map<String, String> vitalsUnit = {
    "BMI": "",
    "Weight": "kg",
    "Mineral": "kg",
    "TEMP": "°F",
    "Pulse": "bpm",
    "ECG": "bpm",
    "BP": "mmHg",
    "SPO2": "%",
    "Protein": "kg",
    "ECW": "Ltr",
    "ICW": "Ltr",
    "BFM": "kg",
    "BCM": "kg",
    "Waist Hip": "",
    "PBF": "%",
    "WtHR": "",
    "VF": "cm.sq",
    "BMR": "Cal",
    "BMC": "kg",
    "SMM": "kg"
  };
  //vitals units particularly for vitals graph screen
  static const Map<String, String> vitalsUnitG = {
    "bmi": "",
    "weightKG": "kg",
    "mineral": "kg",
    "temperature": "°F",
    "pulseBpm": "bpm",
    "ECGBpm": "bpm",
    "bp": "mmHg",
    "spo2": "%",
    "protien": "kg",
    "extra_cellular_water": "Ltr",
    "intra_cellular_water": "Ltr",
    "body_fat_mass": "kg",
    "body_cell_mass": "kg",
    "waist_hip_ratio": "",
    "percent_body_fat": "%",
    "waist_height_ratio": "",
    "visceral_fat": "cm.sq",
    "basal_metabolic_rate": "Cal",
    "bone_mineral_content": "kg",
    "skeletal_muscle_mass": "kg",
    "Cholesterol": 'mg/dL',
  };
  static const Map<String, String> vitalsUnitHHM = {
    "BMI": "",
    "Blood Pressure": "mmHg",
    "Visceral Fat": "cm.sq",
    "Cholesterol": 'mg/dL',
  };
}
