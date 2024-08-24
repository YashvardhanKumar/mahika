import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPBox extends StatelessWidget {
  const OTPBox({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.errorText,
  }) : super(key: key);
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: TextFormField(
        cursorColor: Colors.black,
        textAlign: TextAlign.center,
        inputFormatters: [
          // LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          fontFamily: 'SourceSansPro',
        ),
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isCollapsed: true,
          contentPadding: const EdgeInsets.all(5),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: (errorText != null)
                  ? Colors.red.shade800
                  : (controller.text.isNotEmpty)
                  ? Colors.black
                  : const Color(0xffD8DADC),
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: (errorText != null)
                  ? Colors.red.shade800
                  : (controller.text.isNotEmpty)
                  ? Colors.black
                  : const Color(0xffD8DADC),
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: (errorText != null) ? Colors.red.shade800 : Colors.black,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        controller: controller,
        onChanged: (value) {
          onChanged(value);
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          } else {
            FocusScope.of(context).previousFocus();
          }
          print(controller.text);
        },
      ),
    );
  }
}