class SendMedicalReport {
  var status;

  SendMedicalReport({
    this.status,
  });

  factory SendMedicalReport.fromJson(Map<String, dynamic> json) {
    return SendMedicalReport(
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
      };
}
