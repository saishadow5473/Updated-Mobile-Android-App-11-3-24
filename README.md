# IHL
India Health Link Care mobile app
## utils
### constants/api.dart
links to server and sms service 🌏
### constants/cardTheme.dart
colors for all vitals 🎨
### constants/spKeys.dart
contains keys for shared preferences 🔑
### constants/vitalUI.dart
contains all data for vitals like which vital to show, their units,tips,icon path etc 👀
#
### utils/commonUi.dart
Contains colors 🎨
# TODO
### 👀 implement api for all teleconsultation
### 👀 implement api for my files (format according to json)
### 👀 implement date range picking in select class slot
### 👀 implement date of birth tex field in profile screen

## TODO

# MinSDK ver 23-> 21 (Jitsi Plugin)
########################################################################################################

IOS Care live submit(feb7 2022)
- App version 3.0.0
- Build version 2.2.1(6)
++++++++++++++++++++++++++++++++++

# Jitsi meet shows black screen when screen goes to PIP mode in Ios --Solution
########################################################################################################

//Refer this link
https://github.com/gunschu/jitsi_meet/issues/218#issuecomment-796646877
https://github.com/gunschu/jitsi_meet/issues/120#issuecomment-704934715

Inside SwiftJitsiMeetPlugin.swift

change this code ==>
navigationController.modalPresentationStyle = .fullScreen
navigationController.navigationBar.barTintColor = UIColor.black

to this ==>
navigationController.modalPresentationStyle = .overCurrentContext
navigationController.navigationBar.barTintColor = UIColor.clear

Inside JitsiViewController.swift

change this code ==>
self.view.backgroundColor = .black 

to this ==>
self.view.backgroundColor = UIColor.clear
########################################################################################################
*******************************************************************************************************
# Jitsi meet Android12 and to PIP mode On termination not working in Android --Solution
########################################################################################################

//Refer this url for jitsi SDK
https://github.com/jitsi/jitsi-meet-release-notes/blob/master/CHANGELOG-MOBILE-SDKS.md

Inside /Applications/flutter/flutter/.pub-cache/hosted/pub.dartlang.org/jitsi_meet-4.0.0/android/src/main/AndroidManifest.xml

change this code ==>
android:theme="@android:style/Theme.NoTitleBar.Fullscreen"
android:windowSoftInputMode="adjustResize"
android:exported="true"
to this ==>
android:theme="@style/Theme.AppCompat.Light"
android:exported="false"
android:windowSoftInputMode="adjustResize"

Inside /Applications/flutter/flutter/.pub-cache/hosted/pub.dartlang.org/jitsi_meet-4.0.0/android/build.gradle

change this code ==>
implementation ('org.jitsi.react:jitsi-meet-sdk:3.3.0') { transitive = true }
to this ==>
implementation ('org.jitsi.react:jitsi-meet-sdk:3.10.2') { transitive = true }