import 'dart:io';
import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/services/http_service.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  final _htppService = locator<HttpService>();

  Future<String?> downloadAudio({
    required String chatId,
    required String audioUrl,
    required String messageId,
  }) async {
    // Obtém o diretório local para armazenar o arquivo
    try {
      final directory = await getApplicationDocumentsDirectory();
      final directoryPath = '${directory.path}/$chatId';
      final filePath = '$directoryPath/$messageId.aac';

      // Cria a subpasta, se ela não existir
      final dir = Directory(directoryPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Faz o download do arquivo de áudio
      final response = await _htppService.get(audioUrl);
      final file = File(filePath);

      // Salva o arquivo localmente
      await file.writeAsBytes(response.bodyBytes);
      // _log.i('path dod audio baixado!!!!!');
      // _log.i(filePath);
      return filePath;
    } on Exception catch (e) {
      // _log.e(e);
      // return null;
      throw Exception(e);
    }
  }

  Future<bool> checkIfAudioIsDownloaded({
    required MessageModel message,
    required String chatId,
  }) async {
    Directory? directory = await getApplicationDocumentsDirectory();
    final directoryPath = '${directory.path}/$chatId';
    final filePath = '$directoryPath/${message.id}.aac';

    // Cria a subpasta, se ela não existir
    final file = File(filePath); // Corrigido para usar File em vez de Directory

    // Verifica se o arquivo já foi baixado
    final alreadyExist = file.existsSync();
    if (!alreadyExist) {
      //_log.i('audio ainda nao baixado: $filePath');
      //download(message);
      return false;
    }
    return true;
  }
}
