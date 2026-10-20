import 'package:flutter/cupertino.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('About'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'EcoLoop is a student project. Orders are not processed or shipped.',
                style: TextStyle(fontSize: 15, height: 1.45),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Photos from Wikimedia Commons contributors.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF66705F),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
