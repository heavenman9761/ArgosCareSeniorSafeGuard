import 'package:flutter/material.dart';
import 'package:argoscareseniorsafeguard/constants.dart';

renderTextFormField({
  required BuildContext context,
  String? label,
  FormFieldSetter? onSaved,
  FormFieldValidator? validator,
  required int keyNumber,
  Icon? icon,
  TextInputType? keyboardType,
  bool? obscureText,
  String? initialValue,
}) {
/*  assert(onSaved != null);
  assert(validator != null);*/
  return TextFormField(
    key: ValueKey(keyNumber),
    decoration: InputDecoration(
        prefixIcon: icon,
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
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey[500]),
    ),
    keyboardType: keyboardType,
    initialValue: initialValue,
    // autovalidateMode: AutovalidateMode.always,
    onSaved: onSaved,
    validator: validator,
    obscureText: obscureText ?? false,
    scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
