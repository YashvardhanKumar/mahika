import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpaceTextInputFormatter extends TextInputFormatter {
  final int afterEvery;
  final String charTo;

  SpaceTextInputFormatter({this.charTo = " ", required this.afterEvery});
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    text = text.replaceAll(RegExp(r'(\s)|(\D)'), '');

    int offset = newValue.selection.start;
    var subText =
    newValue.text.substring(0, offset).replaceAll(RegExp(r'(\s)|(\D)'), '');
    int realTrimOffset = subText.length;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % afterEvery == 0 && nonZeroIndex != text.length) {
        buffer.write(
            charTo); // Replace this with anything you want to put after each 4 numbers
      }

      // This block is only executed once
      if (nonZeroIndex % afterEvery == 0 &&
          subText.length == nonZeroIndex &&
          nonZeroIndex > afterEvery) {
        int moveCursorToRight = nonZeroIndex ~/ afterEvery - 1;
        realTrimOffset += moveCursorToRight;
      }

      // This block is only executed once
      if (nonZeroIndex % afterEvery != 0 && subText.length == nonZeroIndex) {
        int moveCursorToRight = nonZeroIndex ~/ afterEvery;
        realTrimOffset += moveCursorToRight;
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: realTrimOffset));
  }
}
