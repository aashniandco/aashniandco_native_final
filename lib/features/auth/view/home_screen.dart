import 'package:aashniandco/features/common/widgets/tab_bar_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/logo.jpeg',
            height: 30,
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          bottom: const TabBarWidget(),
        ),
        body: TabBarView(
          children: [
            Center(child: Text("Editorial Content")),
            Center(child: Text("Featured Content")),
            Center(child: Text("New In Content")),
            Center(child: Text("Categories Content")),
          ],
        ),
      ),
    );
  }
}
