import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  static Future<void> join(
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
        if (context.mounted) {
          //context 마운트 되었는지 여부부터 확인
          Navigator.pushReplacementNamed(context, "/");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> login(
    String emailAddress,
    String password,
    BuildContext context,
  ) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      if (credential.user != null) {
        if (context.mounted) {
          //context 마운트 되었는지 여부부터 확인
          Navigator.pushReplacementNamed(context, "/");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  static Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  static Future<User?> getCurrentUser() async {
    try {
      User? user = await FirebaseAuth.instance.authStateChanges().first;
      return user;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}
