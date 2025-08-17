import 'package:allena/main.dart';
import 'package:allena/repo/navigation_service.dart';
import 'package:allena/repo/user_repo.dart';
import 'package:allena/ui/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isCodeSent = false;

  final TextEditingController emailController = TextEditingController(
    text: 'anton.homeniuk@gmail.com',
  );
  final TextEditingController otpController = TextEditingController(text: '');

  final FocusNode otpFocusNode = FocusNode();

  Future<void> _sendOtp() async {
    showLoadingDialog();

    getIt.get<UserRepo>().sendOtp(
      emailController.text,
      () {
        hideLoadingDialog();

        setState(() {
          _isCodeSent = true;

          otpFocusNode.requestFocus();
        });
      },
      () {
        hideLoadingDialog();
      },
    );
  }

  Future<void> _checkOtp() async {
    showLoadingDialog();

    getIt.get<UserRepo>().checkOtp(
      emailController.text,
      otpController.text,
      () {
        getIt<NavigationService>().navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => DashboardPage()),
          (Route<dynamic> route) => false,
        );
      },
      () {
        setState(() {
          Fluttertoast.showToast(msg: 'Failed to authorize');
          Future.delayed(Duration(milliseconds: 100)).then((v) {
            otpFocusNode.requestFocus();
          });
        });

        hideLoadingDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Log in or sign up',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Spacer(),
            SizedBox(height: 40, child: Image.asset('assets/logo_text.png')),
            SizedBox(height: 64),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: TextField(
                  enabled: !_isCodeSent,
                  controller: emailController,
                  decoration: InputDecoration(hintText: 'Email'),
                  onSubmitted: (s) {
                    _sendOtp();
                  },
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                ),
              ),
            ),
            if (_isCodeSent) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: TextField(
                    focusNode: otpFocusNode,
                    decoration: InputDecoration(
                      fillColor: Colors.red,
                      hintText: 'OTP',
                    ),
                    controller: otpController,
                    keyboardType: TextInputType.numberWithOptions(
                      signed: false,
                      decimal: true,
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: 16),
            if (!_isCodeSent)
              ElevatedButton(
                child: Text('Submit'),
                onPressed: () {
                  _sendOtp();
                },
              ),
            if (_isCodeSent)
              ElevatedButton(
                child: Text('Submit'),
                onPressed: () {
                  _checkOtp();
                },
              ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
