import 'dart:async';
import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/app/app.logger.dart';
import 'package:app_chat/models/chat_model.dart';
import 'package:app_chat/models/message_model.dart';
import 'package:app_chat/models/user_model.dart';
import 'package:app_chat/services/chat_service.dart';
import 'package:app_chat/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ChatViewModel extends BaseViewModel with WidgetsBindingObserver {
  final ChatModel chat;
  BuildContext context;
  ChatViewModel({
    required this.chat,
    required this.context,
  }) {
    WidgetsBinding.instance.addObserver(this);
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
  UserModel? myUser;
  StreamSubscription? _subscription;

//   Future<void> setChatListener() async {
//     //ouvindo a query de documentos desse chats
//     final query = FirebaseFirestore.instance
//         .collection('chats')
//         .doc(chat.id)
//         .collection('messages');

// //instanciando a subscription
//     _subscription = query.snapshots().skip(1).listen((querySnapshot) async {
//       _log.i("New message snapshot received");

//       if (querySnapshot.docs.isEmpty) return;

// //averiguar se aqui so vem um por um mesmo
//       for (var change in querySnapshot.docChanges) {
//         if (change.type == DocumentChangeType.added) {
//           final messageModel = MessageModel.fromDocument(change.doc);
// //atribuindo o user na mensagem
//           if (messageModel.senderId == myUser!.id) {
//             messageModel.user = myUser;
//           } else {
//             messageModel.user = chat.users
//                 .firstWhere((element) => element.id == messageModel.senderId);
//           }
//           messages!.add(messageModel);

//           notifyListeners();
//           Future.delayed(const Duration(milliseconds: 100), () {
//             _scrollToEnd();
//           });
//         }
//       }
//     });
//   }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    super.dispose();
    if (_subscription == null) return;
    _subscription!.cancel();
  }

//chamado quando muda o tasmanhho do layout (qnd abre teclado)
  @override
  void didChangeMetrics() {
    final screenHeight = MediaQuery.of(context).size.height;
    //apenas se a posicao atual e menor que a substracao entre o maximo e o tamanhho total
    // if ((scrollController.position.maxScrollExtent -
    //         scrollController.position.pixels) <
    //     screenHeight) {
    //   _log.e('scroll');
    // }

/*
ao abrir o teclado, caso a distancia entre o scroll atual e o maximo de scroll possivel
for menor que a metade da altura da tela, entao faz o scroll.

ou seja, se estiver QUASE NO FIM DO SCROLL, entao rola la pro final qnd abrir teclado.
 */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((scrollController.position.maxScrollExtent -
              scrollController.position.pixels) <
          screenHeight / 2) {
        _scrollToEnd();
        // scrollController.animateTo(
        //   scrollController.position.maxScrollExtent,
        //   duration: const Duration(milliseconds: 100),
        //   curve: Curves.easeInOut,
        // );
      }
    });
    super.didChangeMetrics();
  }

  void sendMessage() async {
    if (controller.text.isEmpty) return;

    try {
      await _chatService.sendMessage(
        message: controller.text,
        chatId: chat.id,
      );

      // controller.clear();
      controller.text = '';
    } catch (e) {
      _log.e(e);
    }
    //_scrollToEnd();
    notifyListeners();
  }

  Future<void> init() async {
    setBusy(true);
    myUser = _userService.user;

    //todo: load messages //todo: insert on some cache

    //! eu poderia aproveitar a primeira leva de snapshot do streamsubscription ne ao inves de fzr isso...p pegar as msg
    messages = await _chatService.getChatMessages(chat.id);

    if (messages == null) return; //todo: grab error
    //iterar por cada msg e inserir UserModel correspondente
    for (var message in messages!) {
      if (message.senderId == myUser!.id) {
        //aqui posso colocar uma flag na mensagem pra dizer que eh minha, pro exemplo.
        message.user = myUser;
      } else {
        message.user = chat.users.firstWhere(
          (element) => element.id == message.senderId,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd();
    });
    notifyListeners();
    _chatService.setChatListener(chat, (newMessage) {
      // actualChatMessages.value.add(newMessage);
      messages!.add(newMessage);
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToEnd();
      });
      notifyListeners();
    });
    setBusy(false);
  }

  Future<void> _scrollToEnd() async {
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    _log.i('');
    // await Future.delayed(const Duration(milliseconds: 500));
    // _scrollToEnd();
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