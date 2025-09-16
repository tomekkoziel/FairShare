import 'package:fair_share/data/repositories/authentication/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'firebase_options.dart';

import 'app.dart';

Future<void> main() async {

  // TODO: Widgets Binding
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // TODO: Init Local Storage
  await GetStorage.init();

  // TODO: Await Native Splash until initialization is done
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // TODO: Initialize Firebase and Authentication Repository
  await Firebase.initializeApp (
    options: DefaultFirebaseOptions.currentPlatform).then(
      (_) => Get.put(AuthenticationRepository())
    );
  debugPrint('Firebase initialized: ${GetUtils.isNullOrBlank(Firebase.app().name)}');

  runApp(const App());
}