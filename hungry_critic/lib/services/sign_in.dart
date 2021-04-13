import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    return SocialData(gAccount.email, cred, gAccount.email);
  }

  signIn(SignInMethod method, AuthCredential aCred) async {
    final user = await _createUser(aCred);
    if(user == null) throw Exception('Could not create!');

    final email = user.email;
    if(email == null) throw Exception('Could not get email!');

    final creds = Credentials(method, email, user.uid);
    final receipt = await SignInApi(bloc.config).signIn(creds);
    _account = Account(creds: creds, token: receipt.token);

    final api = AccountApi(bloc.config, _account.token);
    if (!receipt.fresh) {
      final oldAccount = await api.fetchAccount(receipt.id);
      if (oldAccount == null) throw Exception('Couldn\t fetch account!');
      _account.profile = oldAccount.profile;
    } else {
      _account.profile = UserProfile(id: receipt.id);
    }

    return bloc.save(_account);
  }

  Future<User?> _createUser(AuthCredential cred) async {
    final result = await _auth.signInWithCredential(cred);
    return result.user;
  }
}
