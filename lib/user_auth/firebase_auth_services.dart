import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> validDomains = [
    'gmail.com',
    'hotmail.com',
    'yahoo.com',
    'outlook.com',
  ];

  /// Signs up a user with email and password, returning the user's UID.
  Future<String?> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    // Validate email and password
    if (!isValidEmail(email)) {
      return 'يرجى إدخال بريد إلكتروني صالح';
    }
    if (!isValidDomain(email)) {
      return 'يرجى إدخال بريد إلكتروني صالح';
    }
    if (!isStrongPassword(password)) {
      return 'كلمة المرور يجب أن لا تقل عن 8 خانات';
    }

    try {
      // Create user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user?.uid; // Return the user ID
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

  /// Saves user data to Firestore in the specified collection.
  Future<void> saveUserData(
      String uid, String collectionName, Map<String, dynamic> data) async {
    await _firestore.collection(collectionName).doc(uid).set(data);
  }

  /// Signs in a user with email and password, returning the user's UID.
  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    if (!isValidEmail(email)) {
      return 'البريد الإلكتروني غير صالح';
    }
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.uid; // Return the user ID if successful
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}'); // Log the error code
      switch (e.code) {
        case 'user-not-found':
          return 'المستخدم غير موجود';
        case 'wrong-password':
          return 'كلمة المرور خاطئة';
        case 'invalid-email':
          return 'البريد الإلكتروني غير صالح';
        case 'user-disabled':
          return 'الحساب معطل';
        case 'invalid-credential':
          return 'البيانات المدخلة غير صحيحة';
        default:
          return 'حدث خطأ: ${e.message ?? "غير معروف"}'; // Default error message
      }
    } catch (e) {
      print('Unexpected error: $e'); // Log unexpected errors
      return 'حدث خطأ غير متوقع: ${e.toString()}';
    }
  }

  /// Validates the email format.
  bool isValidEmail(String email) {
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Checks if the email domain is valid.
  bool isValidDomain(String email) {
    final String domain = email.split('@').last; // Extract domain from email
    return validDomains
        .contains(domain); // Check if domain is in the valid domains list
  }

  /// Checks if the password is strong enough.
  bool isStrongPassword(String password) {
    return password.length >= 8;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
