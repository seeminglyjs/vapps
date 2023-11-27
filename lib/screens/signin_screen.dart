import 'package:flutter/material.dart';
import 'package:vapps/enums/google/google_res_code.dart';
import 'package:vapps/models/google/google_login_res_model.dart';
import 'package:vapps/screens/home_screen.dart';
import 'package:vapps/services/auth/auth_service.dart';

class SignIn extends StatelessWidget {
  SignIn({super.key});
  final AuthService authService = AuthService();

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: () async {
                    GoogleLoginResModel res =
                        await authService.signInWithGoogle();
                    if (res.code == GoogleResCode.success) {
                      if (context.mounted) {
                        //컨텍스트가 마운트 되었으면
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Home(),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // 텍스트 색상을 흰색으로 설정
                  ),
                  icon: Image.asset(
                    'assets/logo/google_logo.jpg', // Google 로고 이미지
                    height: 24.0, // 이미지 높이 조절
                  ),
                  label: const Text('구글 로그인'), // 버튼 텍스트
                ),
                const SizedBox(width: 20), // 간격 조절
              ],
            )
          ],
        ),
      ),
    );
  }
}
