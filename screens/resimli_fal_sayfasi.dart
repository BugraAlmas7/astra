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

class ResimliFalSayfasi extends StatefulWidget {
  final String mod;
  final String baslik;
  const ResimliFalSayfasi({super.key, required this.mod, required this.baslik});
  @override
  State<ResimliFalSayfasi> createState() => _ResimliFalSayfasiState();
}
  
class _ResimliFalSayfasiState extends State<ResimliFalSayfasi> {
  File? _resim;
  String yorum = "";
  bool yukleniyor = false;
  Future<void> gonder() async {
    if (_resim == null) {
      return;
    }
    setState(() {
      yukleniyor = true;
      yorum = "Astra bakiyor...";
    });

    try {
      var req = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$baseUrl/${widget.mod == "kahve" ? "analiz-kahve" : "analiz-el-fali"}',
        ),
      );
      req.files.add(await http.MultipartFile.fromPath('file', _resim!.path));
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.baslik)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final secilenDosya = await FotoSecici.goster(context); 
                if (secilenDosya != null) {
                  setState(() => _resim = secilenDosya);
                }
              },
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.white10,
                child: _resim != null
                    ? Image.file(_resim!, fit: BoxFit.cover)
                    : Icon(
                        widget.mod == "kahve" ? Icons.coffee : Icons.front_hand,
                        size: 50,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (yukleniyor || _resim == null) ? null : gonder,
              child: const Text("FALIMA BAK"),
            ),
            const SizedBox(height: 20),
            if (yukleniyor) const CircularProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(child: SonucKutusu(metin: yorum)),
            ),
          ],
        ),
      ),
    );
  }
}