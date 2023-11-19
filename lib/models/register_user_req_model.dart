import 'package:vapps/enums/social_type.dart';

class RegisterUserReqModel {
  late String? uid;
  late String? email;
  late SocialType socialType;

  RegisterUserReqModel(
      {required this.uid, required this.email, required this.socialType});

  // toJson 메서드를 추가하여 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'socialType': socialType.toString().split('.').last.toUpperCase()
    };
  }
}
