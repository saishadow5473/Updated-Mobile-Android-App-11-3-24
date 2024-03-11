import 'dart:convert';

import '../../../app/utils/localStorageKeys.dart';
import '../../providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../../presentation/pages/spalshScreen/splashScreen.dart';
import '../../../../utils/SpUtil.dart';

class VitalData {
  var BMI;
  var Weight;
  var TEMP;
  var Pulse;
  var ECG;
  var BP;
  var SMM;
  var SPO2;
  var Protein;
  var ECW;
  var ICW;
  var BFM;
  var BCM;
  var WaistHip;
  var PBF;
  var WtHR;
  var Mineral;
  var VF;
  var BMR;
  var BMC;
  var vitalListData;
  var vitalListStatus;
  var BMI_status;
  var Weight_status;
  var TEMP_status;
  var Pulse_status;
  var ECG_status;
  var BP_status;
  var SPO2_status;
  var Protein_status;
  var ECW_status;
  var ICW_status;
  var BFM_status;
  var BCM_status;
  var WaistHip_status;
  var PBF_status;
  var WtHR_status;
  var VF_status;
  var BMR_status;
  var BMC_status;
  //var lastCheckin = localSotrage.read(LSKeys.lastCheckin);
  var lastCheckin = jsonDecode(SpUtil.getString(LSKeys.lastCheckin));
  // var userData = localSotrage.read(LSKeys.userDetail);
  var userData = jsonDecode(SpUtil.getString(LSKeys.userDetail));
  var checkin = localSotrage.read(LSKeys.allScors);
  //var checkinData = SpUtil.getString(LSKeys.allScors);

  updateData() {
    BMI = lastCheckin["bmi"] ??
        (checkin["bmi"] != null && checkin["bmi"].length != 0
            ? checkin["bmi"].last["value"]
            : null);
    Weight = lastCheckin["weightKG"] ??
        (checkin["weightKG"] != null && checkin["weightKG"].length != 0
            ? checkin["weightKG"].last["value"]
            : userData["userInputWeightInKG"]);
    if (checkin.containsKey('temperature')) {
      TEMP = checkin["temperature"].length != 0
          ? double.parse(checkin["temperature"].last["value"] ?? '0.0')
          : 0.0;
    } else {
      TEMP = 0.0;
    }
    Pulse = checkin["pulseBpm"] != null && checkin["pulseBpm"].length != 0
        ? checkin["pulseBpm"].last["value"]
        : 0;
    ECG = checkin["ECGBpm"] != null && checkin["ECGBpm"].length != 0
        ? double.parse(checkin["ECGBpm"].last["value"] ?? '0.0')
        : 0.0;
    BP = lastCheckin["bp"] ??
        (checkin["bp"] != null && checkin["bp"].length != 0 ? checkin["bp"].last["value"] : null);
    SMM = lastCheckin["skeletal_muscle_mass"] ??
        (checkin["skeletal_muscle_mass"] != null && checkin["skeletal_muscle_mass"].length != 0
            ? checkin["skeletal_muscle_mass"].last["value"]
            : null);
    BMC = lastCheckin["bone_mineral_content"] ??
        (checkin["bone_mineral_content"] != null && checkin["bone_mineral_content"].length != 0
            ? checkin["bone_mineral_content"].last["value"]
            : null);
    Protein = lastCheckin["protien"] ??
        (checkin["protien"] != null && checkin["protien"].length != 0
            ? checkin["protien"].last["value"]
            : null);
    ECW = lastCheckin["extra_cellular_water"] ??
        (checkin["extra_cellular_water"] != null && checkin["extra_cellular_water"].length != 0
            ? checkin["extra_cellular_water"].last["value"]
            : null);
    ICW = lastCheckin["intra_cellular_water"] ??
        (checkin["intra_cellular_water"] != null && checkin["intra_cellular_water"].length != 0
            ? checkin["intra_cellular_water"].last["value"]
            : null);
    BFM = lastCheckin["body_fat_mass"] ??
        (checkin["body_fat_mass"] != null && checkin["body_fat_mass"].length != 0
            ? checkin["body_fat_mass"].last["value"]
            : null);
    BCM = lastCheckin["body_cell_mass"] ??
        (checkin["body_cell_mass"] != null && checkin["body_cell_mass"].length != 0
            ? checkin["body_cell_mass"].last["value"]
            : null);
    WaistHip = lastCheckin["waist_hip_ratio"] ??
        (checkin["waist_hip_ratio"] != null && checkin["waist_hip_ratio"].length != 0
            ? checkin["waist_hip_ratio"].last["value"]
            : null);
    PBF = lastCheckin["percent_body_fat"] ??
        (checkin["percent_body_fat"] != null && checkin["percent_body_fat"].length != 0
            ? checkin["percent_body_fat"].last["value"]
            : null);
    VF = lastCheckin["visceral_fat"] ??
        (checkin["visceral_fat"] != null && checkin["visceral_fat"].length != 0
            ? checkin["visceral_fat"].last["value"]
            : null);
    BMR = lastCheckin["basal_metabolic_rate"] ??
        (checkin["basal_metabolic_rate"] != null && checkin["basal_metabolic_rate"].length != 0
            ? checkin["basal_metabolic_rate"].last["value"]
            : null);
    SPO2 = checkin["spo2"] != null && checkin["spo2"].length != 0
        ? checkin["spo2"].last["value"]
        : null;
    WtHR = lastCheckin["waist_height_ratio"] ??
        (checkin["waist_height_ratio"] != null && checkin["waist_height_ratio"].length != 0
            ? checkin["waist_height_ratio"].last["value"]
            : null);
    Mineral = lastCheckin["mineral"] ??
        (checkin["mineral"] != null && checkin["mineral"].length != 0
            ? checkin["mineral"].last["value"]
            : null);

    vitalListData = {
      "BMI": BMI,
      "Weight": Weight,
      "TEMP": TEMP,
      "Mineral": Mineral,
      "SMM": SMM,
      "Pulse": Pulse,
      "ECG": ECG,
      "BP": BP,
      "BMC": BMC,
      "Protein": Protein,
      "ECW": ECW,
      "ICW": ICW,
      "BFM": BFM,
      "BCM": BCM,
      "Waist Hip": WaistHip,
      "PBF": PBF,
      "VF": VF,
      "BMR": BMR,
      "SPO2": SPO2,
      "WtHR": WtHR
    };
    try {
      vitalListStatus = {
        "BMI_status": lastCheckin["bmiClass"] ??
            (checkin["bmi"] != null
                ? checkin["bmi"].length != 0
                    ? checkin["bmi"].last["status"]
                    : null
                : null),
        "BP_status": checkin["bp"] != null
            ? checkin["bp"].length != 0
                ? checkin["bp"].last["status"]
                : null
            : null,
        "Mineral_status": lastCheckin["mineral"] != null && lastCheckin["mineral_status"] != null
            ? lastCheckin["mineral_status"]
            : (checkin["mineral"] != null
                ? checkin["mineral"].length != 0
                    ? checkin["mineral"].last["status"]
                    : null
                : null),
        "Weight_status": lastCheckin["bmiClass"] ??
            (checkin["weightKG"] != null
                ? checkin["weightKG"].length != 0
                    ? checkin["weightKG"].last["status"]
                    : null
                : null),
        "BCM_status":
            lastCheckin["body_cell_mass"] != null && lastCheckin["body_cell_mass_status"] != null
                ? lastCheckin["body_cell_mass_status"]
                : (checkin["body_cell_mass"] != null
                    ? checkin["body_cell_mass"].length != 0
                        ? checkin["body_cell_mass"].last["status"]
                        : null
                    : null),
        "TEMP_status": checkin["temperature"] != null
            ? checkin["temperature"].length != 0
                ? checkin["temperature"].last["status"]
                : null
            : null,
        "Pulse_status": checkin["pulseBpm"] != null
            ? checkin["pulseBpm"].length != 0
                ? checkin["pulseBpm"].last["status"]
                : null
            : null,
        "ECG_status": checkin["ECGBpm"] != null
            ? checkin["ECGBpm"].length != 0
                ? checkin["ECGBpm"].last["status"]
                : null
            : null,
        "Protein_status": lastCheckin["protien"] != null && lastCheckin["protien_status"] != null
            ? lastCheckin["protien_status"]
            : (checkin["protien"] != null
                ? checkin["protien"].length != 0
                    ? checkin["protien"].last["status"]
                    : null
                : null),
        "SPO2_status": checkin["spo2"] != null
            ? checkin["spo2"].length != 0
                ? checkin["spo2"].last["status"]
                : null
            : null,
        "ECW_status": lastCheckin["extra_cellular_water"] != null &&
                lastCheckin["extra_cellular_water_status"] != null
            ? lastCheckin["extra_cellular_water_status"]
            : (checkin["extra_cellular_water"] != null
                ? checkin["extra_cellular_water"].length != 0
                    ? checkin["extra_cellular_water"].last["status"]
                    : null
                : null),
        "ICW_status": lastCheckin["intra_cellular_water"] != null &&
                lastCheckin["intra_cellular_water_status"] != null
            ? lastCheckin["intra_cellular_water_status"]
            : (checkin["intra_cellular_water"] != null
                ? checkin["intra_cellular_water"].length != 0
                    ? checkin["intra_cellular_water"].last["status"]
                    : null
                : null),
        "BFM_status":
            lastCheckin["body_fat_mass"] != null && lastCheckin["body_fat_mass_status"] != null
                ? lastCheckin["body_fat_mass_status"]
                : (checkin["body_fat_mass"] != null
                    ? checkin["body_fat_mass"].length != 0
                        ? checkin["body_fat_mass"].last["status"]
                        : null
                    : null),
        "WaistHip_status":
            lastCheckin["waist_hip_ratio"]!=null && lastCheckin["waist_hip_ratio_status"] != null
                ? lastCheckin["waist_hip_ratio_status"]
                : (checkin["waist_hip_ratio"] != null
                    ? checkin["waist_hip_ratio"].length != 0
                        ? checkin["waist_hip_ratio"].last["status"]
                        : null
                    : null),
        "PBF_status":
            lastCheckin["percent_body_fat"] != null && lastCheckin["body_fat_mass_status"] != null
                ? lastCheckin["body_fat_mass_status"]
                : (checkin["percent_body_fat"] != null
                    ? checkin["percent_body_fat"].length != 0
                        ? checkin["percent_body_fat"].last["status"]
                        : null
                    : null),
        "WtHR_status": lastCheckin["waist_height_ratio"] != null &&
                lastCheckin["waist_height_ratio_status"] != null
            ? lastCheckin["waist_height_ratio_status"]
            : (checkin["waist_height_ratio"] != null
                ? checkin["waist_height_ratio"].length != 0
                    ? checkin["waist_height_ratio"].last["status"]
                    : null
                : null),
        "VF_status":
            lastCheckin["visceral_fat"] != null && lastCheckin["visceral_fat_status"] != null
                ? lastCheckin["visceral_fat_status"]
                : (checkin["visceral_fat"] != null
                    ? checkin["visceral_fat"].length != 0
                        ? checkin["visceral_fat"].last["status"]
                        : null
                    : null),
        "BMR_status": lastCheckin["basal_metabolic_rate"] != null &&
                lastCheckin["basal_metabolic_rate_status"] != null
            ? lastCheckin["basal_metabolic_rate_status"]
            : (checkin["basal_metabolic_rate"] != null
                ? checkin["basal_metabolic_rate"].length != 0
                    ? checkin["basal_metabolic_rate"].last["status"]
                    : null
                : null),
        "BMC_status": lastCheckin["bone_mineral_content"] != null &&
                lastCheckin["bone_mineral_content_status"] != null
            ? lastCheckin["bone_mineral_content_status"]
            : (checkin["bone_mineral_content"] != null
                ? checkin["bone_mineral_content"].length != 0
                    ? checkin["bone_mineral_content"].last["status"]
                    : null
                : null),
        "SMM_status": lastCheckin["skeletal_muscle_mass"] != null &&
                lastCheckin["skeletal_muscle_mass_status"] != null
            ? lastCheckin["skeletal_muscle_mass_status"]
            : (checkin["skeletal_muscle_mass"] != null
                ? checkin["skeletal_muscle_mass"].length != 0
                    ? checkin["skeletal_muscle_mass"].last["status"]
                    : null
                : null),
      };
    } catch (e) {
      print(e);
    }

    localSotrage.write(LSKeys.vitalsData, vitalListData);
    localSotrage.write((LSKeys.vitalStatus), vitalListStatus);
    CheckAllDataLoaded.data.value = true;
  }
}
