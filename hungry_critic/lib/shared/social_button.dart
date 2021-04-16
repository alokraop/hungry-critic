import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/account.dart';
import 'colors.dart';

final _bColor = {
  SignInMethod.GOOGLE: greySwatch[50],
  SignInMethod.FACEBOOK: Color(0xff3b5998),
};

final _fColor = {
  SignInMethod.GOOGLE: greySwatch[500],
  SignInMethod.FACEBOOK: greySwatch[50],
};

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class SocialButton extends StatelessWidget {
  const SocialButton({
    Key? key,
    required this.method,
    required this.onTap,
  }) : super(key: key);

  final SignInMethod method;

  final Function(SignInMethod) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screen = MediaQuery.of(context).size;
    final imageName = describeEnum(method).toLowerCase();
    final label = imageName.capitalize();
    return GestureDetector(
      onTap: () => onTap(method),
      child: Container(
        width: screen.width * 0.325,
        padding: EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
        decoration: BoxDecoration(
          color: _bColor[method],
          borderRadius: BorderRadius.circular(7.5),
          boxShadow: [
            BoxShadow(
              color: greySwatch[800].withOpacity(0.4),
              blurRadius: 3,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logos/${imageName}_signin.png',
                height: 27.5,
              ),
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$label',
                    style: theme.textTheme.bodyText1?.copyWith(
                      fontFamily: 'Roboto',
                      color: _fColor[method],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
