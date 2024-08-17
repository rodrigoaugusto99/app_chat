import 'dart:async';
import 'dart:io';
import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/app/app.logger.dart';
import 'package:app_chat/models/chat_model.dart';
import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/models/user_model.dart';
import 'package:app_chat/services/chat_service.dart';
import 'package:app_chat/services/user_service.dart';
import 'package:app_chat/ui/utils/audio_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

    //issso eh pra notificar os ouvintes qnd essa variavel do chharswervice atualizar
    // _chatService.actualChatMessages.addListener(() {
    //   notifyListeners();
    // });
    // focus.addListener(() {
    //   if (focus.hasFocus) {
    //     _scrollToEnd();
    //     Future.delayed(
    //       const Duration(milliseconds: 1000),
    //       () => _scrollToEnd(),
    //     );
    //   }
    // });
  }
  //getter da variavel do service
  // List<MessageModel>? get actualChatMessages =>
  //     _chatService.actualChatMessages.value;
  // FocusNode focus = FocusNode();

  ScrollController scrollController = ScrollController();

  TextEditingController controller = TextEditingController();
  final _userService = locator<UserService>();
  final _chatService = locator<ChatService>();
  final _log = getLogger('ChatViewModel');
//todo: ao subir teclado, aparecer ultimas msgs normalmente
  List<UserModel>? otherUses;
  List<MessageModel>? messages;
  List<MessagesByDay>? messagesGroupedByDays;
  UserModel? myUser;
  StreamSubscription? _subscription;
  double? screenHeight;
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
  }

//chamado quando muda o tasmanhho do layout (qnd abre teclado)
  @override
  void didChangeMetrics() {
    //pra isso nao chamar quando eu sair da tela, dar dipose no controller e chamar o didChangeMetrics pois o teclado esta visivel
    // if (!scrollController.hasListeners) return;

    //apenas se a posicao atual e menor que a substracao entre o maximo e o tamanhho total
    // if ((scrollController.position.maxScrollExtent -
    //         scrollController.position.pixels) <
    //     screenHeight) {
    //   _log.e('scroll');
    // }
    //if (!scrollController.hasClients) return;
/*
ao abrir o teclado, caso a distancia entre o scroll atual e o maximo de scroll possivel
for menor que a metade da altura da tela, entao faz o scroll.

ou seja, se estiver QUASE NO FIM DO SCROLL, entao rola la pro final qnd abrir teclado.
 */

//se scroll positionf for um pouco maior que o minimi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if ((scrollController.position.minScrollExtent -
      //         scrollController.position.pixels) <
      //     (screenHeight! / 2)) {
      //   _scrollToEnd();
      //   // scrollController.animateTo(
      //   //   scrollController.position.maxScrollExtent,
      //   //   duration: const Duration(milliseconds: 100),
      //   //   curve: Curves.easeInOut,
      //   // );
      // }
      //condicao pro scroll da lista ir la pra baixo
      if ((screenHeight! / 2) > scrollController.position.pixels) {
        _scrollToEnd();
      }
    });
    super.didChangeMetrics();
  }

  Directory? directory;
  //List<MessageModel> audioMessagesToDownload = [];
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    setBusy(true);
    directory = await getApplicationDocumentsDirectory();
    initRecorder();
    myUser = _userService.user;

    //todo: load messages //todo: insert on some cache

    //! eu poderia aproveitar a primeira leva de snapshot do streamsubscription ne ao inves de fzr isso...p pegar as msg
    messages = await _chatService.getChatMessages(chat.id);
    //todo: iterar por todas as msg e ver  quais nao estao baixadas.

    //for(var message in messagea)

    if (messages == null) return; //todo: grab error
    //iterar por cada msg e inserir UserModel correspondente

    List<MessageModel> audiosToCheck = [];

    for (var message in messages!) {
      if (message.audioUrl != '') {
        // //! para teste
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
      if (newMessage.audioUrl != '') {
        newMessage.isDownloading = true;
        _log.f('isDownloading = true');
        notifyListeners();
        // downloadAudio(
        //   chatId: chat.id,
        //   audioUrl: newMessage.audioUrl!,
        //   messageId: newMessage.id!,
        // );
        download(newMessage);
      }
      //adicionando a nova mensagem na lista de mensagens do MessagesByModel de HOJE.
      DateTime now = DateTime.now();
      String nowFormatted = _formatDate(now);
      //temos que saber qual eh o grupo de dias que vms colocar a nova mensagem.
      MessagesByDay todayMessages =
          messagesGroupedByDays!.firstWhere((msg) => msg.day == nowFormatted);
      messages!.add(newMessage);

      // Se o grupo do dia de hoje existe, adicione a nova mensagem a ele
      todayMessages.messages.add(newMessage);

//nao precisa mais de descer o scroll a cada nova msg pq agr a listview ta reversa, entao ela autoajusta pro inicio
      // Future.delayed(const Duration(milliseconds: 100), () {
      //   _scrollToEnd();
      // });
      notifyListeners();
    });

    setBusy(false);

    //to checando em outro loop pra nao atrapalhar ou enlerdar o loop de todas as mensagens.
    //checando as mensagens de audio
    for (var audio in audiosToCheck) {
      await checkIfAudioMessageIsDownloaded(audio);
    }
  }

/*
aqui estou baixando a mensagenm, setando o estado dela de loading para refletir
na view.
 */
  Future<void> checkIfAudioMessageIsDownloaded(MessageModel message) async {
    Directory? directory = await getApplicationDocumentsDirectory();
    final directoryPath = '${directory.path}/${chat.id}';
    final filePath = '$directoryPath/${message.id}.aac';

    // Cria a subpasta, se ela não existir
    final file = File(filePath); // Corrigido para usar File em vez de Directory

    // Verifica se o arquivo já foi baixado
    final alreadyExist = file.existsSync();
    if (!alreadyExist) {
      _log.i('audio ainda nao baixado: $filePath');
      download(message);
    }
  }

  Future<void> download(MessageModel message) async {
    //message.isDownloading = true;
    final fileDownloaded = await downloadAudio(
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

  Future<void> _scrollToEnd() async {
    if (!scrollController.hasClients) return;
    //if (!scrollController.hasListeners) return;
    scrollController.jumpTo(scrollController.position.minScrollExtent);
    _log.i('');
    // await Future.delayed(const Duration(milliseconds: 500));
    // _scrollToEnd();
  }

  List<MessagesByDay> createExtractDayList(List<MessageModel>? allMessages) {
    if (allMessages == null || allMessages.isEmpty) {
      return [];
    }

    Map<String, List<MessageModel>> groupedByDate = {};

    for (var msg in allMessages) {
      DateTime date = msg.createdAt.toDate();
      String formattedDate = _formatDate(date);

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

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void onChanged(String value) {
    if (controller.text.isEmpty) {
      canRecord = true;
    } else {
      canRecord = false;
    }
    notifyListeners();
  }

  void sendMessage({String? audioUrl}) async {
    //if (controller.text.isEmpty) return;
    try {
      // sendText();
      await _chatService.sendMessage(
        message: controller.text,
        chatId: chat.id,
        audioUrl: audioUrl,
      );
      // controller.clear();
      controller.text = '';
    } catch (e) {
      _log.e(e);
    }
    //_scrollToEnd();
    notifyListeners();
  }

//-------------audio recording ---------------

  final recorder = FlutterSoundRecorder();
  bool canRecord = true;
  bool isRecorderReady = false;

  Future<void> initRecorder() async {
    var status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }

    await recorder.openRecorder();

    isRecorderReady = true;

    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  void recordVoice() async {
    bool isGranted = await Permission.microphone.isGranted;
    if (isGranted == false) {
      try {
        initRecorder();
      } on Exception catch (e) {
        _log.e(e);
        return;
      }
    }
    if (!isRecorderReady) return;
    if (recorder.isRecording) {
//parando de gravar
      final path = await recorder.stopRecorder();
      final audioFile = File(path!);

      try {
        //upload do arquivo de voz no storage
        final audioUrl = await uploadAudioFile(path);
        sendMessage(audioUrl: audioUrl);
      } on Exception catch (e) {
        throw Exception(e);
      }

      _log.i('recorded audio: $audioFile');
    } else {
      // await record();
      await recorder.startRecorder(toFile: 'audio');
    }
    notifyListeners();
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
