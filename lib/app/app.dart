


import 'package:aashniandco/app/theme.dart';
import 'package:flutter/material.dart';

import '../features/auth/view/auth_screen.dart';
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aashni + Co',
      theme: AppTheme.lightTheme,
      home: AuthScreen(),
    );
  }
}




// import 'package:aashniandco/bloc/login/login_screen_bloc.dart';
// import 'package:aashniandco/features/accessories/accessories.dart';
// import 'package:aashniandco/features/auth/view/auth_screen.dart';
// import 'package:aashniandco/features/auth/view/login_screen.dart';
// import 'package:aashniandco/features/categories/view/categories_screen.dart';
// import 'package:aashniandco/features/categories/view/menu_categories_screen.dart';
// import 'package:aashniandco/features/auth/view/auth_screen.dart';
// import 'package:aashniandco/panaroma.dart';
// import 'package:aashniandco/prac/count.dart';
// import 'package:flutter/material.dart';
// import 'package:aashniandco/features/auth/view/auth_screen.dart';
// import 'theme.dart';
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Aashni + Co',
//       theme: AppTheme.lightTheme,
//       home: AuthScreen(),
//        // No need for ambiguity now
//         // home: Counter(),
//         // home:PanoramaScreen()
//     );
//   }
// }