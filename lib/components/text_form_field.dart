import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    Key? key,
    required this.label,
    this.hint,
    this.isPassword = false,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.suffix,
    this.onTap,
    this.enabled = true, this.inputFormatters, this.onChange, this.prefixText,
  }) : super(key: key);
  final Widget? suffix;
  final String label;
  final String? hint,prefixText;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final ValueChanged<String?>? onChange;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.poppins(
              color: widget.enabled ? Colors.black : Color(0xffD8DADC),
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 3,
        ),
        TextFormField(
          onTap: widget.onTap,
          controller: widget.controller,
          cursorColor: Colors.black,
          obscureText: widget.isPassword && !isVisible,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChange,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            enabled: widget.enabled,
            hintText: widget.hint,

            prefix: Text(widget.prefixText ?? "", style: TextStyle(color: Colors.black),),
            hintStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: widget.enabled ? Colors.grey.shade400 : Color(0xffD8DADC),
            ),
            suffixIcon: (widget.isPassword)
                ? GestureDetector(
                    onTap: () {
                      isVisible = !isVisible;
                      setState(() {});
                    },
                    child: Icon(
                      !isVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  )
                : widget.suffix,
            isCollapsed: true,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    // (widget.controller.text.isNotEmpty)
                    // ?
                    Colors.black,
                // : const Color(0xffD8DADC),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    // (widget.controller.text.isNotEmpty)
                    //     ?
                    Colors.black,
                // : const Color(0xffD8DADC),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ],
    );
  }
}
