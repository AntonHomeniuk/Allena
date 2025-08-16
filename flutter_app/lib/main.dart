import 'package:allena/repo/navigation_service.dart';
import 'package:allena/repo/user_repo.dart';
import 'package:allena/ui/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.I;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  getIt.registerSingleton<UserRepo>(UserRepo());
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allena',
      debugShowCheckedModeBanner: false,
      navigatorKey: getIt<NavigationService>().navigationKey,
      theme: ThemeData(primarySwatch: Colors.pink),
      home: SplashPage(),
    );
  }
}
