import 'screen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'database/drift_database.dart';
import 'package:get_it/get_it.dart';
import 'provider/schedule_provider.dart';
import 'repository/schedule_repository.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screen/splash_screen.dart';
import '../login.dart'; // 로그인 페이지 import 추가
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screen/main_screen.dart';
import '../signPage.dart';
import 'services/notification_service.dart'; // NotificationService import 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting();

  final database = LocalDatabase();
  final repository = ScheduleRepository();
  final scheduleProvider = ScheduleProvider(repository: repository);

  GetIt.I.registerSingleton<LocalDatabase>(database);

  final NotificationService _notificationService = NotificationService(); // NotificationService 인스턴스 생성
  await _notificationService.init(); // NotificationService 초기화

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ScheduleProvider>(
          create: (_) => scheduleProvider,
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('ko', 'KR'), // Korean
      ],
      routes: {
        '/login': (context) => LoginPage(), // 로그인 페이지 라우트 추가
        '/main': (context) => MainScreen(), // 메인 페이지 라우트 추가
        '/sign': (context) => SignPage(),   // 회원가입 페이지 라우트 추가
      },
    );
  }
}

