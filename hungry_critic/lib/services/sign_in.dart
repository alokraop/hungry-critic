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

class SocialData {
  final String id;
  final AuthCredential cred;
  final String? email;

  SocialData(this.id, this.cred, [this.email]);
}

class SignUpService {
  SignUpService(this.bloc);

  final AccountBloc bloc;

  final _auth = FirebaseAuth.instance;

  Future<File>? fullImage;

  late Account _account;

  Future authWithEmail(
    String email,
    String password, {
    Function? onAuto,
    required Function onManual,
    required Function(FirebaseAuthException) onError,
  }) async {
    Aspects.instance.log('AccountBloc -> authWithEmail');
  }

  Future authWithSocial(SignInMethod method, Function? onAuto) async {
    Aspects.instance.log('AccountBloc -> authWithSocial');

    final auth = {
      SignInMethod.GOOGLE: authWithGoogle,
      SignInMethod.FACEBOOK: authWithFacebook,
    }[method];

    if (auth == null) throw PlatformException(code: 'UNKNOWN_METHOD');
    signIn(method, await auth()).then((_) => onAuto?.call());
  }

  Future<SocialData> authWithGoogle() async {
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
    return SocialData(gAccount.id, cred, gAccount.email);
  }

  Future<SocialData> authWithFacebook() async {
    final result = await FacebookAuth.instance.login();
    final accessToken = result.accessToken;
    if (result.status != LoginStatus.success || accessToken == null) {
      throw PlatformException(
        code: 'SIGN_IN_CANCELED',
        message: 'Sign in canceled',
      );
    }
    final cred = FacebookAuthProvider.credential(accessToken.token);
    return SocialData(accessToken.userId, cred);
  }

  Future signIn(SignInMethod method, SocialData data) async {
    final user = await _createUser(data.cred);
    if (user == null) throw Exception('Could not create!');

    final creds = Credentials(method, data.id, user.uid);
    final receipt = await SignInApi(bloc.config).signIn(creds);
    _account = Account(
      id: receipt.id,
      method: creds.method,
      email: data.email,
    )..token = receipt.token;

    final api = AccountApi(bloc.config, receipt.token);
    if (!receipt.fresh) {
      final oldAccount = await api.fetchAccount(receipt.id);
      if (oldAccount == null) throw Exception('Couldn\t fetch account!');
      _account.update(oldAccount);
    }

    return bloc.save(_account);
  }

  Future<User?> _createUser(AuthCredential cred) async {
    final result = await _auth.signInWithCredential(cred);
    return result.user;
  }

  isVerified() {}
}
