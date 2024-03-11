import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';

import '../../../../constants/app_texts.dart';
import '../../../../new_design/app/utils/appColors.dart';
import '../../../../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../../../../new_design/presentation/pages/onlineServices/couponPage.dart';

class SubscribeClass extends StatefulWidget {
  List timingsList;

  SubscribeClass({Key key, this.timingsList}) : super(key: key);

  @override
  State<SubscribeClass> createState() => _SubscribeClassState();
}

class _SubscribeClassState extends State<SubscribeClass> {
  @override
  void initState() {
    print('SSSSSS${widget.timingsList.length}');
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Class name",
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
          ),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            height: 100.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widget.timingsList
                    .map((e) => Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.sp),
                              child: Container(
                                color: Colors.cyan,
                                child: Padding(padding: EdgeInsets.all(10.sp), child: Text(e)),
                              ),
                            ),
                          ],
                        ))
                    .toList(),
                ElevatedButton(
                  onPressed: () {
                    Get.to(NonFreeSubscriptionCouponPage());
                  },
                  child: Text('Confirm Subscription'),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.sp)),
                      // ignore: deprecated_member_use
                      primary: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
                      textStyle: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                )
              ],
            ),
          ),
        ));
  }
}

class NonFreeSubscriptionCouponPage extends StatefulWidget {
  const NonFreeSubscriptionCouponPage({Key key}) : super(key: key);

  @override
  State<NonFreeSubscriptionCouponPage> createState() => _NonFreeSubscriptionCouponPageState();
}

class _NonFreeSubscriptionCouponPageState extends State<NonFreeSubscriptionCouponPage> {
  TextEditingController coupenController = TextEditingController();
  GlobalKey<FormState> form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final FocusNode _focusNode = FocusNode();

    return WillPopScope(
      onWillPop: () async {
        // Get.to(ConfirmVisitPage());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            AppTexts.paymentTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Get.back();
            },
            color: Colors.white,
            tooltip: 'Back',
          ),
        ),
        body: ListView(children: [
          SizedBox(
            height: 20,
          ),
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                SizedBox(
                  width: 80.w,
                  height: 25.h,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Image.asset('assets/icons/couponCode.png', height: 200, width: 300),
                  ),
                ),
                SizedBox(
                  width: 80.w,
                  height: 10.h,
                  child: Center(
                      child: Text(
                    'Pay by Debit/Credit Cards, NetBanking, Wallets and UPI too!',
                    style: TextStyle(
                        color: Color(0xff6d6e71),
                        fontSize: 16,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.normal,
                        height: 1.4),
                    textAlign: TextAlign.center,
                  )),
                ),
                Form(
                  key: form,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 90.w,
                          // height: 64,
                          child: ValueListenableBuilder(
                              valueListenable: coupenController,
                              builder: (_, val, __) {
                                return TextFormField(
                                  focusNode: _focusNode,
                                  validator: (str) {
                                    if (str.isEmpty) {
                                      return "Enter Coupon Code";
                                    }
                                    return null;
                                  },
                                  controller: coupenController,
                                  textAlignVertical: TextAlignVertical.center,
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                  decoration: InputDecoration(
                                    hintText: " Enter Coupon Code (Optional)",
                                    border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(width: 1, color: AppColors.primaryColor),
                                        borderRadius: BorderRadius.circular(15)),
                                    suffixIcon: GestureDetector(
                                      onTap: () async {},
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Container(
                                          width: 10.w,
                                          height: 4.5.h,
                                          color: Colors.black54,
                                          child: Center(
                                            child: Icon(
                                              Icons.arrow_right_alt,
                                              fill: 1.0,
                                              color: Colors.white,
                                              size: 25.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                // ValueListenableBuilder<bool>(
                //     valueListenable: coupenApplied,
                //     builder: (BuildContext context, bool value, Widget child) {
                //       return Visibility(
                //         visible: value,
                //         child: SizedBox(
                //           width: 90.w,
                //           // decoration: BoxDecoration(
                //           //     border: Border.all(
                //           //       color: Colors.blue,
                //           //       width: 1,
                //           //     ),
                //           //     borderRadius: BorderRadius.circular(15)),
                //           child: Padding(
                //             padding: const EdgeInsets.all(8.0),
                //             child: Column(
                //               children: [
                //                 Text("Bill Details"),
                //                 Divider(thickness: 1, color: Colors.blueGrey),
                //                 coupenDatas(title: "Total Amount", amount: fullAmount.toString()),
                //                 SizedBox(height: 5),
                //                 Row(
                //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                   children: [
                //                     Text("Coupon Discount"),
                //                     Text("₹" +
                //                         (coupenDiscountedAmount.toString().contains(".0")
                //                             ? coupenDiscountedAmount.toStringAsFixed(0)
                //                             : coupenDiscountedAmount.toString())),
                //                   ],
                //                 ),
                //                 // SizedBox(height: 5),
                //                 // coupenDatas(
                //                 //     title: "IGST 18% ",
                //                 //     ammount: (amountTobePaid - (amountTobePaid * 100 / (100 + 18)))
                //                 //         .toStringAsFixed(1)
                //                 //         .toString()),
                //                 // SizedBox(height: 10),
                //                 const Divider(thickness: 1),
                //                 coupenDatas(
                //                     title: "Amount to be paid",
                //                     amount: amountTobePaid.toString().contains(".0")
                //                         ? amountTobePaid.toStringAsFixed(0)
                //                         : amountTobePaid.toString()),
                //               ],
                //             ),
                //           ),
                //         ),
                //       );
                //     }),
                SizedBox(
                  height: 3.h,
                ),
                InkWell(
                  onTap: () {
                    AwesomeDialog(
                            context: context,
                            animType: AnimType.topSlide,
                            headerAnimationLoop: true,
                            dialogType: DialogType.info,
                            dismissOnTouchOutside: false,
                            title: 'Failed!',
                            desc: 'Subscription Process Failed',
                            btnOkOnPress: () {
                              Navigator.of(context).pop();
                            },
                            btnOkColor: AppColors.primaryAccentColor,
                            btnOkText: 'Try Later',
                            btnOkIcon: Icons.refresh,
                            onDismissCallback: (_) {})
                        .show();
                  },
                  child: Container(
                      width: 30.w,
                      height: 5.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColors.primaryColor, borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        "PROCEED",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
