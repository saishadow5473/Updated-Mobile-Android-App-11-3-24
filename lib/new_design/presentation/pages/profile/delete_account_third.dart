import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../repositories/repositories.dart';
import '../../../../widgets/signin_email.dart';
import '../../../app/utils/appColors.dart';
import '../dashboard/common_screen_for_navigation.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DeleteScreeenThird extends StatefulWidget {
  String email;
  DeleteScreeenThird({Key key, this.email}) : super(key: key);

  @override
  State<DeleteScreeenThird> createState() => _DeleteScreeenThirdState();
}

class _DeleteScreeenThirdState extends State<DeleteScreeenThird> {
  TextEditingController oldPasswordController = TextEditingController();
  bool checked = false;
  final Apirepository _apirepository = Apirepository();

  deleteAc(String password) async {
    _apirepository
        .userProfileDeleteAPI(email: widget.email, password: password)
        .then((String value) async {
      if (value == 'wrong old password') {
        SnackBar snackBar1 = const SnackBar(
          content: Text('Account has been Deleted'),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar1);
        // Get.offAll(const LoginEmailScreen());
      }
    }).catchError((e) {
      SnackBar snackBar2 = const SnackBar(
        content: Text('Failed to Delete Account'),
        backgroundColor: Colors.blue,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Delete Account'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 28.sp,
          ),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      content: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 5.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.delete,
                  size: 23.sp,
                  color: Colors.black,
                ),
                SizedBox(
                  width: 4.w,
                ),
                const Text('DELETE PROFILE',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
            SizedBox(
              height: 2.5.h,
            ),
            const Text(
              'Delete Account',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue),
            ),
            Padding(
              padding: EdgeInsets.all(13.sp),
              child: const Text(
                'IF your are sure want to proceed with the deletion of your account please continue below',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(13.sp),
              child: const Text(
                'keep in mind this operation in irreversible and will result in a complete deletion of all your account data.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 2.5.h,
            ),
            const Text(
              'Password',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue),
            ),
            SizedBox(
              height: 1.5.h,
            ),
            Container(
              padding: EdgeInsets.only(left: 4.w, right: 7.w),
              child: TextFormField(
                obscureText: true,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Password field cannot be blank.';
                  }
                },
                controller: oldPasswordController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide(width: 1))),
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: checked,
                  onChanged: (bool value) {
                    setState(() {
                      checked = value;
                    });
                  },
                ),
                SizedBox(
                  height: 10.h,
                  width: 78.w,
                  child: const Text(
                    'I acknowledge I understand that all of my account data will be deleted and want to proceed.',
                    maxLines: 3,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 1.h,
            ),
            Center(
              child: Container(
                child: GestureDetector(
                  onTap: () {
                    if (checked && oldPasswordController.text != null) {
                      deleteAc(oldPasswordController.text);
                    } else {
                      const GetSnackBar(
                        title: "Error Occured",
                        message: "Fields not to be empty",
                        backgroundColor: AppColors.primaryAccentColor,
                        duration: Duration(seconds: 3),
                      );
                    }
                  },
                  child: Container(
                    height: 4.h,
                    width: 60.w,
                    decoration: const BoxDecoration(
                      color: AppColors.ihlPrimaryColor,
                    ),
                    child: const Center(
                      child: Text('DELETE MY ACCOUNT',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
