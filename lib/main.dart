import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsw/screens/chatscreen.dart';
import 'package:vsw/screens/login.dart';
import 'package:vsw/services/signalr.dart';


import 'api_services/agent_apis.dart';
import 'data_controllers/CustomerController.dart';
import 'data_controllers/customerRequestsController.dart';
import 'screens/agent/wakala_main.dart';
import 'screens/customer/mteja_home.dart';
import 'shared/custom_theme.dart';

 //
// void main() {
//   runApp(const MyApp());
// }
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CustomerRequestsController()),
        ChangeNotifierProvider(create: (context) => AgentApiServices()),
        ChangeNotifierProvider(create: (_) => CustomerController()),
        ChangeNotifierProvider(create: (_) => SignalRService()),

      ],
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      initialLocation: '/',

      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return Scaffold(
              body: child,
              // bottomNavigationBar: BottomBarWidget(),
            );
          },

          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) {
                // return LoginScreen();
                return ChatScreen();
              },
            ),
            GoRoute(
              path: '/agent_home',
              builder: (context, state) {
                return WakalaMain();
              },
            ),
            GoRoute(
              path: '/customer_home',
              builder: (context, state) {
                final String customerId = '0658009004'; // Replace with actual customerId
                return MtejaHome();
              },
            ),

          ],
        ),
      ],
    );


    return MaterialApp.router(
      themeMode: ThemeMode.dark,
      darkTheme: darkTheme,
      routerConfig: _router,
    );

  }
}

