import 'package:flutter/material.dart';

class EcoMoraApp extends StatelessWidget {
  const EcoMoraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoMora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF7B2869),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B2869),
          secondary: const Color(0xFF2E7D32),
        ),
        useMaterial3: true,
      ),
      home: const TemporalHomePage(),
    );
  }
}

class TemporalHomePage extends StatelessWidget {
  const TemporalHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoMora'),
        backgroundColor: const Color(0xFF7B2869),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.eco,
              size: 100,
              color: Color(0xFF2E7D32),
            ),
            SizedBox(height: 20),
            Text(
              '🌾 EcoMora',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B2869),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'App funcionando',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}