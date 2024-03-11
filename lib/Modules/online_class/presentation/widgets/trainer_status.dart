import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/trainer_status/bloc/trainer_bloc.dart';

class TrainerStatusWidget extends StatelessWidget {
  const TrainerStatusWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrainerBloc, TrainerAvailabilityState>(
      bloc: TrainerBloc(),
      // builder: (BuildContext context, TrainerAvailabilityState s) {
      //   if (s is InitialTrainerState) {
      //     return const Text('Offline');
      //   }
      //   if (s is UpdatedTrainerState) {
      //     final bool isOnline = s.isOnline;
      //     final String statusText = isOnline ? 'Online' : 'Offline';
      //     return Text(statusText);
      //   }
      //   return const Text('Offline');
      // },
      // ignore: void_checks
      listener: (BuildContext context, TrainerAvailabilityState s) {
        if (s is InitialTrainerState) {
          return 'Offline';
        }
        if (s is UpdatedTrainerState) {
          final bool isOnline = s.isOnline;
          final String statusText = isOnline ? 'Online' : 'Offline';
          return statusText;
        }
        return 'Offline';
      },
    );
  }
}
