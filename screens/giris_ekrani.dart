import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'ana_sayfa.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});
  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final TextEditingController _userController = TextEditingController();
  bool yukleniyor = false;
  String hataMesaji = "";

  Future<void> girisYap() async {
    if (_userController.text.length < 3) {
      setState(() {
        hataMesaji = "Kullanıcı adı en az 3 karakter olmalı.";
      });
      return;
    }

    setState(() {
      yukleniyor = true;
      hataMesaji = "";
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/giris-yap'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"username": _userController.text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', data['username']);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AnaSayfa()),
          );
        }
      } else {
        setState(() {
          hataMesaji = "Sunucu hatasi: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        hataMesaji = "Sunucuya bağlanırken bir hata oluştu.";
      });
    } finally {
      setState(() {
        yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 80,
                color: Colors.purpleAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                "A S T R A",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
              ),
              const Text("Giriş Kapısı", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              TextField(
                controller: _userController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Ruhani Adın Nedir?",
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 10),
              if (hataMesaji.isNotEmpty)
                Text(
                  hataMesaji,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: yukleniyor ? null : girisYap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: yukleniyor
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "KAPIYI AÇ ",
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}