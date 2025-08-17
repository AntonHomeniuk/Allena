import 'package:allena/main.dart';
import 'package:allena/repo/user_repo.dart';
import 'package:allena/ui/dashboard/dashboard_model.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _freeSelected = true;
  bool _paidSelected = true;

  @override
  Widget build(BuildContext context) {
    final items = dashboardList.where((i) {
      if (_freeSelected && _paidSelected) return true;
      if (i.price > 0) {
        return _paidSelected;
      } else {
        return _freeSelected;
      }
    }).toList();

    return Column(
      children: [
        Row(
          children: [
            Spacer(),
            GestureDetector(
              onTap: () {
                setState(() {
                  _freeSelected = !_freeSelected;

                  if (!_freeSelected && !_paidSelected) {
                    _paidSelected = true;
                  }
                });
              },
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  border: BoxBorder.all(color: Color(0xFF77FE53).withAlpha(38)),
                  color: (_freeSelected)
                      ? Color(0xFF77FE53).withAlpha(38)
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 4, 13, 4),
                  child: Text(
                    'Free',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _paidSelected = !_paidSelected;

                  if (!_freeSelected && !_paidSelected) {
                    _freeSelected = true;
                  }
                });
              },
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  border: BoxBorder.all(color: Color(0xFF77FE53).withAlpha(38)),
                  color: (_paidSelected)
                      ? Color(0xFF77FE53).withAlpha(38)
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 4, 13, 4),
                  child: Text(
                    'Paid',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            itemBuilder: (BuildContext context, int index) {
              final item = items[index];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 76,
                            height: 86,
                            child: ClipRRect(
                              borderRadius: BorderRadiusGeometry.all(
                                Radius.circular(16),
                              ),
                              child: Image.asset(
                                'assets/dash_imgs/${item.imgName}',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  item.desc,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Color(0xffB3B2B2)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        child: Container(
                          height: 1,
                          color: Colors.white.withAlpha(26),
                        ),
                      ),
                      Text(
                        'Charities: ${item.charities.join(',\n')}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Color(0xffB3B2B2),
                        ),
                      ),
                      SizedBox(height: 16),
                      StreamBuilder<List<String>?>(
                        stream: getIt.get<UserRepo>().nftCollectionStream,
                        builder: (context, snap) {
                          final nftCollection =
                              (snap.data ??
                              getIt.get<UserRepo>().nftCollection);

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Wrap(
                                  runSpacing: 4,
                                  spacing: 4,
                                  children: item.tags
                                      .map(
                                        (e) => Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(12),
                                            ),
                                            border: BoxBorder.all(
                                              color: Color(
                                                0xFF77FE53,
                                              ).withAlpha(38),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              13,
                                              4,
                                              13,
                                              4,
                                            ),
                                            child: Text(e),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (item.price > 0 &&
                                      (nftCollection?.contains(
                                            item.contract?.toLowerCase(),
                                          ) ==
                                          false)) {
                                    showLoadingDialog();

                                    getIt<UserRepo>().mint(
                                      item.contract!,
                                      item.priceWei,
                                      () {
                                        hideLoadingDialog();
                                      },
                                      (e) {
                                        hideLoadingDialog();
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    color:
                                        (nftCollection == null &&
                                            item.price > 0)
                                        ? Color(0xFF77FE53).withAlpha(25)
                                        : Color(0xFF77FE53),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      13,
                                      4,
                                      13,
                                      4,
                                    ),
                                    child: Text(
                                      (item.price > 0)
                                          ? (nftCollection?.contains(
                                                      item.contract
                                                          ?.toLowerCase(),
                                                    )) ==
                                                    true
                                                ? 'Bought'
                                                : '${item.price}\$'
                                          : 'Free',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                SizedBox(height: 8),
            itemCount: items.length,
          ),
        ),
      ],
    );
  }

  final List<DashboardModel> dashboardList = [
    DashboardModel(
      contract: '0xc68b811d28d140ec04666ad970d00fee5156f400',
      title: 'From Dreams to Goals',
      desc: 'My journey, how I achieved success and play football',
      charities: [
        'Portugal Youth Football Academies',
        'Global Children’s Health & Education',
        'African Grassroots Sports Programs',
      ],
      tags: ['Football', 'LifeStyle', 'Inspiration', 'Motivation'],
      imgName: '1.jpg',
      price: 50,
      priceWei: 1000000000000000000,
    ),
    DashboardModel(
      title: 'From Dreams to Goals',
      desc: 'My journey, how I achieved success and play football',
      charities: [
        'Youth Hockey Development',
        'Children’s Hospitals & Health Programs',
        'Global Sports Access',
      ],
      tags: ['Hockey', 'Leadership', 'Sports Legacy', 'NHL'],
      imgName: '2.jpg',
      price: 0,
      priceWei: 0,
    ),
    DashboardModel(
      contract: '0x736999a7f2e64c2e1F69F552c931E04cc1352443',
      title: 'From Dreams to Goals',
      desc: 'My journey, how I achieved success and play football',
      charities: [
        'Global Food Relief',
        'Education & Schools',
        'Environmental Projects',
      ],
      tags: ['YouTube', 'Global Impact', 'Challenge', 'Charity'],
      imgName: '3.jpg',
      price: 10,
      priceWei: 1,
    ),
    DashboardModel(
      title: 'From Dreams to Goals',
      desc: 'My journey, how I achieved success and play football',
      charities: [
        'Youth Martial Arts Academies',
        'Irish Community Support',
        'Global Health & Recovery Programs',
      ],
      tags: ['MMA', 'UFC', 'Fighting Spirit', 'Discipline'],
      imgName: '4.jpg',
      price: 0,
      priceWei: 0,
    ),
    DashboardModel(
      contract: '0x5caDB0DF90A197387C3c1C48c3f259E50fe34735',
      title: 'From Dreams to Goals',
      desc: 'My journey, how I achieved success and play football',
      charities: [
        'I PROMISE School',
        'Basketball Youth Development',
        'Social Justice & Community Programs',
      ],
      tags: ['Basketball', 'NBA', 'Education', 'Leadership'],
      imgName: '5.jpg',
      price: 10,
      priceWei: 100000000000000,
    ),
  ];
}
