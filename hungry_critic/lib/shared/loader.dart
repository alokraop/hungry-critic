import 'package:flutter/material.dart';

import 'colors.dart';

class LoaderRoute extends PopupRoute<String> {
  LoaderRoute(this.label, {this.dismissable = false});

  final String label;

  final bool dismissable;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.3);

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => 'loader';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: 15,
            bottom: dismissable ? 5 : 15,
          ),
          decoration: BoxDecoration(
            color: greySwatch[50],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircularProgressIndicator(),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        label,
                        style: theme.textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              ),
              if (dismissable)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'DISMISS',
                    style: theme.textTheme.bodyText2?.copyWith(color: theme.primaryColor),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 150);
}