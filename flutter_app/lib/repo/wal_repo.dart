import 'dart:convert';

import 'package:allena/ui/dashboard/dashboard_model.dart';
import 'package:dio/dio.dart';

class WalRepo {
  final stubListBlobId = '2cR9bBP2UolaFUJLE6xC8Wwa-vh0r-rQNVgfMRB5pd0';

  WalRepo() {
    //getDashboardListFromWal();
  }

  Future<List<DashboardModel>?> getDashboardListFromWal() async {
    try {
      final response = await Dio().get(
        'https://aggregator.walrus-testnet.walrus.space/v1/blobs/$stubListBlobId',
      );
      final decodedResponse = (jsonDecode(response.data) as List<dynamic>).map(
        (e) => DashboardModel.fromJson(e as Map<String, dynamic>),
      );

      return decodedResponse.toList();
    } catch (_) {}

    return null;
  }

  Future<void> stubCreateListToWal() async {
    try {
      var response = await Dio().put(
        'https://publisher.walrus-testnet.walrus.space/v1/blobs',
        data: jsonEncode(dashboardList.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }
}

/*try {
var response = await Dio().put(
'https://publisher.walrus-testnet.walrus.space/v1/blobs',
data: 'Authenticated. User data: {linkedAccounts: [{type: email, emailAddress: anton',
);
print('asd $response');

response = await Dio().get(
'https://aggregator.walrus-testnet.walrus.space/v1/blobs/mVuNnWBMPalq1SNjxWKRN_SyYNcm5g4izOHTnh754o8',
);
print('asd $response');
} catch (e) {
print('asd $e');
}*/
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
