class HpodMapModel {
  String city;
  String latitude;
  String longitude;
  String orgAddress;
  String orgAddressLine2;
  String orgAddressLine3;
  String orgPincode;
  String organizationName;
  bool allowGenericUser;

  HpodMapModel(
      {this.city,
      this.latitude,
      this.longitude,
      this.orgAddress,
      this.orgAddressLine2,
      this.orgAddressLine3,
      this.orgPincode,
      this.organizationName,
      this.allowGenericUser});

  HpodMapModel.fromJson(Map<String, dynamic> json) {
    city = json['City'];
    latitude = json['Latitude'];
    longitude = json['Longitude'];
    orgAddress = json['OrgAddress'];
    orgAddressLine2 = json['OrgAddressLine2'];
    orgAddressLine3 = json['OrgAddressLine3'];
    orgPincode = json['OrgPincode'];
    organizationName = json['OrganizationName'];
    allowGenericUser = json['allow_generic_user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['City'] = this.city;
    data['Latitude'] = this.latitude;
    data['Longitude'] = this.longitude;
    data['OrgAddress'] = this.orgAddress;
    data['OrgAddressLine2'] = this.orgAddressLine2;
    data['OrgAddressLine3'] = this.orgAddressLine3;
    data['OrgPincode'] = this.orgPincode;
    data['OrganizationName'] = this.organizationName;
    data['allow_generic_user'] = this.allowGenericUser;
    return data;
  }
}
