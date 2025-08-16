import 'package:allena/main.dart';
import 'package:allena/repo/user_repo.dart';
import 'package:allena/ui/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = getIt.get<UserRepo>().currentUser;
    final address = currentUser?.embeddedEthereumWallets.firstOrNull?.address;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder(
              future: getIt.get<UserRepo>().getBalance(),
              builder: (context, snap) => Text(
                '${snap.data ?? '...'} CHZ',
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              '${address?.substring(0, 5)}...${address?.substring(address.length - 4, address.length)}',
              textAlign: TextAlign.center,
            ),
            Expanded(child: DashboardScreen()),
          ],
        ),
      ),
    );
  }
}
