import 'package:flutter/material.dart';
import 'package:vapps/services/auth/auth_service.dart';
import 'package:vapps/views/join.dart';

class Login extends StatelessWidget {
  Login({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("로그인"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    AuthService.login(_emailController.text,
                        _passwordController.text, context);
                    print('로그인 버튼이 클릭되었습니다.');
                  },
                  child: const Text('로그인'),
                ),
                const SizedBox(width: 20), // 간격 조절
                ElevatedButton(
                  onPressed: () {
                    // "회원가입" 버튼을 누르면 Join 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Join()),
                    );
                  },
                  child: const Text('회원가입'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
