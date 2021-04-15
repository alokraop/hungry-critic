import 'package:flutter/material.dart';

class LabelDivider extends StatelessWidget {
  const LabelDivider({Key? key, this.content, this.color}) : super(key: key);

  final Widget? content;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildDivider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: content,
        ),
        _buildDivider(),
      ],
    );
  }

  _buildDivider() {
    return Flexible(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Divider(color: color),
      ),
    );
  }
}
