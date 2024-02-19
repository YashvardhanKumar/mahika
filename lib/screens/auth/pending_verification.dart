import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

Widget pendingVerification(bool? isValid) =>
    SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                (isValid != null && !isValid)
                    ? 'Your Verification was rejected!'
                    : 'Your Verification is underway!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                (isValid != null && !isValid)
                    ? 'Contact us if it was a mistake!'
                    : 'It may take time depending on load of users!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );