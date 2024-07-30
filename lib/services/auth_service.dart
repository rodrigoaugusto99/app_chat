import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_chat/app/app.locator.dart';
import 'package:app_chat/app/app.logger.dart';
import 'package:app_chat/app/app.router.dart';
import 'package:app_chat/services/user_service.dart';
import 'package:app_chat/ui/dialogs/loading/loading_dialog.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stacked_services/stacked_services.dart';

class AuthService {
  User? currUser = FirebaseAuth.instance.currentUser;
  final _log = getLogger('AuthService');
  final _firestore = FirebaseFirestore.instance;
  final _loading = Loading();

  Future<void> init() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        _log.i('User is currently signed out!');
        currUser = null;
      } else {
        _log.i('User is signed in!');
        currUser = user;
        currUser!.getIdToken().then((value) {
          // _log.i('User token: $value');
        }).catchError((e) {
          // signOut();
          // _navigationService.clearStackAndShow(Routes.loginView);
        });
      }
    });
    FirebaseAuth.instance.setLanguageCode('pt');
  }

  Future<UserCredential> signInWithGoogle() async {
    _loading.showLoading();
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      scopes: ['email', 'profile'],
    ).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    if (googleAuth == null) {
      await _loading.dismiss();
      throw Exception('Google auth failed');
    }

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    currUser = userCredential.user;

    // Once signed in, return the UserCredential
    await setupUserLoggedIn();
    return userCredential;
  }

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      currUser = userCredentials.user;
      //_analytics.logLogin(loginMethod: 'password');
      _log.i('Successfully signed in with email and password!');
      await setupUserLoggedIn();
      return userCredentials;
    } on FirebaseAuthException catch (error) {
      _log.e(error);
      // _snackbarService.showSnackbar(
      //   message: "Ocorreu um erro ao autenticar com o email",
      //   duration: const Duration(seconds: 2),
      // );
    }
    return null;
  }

  Future<void> setupUserLoggedIn() async {
    if (currUser == null) return;
    // createUser(currUser!.uid);
    // await listenForUserCreation(currUser!.uid);

    try {
      await locator<UserService>().setUser(currUser!.uid);
    } on Exception {
      //await _navigationService.clearStackAndShow(Routes.loginView);
      return;
    }
    _log.i('User display name: ${currUser!.displayName}');
    if (currUser!.displayName == null || currUser!.displayName!.isEmpty) {
      //await showBottomSheetEnterName();
    }
  }

  Future signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut().catchError((_) => null);
    currUser = null;
    locator<UserService>().unSetUser();
  }

//todo: api
  Future<void> createUser(String uid) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (currUser == null) {
      // Trate a situação em que o usuário não está autenticado
      _log.e('Usuário não está autenticado');
      return;
    }

    final userDoc = {
      'email': currUser!.email ?? '',
      'name': currUser!.displayName ?? '',
      'photoURL': currUser!.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    };

    WriteBatch batch = firestore.batch();
    DocumentReference userRef =
        firestore.collection('users').doc(currUser!.uid);
    batch.set(userRef, userDoc, SetOptions(merge: true));

    // Incrementar a contagem de usuários
    DocumentReference countRef = firestore.doc('meta/userCount');
    batch.set(
        countRef, {'count': FieldValue.increment(1)}, SetOptions(merge: true));

    try {
      await batch.commit();
      _log.i('Usuário criado com sucesso!');
    } catch (e) {
      _log.e('Erro ao criar usuário: $e');
    }
  }

  Future<void> listenForUserCreation(String uid) async {
    StreamSubscription<DocumentSnapshot> subscription;
    final completer = Completer();

    _log.i("Listening for user on firestore");
    subscription =
        _firestore.collection('users').doc(uid).snapshots().listen((event) {
      _log.i(event);
      if (event.exists &&
          event.data() != null &&
          event.data()!['name'] != null) {
        _log.i("User exists on firestore");
        completer.complete();
      }
    }, onError: (e) {
      _log.e(e);
    });

    await completer.future;
    await subscription.cancel();
  }
}
