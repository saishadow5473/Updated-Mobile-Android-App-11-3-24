import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../constants/api.dart';
import '../model/consultantAndClassListModel.dart';

class ClassAndConsultantApi {
  final Dio dio = Dio();
  static int paginationStartIndex = 1, paginationEndIndex = 10;
  Future<ClassAndConsultantListModel> getData({String wellbeing, List<String> affi}) async {
    try {
      ClassAndConsultantListModel data;

      Response<dynamic> response = await dio.post(
        "${API.iHLUrl}/platformservice/doctor_consultant_and_class_category_affiliation",
        data: json.encode(<String, dynamic>{
          "source": "",
          "affilation_list": affi.isEmpty ? <String>[] : affi,
          "category": <String>[wellbeing],
          "start_index": paginationStartIndex,
          "end_index": paginationEndIndex,
        }),
      );
      paginationStartIndex = paginationEndIndex + 1;
      paginationEndIndex += 10;
      if (response.statusCode == 200) {
        data = ClassAndConsultantListModel.fromJson(response.data);
      } else {
        data = ClassAndConsultantListModel(consultantAndClassList: <ConsultantAndClassList>[]);
      }
      return data;
    } catch (error) {
      return ClassAndConsultantListModel(consultantAndClassList: <ConsultantAndClassList>[]);
    }
  }
}
