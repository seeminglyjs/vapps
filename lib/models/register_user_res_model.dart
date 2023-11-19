class RegisterUserResModel {
  String? code;
  String? message;
  String? email;

  RegisterUserResModel({this.code, this.message, this.email});

  // 추가적인 생성자나 초기화 로직이 필요한 경우 여기에 추가할 수 있습니다.

  factory RegisterUserResModel.fromJson(Map<String, dynamic> json) {
    return RegisterUserResModel(
      code: json['code'],
      message: json['message'],
      email: json['email'],
    );
  }
}
