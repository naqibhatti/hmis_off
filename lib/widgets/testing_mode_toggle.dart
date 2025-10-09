import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/testing_config.dart';

class TestingModeToggle extends StatefulWidget {
  const TestingModeToggle({super.key});

  @override
  State<TestingModeToggle> createState() => _TestingModeToggleState();
}

class _TestingModeToggleState extends State<TestingModeToggle> {
  final TextEditingController _commandController = TextEditingController();
  bool _showCommandInput = false;

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  void _handleCommand(String command) {
    final trimmedCommand = command.trim().toUpperCase();
    
    if (trimmedCommand == 'RESTORE') {
      TestingConfig.restoreApiLogic();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 API Logic Restored - All API calls and authentication enabled'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        _showCommandInput = false;
        _commandController.clear();
      });
    } else if (trimmedCommand == 'TESTING') {
      TestingConfig.enableTestingMode();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🧪 Testing Mode Enabled - API calls disabled, using dummy data'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        _showCommandInput = false;
        _commandController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Unknown command. Use "RESTORE" or "TESTING"'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Testing mode indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: TestingConfig.isTestingMode 
              ? Colors.orange.withOpacity(0.1)
              : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: TestingConfig.isTestingMode 
                ? Colors.orange
                : Colors.green,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                TestingConfig.isTestingMode 
                  ? Icons.science
                  : Icons.cloud,
                size: 16,
                color: TestingConfig.isTestingMode 
                  ? Colors.orange
                  : Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                TestingConfig.isTestingMode 
                  ? 'Testing Mode'
                  : 'Production Mode',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TestingConfig.isTestingMode 
                    ? Colors.orange
                    : Colors.green,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Command input toggle button
        if (!_showCommandInput)
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _showCommandInput = true;
              });
            },
            icon: const Icon(Icons.keyboard, size: 16),
            label: const Text('Commands'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 32),
            ),
          ),
        
        // Command input field
        if (_showCommandInput) ...[
          Container(
            width: 200,
            child: TextField(
              controller: _commandController,
              decoration: InputDecoration(
                hintText: 'Type "RESTORE" or "TESTING"',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    setState(() {
                      _showCommandInput = false;
                      _commandController.clear();
                    });
                  },
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: _handleCommand,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Commands: "RESTORE" (enable API) or "TESTING" (disable API)',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }
}
