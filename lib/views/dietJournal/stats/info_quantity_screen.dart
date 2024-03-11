import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class InfoQuantityScreen extends StatelessWidget {
  InfoQuantityScreen({Key key, this.appBarColor}) : super(key: key);
  Color appBarColor;
  @override
  Widget build(BuildContext context) {
    List quantityList = [
      {
        "title": "Small cup/bowl",
        "image path": "assets/images/quantitys/small_cup_bowl.jpg",
        "quantity": "150ml/gram",
      },
      {
        "title": "Katori",
        "image path": "assets/images/quantitys/katori.jpg",
        "quantity": "150ml/gram",
      },
      {
        "title": "Large cup/bowl",
        "image path": "assets/images/quantitys/large_cup_bowl.jpg",
        "quantity": "350ml/gram",
      },
      {
        "title": "Tea cup",
        "image path": "assets/images/quantitys/tea_cup.jpg",
        "quantity": "180ml",
      },
      {
        "title": "Glass",
        "image path": "assets/images/quantitys/glass.jpg",
        "quantity": "250ml",
      },
      {
        "title": "Large glass",
        "image path": "assets/images/quantitys/large_glass.jpg",
        "quantity": "350ml",
      },
      {
        "title": "1 Tea spoon",
        "image path": "assets/images/quantitys/1_tea_spoon.jpg",
        "quantity": "5ml/grams",
      },
      {
        "title": "1 Table spoon",
        "image path": "assets/images/quantitys/1_table_spoon.jpg",
        "quantity": "15ml/grams",
      }
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 27.sp,
          ),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        title: Text('Quantity'),
        backgroundColor: appBarColor,
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: quantityList
                  .map((e) => quantityTile(
                      title: e["title"], quantity: e["quantity"], imagePath: e["image path"]))
                  .toList()),
        ),
      ),
    );
  }

  Widget quantityTile({String title, quantity, imagePath}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  blurRadius: 3, color: Colors.grey.shade200, offset: Offset(1, 1), spreadRadius: 3)
            ]),
        // height: Device.width / 2.4,
        width: Device.width / 2.2,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(children: [
            SizedBox(
              height: 10,
            ),
            Container(
                padding: EdgeInsets.only(left: 6),
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w400, fontFamily: "Poppins"),
                )),
            SizedBox(
                height: Device.width / 2.8,
                width: Device.width / 2.8,
                child: Image.asset(
                  imagePath,
                )),
            Text(
              quantity,
              style: TextStyle(fontFamily: "Poppins"),
            ),
            SizedBox(
              height: 10,
            ),
          ]),
        ),
      ),
    );
  }
}
