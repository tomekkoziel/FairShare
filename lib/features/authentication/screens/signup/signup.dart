import 'package:fair_share/common/widgets/login_signup/form_divider.dart';
import 'package:fair_share/common/widgets/login_signup/social_buttons.dart';
import 'package:fair_share/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:fair_share/utils/constants/sizes.dart';
import 'package:fair_share/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(TTexts.signupTitle, style: Theme.of(context).textTheme.headlineMedium,),
              const SizedBox(height: TSizes.spaceBtwSections),
              
              // Form
              TSignupForm(),
            
              //Divider
              const SizedBox(height: TSizes.spaceBtwSections),
              const TFormDivider(dividerText: TTexts.orSignUpWith),

              // Footer - Social Media Sign Up
              const SizedBox(height: TSizes.spaceBtwSections),
              const TSocialButtons(),
            ],
          ),
        ),
      ),
      
    );
  }
}