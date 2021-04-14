import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

class UnderlinedTextField extends StatefulWidget {
  final FormFieldValidator<String>? validator;
  final GlobalKey<FormState>? state;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType keyboardType;
  final Icon? prefixIcon;
  final TextAlign textAlign;
  final int? maxLength;
  final bool isDense;
  final TextCapitalization caps;

  const UnderlinedTextField({
    Key? key,
    this.isDense = true,
    this.validator,
    this.state,
    this.controller,
    this.hintText,
    this.caps = TextCapitalization.sentences,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.textAlign = TextAlign.start,
    this.maxLength,
  }) : super(key: key);
  @override
  _UnderlinedTextFieldState createState() => _UnderlinedTextFieldState();
}

class _UnderlinedTextFieldState extends State<UnderlinedTextField> {
  bool unsubmitted = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: widget.state,
      child: SizedBox(
        child: TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(7.5),
            prefixIcon: widget.prefixIcon,
            hintText: widget.hintText,
            hintStyle: theme.textTheme.subtitle1,
            enabledBorder: _makeBorder(greySwatch[300]),
            focusedBorder: _makeBorder(greySwatch),
            errorBorder: _makeBorder(theme.errorColor),
            errorStyle: TextStyle(color: theme.errorColor),
            isDense: widget.isDense,
          ),
          style: theme.textTheme.subtitle1,
          cursorColor: greySwatch[800],
          keyboardType: widget.keyboardType,
          textCapitalization: widget.caps,
          onChanged: (v) {
            unsubmitted = true;
            widget.state?.currentState?.validate();
            unsubmitted = false;
          },
          validator: (v) {
            if (unsubmitted) return null;
            return widget.validator?.call(v);
          },
          textAlign: widget.textAlign,
          inputFormatters: [
            LengthLimitingTextInputFormatter(widget.maxLength),
          ],
        ),
      ),
    );
  }

  _makeBorder(Color color) {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: color, width: 1),
    );
  }
}
