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
    Function(AuthStatus)? onAuto,
    required Function onManual,
    required Function(FirebaseAuthException) onError,
  }) async {
    Aspects.instance.log('AccountBloc -> authWithEmail');
  }

  Future authWithSocial(SignInData info, Function(AuthStatus)? onAuto) async {
    Aspects.instance.log('AccountBloc -> authWithSocial');

    final auth = {
      SignInMethod.GOOGLE: authWithGoogle,
      SignInMethod.FACEBOOK: authWithFacebook,
    }[info.method];

    if (auth == null) throw PlatformException(code: 'UNKNOWN_METHOD');
    return signIn(info, await auth()).then((status) => onAuto?.call(status));
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

  Future<AuthStatus> signIn(SignInData info, SocialData data) async {
    final user = await _createUser(data.cred);
    if (user == null) throw Exception('Could not create!');

    final creds = Credentials(info.method, data.id, user.uid);
    final api = SignInApi(bloc.config);
    final receipt = await (info.create ? api.signUp(creds) : api.signIn(creds));
    _account = Account(
      id: receipt.id,
      method: creds.method,
      email: data.email,
    )..token = receipt.token;

    final aApi = AccountApi(bloc.config, receipt.token);
    if (!receipt.fresh) {
      final oldAccount = await aApi.fetchAccount(receipt.id);
      if (oldAccount == null) throw Exception('Couldn\t fetch account!');
      _account.update(oldAccount);
    }

    await bloc.save(_account);
    if(receipt.fresh) {
      if(info.method == SignInMethod.EMAIL) {
        return user.emailVerified ? AuthStatus.NEW_ACCOUNT : AuthStatus.UNVERIFIED;
      } else {
        return AuthStatus.NEW_ACCOUNT;
      }
    } else {
      return AuthStatus.EXISTING_ACCOUNT;
    }
  }

  Future<User?> _createUser(AuthCredential cred) async {
    final result = await _auth.signInWithCredential(cred);
    return result.user;
  }

  isVerified() {}
}
