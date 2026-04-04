import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/provider/auth_provider.dart';
import 'core/provider/report_provider.dart';
import 'core/store/app_store.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/contacts/contacts_page.dart';
import 'features/explore/explore_page.dart';
import 'features/home/home_page.dart';
import 'features/profile/profile_page.dart';
import 'features/reports/report_page.dart';
import 'features/reports/reports_page.dart';
import 'features/welcome/welcome_page.dart';

class CiviLinkApp extends StatefulWidget {
  const CiviLinkApp({super.key});

  @override
  State<CiviLinkApp> createState() => _CiviLinkAppState();
}

class _CiviLinkAppState extends State<CiviLinkApp> {
  final store = AppStore();
  late final AuthProvider authProvider = AuthProvider(store);
  late final ReportProvider reportProvider = ReportProvider(store);
  late final Future<void> _init;

  @override
  void initState() {
    super.initState();
    _init = store.init();
  }

  @override
  void dispose() {
    authProvider.dispose();
    reportProvider.dispose();
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MaterialPageRoute<dynamic> routeTo(Widget page, [RouteSettings? settings]) {
      return MaterialPageRoute(builder: (_) => page, settings: settings);
    }

    MaterialPageRoute<dynamic> memberRoute(Widget page, [RouteSettings? settings]) {
      if (store.isMember) {
        return routeTo(page, settings);
      }
      return routeTo(LoginPage(store: store), const RouteSettings(name: '/connexion'));
    }

    authProvider.bindStore(store);
    reportProvider.bindStore(store);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStore>.value(value: store),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ReportProvider>.value(value: reportProvider),
      ],
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          return FutureBuilder<void>(
            future: _init,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light(),
                  darkTheme: AppTheme.dark(),
                  themeMode: AppTheme.getThemeMode(store.themeMode),
                  home: const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: AppTheme.getThemeMode(store.themeMode),
                home: WelcomePage(store: store),
                onGenerateRoute: (settings) {
                  switch (settings.name) {
                    case '/':
                      return routeTo(WelcomePage(store: store), settings);
                    case '/accueil':
                      return memberRoute(HomePage(store: store), settings);
                    case '/explorer':
                      return routeTo(ExplorePage(store: store), settings);
                    case '/connexion':
                      return routeTo(LoginPage(store: store), settings);
                    case '/inscription':
                      return routeTo(const RegisterPage(), settings);
                    case '/signaler':
                      return memberRoute(const ReportPage(), settings);
                    case '/signaler-rapide':
                      return routeTo(const ReportPage(quickMode: true), settings);
                    case '/signalements':
                      return memberRoute(ReportsPage(store: store), settings);
                    case '/profil':
                      return memberRoute(ProfilePage(store: store), settings);
                    case '/contacts':
                      return routeTo(const ContactsPage(), settings);
                    default:
                      return routeTo(WelcomePage(store: store), settings);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
