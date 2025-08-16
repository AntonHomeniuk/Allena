class DashboardModel {
  final String title;
  final String desc;
  final List<String> charities;
  final List<String> tags;
  final String imgName;
  final int price;

  DashboardModel({
    required this.title,
    required this.desc,
    required this.charities,
    required this.tags,
    required this.imgName,
    required this.price,
  });
}
