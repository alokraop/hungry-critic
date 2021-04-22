import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../apis/account.dart';
import '../apis/signIn.dart';
import '../blocs/account.dart';
import '../models/account.dart';
import '../shared/aspects.dart';

class SignInData {
  final String id;

  bool create;

  SignInMethod method;

  final String? email;

  SignInData(
    this.id,
    this.method, {
    this.create = true,
    this.email,
  });
}

class SignUpService {
  SignUpService(this.bloc);

  final AccountBloc bloc;

  final _auth = FirebaseAuth.instance;

  Future<File>? fullImage;

  late Account _account;

  EmailData? _data;

  StreamSubscription<User?>? _sub;

  Future<AuthStatus> authWithEmail(EmailData data) async {
    Aspects.instance.log('AccountBloc -> authWithEmail');
    final cred = await _makeCred(data);
    final user = cred.user;
    if (user == null) return AuthStatus.ERROR;
    if (user.emailVerified) {
      final info = SignInData(
        data.email,
        SignInMethod.EMAIL,
        create: data.create,
        email: data.email,
      );
      return authenticate(info, user);
    } else {
      _data = data;
      await user.sendEmailVerification();
      return AuthStatus.UNVERIFIED;
    }
  }

  Future<UserCredential> _makeCred(EmailData data) {
    return data.create
        ? _auth.createUserWithEmailAndPassword(
            email: data.email,
            password: data.password,
          )
        : _auth.signInWithEmailAndPassword(
            email: data.email,
            password: data.password,
          );
  }

  Future<AuthStatus> authWithSocial(SignInMethod method, bool create) async {
    Aspects.instance.log('AccountBloc -> authWithSocial');

    final auth = {
      SignInMethod.GOOGLE: authWithGoogle,
      SignInMethod.FACEBOOK: authWithFacebook,
    }[method];

    if (auth == null) throw PlatformException(code: 'UNKNOWN_METHOD');
    return auth(create);
  }

  Future<AuthStatus> authWithGoogle(bool create) async {
    Aspects.instance.log('AccountBloc -> authWithGoogle');
    final gAuth = GoogleSignIn();
    final gAccount = await gAuth.signIn();
    if (gAccount == null) {
      throw PlatformException(
        code: 'SIGN_IN_CANCELED',
        message: 'Sign in canceled',
      );
    }
    final authInfo = await gAccount.authentication;
    final cred = GoogleAuthProvider.credential(
      idToken: authInfo.idToken,
      accessToken: authInfo.accessToken,
    );
    final uCred = await _createUser(cred);
    final data = SignInData(
      gAccount.id,
      SignInMethod.GOOGLE,
      create: create,
      email: gAccount.email,
    );
    return authenticate(data, uCred.user).catchError((e) {
      gAuth.signOut();
      throw e;
    });
  }

  Future<AuthStatus> authWithFacebook(bool create) async {
    final result = await FacebookAuth.instance.login();
    final accessToken = result.accessToken;
    if (result.status != LoginStatus.success || accessToken == null) {
      throw PlatformException(
        code: 'SIGN_IN_CANCELED',
        message: 'Sign in canceled',
      );
    }
    final cred = FacebookAuthProvider.credential(accessToken.token);
    final uCred = await _createUser(cred);
    final info = SignInData(accessToken.userId, SignInMethod.FACEBOOK, create: create);
    return authenticate(info, uCred.user).catchError((e) {
      FacebookAuth.instance.logOut();
      throw e;
    });
  }

  Future<AuthStatus> authenticate(SignInData info, User? user) async {
    if (user == null) throw Exception('Could not create!');
    final creds = Credentials(info.method, info.id, user.uid);
    final api = SignInApi(bloc.config);
    final receipt = info.create
        ? await api.signUp(creds)
        : await api.signIn(creds).catchError((e) {
            return e is LoginException && e.status == 400
                ? api.signUp(creds).catchError((_) => throw e)
                : throw e;
          });
    _account = Account(
      id: receipt.id,
      email: info.email,
      settings: Settings(
        method: creds.method,
        attempts: 0,
        blocked: false,
        initialized: false,
      ),
    )..token = receipt.token;

    final aApi = AccountApi(bloc.config, receipt.token);
    if (!info.create) {
      final oldAccount = await aApi.fetchAccount(receipt.id);
      if (oldAccount == null) throw Exception('Couldn\t fetch account!');
      _account.update(oldAccount);
    }
    await bloc.save(_account);
    return _account.initialized ? AuthStatus.EXISTING_ACCOUNT : AuthStatus.NEW_ACCOUNT;
  }

  Future<AuthStatus> retryAuth() async {
    final data = _data;
    if (data == null) return AuthStatus.ERROR;
    data.create = false;
    final cred = await _makeCred(data);
    final user = cred.user;
    if (user == null) return AuthStatus.ERROR;
    if (user.emailVerified) {
      final info = SignInData(data.email, SignInMethod.EMAIL, email: data.email);
      return authenticate(info, user);
    } else {
      return AuthStatus.UNVERIFIED;
    }
  }

  Future<UserCredential> _createUser(AuthCredential cred) {
    return _auth.signInWithCredential(cred);
  }

  dispose() {
    _sub?.cancel();
  }

  signOut() async {
    final account = bloc.account;
    await _auth.signOut();
    switch (account.settings.method) {
      case SignInMethod.GOOGLE:
        final gAuth = GoogleSignIn();
        return gAuth.signOut();
      case SignInMethod.FACEBOOK:
        return FacebookAuth.instance.logOut();
      default:
    }
  }
}
