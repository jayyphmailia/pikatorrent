import 'package:flutter_test/flutter_test.dart';
import 'package:pikatorrent/models/premium.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PremiumModel', () {
    late PremiumModel premiumModel;

    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
      premiumModel = PremiumModel();
      // Wait for the model to load
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('should initialize with free status', () {
      expect(premiumModel.isPremium, false);
      expect(premiumModel.subscriptionType, 'none');
      expect(premiumModel.subscriptionExpiryDate, isNull);
      expect(premiumModel.getSubscriptionStatusText(), 'Free');
    });

    test('should activate premium subscription', () async {
      final expiryDate = DateTime.now().add(const Duration(days: 30));
      
      await premiumModel.activateSubscription('monthly', expiryDate);
      
      expect(premiumModel.isPremium, true);
      expect(premiumModel.subscriptionType, 'monthly');
      expect(premiumModel.subscriptionExpiryDate, expiryDate);
      expect(premiumModel.getSubscriptionStatusText(), 'Premium Monthly');
    });

    test('should deactivate premium subscription', () async {
      final expiryDate = DateTime.now().add(const Duration(days: 30));
      await premiumModel.activateSubscription('monthly', expiryDate);
      
      await premiumModel.deactivateSubscription();
      
      expect(premiumModel.isPremium, false);
      expect(premiumModel.subscriptionType, 'none');
      expect(premiumModel.getSubscriptionStatusText(), 'Free');
    });

    test('should check premium features correctly', () async {
      // Test free user
      expect(premiumModel.hasFeature('unlimited_downloads'), false);
      expect(premiumModel.hasFeature('priority_support'), false);
      
      // Test premium user
      final expiryDate = DateTime.now().add(const Duration(days: 30));
      await premiumModel.activateSubscription('monthly', expiryDate);
      
      expect(premiumModel.hasFeature('unlimited_downloads'), true);
      expect(premiumModel.hasFeature('priority_support'), true);
      expect(premiumModel.hasFeature('advanced_streaming'), true);
      expect(premiumModel.hasFeature('custom_themes'), true);
      expect(premiumModel.hasFeature('nonexistent_feature'), false);
    });

    test('should handle subscription expiry correctly', () async {
      // Set an expired subscription
      final expiredDate = DateTime.now().subtract(const Duration(days: 1));
      await premiumModel.activateSubscription('monthly', expiredDate);
      
      // Create a new model to simulate app restart
      final newModel = PremiumModel();
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(newModel.isPremium, false);
      expect(newModel.subscriptionType, 'none');
    });

    test('should provide correct expiry text', () async {
      // Test with future expiry date
      final futureDate = DateTime.now().add(const Duration(days: 5));
      await premiumModel.activateSubscription('monthly', futureDate);
      
      final expiryText = premiumModel.getSubscriptionExpiryText();
      expect(expiryText, contains('5 days'));
      
      // Test with no premium
      await premiumModel.deactivateSubscription();
      expect(premiumModel.getSubscriptionExpiryText(), '');
    });
  });
}