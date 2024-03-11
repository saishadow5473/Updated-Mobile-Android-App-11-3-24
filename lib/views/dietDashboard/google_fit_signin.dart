import 'dart:async';
import 'package:googleapis/fitness/v1.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId:
      '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    FitnessApi.fitnessActivityReadScope,
    FitnessApi.fitnessBodyReadScope,
    FitnessApi.fitnessBloodGlucoseReadScope,
    FitnessApi.fitnessBloodPressureReadScope,
    FitnessApi.fitnessNutritionReadScope,
    FitnessApi.fitnessHeartRateReadScope,
    FitnessApi.fitnessSleepReadScope,
  ],
);

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount _currentUser;
  String _contactText = '';
  List<int> steps = [];
  List<double> calories = [];

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      if (this.mounted) {
        setState(() {
          _currentUser = account;
        });
      }
      if (_currentUser != null) {
        _handleGetContact(_currentUser);
      }
    });
    _googleSignIn.signInSilently();
  }

  void _handleGetContact(GoogleSignInAccount currentUser) async {
    var httpClient = (await _googleSignIn.authenticatedClient());
    var fitnessApi = FitnessApi(httpClient);
    var stepRequest = AggregateRequest(
        aggregateBy: [
          AggregateBy(
              dataSourceId:
                  "derived:com.google.step_count.delta:com.google.android.gms:estimated_steps",
              dataTypeName: "com.google.step_count.delta")
        ],
        bucketByTime: BucketByTime(
          durationMillis: "86400000",
          period: BucketByTimePeriod(
              timeZoneId: "Asia/Kolkata", type: "day", value: 1),
        ),
        startTimeMillis: DateTime.now()
            .subtract(Duration(days: 7))
            .millisecondsSinceEpoch
            .toString(),
        endTimeMillis: DateTime.now().millisecondsSinceEpoch.toString());
    var calorieRequest = AggregateRequest(
        aggregateBy: [
          AggregateBy(
              dataSourceId:
                  'derived:com.google.calories.expended:com.google.android.gms:merge_calories_expended',
              dataTypeName: "com.google.step_count.delta")
        ],
        bucketByTime: BucketByTime(
          durationMillis: "86400000",
          period: BucketByTimePeriod(
              timeZoneId: "Asia/Kolkata", type: "day", value: 1),
        ),
        startTimeMillis: DateTime.now()
            .subtract(Duration(days: 7))
            .millisecondsSinceEpoch
            .toString(),
        endTimeMillis: DateTime.now().millisecondsSinceEpoch.toString());
    fitnessApi.users.dataset.aggregate(stepRequest, 'me').then((value) {
      value.bucket.forEach((bucket) {
        bucket.dataset.forEach((dataset) {
          dataset.point.forEach((point) {
            point.value.forEach((element) {
              steps.add(element.intVal ?? 0);
            });
          });
        });
      });
    });
    fitnessApi.users.dataset.aggregate(calorieRequest, 'me').then((value) {
      value.bucket.forEach((bucket) {
        bucket.dataset.forEach((dataset) {
          dataset.point.forEach((point) {
            point.value.forEach((element) {
              calories.add(element.fpVal ?? 0);
            });
          });
        });
      });
    });
    if (this.mounted) {
      setState(() {});
    }

    fitnessApi.users.sessions.list('me').then((value) => print(value.toJson()));

    //fitnessApi.users.dataSources.list('me').then((value) => value.dataSource.forEach((element) {
    // print(element.toJson());
    //}));
    //fitnessApi.users.dataSources.get('me', 'derived:com.google.calories.expended:com.google.android.gms:merge_calories_expended').then((value) => print(value.toJson()));
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Widget _buildBody() {
    GoogleSignInAccount user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          const Text("Signed in successfully."),
          Text(
            'Weekly Steps Data by Interval of 1 Day:\n${steps.isNotEmpty ? steps.toString() : 'Not Fetched'}',
            textAlign: TextAlign.center,
          ),
          Text(
            'Weekly Calories Data by Interval of 1 Day:\n${calories.isNotEmpty ? calories.toString() : 'Not Fetched'}',
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            child: const Text('SIGN OUT'),
            onPressed: _handleSignOut,
          ),
          ElevatedButton(
            child: const Text('REFRESH'),
            onPressed: () => _handleGetContact(user),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          ElevatedButton(
            child: const Text('SIGN IN'),
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Fit Rest API'),
          centerTitle: true,
          brightness: Brightness.dark,
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}
