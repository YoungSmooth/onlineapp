import 'package:flutter/material.dart';
import 'package:onlineapp/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: 'You cannnot share an empty note!',
    optionBuilder: () => {
      'OK': null,
    },
  );
}
