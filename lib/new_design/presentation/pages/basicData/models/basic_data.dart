class BasicDataModel {
  String name;
 
  String gender;
  String dob;
  String height;
  String weight;
  String mobile;

  BasicDataModel({
    this.name,
   
    this.gender,
    this.dob,
    this.height,
    this.weight,
    this.mobile,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    
      'gender': gender,
      'dob': dob, // dob format
      'height': height,
      'weight': weight,
      'mobile': mobile,
    };
  }

  factory BasicDataModel.fromJson(Map<String, dynamic> json) {
    return BasicDataModel(
      name: json['name'] as String,
     
      gender: json['gender'] as String,
      dob: json['dob'] as String,
      height: json['height'] as String,
      weight: json['weight'] as String,
      mobile: json['mobile'] as String,
    );
  }

  bool hasData() {
    return gender != null &&
        name != null &&
    
        dob != null &&
        height != null &&
        weight != null &&
        mobile != null;
  }
}
