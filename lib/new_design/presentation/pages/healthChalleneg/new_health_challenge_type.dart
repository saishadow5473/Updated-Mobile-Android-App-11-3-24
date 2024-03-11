// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';

import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';

import '../../../../utils/app_colors.dart';
import '../../clippath/subscriptionTagClipPath.dart';

//Dynamic challenge and video player screen 🚩
class HealthChallengeNewType extends StatefulWidget {
  const HealthChallengeNewType({Key key}) : super(key: key);

  @override
  State<HealthChallengeNewType> createState() => _HealthChallengeNewTypeState();
}

class _HealthChallengeNewTypeState extends State<HealthChallengeNewType> {
  ValueNotifier<bool> videoPlay = ValueNotifier(false);
  VideoPlayerController _controller;
  ValueNotifier<int> v = ValueNotifier(0);

  @override
  void initState() {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse("https://dashboard.indiahealthlink.com/affiliate_logo/BigBuckBunny.mp4"),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      closedCaptionFile: null,
    );
    _controller.addListener(() {
      v.notifyListeners();
    });
    _controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return CommonScreenForNavigation(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: FittedBox(child: Text("Surya Namaskar Challenge")),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ValueListenableBuilder(
                  valueListenable: videoPlay,
                  builder: (context, value, child) {
                    return InkWell(
                        onTap: videoPlay.value == false
                            ? () {
                                videoPlay.value = !videoPlay.value;
                                _controller.play();
                              }
                            : () {},
                        child: SizedBox(
                            width: 8.3.w,
                            child: Image.asset(
                              "newAssets/Icons/video_icon.png",
                              color: videoPlay.value ? Colors.white.withOpacity(0.3) : Colors.white,
                            )));
                  }),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ValueListenableBuilder(
                  valueListenable: videoPlay,
                  builder: (ctx, value, widget) {
                    if (!value)
                      return Container(
                          height: 60.w,
                          width: 100.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      "https://images.pexels.com/photos/326055/pexels-photo-326055.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"))),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Align(
                                    alignment: Alignment.topRight,
                                    child: SizedBox(
                                      height: 5.w,
                                      width: 15.w,
                                      child: ClipPath(
                                        clipper: SubscriptionClipPath(),
                                        child: Container(
                                          alignment: Alignment.center,
                                          color: AppColors.primaryColor,
                                          child: Text(
                                            "Day 10",
                                            style: TextStyle(fontSize: 12.px, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    )),
                              ),
                            ],
                          ));
                    else {
                      return Stack(
                        children: [
                          Container(
                            height: 60.w,
                            width: 100.w,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: VideoPlayer(_controller)),
                          ),
                          Container(
                            height: 60.w,
                            width: 100.w,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(7, 0, 7, 6),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                        onTap: () {
                                          videoPlay.value = false;
                                          _controller.pause();
                                          _controller.seekTo(Duration.zero);
                                        },
                                        child: Icon(Icons.close_rounded, color: Colors.white)),
                                  ),
                                  Spacer(),
                                  Container(
                                    height: 10,
                                    // width: 100.w,
                                    child: VideoProgressIndicator(_controller,
                                        allowScrubbing: false,
                                        colors: VideoProgressColors(
                                            playedColor: AppColors.primaryColor,
                                            bufferedColor: AppColors.primaryColor.withOpacity(0.1),
                                            backgroundColor: Colors.grey.withOpacity(0.4))),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _controller.value.isPlaying
                                              ? _controller.pause()
                                              : _controller.play();
                                          videoPlay.notifyListeners();
                                        },
                                        child: Icon(
                                          _controller.value.isPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      ValueListenableBuilder(
                                          valueListenable: v,
                                          builder: (context, value, child) {
                                            return SizedBox(
                                              width: 10.w,
                                              child: StreamBuilder<String>(
                                                stream: generateNumbers(_controller),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<String> snapshot) {
                                                  if (snapshot.connectionState ==
                                                          ConnectionState.active ||
                                                      snapshot.connectionState ==
                                                          ConnectionState.done) {
                                                    if (snapshot.hasError) {
                                                      return const Text(
                                                        'N/A',
                                                        style: TextStyle(color: Colors.white),
                                                      );
                                                    } else if (snapshot.hasData) {
                                                      return Text(snapshot.data,
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 14.px));
                                                    } else {
                                                      return const Text('00:00',
                                                          style: TextStyle(color: Colors.white));
                                                    }
                                                  } else {
                                                    return Text("");
                                                  }
                                                },
                                              ),
                                            );
                                          }),
                                      Text("/${formatDuration(_controller.value.duration)}",
                                          style: TextStyle(color: Colors.white, fontSize: 14.px)),
                                      Spacer(),
                                      InkWell(
                                          onTap: () => Navigator.of(context).push(PageRouteBuilder(
                                              opaque: false,
                                              pageBuilder: (BuildContext context, _, __) =>
                                                  RedeemConfirmationScreen(
                                                      controller: _controller))),
                                          child: Icon(Icons.crop_free, color: Colors.white))
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }),
            ],
          ),
        ));
  }

  Stream<String> generateNumbers(VideoPlayerController controller) async* {
    // String s;
    yield await controller.position.then((value) {
      // String twoDigits(int n) => n;
      String twoDigitMinutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
      String twoDigitSeconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
      return "$twoDigitMinutes:$twoDigitSeconds";
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

class RedeemConfirmationScreen extends StatefulWidget {
  const RedeemConfirmationScreen({
    Key key,
    @required this.controller,
  }) : super(key: key);
  final VideoPlayerController controller;
  @override
  State<RedeemConfirmationScreen> createState() => _RedeemConfirmationScreenState();
}

class _RedeemConfirmationScreenState extends State<RedeemConfirmationScreen> {
  // VideoPlayerController _controller;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    widget.controller.play();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: 100.h,
              width: 100.w,
              child: VideoPlayer(widget.controller),
            ),
            Container(
              height: 100.h,
              width: 100.w,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                          onTap: () => Get.back(),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          )),
                    ),
                  ),
                  Spacer()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
