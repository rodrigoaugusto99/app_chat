import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageUtils {
  static Future<String> uploadAudioFile(File file) async {
    //File file = File(filePath);
    try {
      // Nome do arquivo no Firebase Storage
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.aac";

      // Pasta onde o arquivo será armazenado (por exemplo, 'audios/')
      Reference ref = FirebaseStorage.instance.ref().child('audios/$fileName');

      // Upload do arquivo
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Recupera a URL pública do arquivo armazenado
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      //_log.e('Erro ao fazer upload do áudio: $e');
      throw Exception('Erro ao fazer upload do áudio: $e');
    }
  }

  static Future<String> uploadImageFile(File file) async {
    //File file = File(filePath);
    try {
      // Nome do arquivo no Firebase Storage
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.aac";

      // Pasta onde o arquivo será armazenado (por exemplo, 'audios/')
      Reference ref = FirebaseStorage.instance.ref().child('audios/$fileName');

      // Upload do arquivo
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Recupera a URL pública do arquivo armazenado
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      //_log.e('Erro ao fazer upload do áudio: $e');
      throw Exception('Erro ao fazer upload do áudio: $e');
    }
  }

  static Future<String> uploadVideoFile(File file) async {
    //File file = File(filePath);
    try {
      // Nome do arquivo no Firebase Storage
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.aac";

      // Pasta onde o arquivo será armazenado (por exemplo, 'audios/')
      Reference ref = FirebaseStorage.instance.ref().child('audios/$fileName');

      // Upload do arquivo
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Recupera a URL pública do arquivo armazenado
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      //_log.e('Erro ao fazer upload do áudio: $e');
      throw Exception('Erro ao fazer upload do áudio: $e');
    }
  }
}
