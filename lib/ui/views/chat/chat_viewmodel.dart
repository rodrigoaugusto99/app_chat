import 'dart:async';
import 'dart:io';
import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/app/app.logger.dart';
import 'package:app_chat/models/chat_model.dart';
import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/models/user_model.dart';
import 'package:app_chat/services/chat_service.dart';
import 'package:app_chat/services/local_storage_service.dart';
import 'package:app_chat/services/recorder_service.dart';
import 'package:app_chat/services/user_service.dart';
import 'package:app_chat/ui/utils/storage_utils.dart';
import 'package:app_chat/ui/utils/utiis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';

class MessagesByDay {
  final String day;
  final List<MessageModel> messages;

  MessagesByDay({
    required this.day,
    required this.messages,
  });
}

class ChatViewModel extends BaseViewModel with WidgetsBindingObserver {
  final ChatModel chat;
  BuildContext context;
  ChatViewModel({
    required this.chat,
    required this.context,
  }) {
    WidgetsBinding.instance.addObserver(this);
    screenHeight = MediaQuery.of(context).size.height;
    //isRecording = _recorderService.recorder.isRecording;
    _recorderService.isRecordingNotifier.addListener(() {
      notifyListeners();
    });
  }

//?nao seria melhor pegar o recorder inteiro, ai ja teria acesso ao isPaused tbm etc.
//! mas ai essa viewModel dependeria do pacote, pois teriamos que instanciar o tipo FlutterSoundRecorder...
  //fodase, vou depender msm
  bool get isRecording => _recorderService.isRecordingNotifier.value;
  Stream<RecordingDisposition>? get recordingProgress =>
      _recorderService.recordingProgressStream;
  // FocusNode focus = FocusNode();

  ScrollController scrollController = ScrollController();
  TextEditingController controller = TextEditingController();
  final _userService = locator<UserService>();
  final _chatService = locator<ChatService>();
  final _log = getLogger('ChatViewModel');
  double? screenHeight;

  List<UserModel>? otherUses;
  List<MessageModel>? messages;
  List<MessagesByDay>? messagesGroupedByDays;
  UserModel? myUser;
  StreamSubscription? _subscription;

  final _localStorageService = locator<LocalStorageService>();
  final _recorderService = locator<RecorderService>();
//!
//!vou precisar fzr funcao de voltar manualmente pro back do appbar e pro willpop
//!pois preciso dar dispose no scroll muito rapido pra evitar
//!dessa forma, evita o erro no terminal talvez
  // void back() {
  //   _navigationService.back();
  // }

  @override
  void dispose() {
    //scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    if (_subscription == null) return;
    _subscription!.cancel();
    _chatService.disposeListener();
    //_recorderService.dispose();
    // _localStorageService.dispose();
  }

//chamado quando muda o tasmanhho do layout (qnd abre teclado)
  @override
  void didChangeMetrics() {
/*
ao abrir o teclado, caso a distancia entre o scroll atual e o maximo de scroll possivel
for menor que a metade da altura da tela, entao faz o scroll.

ou seja, se estiver QUASE NO FIM DO SCROLL, entao rola la pro final qnd abrir teclado.
 */

//se scroll positionf for um pouco maior que o minimi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //condicao pro scroll da lista ir la pra baixo
      if ((screenHeight! / 2) > scrollController.position.pixels) {
        _scrollToEnd();
      }
    });
    super.didChangeMetrics();
  }

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    setBusy(true);

    myUser = _userService.user;
    //todo: load messages //todo: insert on some cache
    //! eu poderia aproveitar a primeira leva de snapshot do streamsubscription ne ao inves de fzr isso...p pegar as msg
    messages = await _chatService.getChatMessages(chat.id);
    if (messages == null) return; //todo: grab error

    //audios que serao checados se ja foram baixados.
    List<MessageModel> audiosToCheck = [];

//iterar por cada msg e inserir UserModel correspondente
    for (var message in messages!) {
      if (message.audioUrl != '') {
        //! para teste
        // message.isDownloading = true;
        audiosToCheck.add(message);
      }

      if (message.senderId == myUser!.id) {
        //aqui posso colocar uma flag na mensagem pra dizer que eh minha, pro exemplo.
        message.user = myUser;
      } else {
        message.user = chat.users.firstWhere(
          (element) => element.id == message.senderId,
        );
      }
    }

    //messagesGroupedByDays = createExtractDayList(messages!.reversed.toList());
    messagesGroupedByDays = createExtractDayList(messages);

    notifyListeners();
    _chatService.setChatListener(chat, (newMessage) {
      /*
      funcoes da viewModel que chamam funcao do service.
      Nessas funcoes, o intuito principal eh manipular
      o valor de "isDownloading" do arquivo para
      refletir na view.
       */
      if (newMessage.audioUrl != '') {
        downloadAudio(newMessage);
      } else if (newMessage.imageUrl != '') {
        downloadImage(newMessage);
      }

/*todo: se for um video ou imagem que EU mandei, entao usar o: 
(usa metodo copy pois tenho o arquivo no meu celular).
Que ja foi usado com sucesso la no */

//todo: se o senderId nao for o meu, entao baixar (baixar com httpo arquivo la da url do firestore que eh do storage)

      //adicionando a nova mensagem na lista de mensagens do MessagesByModel de HOJE.
      DateTime now = DateTime.now();
      String nowFormatted = formatDate(now);

      MessagesByDay? todayMessages;

      if (messagesGroupedByDays!.isEmpty) {
        todayMessages = MessagesByDay(
          day: nowFormatted,
          messages: [],
        );
        messagesGroupedByDays!.add(todayMessages);
      }
      todayMessages =
          messagesGroupedByDays!.firstWhere((msg) => msg.day == nowFormatted);
      messages!.add(newMessage);

      todayMessages.messages.add(newMessage);

      //temos que saber qual eh o grupo de dias que vms colocar a nova mensagem.

      // Se o grupo do dia de hoje existe, adicione a nova mensagem a ele

      notifyListeners();
    });

    setBusy(false);

    //to checando em outro loop pra nao atrapalhar ou enlerdar o loop de todas as mensagens.
    //checando as mensagens de audio
    for (var audio in audiosToCheck) {
      bool isDowloaded = await _localStorageService.checkIfAudioIsDownloaded(
        message: audio,
        chatId: chat.id,
      );
      if (!isDowloaded) {
        downloadAudio(audio);
      }
    }
  }

  Future<void> downloadAudio(MessageModel message) async {
    message.isDownloading = true;
    _log.f('isDownloading = true');
    notifyListeners();
    final fileDownloaded = await _localStorageService.downloadAudio(
      audioUrl: message.audioUrl!,
      chatId: chat.id,
      messageId: message.id!,
    );
    if (fileDownloaded == null) {
      _log.e('falha ao baixar mensagem ${message.id}');
      message.isDownloading = false;
      _log.f('isDownloading = false');
      //se der erro, setar esse bool de erro pra mostrar um simbolo de erro nessa mensagem.
      message.hasError = true;
      return;
    }
    //se nao deu erro, ou seja, nao retornou null naquele metodo, entao tirar esse bool true.
    //ai la no bubble, mostraremos a setinha ao inves do simbolo de estar baixando.
    message.isDownloading = false;
    _log.f('isDownloading = false');
    notifyListeners();
  }

  Future<void> downloadImage(MessageModel message) async {
    message.isDownloading = true;
    _log.f('isDownloading = true');
    notifyListeners();
    final fileDownloaded = await _localStorageService.downloadImage(
      chatId: chat.id,
      imageUrl: message.imageUrl!,
      messageId: message.id!,
    );
    if (fileDownloaded == null) {
      _log.e('falha ao baixar mensagem ${message.id}');
      message.isDownloading = false;
      _log.f('isDownloading = false');
      //se der erro, setar esse bool de erro pra mostrar um simbolo de erro nessa mensagem.
      message.hasError = true;
      return;
    }
    //se nao deu erro, ou seja, nao retornou null naquele metodo, entao tirar esse bool true.
    //ai la no bubble, mostraremos a setinha ao inves do simbolo de estar baixando.
    message.isDownloading = false;
    _log.f('isDownloading = false');
    notifyListeners();
  }

  Future<void> _scrollToEnd() async {
    if (!scrollController.hasClients) return;
    scrollController.jumpTo(scrollController.position.minScrollExtent);
    _log.i('');
  }

  List<MessagesByDay> createExtractDayList(List<MessageModel>? allMessages) {
    if (allMessages == null || allMessages.isEmpty) {
      return [];
    }

    Map<String, List<MessageModel>> groupedByDate = {};

    for (var msg in allMessages) {
      DateTime date = msg.createdAt.toDate();
      String formattedDate = formatDate(date);

      if (!groupedByDate.containsKey(formattedDate)) {
        groupedByDate[formattedDate] = [];
      }

      groupedByDate[formattedDate]!.add(msg);
    }

    List<MessagesByDay> extractDays = groupedByDate.entries.map((entry) {
      return MessagesByDay(
        day: entry.key,
        messages: entry.value,
      );
    }).toList();

    return extractDays;
  }

  void onChanged(String value) {
    if (controller.text.isEmpty) {
      canRecord = true;
    } else {
      canRecord = false;
    }
    notifyListeners();
  }

  Future<String?> sendMessage({
    String? audioUrl,
    String? imageUrl,
    String? videoUrl,
  }) async {
    //if (controller.text.isEmpty) return;
    try {
      final messageId = await _chatService.sendMessage(
        message: controller.text,
        chatId: chat.id,
        audioUrl: audioUrl,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
      );
      controller.text = '';
      notifyListeners();
      return messageId;

      // controller.clear();
    } catch (e) {
      _log.e(e);
      return null;
    }
  }

  bool canRecord = true;
  void recordVoice() async {
    File? file = await _recorderService.recordVoice();
    if (file == null) return;
    final audioUrl = await StorageUtils.uploadAudioFile(file);
    sendMessage(audioUrl: audioUrl);
    //notifyListeners();
  }

//apenas manda a iimagem ou video no chat quando terminar download pro storage
  Future<void> sendImageOrVideo() async {
    //pick image or video
    final xFile = await pickMedia();

    // Identificar se é uma imagem ou um vídeo
    String mimeType = xFile!.mimeType!;

    File mediaFile = File(xFile.path);

//todo: need to uuid messageId param.
    //copy file to path_provider

    if (mimeType.startsWith('video/')) {
      // É um vídeo
      //?upload storage

      String url = await StorageUtils.uploadVideoFile(mediaFile);
      //send url message
      String? messageId = await sendMessage(videoUrl: url);
      if (messageId == null) return;
      //?upload local storage
      _localStorageService.saveMyMediaWithPathProvider(
        chatId: chat.id,
        file: mediaFile,
        messageId: messageId,
      );
    } else if (mimeType.startsWith('image/')) {
      // É uma imagem
      //upload storage
      String url = await StorageUtils.uploadImageFile(mediaFile);
      //send url message
      sendMessage(imageUrl: url);
    } else {
      _log.e('Nao eh video nem imagem');
      //thorw exception escolha video ou uma imagem
    }
  }

  Future<XFile?> pickMedia() async {
    final ImagePicker picker = ImagePicker();

    // Permite que o usuário escolha qualquer tipo de mídia (imagem ou vídeo)
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      // Aqui usamos pickImage, que permite ao usuário escolher tanto imagem quanto vídeo
    );

    if (file == null) {
      _log.i('Nenhuma mídia foi selecionada.');
      return null;
    }

    //File mediaFile = File(file.path);
    return file;
  }
}

/*
Aqui para tirar a dependencia do firestore no viewmodel, eu coloquei o listener la no service.

O que eu fiz foi: 
1) Fazer o listener la no service e chama-lo para fazer a criacao aqui na viewmodel,
e sempreq ue tiver uma snapshot nova la, eu recebo aqui pq eu faco um callback.
OU seja, eu determino uma funcao que, caso ela seja chamada la no metodo no service,
eu recebo o resultado aqui.
Ou seja, um callback meu dentro do callback do firestore la com streamsubscription
(aqui mesmo eu tenho que cancelar a subscricao entao.). Dessa forma, eu recebo a nova
mensagem e aqui mesmo eu ja jogo ela na lista de mensagens do chat e dou o setstate

2) Um outro jeito que eu poderia fazer eh, la no service, eu faria um ValueNotifier chamado
newMessage, e toda vez que o snapshot de la acontecer e chamar a funcao anonima do 
setChatListener, entao eu atribuo um novo valor a essa variavel do tipo ValueNotifier 
newMessage. Dessa forma, como eh um valuenotifier, aqui no viewmodel eu poderia escutar
ela usando addListener. Juntamente faria um getter pra acessar o valor daquele service.

no construtor do viewModel:

_chatService.newMessageNotifier.addListener(_onNewMessageReceived);

ou seja, a cada ouvida, chama esse _onNewMessageReceived.

 void _onNewMessageReceived() {
    final newMessage = _chatService.newMessageNotifier.value;
    if (newMessage != null) {
      messages!.add(newMessage);
      notifyListeners();
    }
  }

  o _onNewMessageReceived simplesmente pega o valor
  mais recente da nova mensagem e adiciona na lista.

    @override
  void dispose() {
    _chatService.newMessageNotifier.removeListener(_onNewMessageReceived);
    super.dispose();
  }

  e o dispose padrao.


3) outra coisa que eu poderia fazer seria armazenar la no service a lista de mensagens, mas ai o service
ficaria com muita regra de negocio, sei la. e ai la no service eu faria a logica de pegar as mensagens
ja existentes, colocar na lista de message models, e ir atualizando ela com uma nova mensagem a partir
do snapshot. Ai nesse caso eu simplesmente escutaria as alteracoe4s dessa lista de messanges la no service.
 */
