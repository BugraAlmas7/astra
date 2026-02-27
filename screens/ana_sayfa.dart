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
import '../core/session_manager.dart';
import '../core/sabitler.dart';
import '../screens/giris_ekrani.dart';
import '../screens/ruya_tabiri_sayfasi.dart';
import '../screens/tarot_dijital.dart';
import '../screens/tarot_foto.dart';
import '../screens/sihirli_ayna.dart';
import '../screens/resimli_fal_sayfasi.dart';
import 'burc_sayfasi.dart';
import 'dogum_haritasi.dart';
import 'ask_uyumu.dart';

class _MenuKutusu extends StatelessWidget {
  final String isim;
  final IconData icon;
  final Color renk;
  final Widget sayfa;
  const _MenuKutusu({
    required this.isim,
    required this.icon,
    required this.renk,
    required this.sayfa,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (c) => sayfa)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF240038),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: renk.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: renk.withOpacity(0.2), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: renk),
            const SizedBox(height: 10),
            Text(
              isim,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class AnaSayfa extends StatelessWidget {
  const AnaSayfa({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "A S T R A",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => SessionManager.cikisYap(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<String>(
              future: SessionManager.getUsername(),
              builder: (c, s) => Text(
                "Hos geldin, ${s.data ?? 'Yolcu'}...",
                style: const TextStyle(color: Colors.purpleAccent),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _MenuKutusu(
                    isim: "Rüya Tabiri",
                    icon: Icons.mic,
                    renk: Colors.teal,
                    sayfa: const RuyaTabiriSayfasi(),
                  ),
                  _MenuKutusu(
                    isim: "Tarot Falı",
                    icon: Icons.style,
                    renk: Colors.deepPurple,
                    sayfa: const TarotSayfasiFoto(),
                  ),
                  _MenuKutusu(
                    isim: "Tarot Falı",
                    icon: Icons.style,
                    renk: Colors.deepPurple,
                    sayfa: const TarotSayfasiDijital(),
                  ),
                  _MenuKutusu(
                    isim: "Sihirli Ayna",
                    icon: Icons.face_retouching_natural,
                    renk: Colors.blueGrey,
                    sayfa: const SihirliAynaSayfasi(),
                  ),
                  _MenuKutusu(
                    isim: "Kahve Falı",
                    icon: Icons.coffee,
                    renk: Colors.brown,
                    sayfa: const ResimliFalSayfasi(
                      mod: "kahve",
                      baslik: "Kahve Falı",
                    ),
                  ),
                  _MenuKutusu(
                    isim: "El Falı",
                    icon: Icons.front_hand,
                    renk: Colors.orange,
                    sayfa: const ResimliFalSayfasi(
                      mod: "el",
                      baslik: "El Falı",
                    ),
                  ),
                  _MenuKutusu(
                    isim: "Günlük Burç",
                    icon: Icons.auto_awesome,
                    renk: Colors.purple,
                    sayfa: const BurcSayfasi(),
                  ),
                  _MenuKutusu(
                    isim: "Doğum Haritası",
                    icon: Icons.public,
                    renk: Colors.indigo,
                    sayfa: const DogumHaritasiSayfasi(),
                  ),
                  _MenuKutusu(
                    isim: "Aşk Uyumu",
                    icon: Icons.favorite,
                    renk: Colors.pink,
                    sayfa: const AskUyumuSayfasi(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}