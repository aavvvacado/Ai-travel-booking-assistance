import 'package:equatable/equatable.dart';

class PassengerDetails extends Equatable {
  final String fullName;
  final String email;
  final String phone;

  const PassengerDetails({
    required this.fullName,
    required this.email,
    required this.phone,
  });

  bool get isValid => fullName.trim().isNotEmpty && email.trim().isNotEmpty && phone.trim().isNotEmpty;

  PassengerDetails copyWith({
    String? fullName,
    String? email,
    String? phone,
  }) {
    return PassengerDetails(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [fullName, email, phone];
}
