abstract class MedFileEvent {}

class RefreshEvent extends MedFileEvent {}

class AddMedFileEvent extends MedFileEvent {
  String docid;

  ///triggering of add function
  AddMedFileEvent({
    this.docid,
  });
}

class RemoveMedFileEvent extends MedFileEvent {
  String docid;

  ///triggering of remove function
  RemoveMedFileEvent({this.docid});
}
