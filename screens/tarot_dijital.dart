import 'dart:convert';
import 'dart:io';
import 'dart:math';
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

class _TarotDijital extends StatefulWidget{
  const _TarotDijital();
  @override
  State<_TarotDijital> createState() => _TarotDijitalState();
}

class _TarotDijitalState extends State<_TarotDijital>{
  final _niyetController = TextEditingController();
  double _kartSayisi =3;
  String yorum = "";
  bool yukleniyor =false;
  bool oyunBasladi =false;
  List<bool> acikKartlar = [];
  int acilanKartSayisi = 0;
  final List<String> tumTarotKartlari = [
    "adalet.jpg", "aptal.jpg", "araba.jpg", "asiklar.jpg", "asilmis_adam.jpg",
    "ay.jpg", "bas_rahip.jpg", "buyucu.jpg", "carkifelek.jpg", "dunya.jpg",
    "gunes.jpg", "imparator.jpg", "imparatorice.jpg", "kesis.jpg", "kule.jpg",
    "kuvvet.jpg", "olcululuk.jpg", "olum.jpg", "seytan.jpg", "yargi.jpg",
    "yildiz.jpg", "yuksek_rahibe.jpg",

    "degnek_as.jpg", "degnek_2.jpg", "degnek_3.jpg", "degnek_4.jpg", "degnek_5.jpg",
    "degnek_6.jpg", "degnek_7.jpg", "degnek_8.jpg", "degnek_9.jpg", "degnek_10.jpg",
    "degnek_prensi.jpg", "degnek_sovalyesi.jpg", "degnek_kralicesi.jpg", "degnek_krali.jpg",

    "kilic_as.jpg", "kilic_2.jpg", "kilic_3.jpg", "kilic_4.jpg", "kilic_5.jpg",
    "kilic_6.jpg", "kilic_7.jpg", "kilic_8.jpg", "kilic_9.jpg", "kilic_10.jpg",
    "kilic_prensi.jpg", "kilic_sovalyesi.jpg", "kilic_kralicesi.jpg", "kilic_krali.jpg",

    "kupa_as.jpg", "kupa_2.jpg", "kupa_3.jpg", "kupa_4.jpg", "kupa_5.jpg",
    "kupa_6.jpg", "kupa_7.jpg", "kupa_8.jpg", "kupa_9.jpg", "kupa_10.jpg",
    "kupa_prensi.jpg", "kupa_sovalyesi.jpg", "kupa_kralicesi.jpg", "kupa_krali.jpg",

    "tilsim_as.jpg", "tilsim_2.jpg", "tilsim_3.jpg", "tilsim_4.jpg", "tilsim_5.jpg",
    "tilsim_6.jpg", "tilsim_7.jpg", "tilsim_8.jpg", "tilsim_9.jpg", "tilsim_10.jpg",
    "tilsim_prensi.jpg", "tilsim_sovalyesi.jpg", "tilsim_kralicesi.jpg", "tilsim_krali.jpg",
  ];
  List<String> secilenKartlar = [];
  void desteyiYay(){
    final desteninKopyasi = List<String>.from(tumTarotKartlari);
    desteninKopyasi.shuffle();
    secilenKartlar=desteninKopyasi.take(_kartSayisi.toInt()).toList();

    setState((){
      oyunBasladi = true;
      yorum = "";
      acilanKartSayisi=0;
      acikKartlar=List.generate(_kartSayisi.toInt(),(index)=>false);
    }
    );
  }
  void kartCevir(int index){
    if (acikKartlar[index]) return;
    setState((){
      acikKartlar[index]=true;
      acilanKartSayisi++;
    }
    );
    if(acilanKartSayisi==_kartSayisi.toInt()){
      Future.delayed(const Duration(milliseconds: 500),()=>yorumuGetir());
    }
  }
  Future<void>yorumuGetir()async{
    setState((){
      yukleniyor =true;
      yorum = "Kartlarin okunuyor...";
    }
    );
    try{
      final res = await http.post(
        Uri.parse('$baseUrl/analiz-tarot-dijital'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "niyet": _niyetController.text.isEmpty ? "Genel" : _niyetController.text,
          "kart_sayisi": _kartSayisi.toInt(),
          "cekilen_kartlar": secilenKartlar
          }
        ),
      );
      if(!mounted)return;
      if(res.statusCode==200){
        setState(()=>yorum=jsonDecode(utf8.decode(res.bodyBytes))['interpretation']);
      }
      else{
        setState(() => yorum = "Evrenle baglanti kurulamadi (Hata: ${res.statusCode})");
      }
    }
    catch(e){
      if(mounted)setState(() => yorum ="Bir hata olustu.");
    }
    finally {
      if(mounted)setState(()=>yukleniyor=false);
    }
  }
  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if(!oyunBasladi)...[
            TextField(
              controller: _niyetController,
              decoration: const InputDecoration(
                labelText: "Niyetin (Opsiyonel)",
                filled: true,
                fillColor: Colors.white10,
              ),
            ),
            const SizedBox(height: 20),
            Text("Cekilen Kart Sayisi: ${_kartSayisi.toInt()}"),
            Slider(
              value: _kartSayisi,
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: Colors.purpleAccent,
              onChanged: (v)=> setState(()=>_kartSayisi=v),
            ),
            ElevatedButton(
              onPressed: desteyiYay,
              style:ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text("KARTLARI YAY", style: TextStyle(color: Colors.white)),
            ),
          ]
          else...[
            const Text("Kartlarini Sec", style: TextStyle(fontSize: 18, color: Colors.purpleAccent)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: List.generate(_kartSayisi.toInt(), (index){
                return GestureDetector(
                  onTap: ()=> kartCevir(index),
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin:0,end:acikKartlar[index]?pi:0),
                    duration: const Duration(milliseconds: 600), 
                    builder: (context, double value, child){
                      bool isBack=value<(pi/2);
                      return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(value),
                          child: isBack
                              ? _buildKartArkaYuzu()
                              :Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(pi),
                                child: _buildKartOnYuzu(index),
                              ),
                        );
                    },
                  ),
                );
              }
              ),
            ),
            const SizedBox(height: 30),
            if(yukleniyor)const CircularProgressIndicator(),
            if(yorum.isNotEmpty)SonucKutusu(metin: yorum),
            if(yorum.isNotEmpty)...[
              const SizedBox(height:20),
              TextButton(
                onPressed: () => setState(() {
                    oyunBasladi = false;
                    yorum = "";
                  }
                ),
                child:const Text("YENIDEN NIYET ET", style: TextStyle(color:Colors.purpleAccent)),
              )
            ]
          ]
        ]
      )
    );
  }
  Widget _buildKartArkaYuzu(){
    return Container(
      width: 80,
      height:120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF240038), Colors.deepPurple],
          begin: Alignment.topLeft,
          end:Alignment.topRight, 
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purpleAccent,width: 2),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius:5)],
      ),
      child: const Center(child: Icon(Icons.star_border,color: Colors.amber,size:40),),
    );
  }
  Widget _buildKartOnYuzu(int index){
    return Container(
      width: 80,
      height:120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color:Colors.amber,width:2),
        image: DecorationImage(
          image: AssetImage('tarot_kartlari/${secilenKartlar[index]}'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}