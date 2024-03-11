import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:ihl/views/about_screen.dart';
import 'package:ihl/widgets/offline_widget.dart';

class Tab3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: Scaffold(body: About()));
  }
}
