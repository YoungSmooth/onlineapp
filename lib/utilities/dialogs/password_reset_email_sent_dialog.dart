import 'package:flutter/material.dart';
import 'package:onlineapp/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetEmailSentDialog(BuildContext context) {
  return showGenericDialog<void>(
      context: context,
      title: 'Password Reset',
      content:
          'We have now sent you a password reset link. Please check your email for more information.',
      optionBuilder: () => {
            'Ok': null,
          });
}
