import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fair_share/features/personalization/models/user_model.dart';
import 'package:fair_share/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:fair_share/utils/exceptions/firebase_exceptions.dart';
import 'package:fair_share/utils/exceptions/format_exceptions.dart';
import 'package:fair_share/utils/exceptions/platform_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  // Variables
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save user record to Firestore
  Future<void> saveUserRecord(UserModel user) async {
    try {
      return await _db.collection("Users").doc(user.uid).set(user.toJson());
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Fetch user record from Firestore by UID

}