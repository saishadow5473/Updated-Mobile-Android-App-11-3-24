import 'dart:convert';
import 'dart:io';
import 'package:video_player/video_player.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../views/splash_screen.dart';
import '../controllers/challenge_api.dart';
import '../models/challenge_detail.dart';
import '../models/challenge_video_gen_model.dart';
import '../models/get_selfie_image_model.dart';

class ImageViewerHealthChallenge extends StatefulWidget {
  ImageViewerHealthChallenge(
      {Key key, @required this.enrollmentId, this.enrolledChallenge, this.challengeDetail})
      : super(key: key);
  String enrollmentId;
  EnrolledChallenge enrolledChallenge;
  ChallengeDetail challengeDetail;
  @override
  State<ImageViewerHealthChallenge> createState() => _ImageViewerHealthChallengeState();
}

class _ImageViewerHealthChallengeState extends State<ImageViewerHealthChallenge> {
  int _current = 0;

  bool _isGenVideoOnProcess = false, _alreadyhaveVideo = false;
  final CarouselController _controller = CarouselController();
  String _dir = '';
  Map<String, dynamic> _enrol;
  @override
  void initState() {
    _enrol = gs.read('${widget.enrolledChallenge.enrollmentId}') ?? {};
    print(_enrol);
    try {
      _dir = _enrol["path"];
    } catch (e) {
      _enrol = {};
    }
    if (_dir != null) {
      _alreadyhaveVideo = true;
    } else {
      _alreadyhaveVideo = false;
    }
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollessBasicPageUI(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        actions: [
          Visibility(
            visible: _alreadyhaveVideo,
            child: IconButton(
                onPressed: () async {
                  print(_dir);
                  // VideoPlayerController controller;
                  //
                  // controller = VideoPlayerController.asset(_dir);
                  // controller.initialize().then((value){
                  //   setState(() {
                  //   });
                  // });
                  try {
                    await OpenFile.open(_dir);
                  }catch(e){
                    print(e);}
                },
                icon: Icon(
                  FontAwesome.file_video_o,
                  color: Colors.white,
                )),
          ),
          Visibility(
            visible: _alreadyhaveVideo,
            child: IconButton(
                onPressed: () async {
                  Share.shareFiles([_dir], text: '${widget.challengeDetail.challengeName} Video');
                },
                icon: Icon(
                  FontAwesome.share_alt,
                  color: Colors.white,
                )),
          ),
          Gap(10.sp),
        ],
      ),
      body: FutureBuilder<List<SelifeImageData>>(
          future: ChallengeApi().getSelfieImageData(enroll_id: widget.enrollmentId),
          builder: (ctx, snap) {
            if (snap.data == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snap.data.length == 0) {
              return Center(
                  child: Text(
                "No Uploads Available",
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    fontFamily: 'Poppins',
                    color: Colors.blueGrey),
              ));
            }

            try {
              return Column(children: [
                Expanded(
                  child: CarouselSlider(
                    carouselController: _controller,
                    options: CarouselOptions(
                        //enlargeFactor: 1.0,

                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlay: true,
                        aspectRatio: 0.6,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        }),
                    items: snap.data
                        .map((item) => Container(
                              margin: EdgeInsets.all(5.0),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  child: Stack(
                                    children: <Widget>[
                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //     image: DecorationImage(
                                      //         image: NetworkImage(
                                      //             item.userUploadedImageUrl),
                                      //         fit: BoxFit.fitHeight,
                                      //         opacity: 0.6),
                                      //   ),
                                      // ),
                                      // Container(
                                      //   color: Color.fromRGBO(
                                      //       0, 0, 0, 0.34901960784313724),
                                      //   // color: Color.fromRGBO(
                                      //   //     0, 0, 0, 0.18823529411764706),
                                      // ),
                                      Image.network(
                                        item.userUploadedImageUrl,
                                        fit: BoxFit.fitWidth,
                                        width: 1000.0,
                                        height: 1000,
                                      ),
                                      // Positioned(
                                      //   bottom: 0.0,
                                      //   left: 0.0,
                                      //   right: 0.0,
                                      //   child: Container(
                                      //     decoration: BoxDecoration(
                                      //       gradient: LinearGradient(
                                      //         colors: [
                                      //           Color.fromARGB(200, 0, 0, 0),
                                      //           Color.fromARGB(0, 0, 0, 0)
                                      //         ],
                                      //         begin: Alignment.bottomCenter,
                                      //         end: Alignment.topCenter,
                                      //       ),
                                      //     ),
                                      //     padding: EdgeInsets.symmetric(
                                      //         vertical: 10.0, horizontal: 20.0),
                                      //     child: Text(
                                      //       'No. ${snap.data.indexOf(item)} image',
                                      //       style: TextStyle(
                                      //         color: Colors.white,
                                      //         fontSize: 20.0,
                                      //         fontWeight: FontWeight.bold,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  )),
                            ))
                        .toList(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: snap.data.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(entry.key),
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : AppColors.primaryColor)
                                .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                      ),
                    );
                  }).toList(),
                ),
                Visibility(
                  visible: widget.enrolledChallenge.userProgress == 'completed',
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isGenVideoOnProcess = true;
                          });
                          generateVideoWithImage(
                              snap.data, widget.enrolledChallenge, widget.challengeDetail);
                        },
                        child: Text("Export Video")),
                  ),
                ),
              ]);
              // return ListView.builder(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: snap.data.length,
              //     itemBuilder: (ctx, i) {
              //       return Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: Container(
              //           height: Device.height / 7,
              //           width: Device.height / 7,
              //           decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(20),
              //               border: Border.all(color: Colors.white),
              //               boxShadow: [
              //                 BoxShadow(
              //                     color: Colors.grey.shade200,
              //                     offset: Offset(1, 1),
              //                     blurRadius: 6)
              //               ],
              //               image: DecorationImage(
              //                   fit: BoxFit.cover,
              //                   image: NetworkImage(
              //                       snap.data[i].userUploadedImageUrl))),
              //         ),
              //       );
              //     });
            } catch (e) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.white,
                  direction: ShimmerDirection.ltr,
                  period: Duration(seconds: 2),
                  child: Container(
                    height: Device.height / 7,
                    width: Device.height / 7,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade200, offset: Offset(1, 1), blurRadius: 6)
                        ],
                        image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(""))),
                  ),
                ),
              );
            }
          }),
    );
  }

  generateVideoWithImage(List<SelifeImageData> rawData, EnrolledChallenge enrolledChallenge,
      ChallengeDetail challengeDetail) async {
    Get.defaultDialog(
        title: 'Generating your video...',
        barrierDismissible: false,
        backgroundColor: Colors.lightBlue.shade50,
        titlePadding: EdgeInsets.only(top: 20, bottom: 0, left: 10, right: 10),
        titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
        contentPadding: EdgeInsets.only(top: 0),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Text('Generating....!'),
          ],
        ));
    List<SelifeImageData> data =
        rawData.where((element) => !element.filename.contains("_completed_certificate")).toList();
    SelifeImageData certificateImage;
    try {
      certificateImage =
          rawData.where((element) => element.filename.contains("_completed_certificate")).first;
    } catch (e) {
      certificateImage = null;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var datas = prefs.get('data');
    Map res = jsonDecode(datas);
    var responce = await ChallengeApi().genVideoWithSelfieImage(
        challengeVideoGenModel: ChallengeVideoGenModel(
            img1: data.length > 0 && data[0] != null && data[0].userUploadedImageUrl != null
                ? data[0].userUploadedImageUrl
                : '',
            img2: data.length > 1 && data[1] != null && data[1].userUploadedImageUrl != null
                ? data[1].userUploadedImageUrl
                : '',
            img3: data.length > 2 && data[2] != null && data[2].userUploadedImageUrl != null
                ? data[2].userUploadedImageUrl
                : '',
            img4: data.length > 3 && data[3] != null && data[3].userUploadedImageUrl != null
                ? data[3].userUploadedImageUrl
                : '',
            img5: data.length > 4 && data[4] != null && data[4].userUploadedImageUrl != null
                ? data[4].userUploadedImageUrl
                : '',
            img6: data.length > 5 && data[5] != null && data[5].userUploadedImageUrl != null
                ? data[5].userUploadedImageUrl
                : '',
            img7: data.length > 6 && data[6] != null && data[6].userUploadedImageUrl != null
                ? data[6].userUploadedImageUrl
                : '',
            img8: data.length > 7 && data[7] != null && data[7].userUploadedImageUrl != null
                ? data[7].userUploadedImageUrl
                : '',
            img9: data.length > 8 && data[8] != null && data[8].userUploadedImageUrl != null
                ? data[8].userUploadedImageUrl
                : '',
            img10: data.length > 9 && data[9] != null && data[9].userUploadedImageUrl != null
                ? data[9].userUploadedImageUrl
                : '',
            img11: certificateImage != null && certificateImage.userUploadedImageUrl != null
                ? certificateImage.userUploadedImageUrl
                : '',
            firstName: enrolledChallenge.name,
            lastName: res['User']['lastName']==""?'N/A':res['User']['lastName'],
            runName: challengeDetail.challengeName,
            bib: enrolledChallenge.user_bib_no,
            enrollmentId: enrolledChallenge.enrollmentId,
            speed: enrolledChallenge.speed,
            distance: enrolledChallenge.target.toString(),
            duration: enrolledChallenge.userduration.toString(),
            submit: true.toString(),
            challenge_name: challengeDetail.challengeName,
            template_affiliation: "IHL"));

    if (responce == "process_complete") {
      Get.back();
      Fluttertoast.showToast(
          msg: 'Downloading...!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
      Directory internalDirectory;
      String dir;
      if (Platform.isAndroid) {
        List<Directory> downloadsDirectory =
            await getExternalStorageDirectories(type: StorageDirectory.downloads);
        if (downloadsDirectory == null && downloadsDirectory.isEmpty) {
          internalDirectory = await getApplicationDocumentsDirectory();
        }
        dir = downloadsDirectory[0].path;
      } else if (Platform.isIOS) {
        internalDirectory = await getApplicationDocumentsDirectory();
        dir = internalDirectory.path;
      }
      print("path ${dir}");
      dio.Response response = await dio.Dio().get(
          'http://xampp.indiahealthlink.com:9000/challenge_video_generator/IHL/${enrolledChallenge.enrollmentId}/out_merged.mp4',
          options: dio.Options(responseType: dio.ResponseType.bytes, followRedirects: false),
          onReceiveProgress: (rec, total) async {
        const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails(
          presentAlert: false,
          presentBadge: false,
        );

        final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
          'downloadId',
          'Download',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          channelShowBadge: false,
          autoCancel: true,
          progress: ((rec / total) * 100).toInt(),
          maxProgress: 100,
          onlyAlertOnce: true,
          showProgress: true,
        );
        final NotificationDetails notificationDetails = NotificationDetails(
            android: androidNotificationDetails, iOS: iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
          0,
          'Download',
          'The ${widget.challengeDetail.challengeName} video download ${((rec / total) * 100).toInt()} % ',
          notificationDetails,
          payload: jsonEncode({'path': ''}),
        );
      });
      await flutterLocalNotificationsPlugin.cancel(0);
      final File file = File("$dir/${challengeDetail.challengeName}.mp4");
      _dir = "$dir/${challengeDetail.challengeName}.mp4";
      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      if (Platform.isAndroid)
        await ImageGallerySaver.saveFile("$dir/${challengeDetail.challengeName}.mp4",
            name: "${challengeDetail.challengeName}.mp4");
      gs.write('${widget.enrolledChallenge.enrollmentId}', {
        'id': enrolledChallenge.enrollmentId,
        'path': "$dir/${challengeDetail.challengeName}.mp4"
      });
      // _dir =
      //    _enrol.where((element) => element['id'] == enrolledChallenge.enrollmentId).first['path'];
      print(_dir);
      // OpenFile.open();
      print(file.path);
      if (mounted)
        setState(() {
          _alreadyhaveVideo = true;
          _isGenVideoOnProcess = false; //continue your work from here
        });
    }
  }
}
