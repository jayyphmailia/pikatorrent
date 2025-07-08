import 'package:flutter/material.dart';
import 'package:pikatorrent/storage/shared_preferences.dart';

class PremiumModel extends ChangeNotifier {
  bool _isPremium = false;
  bool _loaded = false;
  DateTime? _subscriptionExpiryDate;
  String _subscriptionType = 'none'; // 'none', 'monthly', 'yearly'

  bool get isPremium => _isPremium;
  bool get loaded => _loaded;
  DateTime? get subscriptionExpiryDate => _subscriptionExpiryDate;
  String get subscriptionType => _subscriptionType;

  PremiumModel() {
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    // Load premium status from SharedPreferences
    _isPremium = await SharedPrefsStorage.getBool('isPremium') ?? false;
    _subscriptionType = await SharedPrefsStorage.getString('subscriptionType') ?? 'none';
    
    // Load subscription expiry date
    final expiryTimestamp = await SharedPrefsStorage.getInt('subscriptionExpiryTimestamp');
    if (expiryTimestamp != null) {
      _subscriptionExpiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    }

    // Check if subscription has expired
    if (_subscriptionExpiryDate != null && _subscriptionExpiryDate!.isBefore(DateTime.now())) {
      _isPremium = false;
      _subscriptionType = 'none';
      await _savePremiumStatus();
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> _savePremiumStatus() async {
    await SharedPrefsStorage.setBool('isPremium', _isPremium);
    await SharedPrefsStorage.setString('subscriptionType', _subscriptionType);
    if (_subscriptionExpiryDate != null) {
      await SharedPrefsStorage.setInt('subscriptionExpiryTimestamp', _subscriptionExpiryDate!.millisecondsSinceEpoch);
    }
  }

  Future<void> setPremiumStatus(bool isPremium, {String subscriptionType = 'none', DateTime? expiryDate}) async {
    _isPremium = isPremium;
    _subscriptionType = subscriptionType;
    _subscriptionExpiryDate = expiryDate;
    await _savePremiumStatus();
    notifyListeners();
  }

  Future<void> activateSubscription(String subscriptionType, DateTime expiryDate) async {
    await setPremiumStatus(true, subscriptionType: subscriptionType, expiryDate: expiryDate);
  }

  Future<void> deactivateSubscription() async {
    await setPremiumStatus(false);
  }

  bool hasFeature(String feature) {
    if (!_isPremium) return false;
    
    // Define premium features here
    switch (feature) {
      case 'unlimited_downloads':
        return true;
      case 'priority_support':
        return true;
      case 'advanced_streaming':
        return true;
      case 'custom_themes':
        return true;
      default:
        return false;
    }
  }

  String getSubscriptionStatusText() {
    if (!_isPremium) return 'Free';
    
    switch (_subscriptionType) {
      case 'monthly':
        return 'Premium Monthly';
      case 'yearly':
        return 'Premium Yearly';
      default:
        return 'Premium';
    }
  }

  String getSubscriptionExpiryText() {
    if (!_isPremium || _subscriptionExpiryDate == null) return '';
    
    final now = DateTime.now();
    final difference = _subscriptionExpiryDate!.difference(now);
    
    if (difference.inDays > 0) {
      return 'Expires in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'Expires in ${difference.inHours} hours';
    } else {
      return 'Expires soon';
    }
  }
}