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

class SihirliAynaSayfasi extends StatefulWidget {
  const SihirliAynaSayfasi({super.key});
  @override
  State<SihirliAynaSayfasi> createState() => _SihirliAynaSayfasiState();
}

class _SihirliAynaSayfasiState extends State<SihirliAynaSayfasi> {
  final List<Map<String, String>> msgs = [];
  final _c = TextEditingController();
  bool yukleniyor = false;
  Future<void> gonder({File? foto}) async {
    String txt = _c.text;
    if (txt.isEmpty && foto == null) {
      return;
    }
    setState(() {
      msgs.add({"role": "user", "text": foto != null ? "[Fotograf]" : txt});
      _c.clear();
      yukleniyor = true;
    });
    try {
      var res;
      if (foto != null) {
        var req = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/analiz-sihirli-ayna'),
        );
        req.files.add(await http.MultipartFile.fromPath('file', foto.path));
        res = await http.Response.fromStream(await req.send());
      } else {
        res = await http.post(
          Uri.parse('$baseUrl/chat-sihirli-ayna'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "history": [
              {"role": "user", "content": txt},
            ],
          }),
        );
      }
      if(!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        setState(
          () => msgs.add({
            "role": "bot",
            "text": foto != null ? data['interpretation'] : data['content'],
          }),
        );
      }
    } catch (e) {
      setState(() => msgs.add({"role": "bot", "text": "Hata."}));
    } finally {
      setState(() => yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sihirli Ayna")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: msgs.length,
              itemBuilder: (c, i) => ListTile(
                title: Align(
                  alignment: msgs[i]['role'] == 'user'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: msgs[i]['role'] == 'user'
                          ? Colors.purple
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      msgs[i]['text']!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            color: Colors.black26,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () async {
                    final secilenDosya = await FotoSecici.goster(context);
                    if (secilenDosya != null) gonder(foto: secilenDosya);
                  },
                ),
                Expanded(child: TextField(controller: _c)),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => gonder(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}