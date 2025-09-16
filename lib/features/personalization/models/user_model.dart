import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fair_share/utils/formatters/formatter.dart';

class UserModel {
  final String uid;
  String firstName;
  String lastName;
  String username;
  final String email;
  String phoneNumber;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
  });

  String get fullName => '$firstName $lastName';

  String get formattedPhoneNumber => TFormatter.formatPhoneNumber(phoneNumber);

  static List<String> nameParts(fullname) => fullname.split(' ');

  // creating empty user model
  static UserModel empty() => UserModel(
        uid: '',
        firstName: '',
        lastName: '',
        username: '',
        email: '',
        phoneNumber: '',
      );

  // Convert model to JSON structure for storing data in Firebase
  Map<String, dynamic> toJson() => {
        'FirstName': firstName,
        'LastName': lastName,
        'Username': username,
        'Email': email,
        'PhoneNumber': phoneNumber,
      };

  // Factory method to create a UserModel from a Firebase document snapshot
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return UserModel(
      uid: snapshot.id,
      firstName: data['FirstName'] ?? '',
      lastName: data['LastName'] ?? '',
      username: data['Username'] ?? '',
      email: data['Email'] ?? '',
      phoneNumber: data['PhoneNumber'] ?? '',
    );
  }
}