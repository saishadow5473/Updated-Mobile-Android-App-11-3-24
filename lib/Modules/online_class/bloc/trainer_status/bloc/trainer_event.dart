part of 'trainer_bloc.dart';

class TrainerEvent {}

class ListenTrainerStatusEvent extends TrainerEvent {
    final bool isOnline;

  ListenTrainerStatusEvent(this.isOnline);
}
