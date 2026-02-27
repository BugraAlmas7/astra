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
import '../core/sabitler.dart'; 
import '../widgets/ortak_bilesenler.dart';

class DogumHaritasiSayfasi extends StatefulWidget {
  const DogumHaritasiSayfasi({super.key});
  @override
  State<DogumHaritasiSayfasi> createState() => _DogumHaritasiSayfasiState();
}

class _DogumHaritasiSayfasiState extends State<DogumHaritasiSayfasi> {
  final _i = TextEditingController(),
      _t = TextEditingController(),
      _s = TextEditingController(),
      _y = TextEditingController();
  String yorum = "";
  bool yukleniyor = false;
  Future<void> yap() async {
    setState(() => yukleniyor = true);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/analiz-dogum-haritasi'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "isim": _i.text,
          "dogum_tarihi": _t.text,
          "dogum_saati": _s.text,
          "dogum_yeri": _y.text,
        }),
      );
      if (res.statusCode == 200) {
        setState(
          () =>
              yorum = jsonDecode(utf8.decode(res.bodyBytes))['interpretation'],
        );
      }
    } catch (e) {}
    setState(() => yukleniyor = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Harita")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _i,
                decoration: const InputDecoration(labelText: "Isim"),
              ),
              TextField(
                controller: _t,
                decoration: const InputDecoration(
                  labelText: "Tarih (GG.AA.YYYY)",
                ),
              ),
              TextField(
                controller: _s,
                decoration: const InputDecoration(labelText: "Saat (SS:DK)"),
              ),
              TextField(
                controller: _y,
                decoration: const InputDecoration(labelText: "Yer"),
              ),
              ElevatedButton(
                onPressed: yukleniyor ? null : yap,
                child: const Text("ANALIZ"),
              ),
              if (yorum.isNotEmpty) SonucKutusu(metin: yorum),
            ],
          ),
        ),
      ),
    );
  }
}