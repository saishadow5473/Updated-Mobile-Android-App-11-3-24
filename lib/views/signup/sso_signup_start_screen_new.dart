import 'dart:convert';
import 'dart:developer';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'sso_login_loading_screen.dart';
import 'sso_waiting_screen.dart';
import 'okta_screen.dart';
import '../../new_design/data/providers/network/apis/get_affiliation_details.dart';
import '../../new_design/presentation/pages/profile/updatePhoto.dart';
import '../../new_design/presentation/Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../new_design/presentation/pages/basicData/functionalities/percentage_calculations.dart';
import '../../new_design/presentation/pages/basicData/models/basic_data.dart';
import 'signup_name_sso.dart';

import '../../new_design/presentation/pages/home/landingPage.dart';
import '../../widgets/signin_email.dart';
import '../../widgets/ssoLoginChange.dart';
import '../../constants/api.dart';
import '../../constants/routes.dart';
import '../../constants/spKeys.dart';
import '../../new_design/app/utils/localStorageKeys.dart';
import '../../new_design/presentation/pages/spalshScreen/splashScreen.dart';
import '../../repositories/api_register.dart';
import '../../utils/SpUtil.dart';
import '../../utils/app_colors.dart';
import '../../utils/screenutil.dart';
import '../../utils/sizeConfig.dart';
import 'signup_alternate_email.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../new_design/data/providers/network/apis/myVitalsApi/myVitalsApi.dart';
import '../../new_design/data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';

bool ssoSignup = false;

class SsoStartScreenNew extends StatefulWidget {
  final bool login;

  const SsoStartScreenNew({Key key, @required this.login}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SsoStartScreenNewState();
}

class _SsoStartScreenNewState extends State<SsoStartScreenNew> {
  final String _authToken =
      "GHG5118RtDtd7C9AXHa9d/i0WDated53MlFmHgDK4n+8s86uo2s4HMvJkWCbKM5485lCRsBc6uTSlUuuzbWMGsJV3q+PEmAfvoVmjF8bKUgBAA==";
  bool isEntered = true;
  bool isChecking = false;
  var _userId;
  bool _ssoLogin = false, _userAccVerify = false, _userAffliation = false;
  String image = ''; // bool isCheckingSso = false;
  final TextEditingController _typeAheadController = TextEditingController();
  String affiUniqName;
  final SuggestionsBoxController _suggsController = SuggestionsBoxController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode typeAheadFocus = FocusNode();
  bool userExistR = false;
  final http.Client _client = http.Client(); //3gb
  GoogleSignInAccount _currentUser;
  final String _contactText = '';
  var _googleSignIn;
  var oauth;
  var microSoftUserDetails;
  var microSoftUserProfilePic;
  String signInType = "";
  String companyName = "";
  bool isFetching = false;

  bool hasOppend = false;
  TextEditingController searchController = TextEditingController();
  List matchAff = [];

  @override
  void initState() {
    super.initState();

    // _googleSignIn = GoogleSignIn(
    //   // Optional clientId
    //   //hostedDomain: 'indiahealthlink.com',
    //   //clientId: '409462954494-6ua123qfc2gspofj2hmeb69gm2a6d6g1.apps.googleusercontent.com',
    //   scopes: <String>[
    //     'email',
    //     'https://www.googleapis.com/auth/userinfo.email',
    //     'https://www.googleapis.com/auth/userinfo.profile'
    //   ],
    // );
    // _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
    //   setState(() {
    //     _currentUser = account;
    //   });
    //   if (isEntered != true) {
    //     login_init();
    //   } else {
    //     _googleSignIn.disconnect();
    //   }
    // });
    //########## This Part is for SSO
    final Config config = Config(
      tenant: 'common',
      clientId: 'e61ccb73-be25-4f31-a708-0156bd0dda6d',
      scope: 'User.Read',
      redirectUri: 'https://dashboard.indiahealthlink.com/ssoload/',
      navigatorKey: navigatorKey,
    );
    oauth = AadOAuth(config);
    callAffiliate();
    //_googleSignIn.signInSilently();
  }

  callAffiliate() async {
    matchAff = await GetAffiliationDetails().affiliationDetailsGetter();
    print(matchAff);
  }

  Future<void> _handleMicrosoftSignIn() async {
    hasOppend = true;
    setState(() {
      isFetching = true;
    });
    try {
      await oauth.logout();
      await oauth.login();
      var token = await oauth.getAccessToken();
      token = await getMicrosoftAccountDetail(token);
      await login(token);
    } catch (e) {
      setState(() {
        isFetching = false;
      });
      showMessageNotVerified();
    }
  }

  Future<void> _handleMicrosoftSignOut() async {
    await oauth.logout();
    setState(() {
      microSoftUserDetails = null;
    });
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (e) {
      print(e);
      setState(() {
        isFetching = false;
      });

      showMessageNotVerified();
    }
  }

  Future<void> _handleoktaSignIn() async {
    try {} catch (e) {}
  }

  Future signInWithGoogle({BuildContext context}) async {
    hasOppend = true;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    setState(() => isFetching = true);
    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      showMessageNotVerified();
    }

    FirebaseAuth auth = FirebaseAuth.instance;
    User user;
    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential = await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
        setState(() {
          isFetching = false;
        });

        showMessageNotVerified();
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        _currentUser = googleSignInAccount;
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential = await auth.signInWithCredential(credential);
          if (userCredential.user.toString().contains("wework.co.in") && signInType == "okta") {
            user = userCredential.user;
            print(user.email);
            List a = user.displayName.split(' ');
            var firstName = a[0];
            var LastName = a[1] ?? ' ';
            SpUtil.putString('fname', firstName);
            SpUtil.putString('lname', LastName);
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('OktaEmail', user.email.toString());
          }
          if (signInType == "okta") {
            showMessageOctaNotVerified();
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            showMessageNotVerified();
          } else if (e.code == 'invalid-credential') {
            showMessageNotVerified();
          }
        } catch (e) {
          print(e);
          setState(() {
            isFetching = false;
          });

          showMessageNotVerified();
        }
      }
    }
    setState(() {
      _currentUser = _currentUser;
    });
    login_init(_currentUser);
    //return user;
  }

  Future signOutGoogle({BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      showMessageNotVerified();
    }
  }

  login_init(userValue) async {
    if (userValue != null) {
      final GoogleSignInAccount userData = userValue;
      GoogleSignInAuthentication ad = await userData.authentication;
      String token = ad.idToken;
      await login(token);
      if (_ssoLogin) {
        Get.to(
          SignupAlternateEmailSso(
            loginSso: true,
            userId: _userId,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    final GoogleSignInAccount user = _currentUser;
    if (signInType == "okta") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SizedBox(
            height: ScUtil().setHeight(10),
          ),
          SizedBox(
            height: ScUtil().setHeight(40),
          ),
          GestureDetector(
            onTap: () {
              Get.to(OktaScreen(
                login: widget.login,
                signInType: signInType,
              ));
            },
            child: Container(
              height: 6.8.h,
              width: 65.w,
              decoration: BoxDecoration(
                  color: const Color(0xFF19a9e5), borderRadius: BorderRadius.circular(8)),
              child: const Center(
                child: Text(
                  'PROCEED',
                  style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.normal,
                      height: 1),
                ),
              ),
            ),
          )
        ],
      );
    }
    if (signInType == "") {
      return const SizedBox(); //Text("Not Found");
    } else if (signInType == "google") {
      if (user != null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Visibility(
              visible: isFetching,
              child: const ListTile(
                title: LinearProgressIndicator(
                  semanticsLabel: 'Loading...',
                ),
              ),
            ),

            // ListTile(
            //   leading: ClipRRect(
            //       borderRadius: BorderRadius.circular(50.0),
            //       child: Image.network(user.photoUrl)),
            //   title: Text(user.displayName ?? ''),
            //   subtitle: Text(user.email),
            // ),
            // const Text('Signed in successfully.'),
            SizedBox(
              height: ScUtil().setHeight(15),
            ),
            ElevatedButton.icon(
              onPressed: isFetching ? null : signInWithGoogle,
              icon: const Icon(Icons.change_circle_outlined),
              label: Text('Try again',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      fontFamily: 'Poppins',
                      fontSize: ScUtil().setSp(16),
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.normal,
                      height: 1)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF19a9e5),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle: TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.bold)),
            ),

            // ElevatedButton(
            //   child: const Text('REFRESH'),
            //   onPressed: () => _handleGetContact(user),
            // ),
          ],
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
              height: ScUtil().setHeight(10),
            ),
            // Text('You are not currently signed in.',
            //     textAlign: TextAlign.center,
            //     style: TextStyle(
            //         color: Colors.black54,
            //         fontFamily: 'Poppins',
            //         fontSize: ScUtil().setSp(16),
            //         letterSpacing: 0.2,
            //         fontWeight: FontWeight.normal,
            //         height: 1)),
            SizedBox(
              height: ScUtil().setHeight(40),
            ),
            GestureDetector(
              onTap: isFetching ? null : signInWithGoogle,
              //onPressed: _handleGoogleSignIn,
              // icon: Image.asset(
              //   'assets/images/google.png',
              //   height: ScUtil().setHeight(20),
              //   width: ScUtil().setWidth(25),
              //   fit: BoxFit.cover,
              // ),
              // label: Text('Sign in using google',
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //         color: const Color.fromRGBO(255, 255, 255, 1),
              //         fontFamily: 'Poppins',
              //         fontSize: ScUtil().setSp(16),
              //         letterSpacing: 0.2,
              //         fontWeight: FontWeight.normal,
              //         height: 1)),
              child: Container(
                height: 5.5.h,
                width: 65.w,
                decoration: BoxDecoration(
                    color: const Color(0xFF19a9e5), borderRadius: BorderRadius.circular(5)),
                child: const Center(
                  child: Text(
                    'PROCEED',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              // style: ElevatedButton.styleFrom(
              //     backgroundColor: const Color(0xFF19a9e5),
              //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              //     textStyle: TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    }
    //  else if (signInType == "okta") {
    //   if (user != null) {
    //     return Column(
    //       mainAxisAlignment: MainAxisAlignment.spaceAround,
    //       children: <Widget>[
    //         Visibility(
    //           visible: isFetching,
    //           child: const ListTile(
    //             title: LinearProgressIndicator(
    //               semanticsLabel: 'Loading...',
    //             ),
    //           ),
    //         ),

    //         // ListTile(
    //         //   leading: ClipRRect(
    //         //       borderRadius: BorderRadius.circular(50.0),
    //         //       child: Image.network(user.photoUrl)),
    //         //   title: Text(user.displayName ?? ''),
    //         //   subtitle: Text(user.email),
    //         // ),
    //         // const Text('Signed in successfully.'),
    //         SizedBox(
    //           height: ScUtil().setHeight(15),
    //         ),
    //         ElevatedButton.icon(
    //           onPressed: isFetching ? null : signInWithGoogle,
    //           icon: const Icon(Icons.change_circle_outlined),
    //           label: Text('Try again',
    //               textAlign: TextAlign.center,
    //               style: TextStyle(
    //                   color: const Color.fromRGBO(255, 255, 255, 1),
    //                   fontFamily: 'Poppins',
    //                   fontSize: ScUtil().setSp(16),
    //                   letterSpacing: 0.2,
    //                   fontWeight: FontWeight.normal,
    //                   height: 1)),
    //           style: ElevatedButton.styleFrom(
    //               backgroundColor: const Color(0xFF19a9e5),
    //               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    //               textStyle: TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.bold)),
    //         ),

    //         // ElevatedButton(
    //         //   child: const Text('REFRESH'),
    //         //   onPressed: () => _handleGetContact(user),
    //         // ),
    //       ],
    //     );
    //   } else {
    //     return Column(
    //       mainAxisAlignment: MainAxisAlignment.spaceAround,
    //       children: <Widget>[
    //         SizedBox(
    //           height: ScUtil().setHeight(10),
    //         ),
    //         // Text('You are not currently signed in.',
    //         //     textAlign: TextAlign.center,
    //         //     style: TextStyle(
    //         //         color: Colors.black54,
    //         //         fontFamily: 'Poppins',
    //         //         fontSize: ScUtil().setSp(16),
    //         //         letterSpacing: 0.2,
    //         //         fontWeight: FontWeight.normal,
    //         //         height: 1)),
    //         SizedBox(
    //           height: ScUtil().setHeight(40),
    //         ),
    //         GestureDetector(
    //           onTap: signInWithGoogle,
    //           //onPressed: _handleGoogleSignIn,
    //           // icon: Image.asset(
    //           //   'assets/images/google.png',
    //           //   height: ScUtil().setHeight(20),
    //           //   width: ScUtil().setWidth(25),
    //           //   fit: BoxFit.cover,
    //           // ),
    //           // label: Text('Sign in using google',
    //           //     textAlign: TextAlign.center,
    //           //     style: TextStyle(
    //           //         color: const Color.fromRGBO(255, 255, 255, 1),
    //           //         fontFamily: 'Poppins',
    //           //         fontSize: ScUtil().setSp(16),
    //           //         letterSpacing: 0.2,
    //           //         fontWeight: FontWeight.normal,
    //           //         height: 1)),
    //           child: Container(
    //             height: 5.5.h,
    //             width: 65.w,
    //             decoration: BoxDecoration(
    //                 color: const Color(0xFF19a9e5), borderRadius: BorderRadius.circular(5)),
    //             child: const Center(
    //               child: Text(
    //                 'PROCEED',
    //                 style: TextStyle(color: Colors.white),
    //               ),
    //             ),
    //           ),
    //           // style: ElevatedButton.styleFrom(
    //           //     backgroundColor: const Color(0xFF19a9e5),
    //           //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    //           //     textStyle: TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.bold)),
    //         )
    //       ],
    //     );
    //   }
    // }
    else if (signInType == "microsoft") {
      if (microSoftUserDetails == null || microSoftUserDetails == "") {
        return isFetching
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(
                    height: ScUtil().setHeight(10),
                  ),
                  // Text('You are not currently signed in.',
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //         color: Colors.black54,
                  //         fontFamily: 'Poppins',
                  //         fontSize: ScUtil().setSp(16),
                  //         letterSpacing: 0.2,
                  //         fontWeight: FontWeight.normal,
                  //         height: 1)),
                  SizedBox(
                    height: ScUtil().setHeight(20),
                  ),
                  GestureDetector(
                    onTap: _handleMicrosoftSignIn,
                    child: Container(
                      height: 5.h,
                      width: 65.w,
                      decoration: BoxDecoration(
                          color: const Color(0xFF19a9e5), borderRadius: BorderRadius.circular(5)),
                      child: const Center(
                        child: Text(
                          'PROCEED',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    // icon: Image.asset(
                    //   'assets/images/microsoft.png',
                    //   height: ScUtil().setHeight(20),
                    //   width: ScUtil().setWidth(20),
                    //   fit: BoxFit.cover,
                    // ),
                    // label: Text('Sign in using microsoft',
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //         color: const Color.fromRGBO(255, 255, 255, 1),
                    //         fontFamily: 'Poppins',
                    //         fontSize: ScUtil().setSp(16),
                    //         letterSpacing: 0.2,
                    //         fontWeight: FontWeight.normal,
                    //         height: 1)),
                    // style: ElevatedButton.styleFrom(
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10), // <-- Radius
                    //     ),
                    //     backgroundColor: const Color(0xFF19a9e5),
                    //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    //     textStyle:
                    //         TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.bold)),
                  )
                ],
              );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // ListTile(
            //   leading: microSoftUserProfilePic != null
            //       ? ClipRRect(
            //           borderRadius: BorderRadius.circular(50.0),
            //           child: Image.memory(microSoftUserProfilePic))
            //       : const Icon(
            //           Icons.account_circle_sharp,
            //           size: 50,
            //         ),
            //   title: Text(microSoftUserDetails['givenName'] ?? ''),
            //   subtitle: Text(microSoftUserDetails['userPrincipalName'] ?? ''),
            // ),
            //const Text('Signed in successfully.'),
            SizedBox(
              height: ScUtil().setHeight(18),
            ),
            isFetching
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton.icon(
                    onPressed: _handleMicrosoftSignOut,
                    icon: const Icon(Icons.change_circle_outlined),
                    label: Text('Try again',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color.fromRGBO(255, 255, 255, 1),
                            fontFamily: 'Poppins',
                            fontSize: ScUtil().setSp(16),
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.normal,
                            height: 1)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF19a9e5),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        textStyle:
                            TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.bold)),
                  ),
            // ElevatedButton(
            //   child: const Text('REFRESH'),
            //   onPressed: () => _handleGetContact(user),
            // ),
          ],
        );
      }
    } else {
      return const SizedBox();
    }
  }

  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (isFetching && (hasOppend == false)) {
            Navigator.of(context).pushNamed(Routes.Welcome, arguments: false);
          }
          return true;
          // isFetching ? null :
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 1 * SizeConfig.heightMultiplier,
            ),
            Container(
              padding: EdgeInsets.only(left: 9.sp, right: 9.sp),
              child: TextFormField(
                // enabled: !suggestionSelected,
                controller: _typeAheadController,
                onChanged: (String query) async {
                  matche.clear();
                  // if (_typeAheadController.text == '') {
                  //   image = '';
                  // }
                  if (_typeAheadController.text != '') {
                    await getSuggestions(query);
                  }
                },
                decoration: InputDecoration(
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryAccentColor,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primaryAccentColor,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: _typeAheadController.text == ''
                        ? const Text('')
                        : Image.network(image, width: 8.w, height: 8.h, errorBuilder:
                            (BuildContext context, Object error, StackTrace stackTrace) {
                            // Handle the error here and display a placeholder or error message
                            return const Text('');
                          }),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: 'Select your organisation',
                  // suffixIcon: Icon(
                  //   Icons.keyboard_arrow_down_sharp,
                  //   size: 36,
                  //   color: AppColors.primaryColor,
                  // )
                ),
              ),
            ),
            Visibility(
              visible: (suggestionsAreCreated != null && suggestionsAreCreated == false),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No Results Found',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.appTextColor, fontSize: 18.0),
                    ),
                    SizedBox(
                      height: 8 * SizeConfig.heightMultiplier,
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: !suggestionSelected && matche.isNotEmpty,
              child: Padding(
                padding: EdgeInsets.only(left: 9.sp, right: 9.sp),
                child: Container(
                  height: 25.h,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Scrollbar(
                    controller: scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            // [
                            matche
                                .map((Map<String, dynamic> e) => Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: InkWell(
                                        onTap: () async {
                                          _typeAheadController.text =
                                              e['company_name'] == "Wework Member"
                                                  ? '${e['company_name']} India'
                                                  : '${e['company_name']}';
                                          FocusScope.of(context).unfocus();
                                          try {
                                            affiUniqName = e["affiliation_unique_name"];

                                            UpdatingColorsBasedOnAffiliations.ssoAffiliation = {
                                              "affiliation_unique_name": affiUniqName,
                                            };
                                            UpdatingColorsBasedOnAffiliations.companyName = {
                                              "company_name": e['company_name']
                                            };
                                            final SharedPreferences prefs =
                                                await SharedPreferences.getInstance();
                                            prefs.setString('okta_unique_name', affiUniqName);
                                            prefs.setString('okta_company_name', e['company_name']);
                                            signInType = e['sign_in_option'];
                                            gType = signInType;
                                            companyName = e['company_name'];
                                            isEntered = false;
                                            suggestionSelected = true;

                                            if (mounted) setState(() {});
                                          } catch (e) {
                                            print(e);
                                          }
                                          matche.clear();
                                        },
                                        child: ListTile(
                                          title: e['company_name'] == "Wework Member"
                                              ? Text('${e['company_name']} India')
                                              : Text('${e['company_name']}'),
                                          // subtitle: Text(
                                          //     '${suggestion['sign_in_option'] != "" ? suggestion['sign_in_option'] : '-'}'),
                                          leading: Image.network(
                                            "${e['logo_url']}",
                                            width: 13.5.w,
                                            errorBuilder: (BuildContext context, Object error,
                                                StackTrace stackTrace) {
                                              // Handle the error here and display a placeholder or error message
                                              return SizedBox(
                                                width: 13.5.w,
                                                child: Image.asset(
                                                  'assets/icons/organization_icon.png',
                                                  height: 50.h,
                                                ),
                                              );
                                            },
                                            //color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                        // ListView.builder(
                        //   itemCount: matches.length,
                        //   itemBuilder: (context, index) {
                        //     return Padding(
                        //       padding: const EdgeInsets.all(20.0),
                        //       child: ListTile(
                        //         title: Text(matches[index]['company_name']),
                        //         // subtitle: Text(
                        //         //     '${suggestion['sign_in_option'] != "" ? suggestion['sign_in_option'] : '-'}'),
                        //         leading: Icon(
                        //           matches[index]['sign_in_option'] == "microsoft"
                        //               ? FontAwesomeIcons.microsoft
                        //               : matches[index]['sign_in_option'] == "google"
                        //                   ? FontAwesomeIcons.google
                        //                   : FontAwesomeIcons.exclamation,
                        //           //color: Colors.white,
                        //         ),
                        //       ),
                        //     );
                        //   },
                        // ),
                        // ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5 * SizeConfig.heightMultiplier,
            ),
            Visibility(visible: suggestionSelected, child: _buildBody())
          ],
        ),
      ),
    );
  }

  bool searchLoad = true;
  List<Map<String, dynamic>> matche = [];
  bool suggestionsAreCreated;
  bool suggestionSelected = false;

  Future<List> getSuggestions(String query) async {
    List<Map<String, dynamic>> matches = [];
    matches = [];
    setState(() {});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    List aff = [];
    http.Client client = http.Client(); //3gb
    final http.Response response = await client.get(
        Uri.parse(
            '${API.iHLUrl}/consult/list_of_aff_starts_with?search_string=$query&ihl_user_id=$iHLUserId'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        });
    if (response.statusCode == 200) {
      // String text = parseFragment(response.body).text;
      // text = parseFragment(text).text; //needed to be done twise to avoid html tags
      // var parse = response.body.replaceAll('&#160;', ' ');
      // var parse1 = parse.replaceAll('(6&quot;)', '');
      // var parse2 = parse1.replaceAll('&amp;', '');

      aff = jsonDecode(response.body);

      List value = aff;
    }
    print(aff);
    if (mounted) setState(() {});
    for (int i = 0; i < aff.length; i++) {
      if (aff[i]['sign_in_option'] == "microsoft" ||
          aff[i]['sign_in_option'] == "google" ||
          aff[i]['sign_in_option'] == "okta") {
        matches.add(aff[i]);
      }
    }
    if (matches.isNotEmpty) {
      suggestionsAreCreated = true;
    } else {
      suggestionsAreCreated = false;
    }
    suggestionSelected = false;
    // if (_typeAheadController.text == "") {
    //   image.isEmpty;
    // }
    if (_typeAheadController.text != "") matche = matches.toSet().toList();
    for (dynamic mac in matches) {
      mac["logo_url"] = matchAff.where((element) {
        return element["affiliation_unique_name"] == mac["affiliation_unique_name"];
      }).first["brand_image_url"];
      print(mac);
      image = '${mac["logo_url"]}';
    }
    searchLoad = false;
    if (mounted) setState(() {});
    return matches;
  }

  Future<String> getMicrosoftAccountDetail(String ssoToken) async {
    http.Client client = http.Client(); //3gb
    final http.Response response =
        await client.get(Uri.parse('https://graph.microsoft.com/v1.0/me'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $ssoToken',
    });
    if (response.statusCode == 200) {
      String text = parseFragment(response.body).text;
      text = parseFragment(text).text;

      setState(() {
        microSoftUserDetails = json.decode(text);
      });
      String displayName = microSoftUserDetails["displayName"].toString().trim();
      bool valid = displayName == "";
      if (valid) {
        setState(() {
          ssoToken = null;
          microSoftUserDetails = null;
          isFetching = false;
          microSoftUserProfilePic = null;
        });
        Get.showSnackbar(
          const GetSnackBar(
            title: "Not Enough Data",
            message: "To sign up for our app, ensure your Microsoft account has your name",
            backgroundColor: AppColors.primaryAccentColor,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        SpUtil.putString('fname', microSoftUserDetails['displayName']);
        SpUtil.putString('lname', microSoftUserDetails['surname'] ?? ' ');
        final http.Response response1 = await client
            .get(Uri.parse('https://graph.microsoft.com/v1.0/me/photo/\$value'), headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $ssoToken',
        });
        if (response1.statusCode == 200) {
          setState(() {
            microSoftUserProfilePic = response1.bodyBytes;
            // isFetching = false;
          });
        } else {
          setState(() {
            microSoftUserProfilePic = null;
          });
        }
      }
    } else {
      if (response.statusCode == 404) {
        Get.showSnackbar(
          const GetSnackBar(
            title: "Not Enough Data",
            message: "To sign up for our app, ensure your Microsoft account has your name",
            backgroundColor: AppColors.primaryAccentColor,
            duration: Duration(seconds: 3),
          ),
        );
        if (mounted)
          setState(() {
            ssoToken = null;
            microSoftUserDetails = null;
            isFetching = false;
            microSoftUserProfilePic = null;
          });
      }
      setState(() {
        microSoftUserDetails = null;
        isFetching = false;
        microSoftUserProfilePic = null;
      });
    }
    return ssoToken;
  }

  void logoutSso() async {
    await oauth.logout();
  }

  bool acountExist = true;

  Future login(String ssoToken) async {
    isFetching = true;

    // CommonController().ssoLoginProcessLoading.notifyListeners;
    setState(() {});
    //await oauth.login();
    // if (signInType == 'okta') {
    //   signInType = 'google';
    // }
    log('SSO Token$ssoToken');
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
        isFetching = true;
        setState(() {});
        var res = jsonDecode(response1.body);
        if (res['response'] == 'user_not_exist') {
          // print(res['id']);
          // SpUtil.putString(SPKeys.sso_token, accessToken);
          // // SpUtil.putString(SPKeys.email, res['id']);
          // SpUtil.putString(SPKeys.signInType, signInType);
          final http.Response response = await _client.post(
            Uri.parse('${API.iHLUrl}/sso/sso_user_details'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "sso_token": accessToken,
              "sso_type": signInType == 'okta' ? 'google' : signInType
            }),
          );
          // if (signInType == 'okta') {
          //   showMessageVerified();
          // }
          print(response.body);
          //for creating a account
          Get.to(SsoWaitingScreen(
            ssoToken: ssoToken,
          ));
          // showMessageVerified();
          // showMessageNotVerifiedInLogin();
        }
        // if (res['response'] == 'user already has an primary account in this email') {
        //   // _userId = res['id'];
        //   // setState(() => _ssoLogin = true);
        // }
        else if (response1.body == 'null') {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('data', '');
          Get.back();
        } else if (res['response'] == 'exception') {
          showMessageNotVerified();
        } else if (res['response'] == 'testing') {
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
          localSotrage.write(LSKeys.logged, true);
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

              Get.offAll(LandingPage());
            });
          }
        } else {
          //for login
          Get.to(SsoLoginLoadingScreen(
            login: true,
            signInType: signInType,
            ssoToken: ssoToken,
            resp: response1,
          ));
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
      if (response.statusCode == 200) {
        var finalresponce = jsonDecode(response.body);
        var outResponce = finalresponce['response']['ihl_account_status'];
        if (outResponce == "emailNotExist") {
          //emailNotExist
          SpUtil.putString(SPKeys.sso_token, accessToken);
          SpUtil.putString(SPKeys.email, finalresponce['response']['email']);
          SpUtil.putString(SPKeys.signInType, signInType);

          showMessageVerified();
        } else if (outResponce == "emailExist") {
          //emailExist
          showMessageUserExist();
          setState(() {
            userExistR = true;
          });
        } else {
          if (signInType == 'okta') {
            print('');
          } else {
            showMessageNotVerified();
          }
        }
      }
    }
  }

  void showMessageVerified() {
    //var succ=CupertinoAlertDialog()
    Get.to(SignupNameSso(
      ssoToken: SpUtil.getString('sso_token'),
    ));
    // CupertinoAlertDialog alert = CupertinoAlertDialog(
    //     content: SingleChildScrollView(
    //         child: Column(
    //       children: [
    //         Lottie.network('https://assets10.lottiefiles.com/packages/lf20_drbxtbz4.json'),
    //         SizedBox(
    //           height: 1 * SizeConfig.heightMultiplier,
    //         ),
    //         Text(
    //           "Verified",
    //           textAlign: TextAlign.center,
    //           style: TextStyle(
    //               color: const Color.fromRGBO(109, 110, 113, 1),
    //               fontFamily: 'Poppins',
    //               fontSize: ScUtil().setSp(25),
    //               letterSpacing: 0.2,
    //               fontWeight: FontWeight.normal,
    //               height: 1),
    //         ),
    //       ],
    //     )),
    //     actions: <Widget>[
    //       CupertinoDialogAction(
    //           isDestructiveAction: false,
    //           onPressed: () async {
    //             setState(() {
    //               isFetching = false;
    //             });
    //             SpUtil.getString('sso_token');
    //             final SharedPreferences prefs = await SharedPreferences.getInstance();
    //             prefs.setString('SignInType', signInType);
    //             Get.to(SignupNameSso(
    //               ssoToken: SpUtil.getString('sso_token'),
    //             ));
    //             // Get.to(const SignupAlternateEmailSso(
    //             //   loginSso: false,
    //             // ));
    //           },
    //           child: Text(
    //             'Ok',
    //             style: TextStyle(
    //                 color: AppColors.primaryColor,
    //                 fontFamily: 'Poppins',
    //                 fontSize: ScUtil().setSp(20),
    //                 letterSpacing: 0.2,
    //                 fontWeight: FontWeight.normal,
    //                 height: 1),
    //           )),
    //     ]);

    // showDialog(
    //     context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

  void showMessageNotVerifiedInLogin() {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.network('https://assets7.lottiefiles.com/packages/lf20_owg6bznj.json',
                  height: 18.h),
              Text(
                "It seems we couldn't find an account associated with the information provided. Would you like to try signing up instead ?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: const Color.fromRGBO(109, 110, 113, 1),
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(16),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () {
                // logoutSso();
                setState(() {
                  isFetching = false;
                });

                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (BuildContext context) => const SsoStartScreenNew(
                //               login: false,
                //             )));
                ssoSignup = true;
                Get.offAll(const LoginEmailScreen(index: 1 ?? 0, existLog: false));
                // Get.off(SsoStartScreenNew(
                //   login: false,
                // ));

                // login();

                // setState(() => _ssoLogin = true);
                // showMessageNotVerifiedExtended();
                //negative flow
              },
              child: Text(
                'Sign Up',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
          CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () {
                // logoutSso();
                setState(() {
                  isFetching = false;
                });
                Navigator.pop(context);

                // setState(() => _ssoLogin = true);
                // showMessageNotVerifiedExtended();
                //negative flow
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

  void showMessageUserExist() {
    //var succ=CupertinoAlertDialog()
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
            child: Column(
          children: [
            Lottie.network('https://assets2.lottiefiles.com/packages/lf20_3etadtp1.json'),
            Text(
              "Email ID already Registered",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: const Color.fromRGBO(109, 110, 113, 1),
                  fontFamily: 'Poppins',
                  fontSize: ScUtil().setSp(20),
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.normal,
                  height: 1),
            ),
          ],
        )),
        actions: <Widget>[
          CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () {
                logoutSso();
                setState(() {
                  isFetching = false;
                });
                Navigator.pop(context);
              },
              child: Text(
                'Ok',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

  void showMessageNotVerified() {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.network('https://assets7.lottiefiles.com/packages/lf20_owg6bznj.json'),
              Text(
                "Unable to Verify. \n Please try again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: const Color.fromRGBO(109, 110, 113, 1),
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () {
                logoutSso();
                setState(() {
                  isFetching = false;
                });
                Navigator.pop(context);
              },
              child: Text(
                'Ok',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

  void showMessageNotVerifiedExtended() {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.network(
                'https://assets5.lottiefiles.com/packages/lf20_ju8hin0q.json',
              ),
              Text(
                "Do you still work in this organisation?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: const Color.fromRGBO(109, 110, 113, 1),
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
              child: Text(
                'Yes',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
              onPressed: () {
                Navigator.pop(context);
                showMessageNotVerifiedExtendedFlow(true);
              }),
          TextButton(
              child: Text(
                'No',
                style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(20),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
              onPressed: () {
                Navigator.pop(context);
                showMessageNotVerifiedExtendedFlow(false);
              })
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

  void showMessageNotVerifiedExtendedFlow(bool isOrganisation) {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  isOrganisation
                      ? "Please contact your organisation admin."
                      : "You can login with your alternate email.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: const Color.fromRGBO(109, 110, 113, 1),
                      fontFamily: 'Poppins',
                      fontSize: ScUtil().setSp(20),
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.normal,
                      height: 1),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            isDestructiveAction: false,
            onPressed: isOrganisation
                ? () {
                    Navigator.pop(context);
                  }
                : () {
                    Get.to(const SsoLoginConvertPage(deepLink: false));
                  },
            child: Text(
              'Okay',
              style: TextStyle(
                  color: AppColors.primaryColor,
                  fontFamily: 'Poppins',
                  fontSize: ScUtil().setSp(20),
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.normal,
                  height: 1),
            ),
          ),
        ]);

    showDialog(
        context: context, builder: (BuildContext context) => alert, barrierDismissible: false);
  }

  void showMessageOctaNotVerified() {
    AlertDialog alert = AlertDialog(
      content: SizedBox(
        height: 44.h,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                  onTap: () {
                    logoutSso();
                    setState(() {
                      isFetching = false;
                    });
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.close,
                    weight: 20,
                  ))
            ],
          ),
          SizedBox(
            height: 3.h,
          ),
          Image.asset(
            'assets/corporation.png',
            height: 18.h,
          ),
          SizedBox(
            height: 3.h,
          ),
          Text(
            "To access your corporate account, please enter your official email ID",
            maxLines: 2,
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: Colors.black,
              fontSize: ScUtil().setSp(13),
              letterSpacing: 0.1,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  logoutSso();
                  setState(() {
                    isFetching = false;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20.5, vertical: 5),
                ),
                child: Text(
                  'OKAY',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: ScUtil().setSp(16),
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.normal,
                      height: 1),
                )),
          )
        ]),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
