import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDropDownField extends StatefulWidget {
  final List<String> listItems;
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? errorText;

  const CustomDropDownField({
    Key? key,
    required this.listItems,
    required this.label,
    this.hint,
    required this.controller,
    required this.errorText,
  }) : super(key: key);

  @override
  State<CustomDropDownField> createState() => _CustomDropDownFieldState();
}

class _CustomDropDownFieldState extends State<CustomDropDownField> {
  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 3,
        ),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => SimpleDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                // title: Text('Select One'),
                children: widget.listItems.map((e) {
                  return SimpleDialogOption(
                    onPressed: () {
                      widget.controller.text = e;
                      setState(() {});
                      Navigator.pop(context);
                    },
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      e,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xffD8DADC),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.controller.text.isEmpty
                        ? 'Select One'
                        : widget.controller.text,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: widget.controller.text.isEmpty
                          ? Colors.grey.shade400
                          : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (widget.errorText != null)
          Text(
            widget.label,
            style: GoogleFonts.poppins(
              color: Colors.red.shade900,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
