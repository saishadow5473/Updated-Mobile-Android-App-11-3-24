class Login {
  final apiToken;
  const Login({this.apiToken});

  List<Object> get props => [apiToken];

  static Login fromJson(dynamic json) {
    return Login(
      apiToken: json['ApiKey'],
    );
  }

  @override
  String toString() => 'Login { ApiToken: $apiToken';
}

class Signup {
  final apiToken, id;
  const Signup({this.apiToken, this.id});

  List<Object> get props => [apiToken, id];

  static Signup fromJson(dynamic json) {
    return Signup(apiToken: json['ApiKey'], id: json['id']);
  }

  @override
  String toString() => 'Signup { ApiToken: $apiToken, id: $id';
}

class JointAccountLogin {
  final apiToken;
  const JointAccountLogin({this.apiToken});

  List<Object> get props => [apiToken];

  static JointAccountLogin fromJson(dynamic json) {
    return JointAccountLogin(
      apiToken: json['ApiKey'],
    );
  }

  @override
  String toString() => 'Login { ApiToken: $apiToken';
}

class JointAccountGuestUserLogin {
  final token;
  const JointAccountGuestUserLogin({this.token});

  List<Object> get props => [token];

  static JointAccountGuestUserLogin fromJson(dynamic json) {
    return JointAccountGuestUserLogin(
      token: json['Token'],
    );
  }

  @override
  String toString() => 'Login { ApiToken: $token';
}

class JointAccountSignup {
  final apiToken, id;
  const JointAccountSignup({this.apiToken, this.id});

  List<Object> get props => [apiToken, id];

  static JointAccountSignup fromJson(dynamic json) {
    return JointAccountSignup(apiToken: json['ApiKey'], id: json['id']);
  }

  @override
  String toString() => 'Signup { ApiToken: $apiToken, id: $id';
}

class JointAccountGuestUSerSignup {
  final token, id;
  const JointAccountGuestUSerSignup({this.token, this.id});

  List<Object> get props => [token, id];

  static JointAccountGuestUSerSignup fromJson(dynamic json) {
    return JointAccountGuestUSerSignup(token: json['token'], id: json['id']);
  }

  @override
  String toString() => 'Signup { ApiToken: $token, id: $id';
}

class JointAccountEditGuestUSerSignup {
  // ignore: non_constant_identifier_names
  final ihl_user_id, ihl_user_name, status;
  final bool vitalRead, vitalWrite, teleconsultRead, teleconsultWrite;
  // ignore: non_constant_identifier_names
  const JointAccountEditGuestUSerSignup(
      // ignore: non_constant_identifier_names
      {this.ihl_user_id,
      // ignore: non_constant_identifier_names
      this.ihl_user_name,
      this.status,
      this.teleconsultRead,
      this.teleconsultWrite,
      this.vitalRead,
      this.vitalWrite});

  List<Object> get props => [
        ihl_user_id,
        ihl_user_name,
        status,
        vitalRead.toString(),
        vitalWrite.toString(),
        teleconsultRead.toString(),
        teleconsultWrite.toString()
      ];

  static JointAccountEditGuestUSerSignup fromJson(dynamic json) {
    return JointAccountEditGuestUSerSignup(
        ihl_user_id: json['ihl_user_id'],
        ihl_user_name: json['ihl_user_name'],
        status: json['status'],
        vitalRead: json['vital_read'],
        vitalWrite: json[''],
        teleconsultRead: json['teleconsult_read'],
        teleconsultWrite: json['teleconsult_write']);
  }

  @override
  String toString() =>
      'EditUser { joint_user_detail_list: {joint_user1:{ihl_user_id: $ihl_user_id, ihl_user_name: $ihl_user_name, status: $status, vitalRead: $vitalRead, vitalWrite:$vitalWrite, teleconsultRead: $teleconsultRead, teleconsultWrite:$teleconsultWrite';
}
