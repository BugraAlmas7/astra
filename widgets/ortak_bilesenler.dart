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

class SonucKutusu extends StatelessWidget {
  final String metin;
  const SonucKutusu({super.key, required this.metin});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(metin, style: const TextStyle(fontSize: 15, height: 1.5)),
    );
  }
}

class FotoSecici{
  static Future<File?> goster(BuildContext context) async {
    final picker = ImagePicker();
    return await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: const Color(0xFF1A002B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context){
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: Colors.purpleAccent
                ),
                title: const Text('Kamerayla Cek'),
                onTap: () async {
                  final x = await picker.pickImage(source: ImageSource.camera);
                  Navigator.of(context).pop(x!=null?File(x.path):null);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library, 
                  color: Colors.purpleAccent
                ),
                title: const Text('Galeriden Sec'),
                onTap: ()async{
                  final x = await picker.pickImage(source: ImageSource.gallery);
                  Navigator.of(context).pop(x!=null?File(x.path):null);
                },
              ),
            ],
          ),
        );
      },
    );

  } 


}