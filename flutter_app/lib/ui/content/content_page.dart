import 'package:allena/ui/content/content_screen.dart';
import 'package:allena/ui/dashboard/dashboard_model.dart';
import 'package:flutter/material.dart';

class ContentPage extends StatelessWidget {
  final DashboardModel item;

  const ContentPage(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: ContentScreen(item));
  }
}
