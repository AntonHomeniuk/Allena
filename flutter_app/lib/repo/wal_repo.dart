import 'dart:convert';

import 'package:allena/ui/dashboard/dashboard_model.dart';
import 'package:dio/dio.dart';

class WalRepo {
  final stubListBlobId = 'gmags6Cx_LCsh3isvwy4hWvQTU6d_3hcSowDaZ_wTW4';

  WalRepo() {
    //stubCreateListToWal();
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
      print('asd $response');
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
    title: 'The path to your dream starts here',
    desc:
        'How to start playing: first trainings, basic exercises, and football tricks.',
    charities: [],
    tags: ['Football', 'LifeStyle', 'Inspiration', 'Motivation'],
    imgName: '1.jpg',
    videoName: '1.mp4',
    price: 0,
    priceWei: 0,
  ),
  DashboardModel(
    contract: '0x13f3c6900a78d427F47C5A1ef033b27e3863A31B',
    title: 'Champion’s Code',
    desc:
        'Exclusive trainings, unique methods, personal growth, and investment in the future.',
    charities: [
      'Portugal Youth Football Academies',
      'Global Children’s Health & Education',
      'African Grassroots Sports Programs',
    ],
    tags: ['Football', 'LifeStyle', 'Inspiration', 'Motivation'],
    imgName: '1_1.jpg',
    videoName: '1_1.mp4',
    price: 50,
    priceWei: 1000000000000000000,
  ),
  DashboardModel(
    title: 'First Step on the Ice',
    desc:
        'How to start playing hockey: basic exercises, first shots, and the values of team play. Lessons of discipline and perseverance.',
    charities: [],
    tags: ['Hockey', 'Leadership', 'Sports Legacy', 'NHL'],
    imgName: '2.jpg',
    videoName: '2.mp4',
    price: 0,
    priceWei: 0,
  ),
  DashboardModel(
    title: 'Above the Ice',
    desc:
        'How to build a career and life with a champion’s mindset. From training to leadership and balance between sport and family.',
    charities: [
      'Youth Hockey Development',
      'Children’s Hospitals & Health Programs',
      'Global Sports Access',
    ],
    tags: ['Hockey', 'Leadership', 'Sports Legacy', 'NHL'],
    imgName: '2_2.jpg',
    videoName: '2_2.mp4',
    price: 10,
    priceWei: 100000000000000,
    contract: '0x5caDB0DF90A197387C3c1C48c3f259E50fe34735',
  ),
  DashboardModel(
    title: 'Step by Step',
    desc:
        'Stories about how small ideas turn into big projects. Simple challenges and lessons of persistence that show anyone can start their own path to success.',
    charities: [],
    tags: ['YouTube', 'Global Impact', 'Challenge', 'Charity'],
    imgName: '3.jpg',
    price: 0,
    videoName: '3.mp4',
    priceWei: 0,
  ),
  DashboardModel(
    contract: '0x736999a7f2e64c2e1F69F552c931E04cc1352443',
    title: 'Creator’s Code',
    desc:
        'How to launch large-scale projects, work with a team, invest in ideas, and build a personal brand.',
    charities: [
      'Global Food Relief',
      'Education & Schools',
      'Environmental Projects',
    ],
    tags: ['YouTube', 'Global Impact', 'Challenge', 'Charity'],
    imgName: '3_3.jpg',
    price: 10,
    videoName: '3_3.mp4',
    priceWei: 1,
  ),
];
