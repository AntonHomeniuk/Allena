class DashboardModel {
  final String? contract;
  final String title;
  final String desc;
  final List<String> charities;
  final List<String> tags;
  final String imgName;
  final int price;
  final int priceWei;

  DashboardModel({
    this.contract,
    required this.title,
    required this.desc,
    required this.charities,
    required this.tags,
    required this.imgName,
    required this.price,
    required this.priceWei,
  });
}
