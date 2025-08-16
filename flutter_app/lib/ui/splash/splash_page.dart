import 'package:allena/main.dart';
import 'package:allena/repo/navigation_service.dart';
import 'package:allena/repo/user_repo.dart';
import 'package:allena/ui/auth/auth_page.dart';
import 'package:allena/ui/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 1)).then((_) {
      getIt.get<UserRepo>().isUserLoggedIn().then((isLoggedIn) {
        if (isLoggedIn) {
          getIt<NavigationService>().navigator.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) => DashboardPage(),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          getIt<NavigationService>().navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => AuthPage()),
            (Route<dynamic> route) => false,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(height: 80, child: Image.asset('assets/icon.png')),
        ),
      ),
    );
  }
}
