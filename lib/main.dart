import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vapps/firebase_options.dart';
import 'package:vapps/services/auth/auth_service.dart';
import 'package:vapps/views/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
        '/login': (context) => Login(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<User?>? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      currentUser = AuthService.getCurrentUser();
    });

    // 예제: 사용자 정보 출력
    User? user = await currentUser;
    if (user != null) {
      print('현재 사용자: ${user.email}');
    } else {
      print('현재 사용자는 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<User?>(
              future: currentUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('에러 발생: ${snapshot.error}');
                } else if (snapshot.data == null) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Login(),
                        ),
                      );
                    },
                    child: const Text('로그인'),
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () async {
                      // 로그아웃 로직
                      await AuthService.logout();
                      // 로그아웃 후에 사용자 정보를 다시 로드
                      _loadCurrentUser();
                    },
                    child: const Text('로그아웃'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
