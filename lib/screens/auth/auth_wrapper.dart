import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();
    
    if (!mounted) return;
    
    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF030712),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00C8FF),
        ),
      ),
    );
  }
}
