import 'package:allena/main.dart';
import 'package:allena/repo/user_repo.dart';
import 'package:allena/repo/wal_repo.dart';
import 'package:allena/ui/dashboard/dashboard_screen.dart';
import 'package:allena/ui/map/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:privy_flutter/privy_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = getIt.get<UserRepo>().currentUser;
    final address = currentUser?.embeddedEthereumWallets.firstOrNull?.address;
    getIt<UserRepo>().getBalance();

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(Icons.book_outlined),
            icon: Icon(Icons.book_outlined),
            label: 'Courses',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.map_outlined),
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
      ),
      body: (currentPageIndex == 1)
          ? MapPage()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: address ?? ''));
                          HapticFeedback.mediumImpact();
                          Fluttertoast.showToast(msg: 'Copied');
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0x1FFFFFFF),
                              border: Border.all(color: Color(0x3FFFFFFF)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: SizedBox(
                                    height: 34,
                                    child: Image.asset('assets/ava_stub.webp'),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 8,
                                    top: 4,
                                    bottom: 4,
                                    left: 2,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${address?.substring(0, 5)}...${address?.substring(address.length - 4, address.length)}',
                                      ),
                                      Text(
                                        (currentUser!.linkedAccounts[0]
                                                as EmailAccount)
                                            .emailAddress,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          getIt.get<UserRepo>().getBalance();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16, left: 8),
                          child: StreamBuilder<double?>(
                            stream: getIt.get<UserRepo>().balanceStream,
                            builder: (context, snap) {
                              return Text(
                                'Balance: ${(snap.data ?? getIt.get<UserRepo>().balance)?.toStringAsFixed(1) ?? '...'}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleSmall,
                              );
                            },
                          ),
                        ),
                      ),
                      /*ElevatedButton(
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
                ),*/
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: getIt.get<WalRepo>().getDashboardListFromWal(),
                    builder: (context, asyncSnapshot) {
                      final items = asyncSnapshot.data;
                      if (items == null) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (items.isNotEmpty) {
                        return DashboardScreen(items);
                      }
                      return Center(child: Text('Failed to load'));
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
