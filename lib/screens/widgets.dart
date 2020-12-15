import 'package:flutter/material.dart';

textFieldWidget({
  TextEditingController controller,
  String label,
  String hint,
  String initialValue,
  Icon prefixIcon,
  Widget suffixIcon,
  double size,
  Function(String) locationCallback,
}) {
  return Container(
    width: size / 1.5,
    child: TextField(
      onChanged: (value) {
        locationCallback(value);
      },
      controller: controller,
      // initialValue: initialValue,
      decoration: new InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(
            color: Colors.blue[400],
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(
            color: Colors.blue[300],
            width: 1,
          ),
        ),
        contentPadding: EdgeInsets.all(15),
        hintText: hint,
      ),
    ),
  );
}
