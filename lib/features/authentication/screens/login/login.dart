import 'package:fair_share/common/styles/spacing_styles.dart';
import 'package:fair_share/common/widgets/login_signup/form_divider.dart';
import 'package:fair_share/common/widgets/login_signup/social_buttons.dart';
import 'package:fair_share/features/authentication/screens/login/widgets/login_form.dart';
import 'package:fair_share/features/authentication/screens/login/widgets/login_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/constants/sizes.dart';
import 'package:fair_share/utils/constants/text_strings.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo, Title & Subtitle
              const TLoginHeader(),

              // Form
              const TLoginForm(),
            
              // Divider with "or sign in with"
              TFormDivider(dividerText: TTexts.orSignInWith.capitalize!),

              const SizedBox(height: TSizes.spaceBtwSections),
            
              // Footer - Social Media Login
              const TSocialButtons(),
            
            ],
          ),
        ),
      ),
    );
  }
}