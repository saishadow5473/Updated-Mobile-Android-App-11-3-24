import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:ihl/new_design/app/utils/localStorageKeys.dart';
import 'package:ihl/new_design/data/providers/network/apis/myVitalsApi/myVitalsApi.dart';

class CheckinDataFcm {
  GetStorage localSotrage = GetStorage();
  updateCheckinData(dynamic vitals) {
    var previousData = localSotrage.read(LSKeys.vitalsData);
    var previousDataStatus = localSotrage.read(LSKeys.vitalStatus);

    CheckAllDataLoaded.data.value = false;
    // vitalData = {
    //   "heamoglobin_class": "Low",
    //   "glucose_post_prandial_class": "normal",
    //   "intra_cellular_water": 60.0,
    //   "skeletal_muscle_mass_status": "Normal",
    //   "urine_ph_class": "normal",
    //   "pulseBpm": 71.0,
    //   "score": 3.0,
    //   "visceral_fat": 10.0,
    //   "heightMeters": 1.73,
    //   "fatClass": "Healthy",
    //   "urine_protein": "24",
    //   "id": "chk_7ZU7aqHhzUy9RU6IGN2nqQ",
    //   "glucose_random": 100.0,
    //   "urine_nitrite_class": "normal",
    //   "waist_hip_ratio_status": "Normal",
    //   "urine_specific_gravity": "1.030",
    //   "lipid_profile_ldl_class": "normal",
    //   "diastolic": 80.0,
    //   "sourceType": "kioskv1",
    //   "ECG_QRS_duration": "41",
    //   "ECGBpm": "60",
    //   "extra_cellular_water": 40.0,
    //   "dateTime": "2024-01-29T13:38:22.1419797Z",
    //   "glucose_fasting": 90.0,
    //   "gender": "m",
    //   "urine_blood": "25",
    //   "waist_height_ratio_status": "Normal",
    //   "waist_height_ratio": 0.5,
    //   "urine_ph": "6.0",
    //   "pulseClass": "Normal",
    //   "Cholesterol_status": "Normal",
    //   "percent_body_fat_status": "Normal",
    //   "lipid_profile_tg_class": "normal",
    //   "urine_protein_class": "normal",
    //   "temperature": 98.6,
    //   "ECG_PR_interval": "31",
    //   "urine_ketone": "26",
    //   "urine_leukocytes_class": "normal",
    //   "sourceVendorID": "higi",
    //   "urine_specific_gravity_class": "normal",
    //   "map": 93.33,
    //   "skeletal_muscle_mass": 55.0,
    //   "weightKG": 65.0,
    //   "urine_urobilinogen": "0.2",
    //   "lipid_profile_tg": 100.0,
    //   "body_cell_mass_status": "Normal",
    //   "lipid_profile_hg_class": "normal",
    //   "intra_cellular_water_status": "High",
    //   "glucose_random_class": "normal",
    //   "dateOfBirth": "11\/25\/2000",
    //   "visceral_fat_status": "Normal",
    //   "Cholesterol": 180.0,
    //   "lipid_profile_tc": 200.0,
    //   "ihl_user_identification_id": "egnFZRH0YT57TB8C",
    //   "glucose_post_prandial": 120.0,
    //   "mineral_status": "Normal",
    //   "bmi": 21.0,
    //   "sourceId": "@k1772",
    //   "protien_status": "Normal",
    //   "body_fat_mass_status": "High",
    //   "ECG_QTC_duration": "31",
    //   "glucose_fasting_class": "normal",
    //   "Roomtemperature": 72.0,
    //   "mineral": 1000.0,
    //   "lipid_profile_hg": 50.0,
    //   "protien": 7.2,
    //   "body_fat_mass": 20.0,
    //   "lipid_profile_ldl": 120.0,
    //   "urine_glucose": "27",
    //   "heamoglobin": "26.7",
    //   "urine_ketone_class": "normal",
    //   "systolic": 120.0,
    //   "urine_bilirubin": "28",
    //   "leadTwoStatus": "High",
    //   "waist_hip_ratio": 0.85,
    //   "bone_mineral_content_status": "Normal",
    //   "temperatureClass": "High",
    //   "urine_glucose_class": "normal",
    //   "urine_leukocytes": "23",
    //   "urine_urobilinogen_class": "normal",
    //   "body_cell_mass": 45.0,
    //   "urine_bilirubin_class": "normal",
    //   "spo2Class": "Normal",
    //   "bmiClass": "Normal",
    //   "ECGData": null,
    //   "ECGData2": null,
    //   "Age": "78",
    //   "urine_blood_class": "normal",
    //   "extra_cellular_water_status": "High",
    //   "lipid_profile_tc_class": "normal",
    //   "fatRatio": 15.0,
    //   "ECGData3": null,
    //   "bone_mineral_content": 2.5,
    //   "percent_body_fat": 18.0,
    //   "bpClass": "Normal",
    //   "spo2": 71.0,
    //   "urine_nitrite": "67"
    // };

    Map vitalData = json.decode(vitals);
    print(vitalData);
    var BMI = vitalData["bmi"];
    var Weight = vitalData["weightKG"];
    var TEMP = vitalData["temperature"];

    var Pulse = vitalData["pulseBpm"];
    var ECG = vitalData["ECGBpm"];
    var BP = vitalData["bp"];
    var SMM = vitalData["skeletal_muscle_mass"];
    var BMC = vitalData["bone_mineral_content"];
    var Protein = vitalData["protien"];
    var ECW = vitalData["extra_cellular_water"];
    var ICW = vitalData["intra_cellular_water"];
    var BFM = vitalData["body_fat_mass"];
    var BCM = vitalData["body_cell_mass"];
    var WaistHip = vitalData["waist_hip_ratio"];
    var PBF = vitalData["percent_body_fat"];
    var VF = vitalData["visceral_fat"];
    var BMR = vitalData["basal_metabolic_rate"];
    var SPO2 = vitalData["spo2"];
    var WtHR = vitalData["waist_height_ratio"];
    var Mineral = vitalData["mineral"];

    var vitalListData = {
      "BMI": BMI ?? previousData["BMI"],
      "Weight": Weight ?? previousData["Weight"],
      "TEMP": TEMP ?? previousData["TEMP"],
      "Mineral": Mineral ?? previousData["Mineral"],
      "SMM": SMM ?? previousData["SMM"],
      "Pulse": Pulse ?? previousData["Pulse"],
      "ECG": ECG ?? previousData["ECG"],
      "BP": BP ?? previousData["BP"],
      "BMC": BMC ?? previousData["BMC"],
      "Protein": Protein ?? previousData["Protein"],
      "ECW": ECW ?? previousData["ECW"],
      "ICW": ICW ?? previousData["ICW"],
      "BFM": BFM ?? previousData["BFM"],
      "BCM": BCM ?? previousData["BCM"],
      "Waist Hip": WaistHip ?? previousData["Waist Hip"],
      "PBF": PBF ?? previousData["PBF"],
      "VF": VF ?? previousData["VF"],
      "BMR": BMR ?? previousData["BMR"],
      "SPO2": SPO2 ?? previousData["SPO2"],
      "WtHR": WtHR ?? previousData["WtHR"]
    };

    var vitalListStatus = {
      "BMI_status": vitalData["bmiClass"] ?? previousDataStatus["BMI_status"],
      "BP_status": vitalData["bpClass"] ?? previousDataStatus["BP_status"],
      "Mineral_status": vitalData["mineral_status"] ?? previousDataStatus["Mineral_status"],
      "Weight_status": vitalData["bmiClass"] ?? previousDataStatus["Weight_status"],
      "BCM_status": vitalData["body_cell_mass_status"] ?? previousDataStatus["BCM_status"],
      "TEMP_status": vitalData["temperatureClass"] ?? previousDataStatus["TEMP_status"],
      "Pulse_status": vitalData["pulseClass"] ?? previousDataStatus["Pulse_status"],
      "ECG_status": vitalData["ECGBpmClass"] ?? previousDataStatus["ECG_status"],
      "Protein_status": vitalData["protien_status"] ?? previousDataStatus["Protein_status"],
      "SPO2_status": vitalData["spo2Class"] ?? previousDataStatus["SPO2_status"],
      "ECW_status": vitalData["extra_cellular_water_status"] ?? previousDataStatus["ECW_status"],
      "ICW_status": vitalData["intra_cellular_water_status"] ?? previousDataStatus["ICW_status"],
      "BFM_status": vitalData["body_fat_mass_status"] ?? previousDataStatus["BFM_status"],
      "WaistHip_status":
          vitalData["waist_hip_ratio_status"] ?? previousDataStatus["WaistHip_status"],
      "PBF_status": vitalData["percent_body_fat_status"] ?? previousDataStatus["PBF_status"],
      "WtHR_status": vitalData["waist_height_ratio_status"] ?? previousDataStatus["WtHR_status"],
      "VF_status": vitalData["visceral_fat_status"] ?? previousDataStatus["VF_status"],
      "BMR_status": vitalData["basal_metabolic_rate_status"] ?? previousDataStatus["BMR_status"],
      "BMC_status": vitalData["bone_mineral_content_status"] ?? previousDataStatus["BMC_status"],
      "SMM_status": vitalData["skeletal_muscle_mass_status"] ?? previousDataStatus["SMM_status"],
    };
    try {
      localSotrage.write(LSKeys.vitalsData, vitalListData);
      localSotrage.write((LSKeys.vitalStatus), vitalListStatus);
      CheckAllDataLoaded.data.value = true;
    } catch (e) {
      print(e);
    }
  }
}
