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

class TarotSayfasiFoto extends StatelessWidget {
  const TarotSayfasiFoto({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Tarot"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "KART CEK"),
              Tab(text: "FOTO YUKLE"),
            ],
          ),
        ),
        body: const TabBarView(children: [_TarotFoto()]),
      ),
    );
  }
}

class _TarotFoto extends StatefulWidget {
  const _TarotFoto();
  @override
  State<_TarotFoto> createState() => _TarotFotoState();
}

class _TarotFotoState extends State<_TarotFoto> {
  final _picker = ImagePicker();
  File? _resim;
  String yorum = "";
  bool yukleniyor = false;
  final _niyet = TextEditingController();
  Future<void> gonder() async {
    if (_resim == null) return;
    setState(() {
      yukleniyor = true;
      yorum = "Inceleniyor...";
    });

    try {
      var req = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/analiz-tarot-foto'),
      );
      req.files.add(await http.MultipartFile.fromPath('file', _resim!.path));
      req.fields['niyet'] = _niyet.text.isEmpty ? "Genel" : _niyet.text;
      var res = await http.Response.fromStream(await req.send());
      if (res.statusCode == 200) {
        setState(
          () =>
              yorum = jsonDecode(utf8.decode(res.bodyBytes))['interpretation'],
        );
      }
    } catch (e) {
      setState(() => yorum = "Hata.");
    } finally {
      setState(() => yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _niyet,
            decoration: const InputDecoration(
              labelText: "Niyetin",
              filled: true,
              fillColor: Colors.white10,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final secilenDosya = await FotoSecici.goster(context);
              if (secilenDosya != null) {
                setState(() => _resim = secilenDosya);
              }
            },
            child: Container(
              height: 150,
              color: Colors.white10,
              child: _resim != null
                  ? Image.file(_resim!)
                  : const Center(child: Icon(Icons.add_a_photo, size: 40)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: (yukleniyor || _resim == null) ? null : gonder,
            child: const Text("YORUMLA"),
          ),
          if (yorum.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SonucKutusu(metin: yorum),
            ),
        ],
      ),
    );
  }
}