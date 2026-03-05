import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mistik_flutter/screens/ana_sayfa_guncelleme.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/ana_sayfa.dart';
import 'screens/giris_ekrani.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? kayitliUser = prefs.getString('username');
  runApp(
    AstraApp(
      baslangicEkrani: kayitliUser != null
          ? AstraAnaSayfa()
          : GirisEkrani(),
    ),
  );
}



class AstraApp extends StatelessWidget {
  final Widget baslangicEkrani;

  const AstraApp({super.key, required this.baslangicEkrani});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASTRA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E0018),
        useMaterial3: true,
        primaryColor: Colors.purple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          surface: const Color(0xFF1A002B),
        ),
        textTheme: GoogleFonts.cinzelTextTheme(Theme.of(context).textTheme)
            .apply(
              bodyColor: const Color(0xFFE0D0FF),
              displayColor: const Color(0xFFE0D0FF),
            ),
      ),
      home:  AstraAnaSayfa(),
    );
  }
}

