import 'package:flutter/material.dart';
import 'package:pikatorrent/models/premium.dart';
import 'package:provider/provider.dart';

class PremiumUtils {
  /// Check if a premium feature is available
  static bool hasFeature(BuildContext context, String feature) {
    final premiumModel = Provider.of<PremiumModel>(context, listen: false);
    return premiumModel.hasFeature(feature);
  }

  /// Show premium upgrade dialog if feature is not available
  static void showFeatureDialog(BuildContext context, String feature, String featureName) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$featureName - Premium Feature'),
          content: Text('$featureName is available for Premium users. Upgrade to Premium to unlock this feature and support PikaTorrent development.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Maybe Later'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Upgrade'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to settings premium section
                // This would typically navigate to the premium upgrade screen
              },
            ),
          ],
        );
      },
    );
  }

  /// Widget wrapper that shows premium badge for premium features
  static Widget premiumFeatureWrapper({
    required BuildContext context,
    required String feature,
    required Widget child,
    Widget? premiumOverlay,
  }) {
    final premiumModel = Provider.of<PremiumModel>(context);
    final hasAccess = premiumModel.hasFeature(feature);

    if (hasAccess) {
      return child;
    }

    return Stack(
      children: [
        Opacity(
          opacity: 0.5,
          child: child,
        ),
        if (premiumOverlay != null) 
          premiumOverlay
        else
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}