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

class RuyaTabiriSayfasi extends StatefulWidget {
  const RuyaTabiriSayfasi({super.key});
  @override
  State<RuyaTabiriSayfasi> createState() => _RuyaTabiriSayfasiState();
}

class _RuyaTabiriSayfasiState extends State<RuyaTabiriSayfasi> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool kayitYapiliyor = false;
  String yorum = "Mikrofona bas...";
  bool islemYapiliyor = false;
  Future<void> islem() async {
    try {
      if (kayitYapiliyor) {
        final path = await _audioRecorder.stop();
        setState(() {
          kayitYapiliyor = false;
          islemYapiliyor = true;
          yorum = "Dinliyorum...";
        });
        if (path != null) {
          await gonder(File(path));
        } else {
          if (await _audioRecorder.hasPermission()) {
            final dir = await getApplicationDocumentsDirectory();
            await _audioRecorder.start(
              const RecordConfig(),
              path: '${dir.path}/ruya.m4a',
            );
            setState(() {
              kayitYapiliyor = true;
              yorum = "Kaydediliyor...";
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        islemYapiliyor = false;
        yorum = "Hata: $e";
      });
    }
  }

  Future<void> gonder(File file) async {
    try {
      var req = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/analiz-ruya'),
      );
      req.files.add(await http.MultipartFile.fromPath('file', file.path));
      var res = await http.Response.fromStream(await req.send());
      if (res.statusCode == 200) {
        setState(
          () =>
              yorum = jsonDecode(utf8.decode(res.bodyBytes))['interpretation'],
        );
      }
    } catch (e) {
      setState(() => yorum = "Baglanti hatasi.");
    } finally {
      setState(() => islemYapiliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ruya")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: islemYapiliyor ? null : islem,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: kayitYapiliyor ? Colors.red : Colors.teal,
                child: Icon(
                  kayitYapiliyor ? Icons.stop : Icons.mic,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (islemYapiliyor) const CircularProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: SonucKutusu(metin: yorum),
              ),
            ),
          ],
        ),
      ),
    );
  }
}