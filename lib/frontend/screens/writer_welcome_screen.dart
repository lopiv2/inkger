import 'package:flutter/material.dart';

class WriterWelcomeScreen extends StatelessWidget {
  const WriterWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[850], // Matching the sidebar background
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Inkger Writer Mode',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start writing your masterpiece',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.edit_document,
              color: Colors.grey[600],
              size: 48,
            ),
          ],
        ),
      ),
    );
  }
}