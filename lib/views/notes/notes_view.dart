import 'package:flutter/material.dart';
import 'package:onlineapp/enums/menu_action.dart';
import 'package:onlineapp/services/auth/bloc/auth_bloc.dart';
import 'package:onlineapp/services/auth/bloc/auth_event.dart';
import 'package:onlineapp/services/cloud/cloud_note.dart';
import 'package:onlineapp/services/cloud/firebase_cloud_storage.dart';
import 'package:onlineapp/utilities/dialogs/logout_dialog.dart';
import 'package:onlineapp/views/notes/notes_list_view.dart';
import '../../constants/routes.dart';
import '../../services/auth/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  get icon => Icons.add;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 13),
                  child: SizedBox(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.redAccent),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text(
                    "Search notes",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                      fontFamily: 'costa',
                    ),
                  ),
                ),
                PopupMenuButton<MenuAction>(
                  onSelected: (value) async {
                    switch (value) {
                      case MenuAction.Logout:
                        final shouldLogout = await showLogoutDialog(context);
                        if (shouldLogout) {
                          context.read<AuthBloc>().add(
                                const AuthEventLogOut(),
                              );
                        }
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem<MenuAction>(
                        value: MenuAction.Logout,
                        child: Text('Logout'),
                      ),
                    ];
                  },
                )
              ],
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        titleSpacing: 3,
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(documentId: note.documentId);
                  },
                  onTap: (note) {
                    Navigator.of(context).pushNamed(
                      createOrUpdateNoteRoute,
                      arguments: note,
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
        },
        child: const Icon(
          Icons.add,
          size: 20,
          color: Colors.white,
        ),
        backgroundColor: Colors.black54,
      ),
    );
  }
}
