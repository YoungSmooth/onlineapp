import 'package:flutter/material.dart';
import 'package:onlineapp/services/auth/auth_service.dart';
import 'package:onlineapp/services/cloud/cloud_note.dart';
import 'package:onlineapp/services/cloud/firebase_cloud_storage.dart';
import 'package:onlineapp/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:onlineapp/utilities/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      documentId: note.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final WidgetNote = context.getArgument<CloudNote>();

    if (WidgetNote != null) {
      _note = WidgetNote;
      _textController.text = WidgetNote.text;
      return WidgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        documentId: note.documentId,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Note',
          style: TextStyle(color: Colors.black54, fontSize: 15),
        ),
        elevation: 0.1,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  autofocus: true,
                  autocorrect: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    // border: UnderlineInputBorder(),
                    hintText: 'You can type here...',
                  ),
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedFontSize: 15,
        selectedIconTheme: IconThemeData(color: Colors.lightBlue, size: 20),
        selectedItemColor: Colors.lightBlue,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.delete_forever_outlined,
              size: 20,
            ),
            label: 'Delete',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.image,
              size: 20,
            ),
            label: 'Add image',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.share_sharp,
              size: 20,
            ),
            label: 'Share',
          ),
        ],
      ),
    );
  }
}
