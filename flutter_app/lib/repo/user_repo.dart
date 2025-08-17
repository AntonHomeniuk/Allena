import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:privy_flutter/privy_flutter.dart';
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

class UserRepo {
  late final Privy privy;
  PrivyUser? currentUser;
  List<String>? nftCollection;
  late final StreamController<List<String>?> _nftCollectionController =
      StreamController.broadcast();

  Stream<List<String>?> get nftCollectionStream {
    return _nftCollectionController.stream;
  }

  double? balance;
  late final StreamController<double?> _balanceStreamController =
      StreamController.broadcast();

  Stream<double?> get balanceStream {
    return _balanceStreamController.stream;
  }

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

  Future<void> mint(
    String contractHex,
    int price,
    void Function() onSuccess,
    void Function(PrivyException error) onFailure,
  ) async {
    const String contractAbi = '''
[
  {
    "inputs": [
      {"internalType": "address", "name": "to", "type": "address"},
      {"internalType": "string", "name": "uri", "type": "string"}
    ],
    "name": "safeMint",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  }
]
''';

    final wallet = currentUser!.embeddedEthereumWallets[0];

    final contract = DeployedContract(
      ContractAbi.fromJson(contractAbi, 'ChilizNFT'),
      EthereumAddress.fromHex(contractHex),
    );

    // Encode the function call data
    final mintFunction = contract.function('safeMint');
    final data = mintFunction.encodeCall([
      EthereumAddress.fromHex(wallet.address),
      'blah blah',
    ]);

    final tx = {
      'from': wallet.address,
      'to': contract.address.with0x,
      'data': '0x${bytesToHex(data)}',
      'value': '0x${price.toRadixString(16)}',
      'chainId': '0x${88882.toRadixString(16)}',
    };

    final result = await wallet.provider.request(
      EthereumRpcRequest(
        method: 'eth_sendTransaction',
        params: [jsonEncode(tx)],
      ),
    );

    result.fold(
      onSuccess: (txHash) async {
        onSuccess.call();

        await Future.delayed(Duration(milliseconds: 200));
        nftCollection = List.of(nftCollection ?? [])..add(contractHex);
        _nftCollectionController.add(nftCollection);
        balance = null;
        _balanceStreamController.add(null);
        await Future.delayed(Duration(seconds: 10));
        await getBalance();
      },
      onFailure: (error) {
        onFailure.call(error);
      },
    );
  }

  Future<void> getNftsCollection() async {
    try {
      final wallet = currentUser?.embeddedEthereumWallets[0];

      final response =
          await Dio(
            BaseOptions(
              headers: {
                'x-api-key':
                    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJub25jZSI6ImE5NjBmNzkyLTVlNjktNDA1OC1iMTExLWY0OGU0OWMyNmVlNCIsIm9yZ0lkIjoiNDY1NTIzIiwidXNlcklkIjoiNDc4OTI0IiwidHlwZUlkIjoiYTVjNWI1YTgtYmQ5Zi00ZTQxLTg1NDktMGM1MmRkZTUyYzRlIiwidHlwZSI6IlBST0pFQ1QiLCJpYXQiOjE3NTUzNzgyNDcsImV4cCI6NDkxMTEzODI0N30.pGFkUplq_EeoUcWL7LiE_qBRNzkMu59W4LnupjbdLTs',
              },
            ),
          ).get(
            'https://deep-index.moralis.io/api/v2.2/${wallet?.address}/nft/collections?chain=chiliz%20testnet',
          );
      nftCollection =
          ((response.data as Map<String, dynamic>)['result'] as List<dynamic>)
              .map(
                (e) => ((e as Map<String, dynamic>)['token_address'] as String)
                    .toLowerCase(),
              )
              .toList();

      _nftCollectionController.add(nftCollection);
    } catch (_) {}
  }

  Future<double> getBalance() async {
    balance = null;
    _balanceStreamController.add(null);

    try {
      final wallet = currentUser?.embeddedEthereumWallets[0];
      await getNftsCollection();
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
      this.balance = balance / 1_000_000_000_000_000_000.0;
      _balanceStreamController.add(this.balance ?? 0);
      return this.balance ?? 0;
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
