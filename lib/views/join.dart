import 'package:flutter/material.dart';
import 'package:vapps/services/auth/auth_service.dart';

class Join extends StatelessWidget {
  Join({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                AuthService.join(
                    emailController.text, passwordController.text, context);
                print('회원가입 버튼이 클릭되었습니다.');
              },
              child: const Text('회원가입2'),
            ),
          ],
        ),
      ),
    );
  }
}
