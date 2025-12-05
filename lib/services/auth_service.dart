import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream do usuário logado
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Usuário atual
  User? get currentUser => _firebaseAuth.currentUser;

  // Login com e-mail e senha
  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Cadastro com e-mail e senha
  Future<void> signUp(String email, String password) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
