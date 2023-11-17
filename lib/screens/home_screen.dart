import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vapps/main.dart';
import 'package:vapps/screens/signin_screen.dart';
import 'package:vapps/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<User?>? currentUser;
  AuthService authService = AuthService(); //firebase 인증관련 객체

  // 변수를 선언하여 서버로부터 받아온 데이터를 저장합니다.
  Map<String, dynamic> data = {};

  // 서버에서 데이터를 가져오는 함수
  Future<void> fetchData() async {
    var response = await http.get(Uri.parse('http://10.0.2.2:9937/test/dto'));
    if (response.statusCode == 200) {
      // 성공적으로 데이터를 가져온 경우
      setState(() {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else {
      // 데이터를 가져오지 못한 경우에 대한 처리를 여기에 추가할 수 있습니다.
      log.i('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    // 위젯이 생성될 때 데이터를 가져오도록 설정
    fetchData();
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
      body: Column(children: <Widget>[
        // 데이터를 표시하는 예제
        Text('Name: ${data['name']}'),
        Text('Age: ${data['age']}'),
      ]),
    );
  }
}
