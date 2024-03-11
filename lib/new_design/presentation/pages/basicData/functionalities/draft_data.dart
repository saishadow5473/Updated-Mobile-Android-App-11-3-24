class DraftData {
  String _firstName;
  String _lastName;
  String _dob;
  String _gender;
  String _weight;
  String _height;
  String _phoneNumber;
  String _alternativeEmail;
  String _email;

  // Getters
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get dob => _dob;
  String get gender => _gender;
  String get weight => _weight;
  String get height => _height;
  String get phoneNumber => _phoneNumber;
  String get alternativeEmail => _alternativeEmail;
  String get email => _email;

  // Setters
  set firstName(String firstName) {
    _firstName = firstName;
  }

  set lastName(String lastName) {
    _lastName = lastName;
  }

  set dob(String dob) {
    _dob = dob;
  }

  set gender(String gender) {
    _gender = gender;
  }

  set weight(String weight) {
    _weight = weight;
  }

  set height(String height) {
    _height = height;
  }

  set phoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
  }

  set alternativeEmail(String alternativeEmail) {
    _alternativeEmail = alternativeEmail;
  }

  set email(String email) {
    _email = email;
  }
}
