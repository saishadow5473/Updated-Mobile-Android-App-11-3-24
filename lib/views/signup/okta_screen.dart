import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../repositories/api_register.dart';
import '../../constants/spKeys.dart';
import '../../new_design/data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../new_design/data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';
import '../../new_design/presentation/pages/basicData/functionalities/percentage_calculations.dart';
import '../../new_design/presentation/pages/basicData/models/basic_data.dart';
import '../../new_design/presentation/pages/home/landingPage.dart';
import '../../new_design/presentation/pages/profile/updatePhoto.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/api.dart';
import '../../new_design/app/utils/localStorageKeys.dart';
import '../../new_design/presentation/pages/spalshScreen/splashScreen.dart';
import '../../utils/SpUtil.dart';
import 'okta_login_screen.dart';

class OktaScreen extends StatefulWidget {
  String signInType;
  bool login;
  OktaScreen({Key key, this.signInType, this.login}) : super(key: key);

  @override
  _OktaScreenState createState() => _OktaScreenState();
}

class _OktaScreenState extends State<OktaScreen> {
  InAppWebViewController _webViewController;
  String url = "";
  double progress = 0;
  bool registrationProgress = false;
  // List<String> blockedUrls = ["https://weworkindia.okta.com/app/UserHome"];
  String blockedUrls = "https://weworkindia.okta.com/app/UserHome";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              size: 24.sp,
              color: Colors.black,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(10.sp),
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  // decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                  child: registrationProgress
                      ? Padding(
                          padding: EdgeInsets.only(top: 25.sp, bottom: 15.sp, left: 20.sp),
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.white),
                            width: MediaQuery.of(context).size.width,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Hello.',
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            letterSpacing: .5),
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        'Welcome Onboard',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w300,
                                          fontSize: 17,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 40,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 80.sp,
                                    child: Center(
                                      child: Image.asset(
                                        "assets/gif/onboardingGIF.gif",
                                        height: 60.sp,
                                        width: 60.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 11.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                            scale: 3,
                            image: NetworkImage(
                                // 'https://icon-library.com/images/loading-gif-icon/loading-gif-icon-24.jpg',
                                'https://s3.scoopwhoop.com/anj/loading/594155876.gif'),
                          )),
                          child: InAppWebView(
                            initialUrlRequest: URLRequest(
                                //   url: Uri.parse("https://dev-43973102.okta.com/app/dev-43973102_hcare_1/exkb3kzaoszkiS8pG5d7/sso/saml")
                                // url: Uri.parse('https://weworkindia.okta.com/')
                                // url: Uri.parse('https://weworkindia.okta.com/')
                                // url: Uri.parse(
                                //     'https://weworkindia.okta.com/app/weworkindia_ihltestuat_1/exkb8jq4wpihvtZ9J5d7/sso/saml')
                                url: Uri.parse(
                                    'https://weworkindia.okta.com/app/weworkindia_hcare_1/exkcv28wsmCYQyzro5d7/sso/saml')),
                            initialOptions: InAppWebViewGroupOptions(
                                crossPlatform: InAppWebViewOptions(
                              javaScriptEnabled: true,
                              transparentBackground: true,
                              useShouldOverrideUrlLoading: true,
                            )),
                            onWebViewCreated: (InAppWebViewController controller) {
                              _webViewController = controller;
                            },
                            // onLoadStart: (InAppWebViewController controller, Uri url) async {
                            //   // controller.stopLoading();
                            //   String content = await _webViewController.evaluateJavascript(
                            //       source: 'document.documentElement.outerHTML');
                            //   final SharedPreferences prefs = await SharedPreferences.getInstance();
                            //   doc.Document document = parse(content);

                            //   String email;
                            //   String fullname;
                            //   dynamic id;
                            //   prefs.setString('SignInType', 'okta');
                            //   // SharedPreferencesData().oktaData('email', 'id');

                            //   email = document.querySelector('.user-details--email').innerHtml;
                            //   fullname = document.querySelector('.user-details--fullname').innerHtml;
                            //   id = document.querySelector('span#okta-encryptedUserId').innerHtml;
                            //   print('${'id from callback#########1' + id}e${email}n$fullname');
                            //   registrationProgress = email != null ? true : false;
                            //   // controller.stopLoading();

                            //   setState(() {});

                            //   // if (email != null) {

                            //   //   // await SharedPreferencesData().oktaData(email, id, fullname);
                            //   // }

                            //   // if (email == null) {
                            //   //   try {
                            //   //     const FlutterSecureStorage storage = FlutterSecureStorage();
                            //   //     // await storage.delete(key: 'P1OKTAEMAIL');
                            //   //     // await storage.delete(key: 'P1OKTAID');
                            //   //     var emailLocal = await SharedPreferencesData().oktaDataEmail();
                            //   //     var idLocal = await SharedPreferencesData().oktaDataId();
                            //   //     //check local and curren ids are same
                            //   //     var fullnameLocal = await SharedPreferencesData().oktaDataId();
                            //   //     print(emailLocal);
                            //   //     email = emailLocal;
                            //   //     id = idLocal;
                            //   //     fullname = fullnameLocal;
                            //   //     print(idLocal);
                            //   //   } catch (e) {
                            //   //     print(e);
                            //   //   }
                            //   // }
                            //   String firstName, LastName;
                            //   print('email: $email');
                            //   // const FlutterSecureStorage storage = FlutterSecureStorage();
                            //   // await storage.delete(key: 'P1OKTAEMAIL');
                            //   // await storage.delete(key: 'P1OKTAID');
                            //   // await storage.delete(key: 'P1OKTAFULLNAME');
                            //   if (email != null) {
                            //     if (isEmailValid(email)) {
                            //       if (fullname != null) {
                            //         List a = fullname.split(' ');
                            //         prefs.setString('OktaEmail', email);

                            //         firstName = a[0];
                            //         LastName = a[1] ?? '';

                            //         prefs.setString('OktaEmail', email);
                            //         print('${'id from callback#########2' + id}e${email}n$fullname');
                            //         Get.to(const SSOWaitingScreen());
                            //         await login('', firstName, LastName);
                            //         controller.stopLoading();

                            //         // await register(firstName, LastName);
                            //       }
                            //     }
                            //   } else {
                            //     // prefs.setString('OktaEmail', 'hopethisnamenotbethere@wework.co.in');
                            //     // await login('', 'dinesh', 'kumar');
                            //     // controller.stopLoading();
                            //     // await register('dinesh', 'prit');
                            //     print('${'id from callback#########3' + id}e${email}n$fullname');
                            //     print('invalid ');
                            //     //
                            //   }
                            // },
                            // // onLoadStop: (InAppWebViewController controller, Uri url) async {
                            // //   // controller.stopLoading();
                            // //   String content = await _webViewController.evaluateJavascript(
                            // //       source: 'document.documentElement.outerHTML');
                            // //   final SharedPreferences prefs = await SharedPreferences.getInstance();
                            // //   doc.Document document = parse(content);

                            // //   String email;
                            // //   String fullname;
                            // //   dynamic id;
                            // //   prefs.setString('SignInType', 'okta');
                            // //   // SharedPreferencesData().oktaData('email', 'id');

                            // //   email = document.querySelector('.user-details--email').innerHtml;
                            // //   fullname = document.querySelector('.user-details--fullname').innerHtml;
                            // //   id = document.querySelector('span#okta-encryptedUserId').innerHtml;
                            // //   print('${'id from callback#########1' + id}e${email}n$fullname');
                            // //   // registrationProgress = email != null ? true : false;
                            // //   // controller.stopLoading();

                            // //   setState(() {});

                            // //   // if (email != null) {

                            // //   //   // await SharedPreferencesData().oktaData(email, id, fullname);
                            // //   // }

                            // //   // if (email == null) {
                            // //   //   try {
                            // //   //     const FlutterSecureStorage storage = FlutterSecureStorage();
                            // //   //     // await storage.delete(key: 'P1OKTAEMAIL');
                            // //   //     // await storage.delete(key: 'P1OKTAID');
                            // //   //     var emailLocal = await SharedPreferencesData().oktaDataEmail();
                            // //   //     var idLocal = await SharedPreferencesData().oktaDataId();
                            // //   //     //check local and curren ids are same
                            // //   //     var fullnameLocal = await SharedPreferencesData().oktaDataId();
                            // //   //     print(emailLocal);
                            // //   //     email = emailLocal;
                            // //   //     id = idLocal;
                            // //   //     fullname = fullnameLocal;
                            // //   //     print(idLocal);
                            // //   //   } catch (e) {
                            // //   //     print(e);
                            // //   //   }
                            // //   // }
                            // //   String firstName, LastName;
                            // //   print('email: $email');
                            // //   // const FlutterSecureStorage storage = FlutterSecureStorage();
                            // //   // await storage.delete(key: 'P1OKTAEMAIL');
                            // //   // await storage.delete(key: 'P1OKTAID');
                            // //   // await storage.delete(key: 'P1OKTAFULLNAME');
                            // //   if (email != null) {
                            // //     if (isEmailValid(email)) {
                            // //       if (fullname != null) {
                            // //         List a = fullname.split(' ');
                            // //         prefs.setString('OktaEmail', email);

                            // //         firstName = a[0];
                            // //         LastName = a[1] ?? '';

                            // //         prefs.setString('OktaEmail', email);
                            // //         print('${'id from callback#########2' + id}e${email}n$fullname');
                            // //         // await login('', firstName, LastName);
                            // //         controller.stopLoading();

                            // //         // await register(firstName, LastName);
                            // //       }
                            // //     }
                            // //   } else {
                            // //     // prefs.setString('OktaEmail', 'hopethisnamenotbethere@wework.co.in');
                            // //     // await login('', 'dinesh', 'kumar');
                            // //     // controller.stopLoading();
                            // //     // await register('dinesh', 'prit');
                            // //     print('${'id from callback#########3' + id}e${email}n$fullname');
                            // //     print('invalid ');
                            // //     //
                            // //   }
                            // // },
                            onLoadStart: (InAppWebViewController controller, Uri url) async {
                              // if (url.path == "/app/UserHome") {
                              //   registrationProgress = true;
                              //   setState(() {});
                              //   // Get.to(SSOWaitingScreen());
                              // }
                              // print(url.origin);
                              // String content = await _webViewController.evaluateJavascript(
                              //     source: 'document.documentElement.outerHTML');
                              // // You can access the URL like this

                              // // final SharedPreferences prefs = await SharedPreferences.getInstance();
                              // // doc.Document document = parse(content);
                              // RegExp emailRegex = RegExp(r'userName:(\S+)');
                              // Match match = emailRegex.firstMatch(content);

                              // if (match != null) {
                              //   String email = match.group(1);
                              //   if (email != null) {
                              //     _webViewController.clearCache();
                              //     await Future.delayed(const Duration(seconds: 3), () {
                              //       // Code to execute after a 2-second delay

                              //       Get.back();
                              //       Get.to(const SSOWaitingScreen());
                              //     });
                              //   }
                              // } else {
                              //   print("Email address not found in the response.");
                              // }
                              // String email;
                              // String fullname;
                              // dynamic id;
                              // prefs.setString('SignInType', 'okta');
                              // SharedPreferencesData().oktaData('email', 'id');

                              // email = document.querySelector('.user-details--email').innerHtml;
                              // fullname = document.querySelector('.user-details--fullname').innerHtml;
                              // if (email != null) {
                              //   await login('', fullname, "fullname");
                              // }
                              // id = document.querySelector('span#okta-encryptedUserId').innerHtml;
                              // print('${'id from callback#########1' + id}e${email}n$fullname');
                            },
                            onLoadStop: (InAppWebViewController controller, Uri url) async {
                              // if (url.path == "/app/UserHome") {
                              //   registrationProgress = true;
                              //   setState(() {});
                              // }
                              String content = await _webViewController.evaluateJavascript(
                                  source: 'document.documentElement.outerHTML');
                              // You can access the URL like this
                              // final SharedPreferences prefs = await SharedPreferences.getInstance();
                              // doc.Document document = parse(content);
                              RegExp emailRegex = RegExp(r'email:([\w.]+@[\w.]+)');
                              // RegExp firstNameRegex = RegExp(r'firstName:(\w+)');
                              // RegExp lastNameRegex = RegExp(r'lastName:(\w+)');

                              Match match = emailRegex.firstMatch(content);
                              // Match firstNameMatch = firstNameRegex.firstMatch(content);
                              // Match lastNameMatch = lastNameRegex.firstMatch(content);
                              _webViewController.clearCache();
                              if (match != null) {
                                String email = match.group(1);
                                // String firstName = firstNameMatch.group(1);
                                // String lastName = lastNameMatch.group(2);

                                if (email != null) {
                                  Get.back();
                                  Get.to(OktaLoginScreen(
                                    email: email,
                                    login: widget.login,
                                    signInType: widget.signInType,
                                    content: content,
                                  ));
                                  _webViewController.stopLoading();
                                }
                              } else {
                                print("Email address not found in the response.");
                              }
                              // String email;
                              // String fullname;
                              // dynamic id;
                              // prefs.setString('SignInType', 'okta');
                              // SharedPreferencesData().oktaData('email', 'id');

                              // email = document.querySelector('.user-details--email').innerHtml;
                              // fullname = document.querySelector('.user-details--fullname').innerHtml;
                              // id = document.querySelector('span#okta-encryptedUserId').innerHtml;
                              // print('${'id from callback#########1' + id}e${email}n$fullname');
                            },
                            onProgressChanged:
                                (InAppWebViewController controller, int progress) async {},
                            // shouldOverrideUrlLoading: (InAppWebViewController controller,
                            //     NavigationAction navigationAction) async {
                            //   final String url = navigationAction.request.url.toString();
                            //   print(url);
                            //   // if (url.contains('https://weworkindia.okta.com/app/callback')) {
                            //   //   String content = await _webViewController.evaluateJavascript(
                            //   //       source: 'document.documentElement.outerHTML');
                            //   //   // You can access the URL like this
                            //   //   final SharedPreferences prefs = await SharedPreferences.getInstance();
                            //   //   doc.Document document = parse(content);
                            //   // }
                            //   if (url.contains('$blockedUrls@@@@')) {
                            //     String content = await _webViewController.evaluateJavascript(
                            //         source: 'document.documentElement.outerHTML');
                            //     // You can access the URL like this
                            //     final SharedPreferences prefs = await SharedPreferences.getInstance();
                            //     doc.Document document = parse(content);
                            //     print('here');
                            //     if (mounted) {
                            //       setState(() {
                            //         NavigationActionPolicy.CANCEL;
                            //       });
                            //     }
                            //     return NavigationActionPolicy.CANCEL;
                            //   }
                            //   if (registrationProgress) {
                            //     // This one means do not navigate
                            //     if (mounted) {
                            //       setState(() {
                            //         NavigationActionPolicy.CANCEL;
                            //       });
                            //     }
                            //     return NavigationActionPolicy.CANCEL;
                            //   }

                            //   // This one means navigate
                            //   return NavigationActionPolicy.ALLOW;
                            // },
                            onLoadResource:
                                (InAppWebViewController controller, LoadedResource resource) {},
                          ),
                        ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  bool isEmailValid(String email) {
    // Define a regular expression pattern for a valid email address
    final RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');

    // Use the RegExp class to match the email against the pattern
    return emailRegExp.hasMatch(email);
  }

  Future register(String firstName, String lastName) async {
    String userRegister = await RegisterUserWithPic().registerUser(
        firstName: firstName,
        lastName: lastName,
        email: '',
        password: '',
        // mobileNumber: mobile,
        // gender: gender,
        // dob: dob,
        // height: height,
        // weight: weight,
        // profilepic: img64,
        isSso: true,
        ssoToken: ' ');
    if (userRegister == 'User Registration Failed') {
      Navigator.pop(context);
      AwesomeDialog(
          context: context,
          animType: AnimType.TOPSLIDE,
          headerAnimationLoop: false,
          dialogType: DialogType.ERROR,
          dismissOnTouchOutside: true,
          title: 'Failed!',
          desc: 'Registration failed\nTry Again',
          onDismissCallback: (_) {
            debugPrint('Dialog Dissmiss from callback');
          }).show();

      setState(() {});
    } else {
      //User Registration Success
      registrationProgress = false;
      Get.off(LandingPage());

      setState(() {});
    }
  }

  bool acountExist = true;
  bool userExistR = false;
  bool _userAffliation = false;
  bool _userAccVerify = false;
  final http.Client _client = http.Client();
  var _userId;
  final String _authToken =
      "GHG5118RtDtd7C9AXHa9d/i0WDated53MlFmHgDK4n+8s86uo2s4HMvJkWCbKM5485lCRsBc6uTSlUuuzbWMGsJV3q+PEmAfvoVmjF8bKUgBAA==";
  Future login(String ssoToken, String firstName, String lastName) async {
    registrationProgress = true;
    setState(() {});
    //await oauth.login();
    // if (signInType == 'okta') {
    //   signInType = 'google';
    // }
    String signInType = widget.signInType;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = ssoToken;
    if (widget.login) {
      SpUtil.putString('sso_token', ssoToken);
      final http.Response response1 = await _client.post(
        Uri.parse('${API.iHLUrl}/sso/login_sso_user_account_v1'),
        headers: {'Content-Type': 'application/json', 'ApiToken': ssoToken},
        body: signInType == 'okta'
            ? jsonEncode(<String, String>{
                'sso_token': ssoToken,
                "sso_type": signInType,
                'email': prefs.getString('OktaEmail')
              })
            : jsonEncode(<String, String>{'sso_token': ssoToken, "sso_type": signInType}),
      );
      print(response1.body);

      if (response1.statusCode == 200) {
        var res = jsonDecode(response1.body);
        if (res['response'] == 'user_not_exist') {
          await register(firstName, lastName);
        } else if (response1.body == 'null') {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('data', '');
          Get.back();
        } else if (res['response'] == 'exception') {
          //showMessageNotVerifiedInLogin();
        } else {
          http.Response resp;
          bool loginRes = true;
          if (res['response'] == 'user already has an primary account in this email') {
            _userId = res['id'];
            loginRes = false;
            resp = await _client.post(
              Uri.parse('${API.iHLUrl}/login/get_user_login'),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken':
                    "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA=="
              },
              body: jsonEncode({"id": _userId}),
            );

            print(resp.body);
          }
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          if (loginRes) {
            prefs.setString('data', response1.body);
          } else {
            prefs.setString('data', resp.body.toString());
          }

          prefs.setString(SPKeys.is_sso, "true");

          //prefs.setString('email', email);
          var decodedResponse = loginRes ? jsonDecode(response1.body) : jsonDecode(resp.body);
          prefs.setString('UserIDSso', decodedResponse['User']['id'].toString());
          prefs.setBool('isSSoUser', true);
          String iHLUserToken = decodedResponse['Token'];
          String iHLUserId = decodedResponse['User']['id'];
          localSotrage.write(LSKeys.ihlUserId, iHLUserId);
          String userEmail = decodedResponse['User']['email'];
          prefs.setString('email', userEmail);
          prefs.setString('emailM', userEmail);
          localSotrage.write(LSKeys.email, userEmail);
          bool introDone = decodedResponse['User']['introDone'] ?? false;
          var b64Image = decodedResponse['User']["photo"] ?? AvatarImage.defaultAva;

          if (b64Image != null) {
            // Uint8List imagB64 = await base64Decode(b64Image);
            // localSotrage.write(LSKeys.imageMemory, b64Image);
            SpUtil.putString(LSKeys.imageMemory, b64Image);
            PhotoChangeNotifier.photo.value = b64Image;
            PhotoChangeNotifier.photo.notifyListeners();
          }

          BasicDataModel basicData;
          try {
            basicData = BasicDataModel(
              name:
                  '${decodedResponse['User']['firstName']} ${decodedResponse['User']['lastName']}',
              dob: decodedResponse['User'].containsKey('dateOfBirth')
                  ? decodedResponse['User']['dateOfBirth'].toString()
                  : null,
              gender: decodedResponse['User'].containsKey('gender')
                  ? decodedResponse['User']['gender'].toString()
                  : null,
              height: decodedResponse['User'].containsKey("heightMeters")
                  ? decodedResponse['User']["heightMeters"].toString()
                  : null,
              mobile: decodedResponse['User'].containsKey("mobileNumber")
                  ? decodedResponse['User']['mobileNumber'].toString()
                  : null,
              weight: decodedResponse['User'].containsKey("userInputWeightInKG")
                  ? decodedResponse['User']['userInputWeightInKG'].toString()
                  : null,
            );
            final GetStorage box = GetStorage();

            box.write('BasicData', basicData);
            BasicDataModel b = box.read('BasicData');
            print(b);
            PercentageCalculations().checkHowManyFilled();
            PercentageCalculations().calculatePercentageFilled();
          } catch (e) {
            print(e);
          }
          API.headerr = {};

          prefs.setString('auth_token',
              "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA==");
          API.headerr['Token'] = iHLUserToken;
          API.headerr['ApiToken'] =
              "YpgmeFGsHCMTppFAupJoT/j1VTRzlDln8n96VeEl54b1k7MLmKNjZsWMCY9pd0qi22CT8hGtOHOqqczf+3s8c//3jKtbun57wF6jWADNUeQBAA==";
          print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${API.headerr}");
          //  localSotrage.write(LSKeys.logged, true);
          try {
            if (loginRes) {
              await MyvitalsApi().vitalDatas(json.decode(response1.body));
            } else {
              await MyvitalsApi().vitalDatas(json.decode(resp.body));
            }
          } catch (e) {
            print(e);
          }

          SharedPreferences prefs1 = await SharedPreferences.getInstance();
          prefs1.setString("ihlUserId", iHLUserId);
          final http.Response getPlatformData = await _client.post(
            Uri.parse("${API.iHLUrl}/consult/GetPlatfromData"),
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
            },
            body: jsonEncode(<String, dynamic>{"ihl_id": iHLUserId, 'cache': "true"}),
          );
          if (getPlatformData.statusCode == 200) {
            final SharedPreferences platformData = await SharedPreferences.getInstance();
            platformData.setString(SPKeys.platformData, getPlatformData.body);
          }
          final http.Response vitalData = await _client.get(
            Uri.parse('${API.iHLUrl}/data/user/$iHLUserId/checkin'),
            headers: {
              'Content-Type': 'application/json',
              'Token': iHLUserToken,
              'ApiToken': _authToken
            },
          );
          Map<String, dynamic> userAffiliationDetail;

          // Object userData = prefs.get(SPKeys.userData);
          dynamic dat = loginRes ? response1.body : resp.body;
          print(dat);
          Map userDecodeData;
          try {
            userDecodeData = jsonDecode(dat);
          } catch (e) {
            print(e);
            print(prefs.get(SPKeys.email));
            print(prefs.get(SPKeys.email));
          }

          final http.Response affiliationDetails = await _client.post(
            Uri.parse("${API.iHLUrl}/sso/affiliation_details"),
            body: jsonEncode(<String, String>{'email': prefs.get(SPKeys.email)}),
          );
          if (affiliationDetails.statusCode == 200) {
            var tokenParse = jsonDecode(affiliationDetails.body);
            userAffiliationDetail = {
              "company_name": tokenParse['response']['company_name'],
              "affiliation_unique_name": tokenParse['response']['affiliation_unique_name']
            };
          }

          http.Response userAffiliationDetailCheck = await _client.post(
              Uri.parse(
                '${API.iHLUrl}/login/get_user_login',
              ),
              body: jsonEncode(
                <String, dynamic>{
                  "id": iHLUserId,
                },
              ),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken':
                    '69/G9PN0M1Y/ZxC9LMG4c+2qFCg+6Qfye8ci7XV53egWzXaBapR3LAVWzBX5+js5Q/Oy4CDOR/x24C/6gT5N/G98x8xd4GtBmbWNRE1YF1cBAA==',
              });
          if (userAffiliationDetailCheck.statusCode == 200) {
            var finalResponse = json.decode(userAffiliationDetailCheck.body);
            final vitalDatas = await SplashScreenApiCalls()
                .checkinData(ihlUID: iHLUserId, ihlUserToken: iHLUserToken);
            prefs1.setString(SPKeys.vitalsData, vitalDatas);
            try {
              await MyvitalsApi().vitalDatas(finalResponse);
            } catch (e) {
              print(e);
            }

            if (iHLUserId == finalResponse['User']['id']) {
              API.headerr['ApiToken'] =
                  '32iYJ+Lw/duU/2jiMHf8vQcmtD4SxpuKcwt7n/ej5dgvZPUgvHaYQHPRW3nh+GT+N9bfMEK5fofdt9AfA6T9S3BnDHVe0FvUYuPmnMO0WGQBAA==';
              API.headerr['Token'] = finalResponse['Token'];
              _userAccVerify = true;
              Map userMap = finalResponse['User'];
              bool affiliationAdded = false;
              if (userMap.containsKey('user_affiliate')) {
                Map userMapAffiliate = finalResponse['User']['user_affiliate'];

                for (int count = 1; count <= 9; count++) {
                  if (userMapAffiliate.containsKey('af_no$count')) {
                    var affiliateData = userMapAffiliate['af_no$count'];

                    if (affiliateData['affilate_unique_name'] == null ||
                        affiliateData['affilate_unique_name'] == '' &&
                            affiliateData['affilate_name'] == null ||
                        affiliateData['affilate_name'] == '') {
                      http.Response updateProfile;
                      try {
                        updateProfile =
                            await _client.post(Uri.parse('${API.iHLUrl}/data/user/$iHLUserId'),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'ApiToken': API.headerr['ApiToken'],
                                  'Token': API.headerr['Token']
                                },
                                body: jsonEncode(<String, dynamic>{
                                  "id": iHLUserId,
                                  "user_affiliate": {
                                    "af_no$count": {
                                      "affilate_unique_name":
                                          userAffiliationDetail['affiliation_unique_name'],
                                      "affilate_name": userAffiliationDetail['company_name'],
                                      "affilate_email": prefs.get(SPKeys.email),
                                      "affilate_mobile": userDecodeData['User']['mobileNumber'],
                                      "affliate_identifier_id": "",
                                      "is_sso": true,
                                    }
                                  }
                                }));
                      } catch (e) {
                        print(e);
                      }

                      print(updateProfile.body);

                      if (updateProfile.statusCode == 200) {
                        final http.Response ssoCount = await _client.post(
                            Uri.parse('${API.iHLUrl}/sso/affiliation_bulk_update'),
                            headers: {
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode(<String, dynamic>{
                              "email": prefs.get(SPKeys.email),
                              "affiliation_unique_name":
                                  userAffiliationDetail['affiliation_unique_name'],
                              "mobileNumber": userDecodeData['User']['mobileNumber'],
                              "company_name": userAffiliationDetail['company_name'],
                              "firstName": userDecodeData['User']['firstName'],
                              "lastName": userDecodeData['User']['lastName'],
                              "ihl_user_id": iHLUserId,
                            }));
                        if (ssoCount.statusCode == 200) {
                          print('Count Added');
                        }
                        _userAffliation = true;

                        break;
                      } else {
                        _userAffliation = true;
                      }
                    } else {
                      if (affiliateData['affilate_unique_name'] ==
                              userAffiliationDetail['affiliation_unique_name'] &&
                          affiliateData['affilate_name'] == userAffiliationDetail['company_name']) {
                        if (affiliateData['affilate_email'] == prefs.get(SPKeys.email) &&
                            affiliateData['is_sso'] == true) {
                          break;
                        } else {
                          final http.Response updateProfile =
                              await _client.post(Uri.parse('${API.iHLUrl}/data/user/$iHLUserId'),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'ApiToken': API.headerr['ApiToken'],
                                    'Token': API.headerr['Token']
                                  },
                                  body: jsonEncode(<String, dynamic>{
                                    "id": iHLUserId,
                                    "user_affiliate": {
                                      "af_no$count": {
                                        "affilate_unique_name":
                                            userAffiliationDetail['affiliation_unique_name'],
                                        "affilate_name": userAffiliationDetail['company_name'],
                                        "affilate_email": prefs.get(SPKeys.email),
                                        "affilate_mobile": userDecodeData['User']['mobileNumber'],
                                        "affliate_identifier_id": "",
                                        "is_sso": true,
                                      }
                                    }
                                  }));
                          print(updateProfile.body);

                          if (updateProfile.statusCode == 200) {
                            final http.Response ssoCount = await _client.post(
                                Uri.parse('${API.iHLUrl}/sso/affiliation_bulk_update'),
                                headers: {
                                  'Content-Type': 'application/json',
                                },
                                body: jsonEncode(<String, dynamic>{
                                  "email": prefs.get(SPKeys.email),
                                  "affiliation_unique_name":
                                      userAffiliationDetail['affiliation_unique_name'],
                                  "mobileNumber": userDecodeData['User']['mobileNumber'],
                                  "company_name": userAffiliationDetail['company_name'],
                                  "firstName": userDecodeData['User']['firstName'],
                                  "lastName": userDecodeData['User']['lastName'],
                                  "ihl_user_id": iHLUserId,
                                }));
                            if (ssoCount.statusCode == 200) {
                              print('Count Added');
                            }
                            _userAffliation = true;

                            break;
                          } else {
                            _userAffliation = true;
                          }
                        }
                        print('Same');
                        break;
                      }
                    }
                  } else {
                    if (affiliationAdded == false) {
                      final http.Response updateProfile =
                          await _client.post(Uri.parse('${API.iHLUrl}/data/user/$iHLUserId'),
                              headers: {
                                'Content-Type': 'application/json',
                                'ApiToken': API.headerr['ApiToken'],
                                'Token': API.headerr['Token']
                              },
                              body: jsonEncode(<String, dynamic>{
                                "id": iHLUserId,
                                "user_affiliate": {
                                  "af_no$count": {
                                    "affilate_unique_name":
                                        userAffiliationDetail['affiliation_unique_name'],
                                    "affilate_name": userAffiliationDetail['company_name'],
                                    "affilate_email": prefs.get(SPKeys.email),
                                    "affilate_mobile": userDecodeData['User']['mobileNumber'],
                                    "affliate_identifier_id": "",
                                    "is_sso": true,
                                  }
                                }
                              }));
                      print(updateProfile.body);

                      if (updateProfile.statusCode == 200) {
                        final http.Response ssoCount = await _client.post(
                            Uri.parse('${API.iHLUrl}/sso/affiliation_bulk_update'),
                            headers: {
                              'Content-Type': 'application/json',
                            },
                            body: jsonEncode(<String, dynamic>{
                              "email": prefs.get(SPKeys.email),
                              "affiliation_unique_name":
                                  userAffiliationDetail['affiliation_unique_name'],
                              "mobileNumber": userDecodeData['User']['mobileNumber'],
                              "company_name": userAffiliationDetail['company_name'],
                              "firstName": userDecodeData['User']['firstName'],
                              "lastName": userDecodeData['User']['lastName'],
                              "ihl_user_id": iHLUserId,
                            }));
                        if (ssoCount.statusCode == 200) {
                          print('Count Added');
                        }
                        affiliationAdded = true;

                        print(updateProfile.body);
                        _userAffliation = true;
                      } else {
                        _userAffliation = true;
                      }
                    }
                    break;
                  }
                }
                print(userMap);
                SpUtil.putString(LSKeys.userDetail, userAffiliationDetailCheck.body);
                print('Already');
              } else {
                final http.Response updateProfile =
                    await _client.post(Uri.parse('${API.iHLUrl}/data/user/$iHLUserId'),
                        headers: {
                          'Content-Type': 'application/json',
                          'ApiToken': API.headerr['ApiToken'],
                          'Token': API.headerr['Token']
                        },
                        body: jsonEncode(<String, dynamic>{
                          "id": iHLUserId,
                          "user_affiliate": {
                            "af_no1": {
                              "affilate_unique_name":
                                  userAffiliationDetail['affiliation_unique_name'],
                              "affilate_name": userAffiliationDetail['company_name'],
                              "affilate_email": prefs.get(SPKeys.email),
                              "affilate_mobile": userDecodeData['User']['mobileNumber'],
                              "affliate_identifier_id": "",
                              "is_sso": true,
                            }
                          }
                        }));
                print(updateProfile.body);

                if (updateProfile.statusCode == 200) {
                  final http.Response ssoCount =
                      await _client.post(Uri.parse('${API.iHLUrl}/sso/affiliation_bulk_update'),
                          headers: {
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode(<String, dynamic>{
                            "email": prefs.get(SPKeys.email),
                            "affiliation_unique_name":
                                userAffiliationDetail['affiliation_unique_name'],
                            "mobileNumber": userDecodeData['User']['mobileNumber'],
                            "company_name": userAffiliationDetail['company_name'],
                            "firstName": userDecodeData['User']['firstName'],
                            "lastName": userDecodeData['User']['lastName'],
                            "ihl_user_id": iHLUserId,
                          }));
                  if (ssoCount.statusCode == 200) {
                    print('Count Added');
                  }
                  affiliationAdded = true;

                  print(updateProfile.body);
                  _userAffliation = true;
                } else {
                  _userAffliation = true;
                }
              }
            } else {
              _userAccVerify = false;
            }
          } else {
            _userAccVerify = false;
          }

          if (vitalData.statusCode == 200) {
            final SharedPreferences sharedUserVitalData = await SharedPreferences.getInstance();
            sharedUserVitalData.setString(SPKeys.vitalsData, vitalData.body);

            prefs.setString('disclaimer', 'no');
            prefs.setString('refund', 'no');
            prefs.setString('terms', 'no');
            prefs.setString('grievance', 'no');
            prefs.setString('privacy', 'no');
          }
          if (mounted) {
            setState(() {
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => HomeScreen(
              //               introDone: introDone,
              //             )),
              //     (Route<dynamic> route) => false);
              registrationProgress = false;
              Get.offAll(LandingPage());
            });
          }
        }
      }
    } else {
      final http.Response response = await _client.post(
        Uri.parse('${API.iHLUrl}/sso/sso_user_details'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {"sso_token": accessToken, "sso_type": signInType == 'okta' ? 'google' : signInType}),
      );
      // if (signInType == 'okta') {
      //   showMessageVerified();
      // }
      print(response.body);
      if (response.statusCode == 200) {
        var finalresponce = jsonDecode(response.body);
        var outResponce = finalresponce['response']['ihl_account_status'];
        if (outResponce == "emailNotExist") {
          //emailNotExist
          SpUtil.putString(SPKeys.sso_token, accessToken);
          SpUtil.putString(SPKeys.email, finalresponce['response']['email']);
          SpUtil.putString(SPKeys.signInType, signInType);
        } else if (outResponce == "emailExist") {
          setState(() {
            userExistR = true;
          });
        } else {
          registrationProgress = false;
          print('Not verified');
        }
      }
    }
    registrationProgress = false;
  }
}
