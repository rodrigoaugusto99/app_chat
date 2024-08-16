import 'dart:io';
import 'package:app_chat/app/app.logger.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

final _log = getLogger('audio_utils');
Future<String> downloadAudio({
  required String chatId,
  required String audioUrl,
  required String messageId,
}) async {
  // Obtém o diretório local para armazenar o arquivo
  final directory = await getApplicationDocumentsDirectory();
  final directoryPath = '${directory.path}/$chatId';
  final filePath = '$directoryPath/$messageId.aac';

  // Cria a subpasta, se ela não existir
  final dir = Directory(directoryPath);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  // Faz o download do arquivo de áudio
  final response = await http.get(Uri.parse(audioUrl));
  final file = File(filePath);

  // Salva o arquivo localmente
  await file.writeAsBytes(response.bodyBytes);
  _log.i('path dod audio baixado!!!!!');
  _log.i(filePath);
  return filePath;
}

Future<String> uploadAudioFile(String filePath) async {
  File file = File(filePath);
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
    _log.e('Erro ao fazer upload do áudio: $e');
    throw Exception('Erro ao fazer upload do áudio: $e');
  }
}
