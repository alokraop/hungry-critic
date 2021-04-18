import 'package:flutter/material.dart';

import 'colors.dart';

class StarSelectionRoute extends PopupRoute<double?> {
  StarSelectionRoute(this.options);

  final List<double> options;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.3);

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => 'starSelection';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Center(
      child: Material(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: greySwatch[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 7.5,
            runSpacing: 7.5,
            children: options.map((o) => _buildOption(context, o)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, double option) {
    final theme = Theme.of(context);
    final rating = option.toStringAsFixed(1);
    return InkWell(
      onTap: () => Navigator.of(context).pop(option),
      child: Container(
        decoration: BoxDecoration(
          color: swatch[300],
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(horizontal: 7.5, vertical: 7.5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rating,
              style: theme.textTheme.bodyText1?.copyWith(
                color: greySwatch[50],
              ),
            ),
            SizedBox(width: 5),
            Icon(Icons.star, size: 20, color: greySwatch[50]),
          ],
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 150);
}
