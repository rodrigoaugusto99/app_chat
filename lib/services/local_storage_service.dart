import 'dart:io';
import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/services/http_service.dart';
import 'package:path_provider/path_provider.dart';

//todo: separar downloads por tipos nas pastas
class LocalStorageService {
  final _htppService = locator<HttpService>();

  Directory? directory;

  Future<void> init() async {
    directory = await getApplicationDocumentsDirectory();
  }

  Future<String?> downloadAudio({
    required String chatId,
    required String audioUrl,
    required String messageId,
  }) async {
    // Obtém o diretório local para armazenar o arquivo
    try {
      final directoryPath = '${directory!.path}/$chatId';
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
    final directoryPath = '${directory!.path}/$chatId';
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

  Future<String?> getFilePath({
    required String chatId,
    required String messageId,
  }) async {
    final filePath = '${directory!.path}/$chatId/$messageId.aac';

    final file = File(filePath);

    bool fileExists = await file.exists();
    //_log.i(file);

    if (!fileExists) {
      throw Exception('Arquivo nao existe');
    }
    return filePath;
  }

//copy local file
  Future<void> saveMyMediaWithPathProvider({
    required String chatId,
    required String messageId,
    required File file,
  }) async {
    File originalFile = File(file.path);

    // Gerar um novo caminho para o arquivo dentro do diretório do aplicativo
    final String newPath = '${directory!.path}/$chatId/$messageId.aac';

    // Copiar o arquivo para o diretório interno
    final File savedFile = await originalFile.copy(newPath);

    // Agora você pode usar savedFile.path para exibir ou enviar o arquivo
    print('Arquivo salvo no caminho: ${savedFile.path}');
  }

//download
  Future<String?> downloadImage({
    required String chatId,
    required String messageId,
    required String imageUrl,
  }) async {
    // Obtém o diretório local para armazenar o arquivo
    try {
      final directoryPath = '${directory!.path}/$chatId';
      final filePath = '$directoryPath/$messageId.jpg';

      // Cria a subpasta, se ela não existir
      final dir = Directory(directoryPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Faz o download do arquivo
      final response = await _htppService.get(imageUrl);
      final file = File(filePath);

      // Salva o arquivo localmente
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } on Exception catch (e) {
      // _log.e(e);
      // return null;
      throw Exception(e);
    }
  }
}
