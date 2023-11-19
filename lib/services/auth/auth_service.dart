import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vapps/enums/social_type.dart';
import 'package:vapps/main.dart';
import 'package:vapps/models/register_user_req_model.dart';
import 'package:vapps/models/register_user_res_model.dart';
import 'package:vapps/screens/signin_screen.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<void> join(
    String emailAddress,
    String password,
    BuildContext context,
  ) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      if (credential.user != null) {
        await FirebaseAuth.instance.setLanguageCode("ko");
        await credential.user?.sendEmailVerification();

        if (context.mounted) {
          //context 마운트 되었는지 여부부터 확인
          // 여기서 인증 메일이 성공적으로 발송되었는지 확인

          // 인증 메일이 성공적으로 발송되었다면 사용자에게 팝업 또는 다른 동작 수행
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('알림'),
                content: RichText(
                  text: const TextSpan(
                    text: '인증 메일이 발송되었습니다. \n발송된 메일을 확인해 주세요.',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 다이얼로그를 닫음

                      // 로그인 페이지로 이동
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SignIn(),
                        ),
                      );
                    },
                    child: const Text('확인'),
                  ),
                ],
              );
            },
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        log.e('The password provided is too weak. at least 6 character');
      } else if (e.code == 'email-already-in-use') {
        log.i('The account already exists for that email.');
      }
    } catch (e) {
      log.e("Unexpected Exception : $e");
    }
  }

  Future<void> signIn(
    String emailAddress,
    String password,
    BuildContext context,
  ) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      if (credential.user != null && credential.user?.emailVerified == true) {
        if (credential.user?.emailVerified == true) {
          if (context.mounted) {
            //context 마운트 되었는지 여부부터 확인
            Navigator.pushReplacementNamed(context, "/");
          }
        } else {
          final userEmail = credential.user?.email;
          log.w("$userEmail not emailVerified");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        log.e('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        log.e('Wrong password provided for that user.');
      }
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      log.e("Unexpected Exception : $e");
    }
  }

  /*
   * 현재 유저 정보를 가져오는 함수
   */
  Future<User?> getCurrentUser() async {
    try {
      User? user = await FirebaseAuth.instance.authStateChanges().first;
      if (user == null) return null;
      if (user.emailVerified == true) {
        return user;
      } else {
        final userEmail = user.email;
        log.w("$userEmail not emailVerified");
        return null;
      }
    } catch (e) {
      log.e('Error getting current user: $e');
      return null;
    }
  }

  /*
   * 신규 로그인 유저 정보를 백엔드 서버에 등록하는 함수
   */
  Future<RegisterUserResModel?> registerUser(
    String? token,
    RegisterUserReqModel userData,
  ) async {
    RegisterUserResModel registerUserResModel;

    // HTTP 헤더에 토큰을 추가 및 컨텐츠 타입을 JSON으로 설정
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json', // JSON 컨텐츠 타입 추가
    };

    // RegisterUserReqModel을 JSON으로 변환하여 body에 추가
    String jsonBody = jsonEncode(userData.toJson());

    var response = await http.post(
      Uri.parse('http://10.0.2.2:9937/user/register/check'),
      headers: headers,
      body: jsonBody,
    );
    registerUserResModel = RegisterUserResModel.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)),
    );

    log.i(registerUserResModel);

    return registerUserResModel;
  }

  // *************************** Google Auth [START] *****************************************

  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    log.i("-------------------------------------");
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;
      IdTokenResult? idTokenResult =
          await userCredential.user?.getIdTokenResult();
      if (user != null) {
        log.i(user.metadata.toString());
        // 처음 로그인한 사용자 백엔드에 유저 정보 저장이 필요
        log.i(' ===== [INFO] signInWithGoogle() User: ${user.uid}');
        RegisterUserResModel? registerUserResponse = await registerUser(
            idTokenResult?.token,
            RegisterUserReqModel(
                uid: user.uid,
                email: user.email,
                socialType: SocialType.google));
        if (registerUserResponse != null) {
          log.i('code : ${registerUserResponse.code}');
          log.i('message : ${registerUserResponse.message}');
        }
      }

      log.i(
          'User ID: ${user?.uid}  Display Name: ${user?.displayName}  Email: ${user?.email}');

      log.i('token: ${idTokenResult?.token}'
          '  token expirationTime: ${idTokenResult?.expirationTime}');
      return userCredential;
    } catch (e) {
      log.e('Error during Google Sign In: $e');
    }

    // Once signed in, return the UserCredential
    return null;
  }

  // *************************** Google Auth [END] *****************************************
}
