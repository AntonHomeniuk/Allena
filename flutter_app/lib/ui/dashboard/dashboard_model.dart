class DashboardModel {
  final String? contract;
  final String title;
  final String desc;
  final List<String> charities;
  final List<String> tags;
  final String imgName;
  final String videoName;
  final int price;
  final int priceWei;

  DashboardModel({
    this.contract,
    required this.title,
    required this.desc,
    required this.charities,
    required this.tags,
    required this.imgName,
    required this.videoName,
    required this.price,
    required this.priceWei,
  });

  DashboardModel.fromJson(Map<String, dynamic> json)
    : contract = json['contract'] as String?,
      title = json['title'] as String,
      desc = json['desc'] as String,
      charities = (json['charities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      tags = (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      imgName = json['imgName'] as String,
      videoName = json['videoName'] as String,
      price = json['price'] as int,
      priceWei = json['priceWei'] as int;

  Map<String, dynamic> toJson() => {
    'contract': contract,
    'title': title,
    'desc': desc,
    'charities': charities,
    'tags': tags,
    'imgName': imgName,
    'videoName': videoName,
    'price': price,
    'priceWei': priceWei,
  };
}
