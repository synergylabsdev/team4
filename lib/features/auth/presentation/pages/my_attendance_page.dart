import 'package:flutter/material.dart';

/// My Attendance page showing events the user is attending.
class MyAttendancePage extends StatelessWidget {
  const MyAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available,
                size: 64,
                color: const Color(0xFF667084),
              ),
              const SizedBox(height: 16),
              const Text(
                'My Attendance',
                style: TextStyle(
                  color: Color(0xFF0F1728),
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your attended events will appear here',
                style: TextStyle(
                  color: Color(0xFF667084),
                  fontSize: 16,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w400,
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

