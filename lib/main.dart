import 'package:flutter/material.dart';
import 'package:onlineapp/constants/routes.dart';
import 'package:onlineapp/services/auth/auth_service.dart';
import 'package:onlineapp/views/login_views.dart';
import 'package:onlineapp/views/notes/create_update_note_view.dart';
import 'package:onlineapp/views/notes/notes_view.dart';
import 'package:onlineapp/views/register_view.dart';
import 'package:onlineapp/views/verify_email_view.dart';
import 'package:path/path.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Onyion Loading',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
