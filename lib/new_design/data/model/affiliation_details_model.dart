import 'package:flutter/material.dart';

class AffiliationDetailsModel {
  AffiliationDetailsModel(
      {this.companyName,
      this.affiliationUniqueName,
      this.affilationCode,
      this.brandImageUrl,
      this.medicationPartnerLogo,
      this.medicationPartnerName,
      this.labPartnerLogo,
      this.labPartnerName,
      this.medicationPartnerEmail,
      this.labPartnerEmail,
      this.discountDetails,
      this.providerList,
      this.challengeBannerUrl,
      this.challengeCompletedCertficateUrl,
      this.companyDomainName,
      @required this.partitionKey,
      @required this.rowKey,
      @required this.timestamp,
      @required this.eTag,
      this.dashboardSettings});

  String companyName;
  String affiliationUniqueName;
  String affilationCode;
  String brandImageUrl;
  String medicationPartnerLogo;
  String medicationPartnerName;
  String labPartnerLogo;
  String labPartnerName;
  String medicationPartnerEmail;
  String labPartnerEmail;
  String discountDetails;
  String providerList;
  String challengeBannerUrl;
  String challengeCompletedCertficateUrl;
  String companyDomainName;
  String partitionKey;
  String rowKey;
  String timestamp;
  String eTag;
  FeatureSettings dashboardSettings;
  factory AffiliationDetailsModel.fromJson(Map<String, dynamic> json) => AffiliationDetailsModel(
        companyName: json["company_name"],
        affiliationUniqueName: json["affiliation_unique_name"],
        affilationCode: json["affilation_code"],
        brandImageUrl: json["brand_image_url"],
        medicationPartnerLogo: json["medication_partner_logo"],
        medicationPartnerName: json["medication_partner_name"],
        labPartnerLogo: json["lab_partner_logo"],
        labPartnerName: json["lab_partner_name"],
        medicationPartnerEmail: json["medication_partner_email"],
        labPartnerEmail: json["lab_partner_email"],
        discountDetails: json["discount_details"],
        providerList: json["provider_list"],
        challengeBannerUrl: json["challenge_banner_url"],
        challengeCompletedCertficateUrl: json["challenge_completed_certficate_url"],
        companyDomainName: json["company_domain_name"],
        partitionKey: json["PartitionKey"],
        rowKey: json["RowKey"],
        timestamp: json["Timestamp"],
        dashboardSettings:
            // json["feature_settings"] != null && json["feature_settings"] == '[]'
            //     ?
            // FeatureSettings.fromJson(json["feature_settings"])
            FeatureSettings(
                healthJornal: true,
                challenges: true,
                newsLetter: true,
                askIhl: true,
                hpodLocations: true,
                teleconsultation: true,
                onlineClasses: true,
                myVitals: true,
                stepCounter: true,
                heartHealth: true,
                setYourGoals: true,
                diabeticsHealth: true,
                healthTips: true,
                personalData: false),
        eTag: json["ETag"],
      );

  Map<String, dynamic> toJson() => {
        "company_name": companyName,
        "affiliation_unique_name": affiliationUniqueName,
        "affilation_code": affilationCode,
        "brand_image_url": brandImageUrl,
        "medication_partner_logo": medicationPartnerLogo,
        "medication_partner_name": medicationPartnerName,
        "lab_partner_logo": labPartnerLogo,
        "lab_partner_name": labPartnerName,
        "medication_partner_email": medicationPartnerEmail,
        "lab_partner_email": labPartnerEmail,
        "discount_details": discountDetails,
        "provider_list": providerList,
        "challenge_banner_url": challengeBannerUrl,
        "challenge_completed_certficate_url": challengeCompletedCertficateUrl,
        "company_domain_name": companyDomainName,
        "PartitionKey": partitionKey,
        "RowKey": rowKey,
        "Timestamp": timestamp,
        "ETag": eTag,
      };
}

class FeatureSettings {
  bool healthJornal;
  bool challenges;
  bool newsLetter;
  bool askIhl;
  bool hpodLocations;
  bool teleconsultation;
  bool onlineClasses;
  bool myVitals;
  bool stepCounter;
  bool heartHealth;
  bool setYourGoals;
  bool diabeticsHealth;
  bool personalData;
  bool healthTips;

  FeatureSettings({
    @required this.healthJornal,
    @required this.challenges,
    @required this.newsLetter,
    @required this.askIhl,
    @required this.hpodLocations,
    @required this.teleconsultation,
    @required this.onlineClasses,
    @required this.myVitals,
    @required this.stepCounter,
    @required this.heartHealth,
    @required this.setYourGoals,
    @required this.diabeticsHealth,
    @required this.personalData,
    @required this.healthTips,
  });

  factory FeatureSettings.fromJson(Map<String, dynamic> map) {
    if (map == null) {
      return FeatureSettings(
          healthJornal: true,
          challenges: true,
          newsLetter: true,
          askIhl: true,
          hpodLocations: true,
          teleconsultation: true,
          onlineClasses: true,
          myVitals: true,
          stepCounter: true,
          heartHealth: true,
          setYourGoals: true,
          diabeticsHealth: true,
          healthTips: true,
          personalData: false);
    } else {
      return FeatureSettings(
          healthJornal: map["health_jornal"],
          challenges: map["challenges"],
          newsLetter: map["news_letter"],
          askIhl: map["ask_ihl"],
          hpodLocations: map["hpod_locations"],
          teleconsultation: map["teleconsultation"],
          onlineClasses: map["online_classes"],
          myVitals: map["my_vitals"],
          stepCounter: map["step_counter"],
          heartHealth: map["heart_health"],
          setYourGoals: map["set_your_goals"],
          diabeticsHealth: map["diabetics_health"],
          healthTips: map["health_tips"],
          personalData: map["personal_data"]);
    }
  }
}
