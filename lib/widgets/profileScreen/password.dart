import '../../constants/spKeys.dart';
import '../../models/checkInternet.dart';
import '../../repositories/api_repository.dart';
import 'package:flutter/material.dart';
import '../../utils/ScUtil.dart';
import '../../utils/app_colors.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Self contained change password widget 🔐🔐
class ChangePassword extends StatefulWidget {
  const ChangePassword({Key key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  String pwd;
  String conPwd;
  String oldPwd;
  String email;
  bool isChanging = false;
  bool eightChars = false;
  bool specialChar = false;
  bool upperCaseChar = false;
  bool number = false;
  String correct = '';
  bool _passwordVisible = false;
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;
  final Apirepository _apirepository = Apirepository();
  bool isEditing = false;
  Future<String> _change({BuildContext context}) async {
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
    if (email == null || email == '') {
      SnackBar snackBar = const SnackBar(
        content: Text('Please try again in a few moments.'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return 'Please try again in a few moments.';
    }
    if (specialChar && upperCaseChar && number && eightChars && pwd == conPwd) {
      if (correct != oldPwd && correct != null && correct != '') {
        SnackBar snackBar = const SnackBar(
          content: Text('Please enter the correct old password.'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return 'Please enter the correct old password.';
      }
      if (oldPwd == pwd) {
        SnackBar snackBar = const SnackBar(
          content: Text('Old and new password shouldn\'t be same'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return 'Please enter the correct old password.';
      }
      if (mounted) {
        setState(() {
          isChanging = true;
        });
      }
      SnackBar snackBar = const SnackBar(
        content: Text('Updating Password.....'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      _apirepository
          .userProfileResetPasswordAPI(email: email, newPassword: conPwd, password: oldPwd)
          .then((String value) {
        SnackBar snackBar1 = const SnackBar(
          content: Text('Password Succesfully Updated'),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar1);
        if (mounted) {
          setState(() {
            isEditing = false;
            isChanging = false;
          });
        }
      }).catchError((onError) {
        SnackBar snackBar = SnackBar(
          content: Text('Failed to Update Password+++:$onError'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        if (mounted) {
          setState(() {
            isChanging = false;
          });
        }
      });
    } else {
      if (mounted) {
        setState(() {
          isChanging = false;
        });
      }
      SnackBar snackBar = const SnackBar(
        content: Text('Enter valid values'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  String validateCon() {
    if (conPwd != pwd) {
      return 'Both the Passwords does not match';
    }
  }

  String validatePass() {
    if (!eightChars) {
      return 'Password must include min. 8 characters.';
    }
    if (!specialChar) {
      return 'Password should have a special character';
    }
    if (!upperCaseChar) {
      return 'Password should have a capital letter.[A-Z]';
    }
    if (!number) {
      return 'Password must include at least 1 numeral between 0-9.';
    }
  }

  Future<String> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userData);

    data = data == null || data == '' ? '{"User":{}}' : data;

    Map res = jsonDecode(data);
    correct = prefs.get(SPKeys.password);
    return res['User']['email'];
  }

  getData() async {
    email = await getEmail();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isEditing = false;
    passwordController.clear();
    oldPasswordController.clear();
    confirmPasswordController.clear();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    if (!isEditing) {
      passwordController.clear();
      oldPasswordController.clear();
      confirmPasswordController.clear();
    }
    return Container(
        child: Column(
      children: [
        isEditing
            ? AbsorbPointer(
                absorbing: isChanging,
                child: Opacity(
                  opacity: isChanging ? 0.5 : 1,
                  child: Form(
                    onWillPop: () async {
                      isEditing = false;
                      passwordController.clear();
                      oldPasswordController.clear();
                      confirmPasswordController.clear();
                      return true;
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                          child: TextField(
                            obscureText: !_passwordVisible,
                            keyboardType: TextInputType.visiblePassword,
                            onChanged: (String value) {
                              if (mounted) {
                                setState(() {
                                  oldPwd = value;
                                });
                              }
                            },
                            style: TextStyle(
                              fontSize: ScUtil().setSp(16),
                            ),
                            controller: oldPasswordController,
                            decoration: InputDecoration(
                              disabledBorder: InputBorder.none,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primaryAccentColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              labelStyle: TextStyle(
                                  fontSize: ScUtil().setSp(20), fontWeight: FontWeight.normal),
                              labelText: 'Old Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  // Based on passwordVisible state choose the icon
                                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: const Color(0xff252529),
                                ),
                                onPressed: () {
                                  // Update the state i.e. toogle the state of passwordVisible variable
                                  if (mounted) {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                          child: TextField(
                            obscureText: !_passwordVisible1,
                            keyboardType: TextInputType.visiblePassword,
                            onChanged: (String value) {
                              pwd = value;

                              eightChars = pwd.length >= 8;
                              number = pwd.contains(RegExp(r'\d'), 0);
                              upperCaseChar = pwd.contains(RegExp(r'[A-Z]'), 0);
                              specialChar =
                                  pwd.isNotEmpty && !pwd.contains(RegExp(r'^[\w&.-]+$'), 0);
                              if (mounted) {
                                setState(() {});
                              }
                            },
                            style: TextStyle(
                              fontSize: ScUtil().setSp(16),
                            ),
                            controller: passwordController,
                            decoration: InputDecoration(
                              disabledBorder: InputBorder.none,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primaryAccentColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              errorText: validatePass(),
                              labelStyle: TextStyle(
                                fontSize: ScUtil().setSp(20),
                                fontWeight: FontWeight.normal,
                              ),
                              labelText: 'New Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  // Based on passwordVisible state choose the icon
                                  _passwordVisible1 ? Icons.visibility : Icons.visibility_off,
                                  color: const Color(0xff252529),
                                ),
                                onPressed: () {
                                  // Update the state i.e. toogle the state of passwordVisible variable
                                  if (mounted) {
                                    setState(() {
                                      _passwordVisible1 = !_passwordVisible1;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                          child: TextField(
                            obscureText: !_passwordVisible2,
                            keyboardType: TextInputType.visiblePassword,
                            onChanged: (String value) {
                              if (mounted) {
                                setState(() {
                                  conPwd = value;
                                });
                              }
                            },
                            style: TextStyle(
                              fontSize: ScUtil().setSp(16),
                            ),
                            controller: confirmPasswordController,
                            decoration: InputDecoration(
                              disabledBorder: InputBorder.none,
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primaryAccentColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              errorText: validateCon(),
                              labelStyle: TextStyle(
                                  fontSize: ScUtil().setSp(20), fontWeight: FontWeight.normal),
                              labelText: 'Confirm Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  // Based on passwordVisible state choose the icon
                                  _passwordVisible2 ? Icons.visibility : Icons.visibility_off,
                                  color: const Color(0xff252529),
                                ),
                                onPressed: () {
                                  // Update the state i.e. toogle the state of passwordVisible variable
                                  if (mounted) {
                                    setState(() {
                                      _passwordVisible2 = !_passwordVisible2;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                isEditing = false;
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: AppColors.primaryAccentColor),
                              onPressed: () async {
                                _change(context: context);
                              },
                              child: Text(
                                'Change',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextButton(
                  style: TextButton.styleFrom(
                      textStyle: const TextStyle(color: Colors.white),
                      backgroundColor: AppColors.primaryAccentColor),
                  child: const Text(
                    'Change Password',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    isEditing = true;
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              ),
      ],
    ));
  }
}

/// Self contained change password widget 🔐🔐
class ChangeProfilePassword extends StatefulWidget {
  const ChangeProfilePassword({Key key}) : super(key: key);

  @override
  _ChangeProfilePasswordState createState() => _ChangeProfilePasswordState();
}

class _ChangeProfilePasswordState extends State<ChangeProfilePassword> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  String pwd;
  String conPwd;
  String oldPwd;
  String email;
  bool isChanging = false;
  bool eightChars = false;
  bool specialChar = false;
  bool upperCaseChar = false;
  bool number = false;
  String correct = '';
  bool _passwordVisible = false;
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;
  final Apirepository _apirepository = Apirepository();
  bool isEditing = true;
  Future<String> _change({BuildContext context}) async {
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
    if (email == null || email == '') {
      SnackBar snackBar = const SnackBar(
        content: Text('Please try again in a few moments.'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return 'Please try again in a few moments.';
    }
    if (specialChar && upperCaseChar && number && eightChars && pwd == conPwd) {
      if (correct != oldPwd && correct != null && correct != '') {
        SnackBar snackBar = const SnackBar(
          content: Text('Please enter the correct old password.'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return 'Please enter the correct old password.';
      }
      if (oldPwd == pwd) {
        SnackBar snackBar = const SnackBar(
          content: Text('Old and new password shouldn\'t be same'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return 'Please enter the correct old password.';
      }
      if (mounted) {
        setState(() {
          isChanging = true;
        });
      }
      SnackBar snackBar = const SnackBar(
        content: Text('Updating Password.....'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      _apirepository
          .userProfileResetPasswordAPI(email: email, newPassword: conPwd, password: oldPwd)
          .then((String value) async {
        if (value == 'wrong old password') {
          SnackBar snackBar = const SnackBar(
            content: Text('Failed to Update Password: OLD PASSWORD IS WRONG !'),
            backgroundColor: Colors.red,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          if (mounted) {
            setState(() {
              isChanging = false;
            });
          }
        } else {
          SnackBar snackBar1 = const SnackBar(
            content: Text('Password Succesfully Updated'),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar1);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(SPKeys.password, conPwd);
          await getData();
          if (mounted) {
            setState(() {
              pwd = '';
              conPwd = '';
              oldPwd = '';
              passwordController.clear();
              oldPasswordController.clear();
              confirmPasswordController.clear();
              isChanging = false;
            });
          }
        }
      }).catchError((onError) {
        SnackBar snackBar = SnackBar(
          content: Text('Failed to Update Password----:$onError'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        if (mounted) {
          setState(() {
            isChanging = false;
          });
        }
      });
    } else {
      if (mounted) {
        setState(() {
          isChanging = false;
        });
      }
      SnackBar snackBar = const SnackBar(
        content: Text('Enter valid values'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  String validateCon() {
    if (conPwd == null) {
      return null;
    }
    if (conPwd != pwd) {
      return 'Both the Passwords does not match';
    }
  }

  String validatePass() {
    if (passwordController.text.isEmpty) {
      return null;
    }
    if (!eightChars) {
      return 'Password must include min. 8 characters.';
    }
    if (!specialChar) {
      return 'Password should have a special character';
    }
    if (!upperCaseChar) {
      return 'Password should have a capital letter.[A-Z]';
    }
    if (!number) {
      return 'Password must include at least 1 numeral between 0-9.';
    }
    if (oldPasswordController.text == passwordController.text &&
        oldPasswordController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      return 'Old and New password should not be same !';
    }
  }

  Future<String> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userData);

    data = data == null || data == '' ? '{"User":{}}' : data;

    Map res = jsonDecode(data);
    correct = prefs.get(SPKeys.password);
    return res['User']['email'];
  }

  getData() async {
    email = await getEmail();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    passwordController.clear();
    oldPasswordController.clear();
    confirmPasswordController.clear();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    if (!isEditing) {
      passwordController.clear();
      oldPasswordController.clear();
      confirmPasswordController.clear();
    }
    return Container(
        child: Column(
      children: [
        AbsorbPointer(
          absorbing: isChanging,
          child: Opacity(
            opacity: isChanging ? 0.5 : 1,
            child: Form(
              onWillPop: () async {
                isEditing = false;
                passwordController.clear();
                oldPasswordController.clear();
                confirmPasswordController.clear();
                return true;
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                    child: TextField(
                      obscureText: !_passwordVisible,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (String value) {
                        if (mounted) {
                          setState(() {
                            oldPwd = value;
                          });
                        }
                      },
                      style: TextStyle(
                        fontSize: ScUtil().setSp(16),
                      ),
                      controller: oldPasswordController,
                      decoration: InputDecoration(
                        disabledBorder: InputBorder.none,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primaryAccentColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        labelStyle:
                            TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.normal),
                        labelText: 'Old Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xff252529),
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            if (mounted) {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                    child: TextField(
                      obscureText: !_passwordVisible1,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (String value) {
                        pwd = value;
                        eightChars = pwd.length >= 8;
                        number = pwd.contains(RegExp(r'\d'), 0);
                        upperCaseChar = pwd.contains(RegExp(r'[A-Z]'), 0);
                        specialChar = pwd.isNotEmpty && !pwd.contains(RegExp(r'^[\w&.-]+$'), 0);
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      style: TextStyle(
                        fontSize: ScUtil().setSp(16),
                      ),
                      controller: passwordController,
                      decoration: InputDecoration(
                        disabledBorder: InputBorder.none,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primaryAccentColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        errorText: validatePass(),
                        labelStyle: TextStyle(
                          fontSize: ScUtil().setSp(20),
                          fontWeight: FontWeight.normal,
                        ),
                        labelText: 'New Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible1 ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xff252529),
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            if (mounted) {
                              setState(() {
                                _passwordVisible1 = !_passwordVisible1;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                    child: TextField(
                      obscureText: !_passwordVisible2,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (String value) {
                        if (mounted) {
                          setState(() {
                            conPwd = value;
                          });
                        }
                      },
                      style: TextStyle(
                        fontSize: ScUtil().setSp(16),
                      ),
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        disabledBorder: InputBorder.none,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primaryAccentColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        errorText: validateCon(),
                        labelStyle:
                            TextStyle(fontSize: ScUtil().setSp(20), fontWeight: FontWeight.normal),
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible2 ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xff252529),
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            if (mounted) {
                              setState(() {
                                _passwordVisible2 = !_passwordVisible2;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          isEditing = false;
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(backgroundColor: AppColors.primaryAccentColor),
                        onPressed: () async {
                          _change(context: context);
                        },
                        child: Text(
                          'Change',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    ));
  }
}
