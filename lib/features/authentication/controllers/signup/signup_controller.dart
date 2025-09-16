import 'package:fair_share/data/repositories/authentication/authentication_repository.dart';
import 'package:fair_share/data/repositories/user/user_repository.dart';
import 'package:fair_share/features/authentication/screens/signup/verify_email.dart';
import 'package:fair_share/features/personalization/models/user_model.dart';
import 'package:fair_share/utils/helpers/network_manager.dart';
import 'package:fair_share/utils/popups/full_screen_loader.dart';
import 'package:fair_share/utils/popups/loaders.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  // Variables
  final hidePassword = true.obs;
  final email = TextEditingController();
  final lastName = TextEditingController();
  final firstName = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final phoneNumber = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  // Methods for Sign Up
  Future<void> signup() async {
    try {
    // Start Loading
    FullScreenLoader.openLoadingDialog("We are processing your data...");

    // Check Internet Connection
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      FullScreenLoader.stopLoading();
      return;
    }

    // Form Validation
    if(!signupFormKey.currentState!.validate()) {
      // FullScreenLoader.stopLoading();
      return;
    }

    // Register user in the Firestore Authentication and Save user data in Firebase
    final userCredential = await AuthenticationRepository.instance.registerWithEmailAndPassword(email.text.trim(), password.text.trim());

    // Save Authenticated user data in the Firebase Firestore
    final newUser = UserModel(
      uid: userCredential.user!.uid, 
      firstName: firstName.text.trim(), 
      lastName: lastName.text.trim(), 
      username: username.text.trim(), 
      email: email.text.trim(), 
      phoneNumber: phoneNumber.text.trim(),
    );

    final userRepository = Get.put(UserRepository());
    await userRepository.saveUserRecord(newUser);

    // FullScreenLoader.stopLoading();

    // Show Success Message
    TLoaders.successSnackBar(title: 'Success', message: 'Your account has been created successfully! Verify your email to login.');

    // Redirect to Verify Email Screen
    Get.to(() => const VerifyEmailScreen());

    // Move to Verification Screen
    } catch (e) {
      // FullScreenLoader.stopLoading();

      // Show Error Message
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      // Remove Loader
      FullScreenLoader.stopLoading();
    }
  }
}