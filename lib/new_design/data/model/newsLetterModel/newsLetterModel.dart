class NewsLetterModel {
  String documentId;
  String documentTitle;
  String documentPublishDate;
  String documentBlobUrl;
  String imageUrl;
  String imageThumbUrl;

  NewsLetterModel(
      {this.documentId,
      this.documentTitle,
      this.documentPublishDate,
      this.documentBlobUrl,
      this.imageUrl,
      this.imageThumbUrl});

  NewsLetterModel.fromJson(Map<String, dynamic> json) {
    documentId = json['document_id'];
    documentTitle = json['document_title'];
    documentPublishDate = json['document_publish_date'];
    documentBlobUrl = json['document_blob_url'];
    imageUrl = json['image_url'];
    imageThumbUrl = json['image_thumb_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['document_id'] = this.documentId;
    data['document_title'] = this.documentTitle;
    data['document_publish_date'] = this.documentPublishDate;
    data['document_blob_url'] = this.documentBlobUrl;
    data['image_url'] = this.imageUrl;
    data['image_thumb_url'] = this.imageThumbUrl;
    return data;
  }
}
