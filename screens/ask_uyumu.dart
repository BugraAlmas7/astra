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

class AskUyumuSayfasi extends StatefulWidget {
  const AskUyumuSayfasi({super.key});
  @override
  State<AskUyumuSayfasi> createState() => _AskUyumuSayfasiState();
}

class _AskUyumuSayfasiState extends State<AskUyumuSayfasi> {
  final _i1 = TextEditingController(), _i2 = TextEditingController(), _t1 = TextEditingController(), _t2 = TextEditingController(), _s1 = TextEditingController(), _s2 = TextEditingController(), _y1 = TextEditingController(), _y2 = TextEditingController();
  String d = "Flört", yorum = "";
  bool yukleniyor = false;
  Future<void> yap() async {
    setState(() => yukleniyor = true);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/analiz-uyum'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "partner_1": {
            "isim": _i1.text,
            "dogum_tarihi": "01.01.2000",
            "dogum_saati": "12:00",
            "dogum_yeri": "x",
          },
          "partner_2": {
            "isim": _i2.text,
            "dogum_tarihi": "01.01.2000",
            "dogum_saati": "12:00",
            "dogum_yeri": "x",
          },
          "iliski_durumu": d,
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
      appBar: AppBar(title: const Text("Ask Uyumu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _i1,
                decoration: const InputDecoration(labelText: "Senin Adin"),
              ),

              TextField(
                controller: _i2,
                decoration: const InputDecoration(labelText: "Partnerin Adi"),
              ),
              TextField(
                controller: _t1,
                decoration: const InputDecoration(labelText: "Dogum Tarihin"),
              ),
              TextField(
                controller: _t2,
                decoration: const InputDecoration(labelText: "Partnerinin Dogum Tarihi"),
              ),
              TextField(
                controller: _s1,
                decoration: const InputDecoration(labelText: "Dogum Saatin"),
              ),
              TextField(
                controller: _s2,
                decoration: const InputDecoration(labelText: "Partnerinin Dogum Saati"),
            
              ),
              TextField(
                controller: _y1,
                decoration: const InputDecoration(labelText: "Dogum Yerin"),
              ),
              TextField(
                controller: _y2,
                decoration: const InputDecoration(labelText: "Partnerinin Dogum Yeri"), 
              ),

              DropdownButtonFormField<String>(
                initialValue: d,
                items: ["Flört", "Sevgili", "Platonik", "Evli", "Eski Sevgili"]
                    .map(
                      (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => d = v as String),
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