import 'package:onlineapp/services/auth/auth_provider.dart';
import 'package:onlineapp/services/auth/auth_user.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  @override
  Future<AuthUser> creatUser({
    required String email,
    required String password,
  }) {
    // TODO: implement creatUser
    throw UnimplementedError();
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => throw UnimplementedError();

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    // TODO: implement logIn
    throw UnimplementedError();
  }

  @override
  Future<void> logOut() {
    // TODO: implement logOut
    throw UnimplementedError();
  }

  @override
  Future<void> sendEmailVerification() {
    // TODO: implement sendEmailVerification
    throw UnimplementedError();
  }
}
