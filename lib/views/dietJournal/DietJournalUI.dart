import 'package:flutter/material.dart';
import 'package:ihl/views/dietJournal/DietJournalScrollessBasicPageUI.dart';

// ignore: must_be_immutable
class DietJournalUI extends StatelessWidget {

  final Widget appBar;
  final Widget body;
  final Widget fab;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  Color backgroundColor;
  final Color topColor;
  DietJournalUI({Key key, this.appBar, this.topColor, this.body, this.fab, this.backgroundColor, this.floatingActionButtonLocation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DietJournalScrollessBasicPageUI(
      appBar: appBar,
      body: Container(width: double.infinity, color: backgroundColor,//to resize the fit even when child is empty
          child: SingleChildScrollView( child: body )
          ),
          fab: fab,
          topColor: topColor,
          floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
