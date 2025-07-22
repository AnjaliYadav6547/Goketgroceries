import 'package:flutter/foundation.dart';

class UserProfile with ChangeNotifier {
  String? _name;
  String? _email;
  String? _phone;
  String? _address;
  String? _profileImageUrl;
  DateTime? _memberSince;

  String? get name => _name;
  String? get email => _email;
  String? get phone => _phone;
  String? get address => _address;
  String? get profileImageUrl => _profileImageUrl;
  DateTime? get memberSince => _memberSince;

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImageUrl,
  }) {
    _name = name ?? _name;
    _email = email ?? _email;
    _phone = phone ?? _phone;
    _address = address ?? _address;
    _profileImageUrl = profileImageUrl ?? _profileImageUrl;
    _memberSince ??= DateTime.now();
    notifyListeners();
  }

  void logout() {
    _name = null;
    _email = null;
    _phone = null;
    _address = null;
    _profileImageUrl = null;
    notifyListeners();
  }

  String get formattedMemberSince {
    if (_memberSince == null) return 'Not available';
    return '${_memberSince!.day}/${_memberSince!.month}/${_memberSince!.year}';
  }
}