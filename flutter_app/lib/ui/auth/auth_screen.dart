import 'package:allena/main.dart';
import 'package:allena/repo/navigation_service.dart';
import 'package:allena/repo/user_repo.dart';
import 'package:allena/ui/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  bool _isCodeSent = false;

  final TextEditingController emailController = TextEditingController(
    text: 'anton.homeniuk@gmail.com',
  );
  final TextEditingController otpController = TextEditingController(text: '');

  final FocusNode otpFocusNode = FocusNode();

  Future<void> _sendOtp() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    getIt.get<UserRepo>().sendOtp(
      emailController.text,
      () {
        setState(() {
          _isCodeSent = true;
          _isLoading = false;

          otpFocusNode.requestFocus();
        });
      },
      () {
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _checkOtp() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

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
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Email'),
          TextField(
            enabled: !_isLoading && !_isCodeSent,
            controller: emailController,
            onSubmitted: (s) {
              _sendOtp();
            },
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofocus: true,
          ),
          if (_isCodeSent) ...[
            Text('OTP'),
            TextField(
              enabled: !_isLoading,
              focusNode: otpFocusNode,
              controller: otpController,
              keyboardType: TextInputType.numberWithOptions(
                signed: false,
                decimal: true,
              ),
            ),
          ],
          if (!_isCodeSent && !_isLoading)
            ElevatedButton(
              child: Text('Send'),
              onPressed: () {
                _sendOtp();
              },
            ),
          if (_isCodeSent && !_isLoading)
            ElevatedButton(
              child: Text('Check'),
              onPressed: () {
                _checkOtp();
              },
            ),
        ],
      ),
    );
  }
}
