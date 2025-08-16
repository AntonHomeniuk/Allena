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

  Future<void> mint() async {
    /*final wallet = currentUser?.embeddedEthereumWallets[0];
    wallet?.provider
        .request(
          EthereumRpcRequest(
            method: 'eth_signTransaction',
            params: [
              jsonEncode({
                "to": "0x736999a7f2e64c2e1F69F552c931E04cc1352443",
                "chain_id": "0x15B32",
                'value': '0x186a0',
                'from':'${wallet.address}'
              }),
            ],
          ),
        )
        .then((v) {
          print('asd');
        })
        .onError((e, s) {});
    (await currentUser?.getAccessToken())?.fold(
      onSuccess: (token) async {
        try {
          await Dio().post(
            'https://api.privy.io/v1/wallets/${wallet?.id}/rpc',
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'privy-authorization-signature': '$token',
                'Authorization':
                    'Basic ${base64.encode(utf8.encode('cmedf19v400j4l70bhm9ubix5:5AscHzURiha4dDDtqoeuPhgWq3kbnjUSfqzaQyZxXP1a2sPUfAQLLkxqK97pkbgGFQmV1gbzBssGzGhs7PVu8vw7'))}',
                'privy-app-id': 'cmedf19v400j4l70bhm9ubix5',
              },
            ),
            data:
                '{"method": "eth_sign7702Authorization","params": {"contract": "0x736999a7f2e64c2e1F69F552c931E04cc1352443","chain_id": "15B32"}}',
          );
        } catch (e) {
          print('asd ${(e as DioException).response}');
        }
      },
      onFailure: (e) {
        print('asd $e');
      },
    );*/
  }

  Future<double> getBalance() async {
    mint();
    try {
      final wallet = currentUser?.embeddedEthereumWallets[0];
      final response = await Dio().get(
        'https://spicy-explorer.chiliz.com/api?module=account&action=eth_get_balance&address=${wallet?.address}',
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
            currentUser = u;
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
