import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/categories_page.dart';
import 'pages/budgets_page.dart';
import 'pages/expenses_page.dart';
import 'pages/home_page.dart';
import 'pages/incomings_page.dart';
import 'pages/payers_page.dart';
import 'pages/payment_types_page.dart';
import 'utils/app_constants.dart';
import 'utils/app_routes.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
        navigatorKey: AppConstants.globalNavKey,
        locale: const Locale('pt', 'BR'),
        theme: ThemeData(
            primarySwatch: AppConstants.primaryColor,
            scaffoldBackgroundColor: Colors.grey[100]),
        routes: {
          AppRoutes.HOME: (ctx) => const HomePage(),
          AppRoutes.BUDGETS: (ctx) => const BudgetsPage(),
          AppRoutes.EXPENSES: (ctx) => const ExpensesPage(),
          AppRoutes.INCOMINGS: (ctx) => const IncomingsPage(),
          AppRoutes.CATEGORIES: (ctx) => const CategoriesPage(),
          AppRoutes.PAYERS: (ctx) => const PayersPage(),
          AppRoutes.PAYMENT_TYPES: (ctx) => const PaymentTypesPage(),
        },
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate]);
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
