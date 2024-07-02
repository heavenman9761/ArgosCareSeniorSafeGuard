import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:argoscareseniorsafeguard/constants.dart';

renderTextFormField({
  required BuildContext context,
  bool? autofocus,
  bool? readOnly,
  FocusNode? focusNode,
  String? label,
  FormFieldSetter? onSaved,
  FormFieldValidator? validator,
  int? keyNumber,
  Icon? icon,
  IconButton? suffixIcon,
  TextInputType? keyboardType,
  bool? obscureText,
  String? initialValue,
  ValueChanged<String>? onChanged,
  TextEditingController? controller,
}) {
/*  assert(onSaved != null);
  assert(validator != null);*/
  return TextFormField(
    key: ValueKey(keyNumber),
    autofocus: autofocus ?? false,
    focusNode: focusNode,
    readOnly: readOnly ?? false,
    decoration: InputDecoration(
        prefixIcon: icon,
        suffixIcon: suffixIcon,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFF0F0F0)),
          borderRadius: BorderRadius.all(Radius.circular(8.0))
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Constants.primaryColor),
          borderRadius: BorderRadius.all(Radius.circular(8.0))
        ),
        disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Constants.borderColor),
            borderRadius: BorderRadius.all(Radius.circular(8.0))
        ),
        isDense: true,
        contentPadding: const EdgeInsets.all(16),
        fillColor: Colors.white,
        filled: true,
        hintText: label,
        hintStyle: const TextStyle(color: Constants.hintColor),
    ),
    onChanged: onChanged,
    controller: controller,
    keyboardType: keyboardType,
    initialValue: initialValue,
    // autovalidateMode: AutovalidateMode.always,
    onSaved: onSaved,
    validator: validator,
    obscureText: obscureText ?? false,
    scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    style: TextStyle(fontSize: 16.sp)
  );
}

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        style: TextStyle(fontSize: deviceFontSize),
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.all(8),
            fillColor: Colors.grey.shade200,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[500])
        ),

      ),
    );
  }
}
