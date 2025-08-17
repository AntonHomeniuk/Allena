import 'package:allena/repo/navigation_service.dart';
import 'package:allena/repo/user_repo.dart';
import 'package:allena/repo/wal_repo.dart';
import 'package:allena/ui/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.I;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  getIt.registerSingleton<UserRepo>(UserRepo());
  getIt.registerSingleton<WalRepo>(WalRepo());
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
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
      ),
      home: SplashPage(),
    );
  }
}

Future? _currentLoadingDialog;

Future showLoadingDialog() async {
  _currentLoadingDialog ??= showDialog(
    barrierDismissible: false,
    context: getIt.get<NavigationService>().navigatorContext,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: const SizedBox(
            width: 48,
            height: 48,
            child: FittedBox(child: CircularProgressIndicator.adaptive()),
          ),
        ),
      );
    },
  );
  await _currentLoadingDialog;
}

void hideLoadingDialog() {
  if (_currentLoadingDialog != null) {
    getIt.get<NavigationService>().navigator.pop();
    _currentLoadingDialog = null;
  }
}
