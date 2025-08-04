import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _majorController = TextEditingController();
  final _classYearController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    'Fill in your details to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                CustomTextField(
                  label: 'Student Number',
                  hint: 'Enter your student number',
                  controller: _studentNumberController,
                  prefixIcon: Icons.badge,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your student number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                CustomTextField(
                  label: 'Major',
                  hint: 'Enter your major',
                  controller: _majorController,
                  prefixIcon: Icons.school,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your major';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                CustomTextField(
                  label: 'Class Year',
                  hint: 'Enter your class year (e.g., 2024)',
                  controller: _classYearController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.calendar_today,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your class year';
                    }
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid year';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your password';
                    }
                    if (value!.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: 'Sign Up',
                      isLoading: authProvider.isLoading,
                      onPressed: () => _handleRegister(context, authProvider),
                    );
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister(BuildContext context, AuthProvider authProvider) async {
    if (_formKey.currentState?.validate() ?? false) {
      final error = await authProvider.register(
        name: _nameController.text,
        email: _emailController.text,
        studentNumber: _studentNumberController.text,
        major: _majorController.text,
        classYear: int.parse(_classYearController.text),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }
}
