import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vapps/main.dart';
import 'package:vapps/screens/signin_screen.dart';

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
}
