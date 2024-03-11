import 'package:flutter/material.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';

/// Basic Page UI with scroll implemented, pass appbar and body, uses app primary colors 😇
class BasicPageUI extends StatelessWidget {
  final Widget appBar;
  final Widget body;
  Color backgroundColor;
  BasicPageUI({Key key, this.appBar, this.body, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollessBasicPageUI(
      appBar: appBar,
      body: Container(width: double.infinity, color: backgroundColor,//to resize the fit even when child is empty
          child: SingleChildScrollView( child: body )),
    );
  }
}
