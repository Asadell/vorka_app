import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vorka_app2/core/constants/firebase_constants.dart';
import 'package:vorka_app2/core/utils/notification_helper.dart';
import 'package:vorka_app2/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up with Email
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      await user.updateDisplayName(name);

      // Get FCM token
      final fcmToken = await NotificationHelper.getFcmToken();

      // Create user document
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        name: name,
        photoURL: user.photoURL,
        fcmToken: fcmToken,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore());

      return userModel;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign In with Email
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;

      // Update FCM token
      final fcmToken = await NotificationHelper.getFcmToken();
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .update({'fcmToken': fcmToken});

      // Get user document
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .get();

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign In with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in cancelled');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Get FCM token
      final fcmToken = await NotificationHelper.getFcmToken();

      // Check if user exists
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        // Create new user
        final userModel = UserModel(
          uid: user.uid,
          email: user.email!,
          name: user.displayName ?? '',
          photoURL: user.photoURL,
          fcmToken: fcmToken,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toFirestore());

        return userModel;
      } else {
        // Update FCM token
        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(user.uid)
            .update({'fcmToken': fcmToken});

        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Get Current User Data
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Get user data failed: $e');
    }
  }

  // Update User Profile
  Future<void> updateUserProfile({
    String? name,
    String? photoURL,
    String? phoneNumber,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      final updates = <String, dynamic>{};
      if (name != null) {
        updates['name'] = name;
        await user.updateDisplayName(name);
      }
      if (photoURL != null) {
        updates['photoURL'] = photoURL;
        await user.updatePhotoURL(photoURL);
      }
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;

      if (updates.isNotEmpty) {
        await _firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(user.uid)
            .update(updates);
      }
    } catch (e) {
      throw Exception('Update profile failed: $e');
    }
  }
}
