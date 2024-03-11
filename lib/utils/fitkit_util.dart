// import 'package:fit_kit/fit_kit.dart';
//
// class FitKitHelper {
//   static getEnergy({int days}) async {
//     return await FitKit.readLast(
//       DataType.ENERGY,
//     );
//   }
//
//   static getStepCount({int days}) async {
//     return await FitKit.readLast(
//       DataType.STEP_COUNT,
//     );
//   }
//
//   static getDistance({int days}) async {
//     return await FitKit.readLast(
//       DataType.DISTANCE,
//     );
//   }
//
//   static Future<DailyFitData> getDailyData() async {
//     return await FitKit.readDaily();
//   }
//
//   static revokeFit() async{
//     await FitKit.revokePermissions();
//   }
//   static getHR({int days}) async {
//     return await FitKit.readLast(
//       DataType.HEART_RATE,
//     );
//   }
//   //there's other types of data too
// }
//
