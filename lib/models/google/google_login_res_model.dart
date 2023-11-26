import 'package:firebase_auth/firebase_auth.dart';
import 'package:vapps/enums/google/google_res_code.dart';

class GoogleLoginResModel {
  late GoogleResCode code;
  late String message;
  late UserCredential? userCredential; //실패할 경우 어쩔수 없이 null을 넣어야함

  // Constructor
  GoogleLoginResModel({
    this.code = GoogleResCode.fail,
    this.message =
        "An unexpected error occurred, resulting in the return of a default object.",
    required this.userCredential,
  });

  // Setter method for 'code'
  void setCode(GoogleResCode newCode) {
    code = newCode;
  }

  // Setter method for 'message'
  void setMessage(String newMessage) {
    message = newMessage;
  }

  // Setter method for 'userCredential'
  void setUserCredential(UserCredential newUserCredential) {
    userCredential = newUserCredential;
  }
}
