import 'package:flutter/material.dart';

import '../../constants.dart';

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.isClicked = false,
  }) : super(key: key);
  final String label;
  final VoidCallback? onPressed;
  final bool isClicked;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: kColorDark,
        shape: RoundedRectangleBorder(
          side: isClicked ? BorderSide.none : BorderSide(
            width: 2,
            color: kColorDark,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: !isClicked ? onPressed : null,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: !isClicked
            ? Text(
                label,
                style: const TextStyle(fontSize: 18),
              )
            : SizedBox(
                height: 30,
                width: 30,
                child: const CircularProgressIndicator(
                  color: kColorDark,
                  strokeCap: StrokeCap.round,
                  strokeWidth: 2,
                ),
              ),
      ),
    );
  }
}

class CustomOutlineButton extends StatelessWidget {
  const CustomOutlineButton(
      {Key? key, required this.onPressed, required this.label})
      : super(key: key);
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: kColorLight,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: kColorDark, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: kColorDark,
          ),
        ),
      ),
    );
  }
}
