import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';

class PrescriptionDetails extends StatefulWidget {
  @override
  _PrescriptionDetailsState createState() => _PrescriptionDetailsState();
}

class _PrescriptionDetailsState extends State<PrescriptionDetails> {
  @override
  Widget build(BuildContext context) {
    return ScrollessBasicPageUI(
      appBar: Column(
        children: [
          SizedBox(
            width: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(
                color: Colors.white,
              ),
              Flexible(
                child: Center(
                  child: Text(
                    "Prescription",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.file_download),
                color: Colors.white,
                onPressed: () {},
              ),
              SizedBox(
                width: 20,
              )
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 2200,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Center(
                child: Image.asset(
                  'assets/images/ihl.png',
                  height: ScUtil().setHeight(60),
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              SizedBox(
                height: 20.0,
              ),
              Text("DOCTOR INFORMATION",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryAccentColor,
                      fontSize: 17.0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    thickness: 1.0,
                    indent: 2.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Name: Ms. Pooja Malhotra"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Text("Specialization: Masters in food and Nutrition"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Add: Mumbai"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Maharashtra,India-400053"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Phone: 9500044065"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Email: Pooja@indiahealthlink.com"),
                  )
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Text("PATIENT INFORMATION",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryAccentColor,
                      fontSize: 17.0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    thickness: 1.0,
                    indent: 2.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Name: Mariyappan"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Age: 34 years"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Gender: Male"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Weight: 81 kg"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Add: Chennai"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Tamil Nadu,India-600081"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Phone: +916383422688"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Email: mariyappan@indiahealthlink.com"),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Text("CHIEF COMPLAINTS",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryAccentColor,
                      fontSize: 17.0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    thickness: 1.0,
                    indent: 2.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Abdominal Pain"),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Text("RELEVANT POINTS FROM HEALTH HISTORY",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryAccentColor,
                      fontSize: 17.0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    thickness: 1.0,
                    indent: 2.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("PeniciIIin"),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    FontAwesomeIcons.prescription,
                    size: 40.0,
                    color: AppColors.primaryAccentColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 38.0),
                    child: Text("PRESCRIPTION DETAILS",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryAccentColor,
                            fontSize: 17.0)),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    thickness: 1.0,
                    indent: 2.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Date: 28/08/2020 05:24 PM"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Medicine Name: Dolo 500'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Note :After food"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Frequency: 1-1-1"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Quantity: 9"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Refills: 0"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Days Supply: 3"),
                  ),
                  Divider(
                    thickness: 1.0,
                    indent: 2.0,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 28.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Text("Prescriber Signature: "), Text("Pooja")],
                ),
              ),
              Divider(
                thickness: 1.0,
                indent: 2.0,
              ),
              Text("Note: This prescription is generated on a teleconsultation")
            ]),
          ),
        ),
      ),
    );
  }
}
