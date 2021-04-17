import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

InputBorder noBorder(Color color) => InputBorder.none;

InputBorder _outlineBorder(Color color) {
  return OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 1),
    borderRadius: BorderRadius.circular(22.5),
  );
}

InputBorder _underlineBorder(Color color) {
  return UnderlineInputBorder(
    borderSide: BorderSide(color: color, width: 1),
    borderRadius: BorderRadius.circular(22.5),
  );
}

class OutlinedTextField extends CustomTextField {
  OutlinedTextField({
    Key? key,
    bool isDense = true,
    FormFieldValidator<String>? validator,
    GlobalKey<FormState>? state,
    TextEditingController? controller,
    String? hintText,
    bool obscure = false,
    TextCapitalization caps = TextCapitalization.sentences,
    TextInputType keyboardType = TextInputType.text,
    Icon? prefixIcon,
    TextAlign textAlign = TextAlign.start,
    int? maxLength,
    TextStyle? style,
  }) : super(
          key: key,
          isDense: isDense,
          validator: validator,
          state: state,
          controller: controller,
          hintText: hintText,
          obscure: obscure,
          caps: caps,
          keyboardType: keyboardType,
          prefixIcon: prefixIcon,
          textAlign: textAlign,
          maxLength: maxLength,
          makeBorder: _outlineBorder,
          style: style,
        );
}

class UnderlinedTextField extends CustomTextField {
  UnderlinedTextField({
    Key? key,
    bool isDense = true,
    FormFieldValidator<String>? validator,
    GlobalKey<FormState>? state,
    TextEditingController? controller,
    String? hintText,
    bool obscure = false,
    TextCapitalization caps = TextCapitalization.sentences,
    TextInputType keyboardType = TextInputType.text,
    Icon? prefixIcon,
    TextAlign textAlign = TextAlign.start,
    int? maxLength,
    EdgeInsetsGeometry? padding,
    TextStyle? style,
  }) : super(
          key: key,
          isDense: isDense,
          validator: validator,
          state: state,
          controller: controller,
          hintText: hintText,
          obscure: obscure,
          caps: caps,
          keyboardType: keyboardType,
          prefixIcon: prefixIcon,
          textAlign: textAlign,
          maxLength: maxLength,
          makeBorder: _underlineBorder,
          style: style,
          padding: padding,
        );
}

class CustomTextField extends StatefulWidget {
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
  final InputBorder Function(Color) makeBorder;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;

  CustomTextField({
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
    this.makeBorder = noBorder,
    this.style,
    this.padding = const EdgeInsets.all(10),
  }) : super(key: key);
  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool unsubmitted = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _style = widget.style ?? theme.textTheme.headline6;
    return SizedBox(
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          contentPadding: widget.padding,
          prefixIcon: widget.prefixIcon,
          hintText: widget.hintText,
          hintStyle: _style?.copyWith(
            color: greySwatch[800].withOpacity(0.6),
          ),
          enabledBorder: widget.makeBorder(greySwatch[300]),
          focusedBorder: widget.makeBorder(theme.primaryColor),
          errorBorder: widget.makeBorder(theme.errorColor),
          focusedErrorBorder: widget.makeBorder(theme.errorColor),
          errorStyle: TextStyle(color: theme.errorColor),
          isDense: widget.isDense,
        ),
        style: _style,
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
}
