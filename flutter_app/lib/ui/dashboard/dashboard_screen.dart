import 'package:allena/main.dart';
import 'package:allena/repo/navigation_service.dart';
import 'package:allena/repo/user_repo.dart';
import 'package:allena/ui/auth/auth_page.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            getIt.get<UserRepo>().logOut().then((_) {
              getIt<NavigationService>().navigator.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (BuildContext context) => AuthPage(),
                ),
                (Route<dynamic> route) => false,
              );
            });
          },
          child: Text('Logout'),
        ),
      ],
    );
  }
}
