import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vapps/main.dart';
import 'package:vapps/screens/signin_screen.dart';
import 'package:vapps/services/auth/auth_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<User?>? currentUser;
  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      currentUser = authService.getCurrentUser();
    });

    User? user = await currentUser;
    if (user != null) {
      log.i('현재 로그인 유저 : ${user.email}');
    } else {
      log.i('현재 사용자는 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.favorite,
          color: Colors.pink,
          size: 24.0,
          semanticLabel: 'Text to announce in accessibility modes',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          FutureBuilder<User?>(
            future: currentUser,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return IconButton(
                  icon: const CircularProgressIndicator(),
                  onPressed: () {},
                );
              } else if (snapshot.hasError) {
                return IconButton(
                  icon: const Icon(Icons.error),
                  onPressed: () {
                    // Handle error action if needed
                  },
                );
              } else if (snapshot.data == null) {
                return IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SignIn(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login),
                );
              } else {
                return IconButton(
                  onPressed: () async {
                    // 로그아웃 로직
                    await authService.signOut();
                    // 로그아웃 후에 사용자 정보를 다시 로드
                    _loadCurrentUser();
                  },
                  icon: const Icon(Icons.logout),
                );
              }
            },
          ),
        ],
      ),
      body: const Column(),
    );
  }
}
