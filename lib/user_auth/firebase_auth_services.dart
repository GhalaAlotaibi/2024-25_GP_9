import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    // Validate email and password
    if (!isValidEmail(email)) {
      return 'يرجى إدخال بريد إلكتروني صالح';
    }
    if (!isStrongPassword(password)) {
      return 'كلمة المرور ضعيفة';
    }

    try {
      // Create user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore after authentication
      await _firestore
          .collection('Customer')
          .doc(userCredential.user?.uid)
          .set({
        'email': email,
        'Name': username,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'البريد الإلكتروني مستخدم بالفعل';
        case 'operation-not-allowed':
          return 'تسجيل الدخول غير مفعل';
        case 'weak-password':
          return 'يجب ان تحتوي كلمة المرور 8 احرف على الاقل';
        default:
          return 'حدث خطأ: ${e.message}';
      }
    }
  }

  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'المستخدم غير موجود';
        case 'wrong-password':
          return 'كلمة المرور خاطئة';
        default:
          return 'حدث خطأ: ${e.message}';
      }
    }
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool isStrongPassword(String password) {
    return password.length >= 8;
  }
}
