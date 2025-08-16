import 'dart:math';

import 'package:dio/dio.dart';
import 'package:privy_flutter/privy_flutter.dart';

class UserRepo {
  late final Privy privy;
  PrivyUser? currentUser;

  UserRepo() {
    final privyConfig = PrivyConfig(
      appId: "cmedf19v400j4l70bhm9ubix5",
      appClientId: "client-WY6PoZtJWLdnagib8NGowtXbXYnkkHgkKw8WpKeHBK51q",
      logLevel: PrivyLogLevel.verbose,
    );

    privy = Privy.init(config: privyConfig);
    privy.getAuthState().then((r) {
      currentUser = r.user;
    });
  }

  Future<bool> isUserLoggedIn() async {
    return privy.currentAuthState.isAuthenticated;
  }

  Future<void> logOut() async {
    await privy.logout();
  }

  Future<double> getBalance() async {
    try {
      final response = await Dio().get(
        'https://spicy-explorer.chiliz.com/api?module=account&action=eth_get_balance&address=0x899522483e2a14e9dba6DeFc383490bC5f9959e6',
      );

      final hexString = (response.data as Map<String, dynamic>)['result']
          .toString()
          .substring(2);
      var balance = 0.0;
      hexString.split('').indexed.forEach((s) {
        final hx =
            int.parse(s.$2, radix: 16) * pow(16.0, hexString.length - s.$1 - 1);
        balance += hx;
      });
      return balance / 1_000_000_000_000_000_000.0;
    } catch (_) {}

    return 0;
  }

  Future<void> sendOtp(
    String email,
    void Function() onSuccess,
    void Function() onError,
  ) async {
    try {
      final result = await privy.email.sendCode(email);
      result.fold(
        onSuccess: (_) {
          onSuccess.call();
        },
        onFailure: (e) {
          onError.call();
        },
      );
    } catch (_) {
      //TODO ERROR
      onError.call();
    }
  }

  Future<void> checkOtp(
    String email,
    String code,
    void Function() onSuccess,
    void Function() onError,
  ) async {
    try {
      final result = await privy.email.loginWithCode(code: code, email: email);

      result.fold(
        onSuccess: (u) async {
          if (u.embeddedEthereumWallets.isEmpty) {
            try {
              await u.createEthereumWallet(allowAdditional: false);
              currentUser = u;
              onSuccess.call();
            } catch (e) {
              await privy.logout();
              onError.call();
            }
          } else {
            onSuccess.call();
          }
        },
        onFailure: (e) {
          onError.call();
        },
      );
    } catch (_) {
      //TODO ERROR
      onError.call();
    }
  }
}
