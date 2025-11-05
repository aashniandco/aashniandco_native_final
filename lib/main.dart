// import 'package:aashniandco/bloc/text_change/state/text_bloc.dart';
// import 'package:aashniandco/constants/api_constants.dart';
// import 'package:aashniandco/constants/environment.dart';
// import 'package:aashniandco/features/designer/bloc/designers_bloc.dart';
// import 'package:aashniandco/features/newin/bloc/new_in_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'app/app.dart';
// import 'features/auth/bloc/home_screen_banner_bloc.dart';
// import 'features/newin/bloc/newin_products_bloc.dart';
// import 'features/shoppingbag/ shipping_bloc/shipping_bloc.dart';
// import 'features/shoppingbag/cart_bloc/cart_bloc.dart';
// import 'features/signup/bloc/signup_bloc.dart';
// import 'features/signup/repository/signup_repository.dart';
// import 'features/signup/view/signup_screen.dart';
//
// void main() {
//
//   ApiConstants.setEnvironment(Environment.stage);
//   runApp(
//     ProviderScope( // ✅ Wrap everything in ProviderScope for Riverpod
//       child: MultiBlocProvider(
//         providers: [
//           BlocProvider(create: (context) => TextBloc()),
//           BlocProvider(create: (context) => DesignersBloc()..add(FetchDesigners())),
//           BlocProvider(create: (context) => NewInBloc()),
//           BlocProvider(create: (context) => CartBloc()),
//           BlocProvider(create: (_) => ShippingBloc()),
//           BlocProvider(create: (_) => HomeScreenBannerBloc()),
//   BlocProvider(
//   create: (_) => SignupBloc(SignupRepository(baseUrl: 'https://stage.aashniandco.com')),
//   child: const SignupScreen(),
//   )
//
//
//   // BlocProvider(create: (context) => NewInProductsBloc(productRepository: productRepository, subcategory: subcategory)),
//           // BlocProvider(create: (_) => NewInBloc()),
//         ],
//         child: const MyApp(),
//       ),
//     ),
//   );
// }


// import 'package:aashniandco/bloc/text_change/state/text_bloc.dart';
// import 'package:aashniandco/constants/api_constants.dart';
// import 'package:aashniandco/constants/environment.dart';
// import 'package:aashniandco/features/designer/bloc/designers_bloc.dart';
// import 'package:aashniandco/features/newin/bloc/new_in_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// // import 'package:flutter_stripe/flutter_stripe.dart';
// import 'app/app.dart';
//
// // Import your repositories
// import 'package:aashniandco/features/shoppingbag/repository/cart_repository.dart';
//  // Make sure this path is correct
//
// import 'features/auth/bloc/home_screen_banner_bloc.dart';
// import 'features/auth/data/auth_repository.dart';
// import 'features/newin/bloc/newin_products_bloc.dart';
// import 'features/shoppingbag/ shipping_bloc/shipping_bloc.dart';
// import 'features/shoppingbag/cart_bloc/cart_bloc.dart';
// import 'features/shoppingbag/cart_bloc/cart_event.dart'; // Import the event
// import 'features/shoppingbag/repository/shipping_repository.dart';
// import 'features/signup/bloc/signup_bloc.dart';
// import 'features/signup/repository/signup_repository.dart';
// import 'features/signup/view/signup_screen.dart';
//
// void main() {
//   ApiConstants.setEnvironment(Environment.stage);
//
//   Stripe.publishableKey = 'pk_test_CjTXZoMy2Ax0gA2xZbf3F99u00fGR7Cnph';
//
//   // --- 1. Create your repository instances here ---
//   // These will be shared with any BLoC that needs them.
//   final CartRepository cartRepository = CartRepository();
//   final AuthRepository authRepository = AuthRepository();
//
//   // final ShippingRepository shippingRepository = ShippingRepository(); // etc.
//
//   runApp(
//     ProviderScope( // For Riverpod
//       child: MultiBlocProvider(
//         providers: [
//           BlocProvider(create: (context) => TextBloc()),
//           BlocProvider(create: (context) => DesignersBloc()..add(FetchDesigners())),
//           BlocProvider(create: (context) => NewInBloc()),
//
//           // --- 2. Provide the repositories to the CartBloc ---
//           BlocProvider(
//             create: (context) => CartBloc(
//               cartRepository: cartRepository, // Pass the instance
//               authRepository: authRepository,
//           // Pass the instance
//             )..add(FetchCartItems()), // 3. (Recommended) Load initial cart data
//           ),
//
//           BlocProvider(create: (_) => ShippingBloc()),
//           BlocProvider(create: (_) => HomeScreenBannerBloc()),
//           BlocProvider(
//             create: (_) => SignupBloc(SignupRepository(baseUrl: 'https://stage.aashniandco.com')),
//             // 'child' inside BlocProvider is generally not recommended.
//             // It's better to have the child widget be part of the main widget tree.
//           ),
//         ],
//         child: const MyApp(),
//       ),
//     ),
//   );
// }


// main.dart

import 'dart:io';

import 'package:aashniandco/bloc/text_change/state/text_bloc.dart';
import 'package:aashniandco/constants/api_constants.dart';
import 'package:aashniandco/constants/environment.dart';
import 'package:aashniandco/features/designer/bloc/designers_bloc.dart';
import 'package:aashniandco/features/newin/bloc/new_in_bloc.dart';
import 'package:aashniandco/features/welcome/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'app/app.dart';

// Import your repositories
import 'package:aashniandco/features/shoppingbag/repository/cart_repository.dart';
import 'package:aashniandco/features/auth/data/auth_repository.dart';
import 'package:aashniandco/features/signup/repository/signup_repository.dart';
import 'package:aashniandco/features/shoppingbag/repository/shipping_repository.dart';

// ✅ 1. Import Product BLoC and Repository
// Please adjust the paths to match your project structure.



// Import your BLoCs and Events
import 'features/auth/bloc/currency_bloc.dart';
import 'features/auth/bloc/currency_event.dart';
import 'features/auth/bloc/home_screen_banner_bloc.dart';
import 'features/auth/services/currency_service.dart';
import 'features/auth/services/ip_service.dart';
import 'features/categories/repository/api_service.dart';
import 'features/new_in_tabbar/api/product_repository.dart';
import 'features/new_in_tabbar/bloc/product_bloc.dart';
import 'features/search/bloc/search_bloc.dart';
import 'features/search/data/repositories/search_repository.dart';
import 'features/shoppingbag/ shipping_bloc/shipping_bloc.dart';
import 'features/shoppingbag/cart_bloc/cart_bloc.dart';
import 'features/shoppingbag/cart_bloc/cart_event.dart';
import 'features/signup/bloc/signup_bloc.dart';


// main.dart

import 'package:aashniandco/bloc/text_change/state/text_bloc.dart';
import 'package:aashniandco/constants/api_constants.dart';
import 'package:aashniandco/constants/environment.dart';
import 'package:aashniandco/features/designer/bloc/designers_bloc.dart';
import 'package:aashniandco/features/newin/bloc/new_in_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'app/app.dart';

// Import your repositories
import 'package:aashniandco/features/shoppingbag/repository/cart_repository.dart';
import 'package:aashniandco/features/auth/data/auth_repository.dart';
import 'package:aashniandco/features/signup/repository/signup_repository.dart';
import 'package:aashniandco/features/shoppingbag/repository/shipping_repository.dart';
import 'package:aashniandco/features/new_in_tabbar/api/product_repository.dart';

// ✅ 1. Import your SearchRepository
import 'package:aashniandco/features/search/data/repositories/search_repository.dart';


// Import your BLoCs and Events
import 'features/auth/bloc/home_screen_banner_bloc.dart';
import 'features/new_in_tabbar/bloc/product_bloc.dart';
import 'features/search/bloc/search_bloc.dart';
import 'features/shoppingbag/ shipping_bloc/shipping_bloc.dart';
import 'features/shoppingbag/cart_bloc/cart_bloc.dart';
import 'features/shoppingbag/cart_bloc/cart_event.dart';
import 'features/signup/bloc/signup_bloc.dart';
import 'features/welcome/welcome_scren.dart';
import 'http_overrides.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Your existing initialization
  HttpOverrides.global = MyHttpOverrides();
  ApiConstants.setEnvironment(Environment.prod);
  Stripe.publishableKey = 'pk_live_6AVyw9mDOfUeaSLLbFOheLcg00GGRaLY3K';
  await Stripe.instance.applySettings();

  // Create repository instances
  final authRepository = AuthRepository();
  final cartRepository = CartRepository();
  final signupRepository = SignupRepository(baseUrl: 'https://aashniandco.com');
  final shippingRepository = ShippingRepository();
  final productRepository = ProductRepository();
  final searchRepository = SearchRepository();
  final apiService = ApiService();
  final ipService = IpService();

  // Fetch IP (optional)
  try {
    final ipAddress = await ipService.getPublicIpAddress();
    print('Your IP: $ipAddress');
  } catch (e) {
    print('Could not fetch IP: $e');
  }

  runApp(
    ProviderScope(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ApiService>.value(value: apiService),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => TextBloc()),
            BlocProvider(create: (_) => DesignersBloc()..add(FetchDesigners())),
            BlocProvider(create: (_) => NewInBloc()),
            BlocProvider(create: (_) => HomeScreenBannerBloc()),
            BlocProvider(create: (_) => ShippingBloc()),
            BlocProvider(create: (_) => SignupBloc(signupRepository)),
            BlocProvider(create: (_) => CartBloc(
              cartRepository: cartRepository,
              authRepository: authRepository,
            )..add(FetchCartItems())),
            BlocProvider(create: (_) => ProductBloc(productRepository: productRepository)),
            BlocProvider(create: (_) => SearchBloc(searchRepository: searchRepository)),
            BlocProvider<CurrencyBloc>(create: (_) => CurrencyBloc(CurrencyService())..add(FetchCurrencyData())),
          ],
          // ✅ Set WelcomeScreen as the initial screen
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Aashni & Co',
            theme: ThemeData(primarySwatch: Colors.purple),
            home:  SplashScreen(),
            routes: {
              '/home': (context) => const MyApp(), // Your main app screen
            },
          ),
        ),
      ),
    ),
  );
}
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   HttpOverrides.global = MyHttpOverrides();
//   ApiConstants.setEnvironment(Environment.stage);
//   Stripe.publishableKey = 'pk_test_CjTXZoMy2Ax0gA2xZbf3F99u00fGR7Cnph';
//   await Stripe.instance.applySettings();
//
//   // --- Create repository instances ---
//   final AuthRepository authRepository = AuthRepository();
//   final CartRepository cartRepository = CartRepository();
//   final SignupRepository signupRepository = SignupRepository(baseUrl: 'https://stage.aashniandco.com');
//   final ShippingRepository shippingRepository = ShippingRepository();
//   final ProductRepository productRepository = ProductRepository();
//   final SearchRepository searchRepository = SearchRepository();
//
//   // ✅ 2. CREATE AN INSTANCE OF YOUR API SERVICE
//   final ApiService apiService = ApiService();
//
//   final ipService = IpService();
//
//   print('Fetching your public IP address...');
//
//   try {
//     // 2. Call the method. Since it returns a Future, you must use 'await'.
//     //    'await' pauses the execution until the Future completes.
//     final String ipAddress = await ipService.getPublicIpAddress();
//
//     // 3. Print the result to the console.
//     print('-----------------------------------------');
//     print('✅ SUCCESS! Your IP address is: $ipAddress');
//     print('-----------------------------------------');
//
//   } catch (e) {
//     // This block will run if the method throws an Exception.
//     print('------------------------------------');
//     print('❌ ERROR! Could not get IP address.');
//     print('Reason: $e');
//     print('------------------------------------');
//   }
//
//
//   runApp(
//     ProviderScope( // For existing Riverpod usage
//       // ✅ 3. WRAP WITH MULTIREPOSITORYPROVIDER TO PROVIDE NON-BLOC DEPENDENCIES
//       child: MultiRepositoryProvider(
//         providers: [
//           // ✅ 4. PROVIDE THE ApiService INSTANCE TO THE ENTIRE APP
//           // We use .value to provide an already-created instance.
//           RepositoryProvider<ApiService>.value(
//             value: apiService,
//           ),
//           // You can also provide other repositories here if you need to access them
//           // via `RepositoryProvider.of(context)` elsewhere in your app. For now,
//           // only ApiService is needed this way.
//           // Example:
//           // RepositoryProvider<SearchRepository>.value(value: searchRepository),
//         ],
//         child: MultiBlocProvider(
//           providers: [
//             // Existing BLoCs - no changes needed here
//             BlocProvider(create: (context) => TextBloc()),
//             BlocProvider(create: (context) => DesignersBloc()..add(FetchDesigners())),
//             BlocProvider(create: (context) => NewInBloc()),
//             BlocProvider(create: (_) => HomeScreenBannerBloc()),
//             BlocProvider(create: (_) => ShippingBloc()),
//             BlocProvider(
//               create: (_) => SignupBloc(signupRepository),
//             ),
//             BlocProvider(
//               create: (context) => CartBloc(
//                 cartRepository: cartRepository,
//                 authRepository: authRepository,
//               )..add(FetchCartItems()),
//             ),
//             BlocProvider(
//               create: (context) => ProductBloc(
//                 productRepository: productRepository,
//               ),
//             ),
//             BlocProvider(
//               create: (context) => SearchBloc(
//                 searchRepository: searchRepository, // Pass the instance directly
//               ),
//             ),
//
//       BlocProvider<CurrencyBloc>(
//         create: (context) => CurrencyBloc(CurrencyService())
//           ..add(FetchCurrencyData()), // Dispatch the new initial event
//       ),
//           ],
//           child: const MyApp(), // Your root widget
//         ),
//       ),
//     ),
//   );
// }


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   HttpOverrides.global = MyHttpOverrides();
//   ApiConstants.setEnvironment(Environment.stage);
//   Stripe.publishableKey = 'pk_test_CjTXZoMy2Ax0gA2xZbf3F99u00fGR7Cnph';
//   await Stripe.instance.applySettings();
//
//   // --- Create repository instances ---
//   final AuthRepository authRepository = AuthRepository();
//   final CartRepository cartRepository = CartRepository();
//   final SignupRepository signupRepository = SignupRepository(baseUrl: 'https://stage.aashniandco.com');
//   final ShippingRepository shippingRepository = ShippingRepository();
//   final ProductRepository productRepository = ProductRepository();
//
//   // ✅ 2. Create an instance of your SearchRepository
//   final SearchRepository searchRepository = SearchRepository();
//
//
//   runApp(
//     ProviderScope( // For Riverpod
//       child: MultiBlocProvider(
//         providers: [
//           // Existing BLoCs
//           BlocProvider(create: (context) => TextBloc()),
//           BlocProvider(create: (context) => DesignersBloc()..add(FetchDesigners())),
//           BlocProvider(create: (context) => NewInBloc()),
//           BlocProvider(create: (_) => HomeScreenBannerBloc()),
//           BlocProvider(create: (_) => ShippingBloc()),
//           BlocProvider(
//             create: (_) => SignupBloc(signupRepository),
//           ),
//           BlocProvider(
//             create: (context) => CartBloc(
//               cartRepository: cartRepository,
//               authRepository: authRepository,
//             )..add(FetchCartItems()),
//           ),
//           BlocProvider(
//             create: (context) => ProductBloc(
//               productRepository: productRepository,
//             ),
//           ),
//
//           // ✅ 3. Provide the SearchBloc correctly
//           BlocProvider(
//             create: (context) => SearchBloc(
//               searchRepository: searchRepository, // Pass the instance directly
//             ),
//           )
//         ],
//         child: const MyApp(),
//       ),
//     ),
//   );
// }
