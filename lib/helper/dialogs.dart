import 'package:flutter/material.dart';

class Dialogs {
  static void ShowSnackbar(
    BuildContext context,
    String msg,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue.withOpacity(
          .8,
        ),
        behavior: SnackBarBehavior.floating,
        content: Text(
          msg,
        ),
      ),
    );
  }

  static void ShowProgressBar(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (_) => Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
