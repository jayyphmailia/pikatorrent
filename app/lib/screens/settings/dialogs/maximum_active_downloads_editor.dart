import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pikatorrent/models/premium.dart';
import 'package:provider/provider.dart';

class MaximumActiveDownloadEditorDialog extends StatefulWidget {
  final void Function(int) onSave;

  const MaximumActiveDownloadEditorDialog({super.key, required this.onSave});

  @override
  State<MaximumActiveDownloadEditorDialog> createState() =>
      _MaximumActiveDownloadEditorState();
}

class _MaximumActiveDownloadEditorState
    extends State<MaximumActiveDownloadEditorDialog> {
  late TextEditingController _maximumActiveDownloadsController;

  @override
  void initState() {
    super.initState();
    _maximumActiveDownloadsController = TextEditingController();
  }

  @override
  void dispose() {
    _maximumActiveDownloadsController.dispose();
    super.dispose();
  }

  void handleSave() async {
    final premiumModel = Provider.of<PremiumModel>(context, listen: false);
    final value = int.parse(_maximumActiveDownloadsController.text);
    
    // Limit free users to maximum 3 active downloads
    if (!premiumModel.isPremium && value > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Free users are limited to 3 active downloads. Upgrade to Premium for unlimited downloads.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    widget.onSave(value);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumModel>(
      builder: (context, premiumModel, child) {
        return AlertDialog(
          title: const Text('Maximum active downloads'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _maximumActiveDownloadsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Enter a number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null; // Return null if the input is valid
                },
              ),
              if (!premiumModel.isPremium) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade600, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Free users are limited to 3 active downloads. Upgrade to Premium for unlimited downloads.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop();
                handleSave();
              },
            ),
          ],
        );
      },
    );
  }
}
