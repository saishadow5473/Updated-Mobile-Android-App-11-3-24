import 'package:flutter/material.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/app_texts.dart';

// TODO:
// [ ]screen navigation
// [x] Tested with API working

class SignupEmail extends StatefulWidget {
  SignupEmail({Key key}) : super(key: key);

  static const id = '/signup_email';

  @override
  _SignupEmailState createState() => _SignupEmailState();
}

class _SignupEmailState extends State<SignupEmail> {
  FocusNode emailFocusNode;
  bool emailchar = false;
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailFocusNode = FocusNode();
    _emailController.addListener(() {
      if (this.mounted) {
        setState(() {
          emailchar = _emailController.text.contains(
              RegExp(
                  "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$"),
              0);
        });
      }
    });
  }

  Widget emailTextField() {
    return StreamBuilder<String>(
      builder: (context, snapshot) {
        return TextField(
          controller: _emailController,
          autocorrect: true,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
                vertical: (snapshot.hasData) ? 24 : 18, horizontal: 15.0),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.email),
            ),
            labelText: "E-mail address..",
            hintText: 'johndoe@example.com',
            fillColor: Colors.white,
            enabledBorder: const OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Colors.transparent, width: 0.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Colors.transparent, width: 0.0),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide:
                  const BorderSide(color: Colors.transparent, width: 0.0),
            ),
            border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(15.0),
                borderSide: new BorderSide(color: Colors.blueGrey)),
            errorText: validateEmail(_emailController.text),
          ),
          keyboardType: TextInputType.emailAddress,
          maxLines: 1,
          style: TextStyle(fontSize: 16.0),
          focusNode: emailFocusNode,
          onSubmitted: (_) {},
          textInputAction: TextInputAction.next,
        );
      },
    );
  }

  String validateEmail(String value) {
    if (!(emailchar) && value.isNotEmpty) {
      return "Invalid Email";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SafeArea(
        top: true,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 5,
                  child: LinearProgressIndicator(
                    value: 0.25,
                    backgroundColor: Color(0xffDBEEFC),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pushNamed(Routes.Sname),
              color: Colors.black,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed(Routes.Spwd),
                child: Text(AppTexts.next,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    color: Color(0xFF19a9e5),
                  ),
                  shape:
                      CircleBorder(side: BorderSide(color: Colors.transparent)),
                ),
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color.fromRGBO(244, 246, 250, 1),
                  Color.fromRGBO(255, 255, 255, 1)
                ],
              ),
            ),
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 8 * SizeConfig.heightMultiplier,
                  ),
                  Text(
                    AppTexts.step2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.primaryAccentColor,
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        height: 1.1),
                  ),
                  SizedBox(
                    height: 8 * SizeConfig.heightMultiplier,
                  ),
                  Text(
                    AppTexts.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(109, 110, 113, 1),
                        fontFamily: 'Poppins',
                        fontSize: 26,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                        height: 1.33),
                  ),
                  SizedBox(
                    height: 3 * SizeConfig.heightMultiplier,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                    child: Text(
                      AppTexts.sub2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color.fromRGBO(109, 110, 113, 1),
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.normal,
                          height: 1.75),
                    ),
                  ),
                  SizedBox(
                    height: 4 * SizeConfig.heightMultiplier,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(64, 117, 205, 0.07),
                              offset: Offset(0, 15),
                              blurRadius: 20)
                        ],
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                      child: emailTextField(),
                    ),
                  ),
                  SizedBox(
                    height: 5 * SizeConfig.heightMultiplier,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                    child: Center(
                      child: Container(
                        height: 60.0,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.of(context).pushNamed(Routes.Spwd),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF19a9e5),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                  child: Text(
                                    'Continue',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        letterSpacing: 0.2,
                                        fontWeight: FontWeight.normal,
                                        height: 1),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
