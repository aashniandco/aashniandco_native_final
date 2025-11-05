import 'package:flutter/material.dart';

class TabBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const TabBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      labelColor: Colors.black,
      indicatorColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      tabs: [
        Tab(text: "Editorial"),
        Tab(text: "Featured"),
        Tab(text: "New In"),
        Tab(text: "Categories"),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48.0);
}
