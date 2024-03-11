class HealthTipsModel {
  String healthTipId;
  String healthTipTitle;
  String message;
  String healthTipBlobUrl;
  String healthTipBlobThumbNailUrl;
  String healthTipLog;

  HealthTipsModel(
      {this.healthTipId,
      this.healthTipTitle,
      this.message,
      this.healthTipBlobUrl,
      this.healthTipBlobThumbNailUrl,
      this.healthTipLog});

  HealthTipsModel.fromJson(Map<String, dynamic> json) {
    healthTipId = json['health_tip_id'];
    healthTipTitle = json['health_tip_title'];
    message =
        json['message'].replaceAll("&#39", "").replaceAll('&amp;', '&').replaceAll('&quot;', '"');
    healthTipBlobUrl = json['health_tip_blob_url'];
    healthTipBlobThumbNailUrl = json['health_tip_blob_thumb_nail_url'];
    healthTipLog = json['health_tip_log'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['health_tip_id'] = this.healthTipId;
    data['health_tip_title'] = this.healthTipTitle;
    data['message'] = this.message;
    data['health_tip_blob_url'] = this.healthTipBlobUrl;
    data['health_tip_blob_thumb_nail_url'] = this.healthTipBlobThumbNailUrl;
    data['health_tip_log'] = this.healthTipLog;
    return data;
  }
}
