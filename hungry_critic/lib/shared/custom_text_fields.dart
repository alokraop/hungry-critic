import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

class OutlinedTextField extends StatefulWidget {
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
  final bool obscure;

  OutlinedTextField({
    Key? key,
    this.isDense = true,
    this.validator,
    this.state,
    this.controller,
    this.hintText,
    this.obscure = false,
    this.caps = TextCapitalization.sentences,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.textAlign = TextAlign.start,
    this.maxLength,
  }) : super(key: key);
  @override
  _OutlinedTextFieldState createState() => _OutlinedTextFieldState();
}

class _OutlinedTextFieldState extends State<OutlinedTextField> {
  bool unsubmitted = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(12.5),
          prefixIcon: widget.prefixIcon,
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyText1?.copyWith(
            color: greySwatch[800].withOpacity(0.6),
          ),
          enabledBorder: _makeBorder(greySwatch[300]),
          focusedBorder: _makeBorder(theme.primaryColor),
          errorBorder: _makeBorder(theme.errorColor),
          focusedErrorBorder: _makeBorder(theme.errorColor),
          errorStyle: TextStyle(color: theme.errorColor),
          isDense: widget.isDense,
        ),
        style: theme.textTheme.bodyText1,
        obscureText: widget.obscure,
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
    );
  }

  _makeBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: 1),
      borderRadius: BorderRadius.circular(22.5),
    );
  }
}
