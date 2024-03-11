import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';

class AffiliationTile extends StatelessWidget {
  final Widget leading;
  final String companyName;
  final Function onTap;

  AffiliationTile(
      {Key key, this.leading, this.companyName, this.onTap})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 2,
      borderOnForeground: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.0),
        onTap: onTap,
        splashColor: AppColors.primaryAccentColor.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50.0,
                child: leading,
              ),
              SizedBox(height: 20.0),
              Text(
                companyName,
                style: TextStyle(
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AffiliationCard extends StatelessWidget {
  final Widget leading;
  final String companyName;
  final Function onTap;

  AffiliationCard(
      {Key key, this.leading, this.companyName, this.onTap})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 26.0,
        right: 26.0,
        top: 10.0,
      ),
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            bottomLeft: Radius.circular(8.0),
            bottomRight: Radius.circular(8.0),
            topRight: Radius.circular(68.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: FitnessAppTheme.grey.withOpacity(0.2),
              offset: Offset(1.1, 1.1),
              blurRadius: 10.0),
        ],
      ),
      child: InkWell(
        customBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        onTap: onTap,
        child: Container(
          child: Align(
            alignment: FractionalOffset.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      right: 20.0,
                    ),
                    child: ClipOval(
                        child: //imagePath != null
                        //     ? CachedNetworkImage(
                        //   imageUrl: imagePath,
                        //   imageBuilder: (context, imageProvider) =>
                        //       Container(
                        //         width: 70.0,
                        //         height: 72.5,
                        //         decoration: BoxDecoration(
                        //           image: DecorationImage(
                        //             image: imageProvider,
                        //             fit: BoxFit.cover,
                        //           ),
                        //         ),
                        //       ),
                        //   placeholder: (context, url) =>
                        //       CircularProgressIndicator(),
                        //   errorWidget: (context, url, error) =>
                        //       Image.asset('assets/images/user.jpg'),
                        // )
                        leading
                    ),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: FractionalOffset.centerLeft,
                          child: Text(
                            companyName,
                            style: TextStyle(
                              // fontWeight: FontWeight.bold,
                              // fontSize: 16,
                              // color: Color(0xFF6f6f6f),
                                color: FitnessAppTheme.grey,
                                fontSize: ScUtil().setSp(14),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        // Align(
                        //   alignment: FractionalOffset.centerLeft,
                        //   child: Padding(
                        //     padding: EdgeInsets.only(
                        //       top: 5.0,
                        //     ),
                        //     child: Text(
                        //       specialty,
                        //       style: TextStyle(
                        //         fontSize: 14,
                        //         color: Color(0xFF9f9f9f),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // Align(
                        //   alignment: FractionalOffset.centerLeft,
                        //   child: Padding(
                        //     padding: EdgeInsets.only(
                        //       top: 5.0,
                        //     ),
                        //     child: StarRating(
                        //       rating: rank,
                        //       rowAlignment: MainAxisAlignment.start,
                        //     ),
                        //   ),
                        // ),
                      ],
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