import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/core/utils/validators.dart';
import 'package:e_learning/core/widgets/button/custom_button.dart';
import 'package:e_learning/core/widgets/text_filed/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/login_request_model.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const c = MyColors();

    return BlocProvider(
      create: (_) => LoginCubit(getIt()),
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: BlocConsumer<LoginCubit, LoginState>(
                  listener: (context, state) {
                    if (state is LoginSuccess) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                    if (state is LoginError) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                gradient: c.heroGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 34),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Welcome Back',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: c.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to keep exchanging skills',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: c.textSecondary),
                          ),
                          const SizedBox(height: 32),
                          CustomTextField(
                            hintText: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            hintText: 'Password',
                            controller: _passwordController,
                            obscureText: true,
                            validator: Validators.required,
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Login',
                            isLoading: state is LoginLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<LoginCubit>().login(
                                  LoginRequestModel(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                            child: const Text("Don't have an account? Register"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}