import 'dart:async';
import 'dart:io';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ihl/new_design/presentation/bindings/initialControllerBindings.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart'; // new Splash Scren
import 'package:ihl/notification_service.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/router.dart' as R;
// import 'package:ihl/views/splash_screen.dart'; // old splash screen
// import 'package:ihl/views/screens.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
// old splash screen
import 'package:sizer/sizer.dart'; // new splash screen

import 'constants/api.dart';
import 'firebase_options.dart';
import 'views/vital_screen.dart';
// new design splash screen
// import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// final facebookAppEvents = FacebookAppEvents();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
///
///
var prescription_progress;
var bill_progress;
var bill_progress_consultation_summary;
var daily_tips, waterReminder;
var news_letter;
var class_created_notification;
Future<void> main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();

  ///notification initialization
  await FlutterDownloader.initialize(debug: true);
  await Hive.initFlutter();
  await Hive.openBox<int>('steps');
  await Permission.camera.request();
  await Permission.microphone.request();
  if (Platform.isAndroid) {
    await Permission.activityRecognition.request();
  } else {
    try {
      await Permission.sensors.request();
    } catch (e) {
      print("Sensor Permission Error");
    }
  }
  //await Permission.sensors.request();
  if (Platform.isAndroid) {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    if (deviceInfo.version.sdkInt <= 32) {
      await Permission.storage.request();
    } else {
      await Permission.photos.request();
      await Permission.videos.request();
    }
  }
  await Permission.notification.request();
  await Permission.audio.request();
  await Permission.mediaLibrary.request();
  // AwesomeNotifications().initialize('', [
  //   NotificationChannel(
  //       icon: null,
  //       channelKey: 'prescription_progress',
  //       channelShowBadge: true,
  //       importance: NotificationImportance.High,
  //       locked: true,
  //       defaultColor: Colors.blueAccent,
  //       ledColor: Colors.red,
  //       defaultPrivacy: NotificationPrivacy.Public,
  //       onlyAlertOnce: true,
  //       enableVibration: false),
  prescription_progress = await initChanelPrescriptionProgress();

  //   NotificationChannel(
  //       icon: null,
  //       channelKey: 'bill_progress',
  //       channelShowBadge: true,
  //       importance: NotificationImportance.High,
  //       locked: true,
  //       defaultColor: Colors.blueAccent,
  //       ledColor: Colors.red,
  //       defaultPrivacy: NotificationPrivacy.Public,
  //       onlyAlertOnce: true,
  //       enableVibration: false),
  bill_progress = await initChannelBillProgress();
  //   NotificationChannel(
  //       icon: null,
  //       channelKey: 'bill_progress_consultation_summary',
  //       channelShowBadge: true,
  //       importance: NotificationImportance.High,
  //       locked: true,
  //       defaultColor: Colors.blueAccent,
  //       ledColor: Colors.red,
  //       defaultPrivacy: NotificationPrivacy.Public,
  //       onlyAlertOnce: true,
  //       enableVibration: false),

  bill_progress_consultation_summary =
      await initChannelBillProgressConsultationSummary();

  //   NotificationChannel(
  //       icon: null,
  //       channelKey: 'daily_tips',
  //       channelShowBadge: true,
  //       importance: NotificationImportance.High,
  //       locked: false,
  //       defaultColor: Colors.blueAccent,
  //       ledColor: Colors.red,
  //       defaultPrivacy: NotificationPrivacy.Public,
  //       onlyAlertOnce: true,
  //       enableVibration: false),

  daily_tips = await initChannelDailyTips();
  waterReminder = await initChannelWaterReminder();
  //   NotificationChannel(
  //       icon: null,
  //       channelKey: 'news_letter',
  //       channelShowBadge: true,
  //       importance: NotificationImportance.High,
  //       locked: false,
  //       defaultColor: Colors.blueAccent,
  //       ledColor: Colors.red,
  //       defaultPrivacy: NotificationPrivacy.Public,
  //       onlyAlertOnce: true,
  //       enableVibration: false),
  news_letter = await initChannelNewsLetter();
  //   NotificationChannel(
  //       icon: null,
  //       channelKey: 'class_created_notification',
  //       channelShowBadge: true,
  //       importance: NotificationImportance.High,
  //       locked: false,
  //       defaultColor: Colors.blueAccent,
  //       ledColor: Colors.red,
  //       defaultPrivacy: NotificationPrivacy.Public,
  //       onlyAlertOnce: true,
  //       enableVibration: false),
  class_created_notification = await initChannelClassCreated();
  //
  // ]);
  HttpOverrides.global =  MyHttpOverrides();
  // await SentryFlutter.init(
  //   (options) {
  //     options.dsn =
  //         'https://62edc19591204b1dab46ae03ee98fbb8@o4505100150505472.ingest.sentry.io/4505101055557632';
  //     options.tracesSampleRate = 1.0;
  //   },
  //   appRunner: () => runApp(App()),
  // );
  runApp(
    App(),
  );
  // SentryFlutter.init(
  //       (options) => {
  //     options.dsn = 'https://3cc762c977a43addb7b29acc20b67b47@o4505984661127168.ingest.sentry.io/4505984666173440',
  //     // To set a uniform sample rate
  //     options.tracesSampleRate = 1.0,
  //     // OR if you prefer, determine traces sample rate based on the sampling context
  //     options.tracesSampler = (samplingContext) {
  //       return 1;
  //       // return a number between 0 and 1 or null (to fallback to configured value)
  //     },
  //   },
  //   appRunner: () => runApp(App()),
  // );

}
final navigatorKey = GlobalKey<NavigatorState>();
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectivityAppWrapper(
      app: ResponsiveSizer(builder: (context, rorientation, rscreenType) {
        return Sizer(builder: (context, sorientation, sscreenType) {
          // new splash screen
          return GetMaterialApp(
              debugShowCheckedModeBanner: API.live ? false : true,
              title: 'hCare',
              navigatorKey: navigatorKey,
              theme: ThemeData(
                primaryColor: AppColors.primaryColor,
                fontFamily: 'Poppins',
                colorScheme: ColorScheme.fromSwatch()
                    .copyWith(secondary: AppColors.primaryColor),

              ),
              initialBinding: InitialBindings(),
              // getPages: getPages, // new splash screen
              /*
                TODO: New Design Splash Screen change import line
                */
              // home: const SplashScreen(), // new splashscreen
              home: SplashScreen(), // old splashscreen
              onGenerateRoute: R.Router.generateRoute,
              routes: {
                // HomeDashBoard.id: (context) => HomeDashBoard(),
                // HomeScreen.id: (context) => HomeScreen(),
                // ForgotPasswordPage.id: (context) => ForgotPassword(),
                VitalScreen.id: (context) => VitalScreen(),
                // ECGGraphScreen.id: (context) => ECGGraphScreen(),
              },
              enableLog: false);
        });
      }),
    );
  }
}
