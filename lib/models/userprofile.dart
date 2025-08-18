import 'package:flutter/foundation.dart';

class UserProfile with ChangeNotifier {
  String? _name = 'Sandeep Shakya';
  String? _email;
  String? _phone;
  String? _address;
  String? _profileImageUrl;
  DateTime? _memberSince;
  String? _birthday;

  String? get name => _name;
  String? get email => _email;
  String? get phone => _phone;
  String? get address => _address;
  String? get profileImageUrl => _profileImageUrl;
  DateTime? get memberSince => _memberSince;
  String? get birthday => _birthday;

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImageUrl,
    String? birthday,
  }) {
    _name = name ?? _name;
    _email = email ?? _email;
    _phone = phone ?? _phone;
    _address = address ?? _address;
    _profileImageUrl = profileImageUrl ?? _profileImageUrl;
    _birthday = birthday ?? _birthday;
    _memberSince ??= DateTime.now();
    notifyListeners();
  }

  void logout() {
    _name = null;
    _email = null;
    _phone = null;
    _address = null;
    _profileImageUrl = null;
    _birthday = null;
    notifyListeners();
  }

  String get formattedMemberSince {
    if (_memberSince == null) return 'Not available';
    return '${_memberSince!.day}/${_memberSince!.month}/${_memberSince!.year}';
  }
}