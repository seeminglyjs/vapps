import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vapps/enums/user_state.dart';
import 'package:vapps/main.dart';
import 'package:vapps/models/current_user_model.dart';
import 'package:vapps/screens/signin_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<CurrentUser>? currentUserFuture;
  User? userInfo;

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

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCurrentUser(currentUserFuture, userInfo);
    // 위젯이 생성될 때 데이터를 가져오도록 설정
    fetchData();

    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  Future<void> loadCurrentUser(
    Future<CurrentUser>? currentUserFuture,
    User? userInfo,
  ) async {
    setState(() {
      currentUserFuture = authService.getCurrentUser();
    });

    CurrentUser? currentUser = await currentUserFuture;
    if (currentUser != null && currentUser.userState == UserState.signin) {
      userInfo = currentUser.user;
      log.i(
          '현재 로그인 유저 : ${userInfo?.email} \n현재 로그인 유저 이메일 인증여부: ${userInfo?.emailVerified}');
    } else {
      log.i('현재 사용자는 없습니다.');
    }
  }

  // var controller = WebViewController()
  //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //   ..setBackgroundColor(const Color(0x00000000))
  //   ..setNavigationDelegate(
  //     NavigationDelegate(
  //       onProgress: (int progress) {
  //         // Update loading bar.
  //       },
  //       onPageStarted: (String url) {},
  //       onPageFinished: (String url) {},
  //       onWebResourceError: (WebResourceError error) {},
  //       onNavigationRequest: (NavigationRequest request) {
  //         if (request.url.startsWith('https://www.youtube.com/')) {
  //           return NavigationDecision.prevent;
  //         }
  //         return NavigationDecision.navigate;
  //       },
  //     ),
  //   )
  //   ..loadRequest(Uri.parse('http://10.0.2.2:9937/test/view'));

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
            FutureBuilder<CurrentUser?>(
              future: currentUserFuture,
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
                } else if (snapshot.data != null &&
                    snapshot.data?.userState != UserState.signin) {
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
                      loadCurrentUser(currentUserFuture, userInfo);
                    },
                    icon: const Icon(Icons.logout),
                  );
                }
              },
            ),
          ],
        ),
        // body: WebViewWidget(controller: controller),
        body: SafeArea(
            child: Column(children: <Widget>[
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
            controller: urlController,
            keyboardType: TextInputType.url,
            onSubmitted: (value) {
              var url = WebUri(value);
              if (url.scheme.isEmpty) {
                url = WebUri("https://www.google.com/search?q=$value");
              }
              webViewController?.loadUrl(urlRequest: URLRequest(url: url));
            },
          ),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest:
                      URLRequest(url: WebUri("http://10.0.2.2:9937/test/view")),
                  initialSettings: settings,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                        resources: request.resources,
                        action: PermissionResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunchUrl(uri)) {
                        // Launch the App
                        await launchUrl(
                          uri,
                        );
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController?.endRefreshing();
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onReceivedError: (controller, request, error) {
                    pullToRefreshController?.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController?.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    if (kDebugMode) {
                      print(consoleMessage);
                    }
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: const Icon(Icons.arrow_back),
                onPressed: () {
                  webViewController?.goBack();
                },
              ),
              ElevatedButton(
                child: const Icon(Icons.arrow_forward),
                onPressed: () {
                  webViewController?.goForward();
                },
              ),
              ElevatedButton(
                child: const Icon(Icons.refresh),
                onPressed: () {
                  webViewController?.reload();
                },
              ),
            ],
          ),
        ]))
        // body: Column(children: <Widget>[
        //   // 데이터를 표시하는 예제
        //   Text('Name: ${data['name']}'),
        //   Text('Age: ${data['age']}'),
        // ]),
        );
  }
}
