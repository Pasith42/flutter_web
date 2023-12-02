import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web/datatable.dart';
import 'package:flutter_web/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ตารางข้อมูลครุภัณฑ์และพัสดุ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ตารางข้อมูลครุภัณฑ์และพัสดุ'),
    );
  }
}
