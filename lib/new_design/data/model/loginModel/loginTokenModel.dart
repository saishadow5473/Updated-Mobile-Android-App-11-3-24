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
