import 'package:fair_share/common/widgets/texts/section_heading.dart';
import 'package:fair_share/features/personalization/screens/widgets/profile_widgets.dart';
import 'package:fair_share/utils/constants/sizes.dart';
import 'package:fair_share/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              TSectionHeading(title: 'Profile Information', showActionButton: false,),
              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              ProfileMenuWidget(title: 'Username', value: 'username', onPress: () {}),
              const SizedBox(width: TSizes.spaceBtwItems),
              ProfileMenuWidget(title: 'First Name', value: 'Name', onPress: () {}),
              const SizedBox(width: TSizes.spaceBtwItems),
              ProfileMenuWidget(title: 'Last Name', value: 'Surname', onPress: () {}),
              const SizedBox(width: TSizes.spaceBtwItems),
              ProfileMenuWidget(title: 'Email', value: 'email@gmail.com', onPress: () {}),
              const SizedBox(width: TSizes.spaceBtwItems),
              ProfileMenuWidget(title: 'Phone', value: '+1234567890', onPress: () {}),

              const SizedBox(height: TSizes.spaceBtwSections),
              TSectionHeading(title: 'Expense Summary', showActionButton: false,),
              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 3, child: Text('Total Expenses', style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis,)),
                  Expanded(flex: 5, child: Text('Number', style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis,)),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Add your logout logic here
            },
            child: const Text(TTexts.logOut),
          ),
        ),
      ),
    );
  }
}