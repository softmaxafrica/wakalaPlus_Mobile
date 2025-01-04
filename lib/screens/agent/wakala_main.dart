import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../../api_services/agent_apis.dart';
import '../../data_controllers/customerRequestsController.dart';
import '../../shared/custom_theme.dart';
import '../../shared/navigation.dart';

import 'agent_home.dart';
import 'wakala_history.dart';
import 'wakala_mawasiliano.dart';

class WakalaMain extends StatelessWidget {
  WakalaMain({Key? key}) : super(key: key);

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: WakalaBottomBarWidget(),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              return AgentMap();
            },
          ),
          GoRoute(
            path: '/agent_history',
            builder: (context, state) {
              return WakalaHistory();
            },
          ),
          GoRoute(
            path: '/agent_communication',
            builder: (context, state) {
              return WakalaCommunications();
            },
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      themeMode: ThemeMode.dark,
      darkTheme: darkTheme,
       routerConfig: _router,
    );
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CustomerRequestsController()),
        ChangeNotifierProvider(create: (context) => AgentApiServices()),

      ],
      child: WakalaMain(),
    ),
  );
}
