import 'package:flutter/material.dart';
import 'package:onlineapp/enums/menu_action.dart';
import 'package:onlineapp/services/auth/bloc/auth_bloc.dart';
import 'package:onlineapp/services/auth/bloc/auth_event.dart';
import 'package:onlineapp/services/cloud/cloud_note.dart';
import 'package:onlineapp/services/cloud/firebase_cloud_storage.dart';
import 'package:onlineapp/utilities/dialogs/logout_dialog.dart';
import 'package:onlineapp/views/notes/notes_list_view.dart';
import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
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

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Humphrey's Notes"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              },
              icon: const Icon(Icons.add)),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedFontSize: 15,
        selectedIconTheme: IconThemeData(color: Colors.orange, size: 20),
        selectedItemColor: Colors.orange,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.business_center_rounded,
              size: 20,
            ),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.contact_phone_outlined,
              size: 20,
            ),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_accessibility_rounded,
              size: 20,
            ),
            label: 'Share',
          ),
        ],
      ),
    );
  }
}
