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

class BurcSayfasi extends StatefulWidget {
  const BurcSayfasi({super.key});
  @override
  State<BurcSayfasi> createState() => _BurcSayfasiState();
}

class _BurcSayfasiState extends State<BurcSayfasi> {
  String secilen = "Koç";
  String yorum = "";
  bool yukleniyor = false;
  Future<void> getir() async {
    setState(() {
      yukleniyor = true;
      yorum = "";
    });
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/analiz-burc'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"burc": secilen, "konu": "Genel"}),
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
      appBar: AppBar(title: const Text("Burc")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField(
              initialValue: secilen,
              dropdownColor: const Color(0xFF240038),
              items:
                  [
                    "Koç",
                    "Boğa",
                    "İkizler",
                    "Yengeç",
                    "Aslan",
                    "Başak",
                    "Terazi",
                    "Akrep",
                    "Yay",
                    "Oğlak",
                    "Kova",
                    "Balık",
                  ].map((String burc) {
                    return DropdownMenuItem(child: Text(burc));
                  }).toList(),
              onChanged: (v) => setState(() => secilen = v as String),
            ),
            ElevatedButton(
              onPressed: yukleniyor ? null : getir,
              child: const Text("YORUMLA"),
            ),
            if (yorum.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(child: SonucKutusu(metin: yorum)),
              ),
          ],
        ),
      ),
    );
  }
}