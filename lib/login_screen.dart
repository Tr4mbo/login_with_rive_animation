import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Rive Animation variables
  StateMachineController? _controller;
  SMIInput<bool>? _isChecking;
  SMIInput<double>? _numLook;
  SMIInput<bool>? _isHandsUp;
  SMIInput<bool>? _trigSuccess;
  SMIInput<bool>? _trigFail;

  // Form Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Focus Nodes
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_emailFocus);
    _passwordFocusNode.addListener(_passwordFocus);
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_emailFocus);
    _passwordFocusNode.removeListener(_passwordFocus);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _emailFocus() {
    _isChecking?.value = _emailFocusNode.hasFocus;
  }

  void _passwordFocus() {
    _isHandsUp?.value = _passwordFocusNode.hasFocus;
  }

  void _onInit(Artboard artboard) {
    // Look for generic Login Machine, or State Machine 1
    _controller = StateMachineController.fromArtboard(
      artboard,
      'Login Machine',
    );
    
    if (_controller == null) {
      _controller = StateMachineController.fromArtboard(
        artboard,
        'State Machine 1',
      );
    }
    
    if (_controller != null) {
      artboard.addController(_controller!);
      
      // Typical input names for the standard Rive animated bear
      _isChecking = _controller!.findInput('isChecking') ?? _controller!.findInput('Check');
      _numLook = _controller!.findInput('numLook') ?? _controller!.findInput('Look');
      _isHandsUp = _controller!.findInput('isHandsUp') ?? _controller!.findInput('hands_up');
      _trigSuccess = _controller!.findInput('trigSuccess') ?? _controller!.findInput('success');
      _trigFail = _controller!.findInput('trigFail') ?? _controller!.findInput('fail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6E2E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Rive Animation Container
              SizedBox(
                height: 250,
                width: 250,
                child: RiveAnimation.asset(
                  'assets/login_animation.riv',
                  fit: BoxFit.cover,
                  onInit: _onInit,
                ),
              ),
              const SizedBox(height: 10),
              // Login Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Email Field
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor: const Color(0xFFEBE2EC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB17C8A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB17C8A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB17C8A), width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (_emailFocusNode.hasFocus) {
                          _numLook?.value = value.length.toDouble() * 2;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: const Color(0xFFEBE2EC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB17C8A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB17C8A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFB17C8A), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Remember Me & Login Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFFB17C8A),
                            ),
                            const Text('Remember me'),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _emailFocusNode.unfocus();
                            _passwordFocusNode.unfocus();
                            
                            // Simulate login success or fail based on inputs
                            if (_emailController.text == 'amani@gmail.com' &&
                                _passwordController.text.isNotEmpty) {
                              _trigSuccess?.value = true;
                            } else {
                              _trigFail?.value = true;
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB17C8A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}