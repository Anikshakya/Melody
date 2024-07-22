import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/src/services/notification_service.dart';
import 'package:melody/src/views/main_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
   await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}