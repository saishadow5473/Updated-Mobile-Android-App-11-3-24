import 'dart:io';

import 'package:get_storage/get_storage.dart';
import '../../models/checkInternet.dart';
import '../../new_design/presentation/pages/spalshScreen/splashScreen.dart';
import '../../utils/ScUtil.dart';
import '../../utils/SpUtil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../repositories/api_repository.dart';
import '../../constants/routes.dart';

class DeleteUser extends StatefulWidget {
  const DeleteUser({Key key}) : super(key: key);

  @override
  _DeleteUserState createState() => _DeleteUserState();
}

class _DeleteUserState extends State<DeleteUser> {
  bool isEditing = false;
  bool opedAd = false;
  bool agreed = false;
  String password = '';
  String email = '';
  String correct;
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final Apirepository _apirepository = Apirepository();
  final String warningAdvanced = '!Advanced settings!';
  final String warningAgree =
      'Deleting your account will erase all the data from IHL, do you want to continue?';
  final String warningDel =
      'Once deleted all your account data will not be recoverable, this includes your health score and vital data.';
  getCorrect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    correct = prefs.get('password');
    emailController.text = prefs.get('email');
  }

  @override
  void initState() {
    super.initState();
    _initSp();
    isEditing = false;
    passwordController.clear();
    emailController.clear();
    password = '';
    getCorrect();
  }

  void _initSp() async {
    await SpUtil.getInstance();
  }

  del({BuildContext context}) async {
    FocusScope.of(context).unfocus();

    bool connection = await checkInternet();
    if (connection == false) {
      SnackBar snackBar = const SnackBar(
        content: Text('No internet connection. Please check and try again.'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return null;
    }

    if (correct != password) {
      SnackBar snackBar = const SnackBar(
        content: Text('Incorrect Password'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (true) {
      SnackBar snackBar = const SnackBar(
        content: Text('Deleting Account...'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _apirepository
          .userProfileDeleteAPI(email: emailController.text, password: password)
          .then((String value) async {
        SnackBar snackBar1 = const SnackBar(
          content: Text('Account has been Deleted'),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar1);
        if (mounted) {
          setState(() {
            isEditing = false;
          });
        }
        clear();
      }).catchError((onError) {
        SnackBar snackBar = SnackBar(
          content: Text('Failed to Delete Account:$onError'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      SnackBar snackBar = const SnackBar(
        content: Text('Enter valid values'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  ask({BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account?'),
          content: const Flexible(child: Text('warning')),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
      barrierDismissible: true,
    );
  }

  void clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool x = await SpUtil.remove('qAns');
    bool y = await SpUtil.clear();
    _deleteCacheDir();
    _deleteAppDir();
    if (x == true && y == true) {
      final GetStorage box = GetStorage();
      await localSotrage.erase();
      await prefs.clear().then((bool value) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.Welcome, (Route<dynamic> route) => false,
            arguments: false);
      });
    }
  }

  Future<void> _deleteCacheDir() async {
    final Directory cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  Future<void> _deleteAppDir() async {
    final Directory appDir = await getApplicationSupportDirectory();

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }

  // ignore: missing_return
  String emailValidator(String mail) {
    bool isMail = mail.contains(
        RegExp(
            "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$"),
        0);
    if ((mail.isEmpty || !isMail) && isEditing) {
      return 'Enter valid Email';
    }
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return Container(
      child: Column(
        children: [
          opedAd
              ? agreed
                  ? (isEditing
                      ? Form(
                          onWillPop: () async {
                            isEditing = false;
                            passwordController.clear();
                            return true;
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                                child: TextField(
                                  enabled: false,
                                  controller: emailController,
                                  style: TextStyle(
                                    fontSize: ScUtil().setSp(16),
                                  ),
                                  decoration: InputDecoration(
                                    errorText: emailValidator(email),
                                    disabledBorder: InputBorder.none,
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.primaryAccentColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                    labelStyle: const TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.normal),
                                    labelText: 'Email',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                                child: TextField(
                                  onChanged: (String value) {
                                    if (mounted) {
                                      setState(() {
                                        password = value;
                                      });
                                    }
                                  },
                                  obscureText: true,
                                  controller: passwordController,
                                  style: TextStyle(
                                    fontSize: ScUtil().setSp(16),
                                  ),
                                  decoration: const InputDecoration(
                                    disabledBorder: InputBorder.none,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.primaryAccentColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                    labelStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    labelText: 'Password',
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      opedAd = false;
                                      isEditing = false;
                                      agreed = false;
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                        textStyle: const TextStyle(color: Colors.white),
                                        backgroundColor: Colors.redAccent),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      del(context: context);
                                    },
                                    style: TextButton.styleFrom(
                                      textStyle: const TextStyle(color: Colors.white),
                                      backgroundColor: AppColors.primaryAccentColor,
                                    ),
                                    child: Row(
                                      children: [Icon(Icons.delete), Text('Delete')],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Text(warningDel),
                              TextButton(
                                style: TextButton.styleFrom(
                                    textStyle: const TextStyle(color: Colors.white),
                                    backgroundColor: Colors.red),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.error_outline),
                                    Text('Delete Account')
                                  ],
                                ),
                                onPressed: () {
                                  isEditing = true;
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                        ))
                  : Column(
                      children: [
                        Text(warningAgree),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                opedAd = false;
                                isEditing = false;
                                agreed = false;
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(color: Colors.white),
                                  backgroundColor: Colors.redAccent),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                opedAd = true;
                                isEditing = true;
                                agreed = true;
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(color: Colors.white),
                                backgroundColor: AppColors.primaryAccentColor,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_outline),
                                  Text(
                                    'I understand',
                                    style: TextStyle(
                                      fontSize: ScUtil().setSp(14),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
              : TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.red),
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        opedAd = true;
                      });
                    }
                  },
                  child: Text(
                    'Delete account',
                  ),
                )
        ],
      ),
    );
  }
}

class DeleteUserProfile extends StatefulWidget {
  const DeleteUserProfile({Key key}) : super(key: key);

  @override
  _DeleteUserProfileState createState() => _DeleteUserProfileState();
}

class _DeleteUserProfileState extends State<DeleteUserProfile> {
  bool isEditing = false;
  bool opedAd = true;
  bool agreed = false;
  String password = '';
  String email = '';
  String correct;
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final Apirepository _apirepository = Apirepository();
  final String warningAdvanced = '!Advanced settings!';
  final String warningAgree =
      'Deleting your account will erase all the data from IHL, do you want to continue?';
  final String warningDel =
      'Once deleted all your account data will not be recoverable, this includes your health score and vital data.';
  getCorrect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    correct = prefs.get('password');
    emailController.text = prefs.get('email');
  }

  @override
  void initState() {
    super.initState();
    _initSp();
    isEditing = false;
    passwordController.clear();
    emailController.clear();
    password = '';
    getCorrect();
  }

  void _initSp() async {
    await SpUtil.getInstance();
  }

  del({BuildContext context}) async {
    FocusScope.of(context).unfocus();

    bool connection = await checkInternet();
    if (connection == false) {
      SnackBar snackBar = const SnackBar(
        content: Text('No internet connection. Please check and try again.'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return null;
    }

    if (correct != password) {
      SnackBar snackBar = const SnackBar(
        content: Text('Incorrect Password'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (true) {
      SnackBar snackBar = const SnackBar(
        content: Text('Deleting Account...'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _apirepository
          .userProfileDeleteAPI(email: emailController.text, password: password)
          .then((String value) async {
        SnackBar snackBar1 = const SnackBar(
          content: Text('Account has been Deleted'),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar1);
        if (mounted) {
          setState(() {
            isEditing = false;
          });
        }
        clear();
      }).catchError((onError) {
        SnackBar snackBar = SnackBar(
          content: Text('Failed to Delete Account:$onError'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      SnackBar snackBar = const SnackBar(
        content: Text('Enter valid values'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  ask({BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account?'),
          content: const Flexible(child: Text('warning')),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
      barrierDismissible: true,
    );
  }

  void clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool x = await SpUtil.remove('qAns');
    bool y = await SpUtil.clear();
    _deleteCacheDir();
    _deleteAppDir();
    if (x == true && y == true) {
      final GetStorage box = GetStorage();
      await localSotrage.erase();
      await prefs.clear().then((bool value) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.Welcome, (Route<dynamic> route) => false,
            arguments: false);
      });
    }
  }

  Future<void> _deleteCacheDir() async {
    final Directory cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  Future<void> _deleteAppDir() async {
    final Directory appDir = await getApplicationSupportDirectory();

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }

  // ignore: missing_return
  String emailValidator(String mail) {
    bool isMail = mail.contains(
        RegExp(
            "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$"),
        0);
    if ((mail.isEmpty || !isMail) && isEditing) {
      return 'Enter valid Email';
    }
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return Container(
      child: Column(
        children: [
          agreed
              ? (isEditing
                  ? Form(
                      onWillPop: () async {
                        isEditing = false;
                        passwordController.clear();
                        return true;
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                            child: TextField(
                              enabled: false,
                              controller: emailController,
                              style: TextStyle(
                                fontSize: ScUtil().setSp(16),
                              ),
                              decoration: InputDecoration(
                                errorText: emailValidator(email),
                                disabledBorder: InputBorder.none,
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.primaryAccentColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                labelStyle:
                                    const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                                labelText: 'Email',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                            child: TextField(
                              onChanged: (String value) {
                                if (mounted) {
                                  setState(() {
                                    password = value;
                                  });
                                }
                              },
                              obscureText: true,
                              controller: passwordController,
                              style: TextStyle(
                                fontSize: ScUtil().setSp(16),
                              ),
                              decoration: const InputDecoration(
                                disabledBorder: InputBorder.none,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.primaryAccentColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                                labelStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                ),
                                labelText: 'Password',
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {
                                  opedAd = false;
                                  isEditing = false;
                                  agreed = false;
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.redAccent),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  del(context: context);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: AppColors.primaryAccentColor,
                                ),
                                child: Row(
                                  children: [Icon(Icons.delete), Text('Delete')],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(warningDel),
                          TextButton(
                            style: TextButton.styleFrom(
                                textStyle: const TextStyle(color: Colors.white),
                                backgroundColor: Colors.red),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [Icon(Icons.error_outline), Text('Delete Account')],
                            ),
                            onPressed: () {
                              isEditing = true;
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    ))
              : Column(
                  children: [
                    Text(warningAgree,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            opedAd = false;
                            isEditing = false;
                            agreed = false;
                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(color: Colors.white),
                              backgroundColor: Colors.redAccent),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            opedAd = true;
                            isEditing = true;
                            agreed = true;
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primaryAccentColor,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline),
                              SizedBox(width: 6),
                              Text(
                                'I understand',
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
        ],
      ),
    );
  }
}
