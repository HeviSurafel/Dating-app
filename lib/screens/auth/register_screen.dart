// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dating_app/providers/auth_provider.dart';
import 'package:dating_app/providers/location_provider.dart';
import 'package:dating_app/widgets/custom_button.dart';
import 'package:dating_app/widgets/custom_text_field.dart';
import 'package:dating_app/widgets/location_permission_popup.dart';
import 'package:dating_app/themes/app_theme.dart';
import 'package:dating_app/utils/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();

  String? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasLocation = false;
  bool _locationPopupShown = false;

  @override
  void initState() {
    super.initState();
    // Show location popup after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLocationPopupIfNeeded();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _showLocationPopupIfNeeded() async {
    if (_locationPopupShown) return;

    final locationState = ref.read(locationProvider);

    // Check if location is already enabled
    if (locationState.hasPermission &&
        locationState.serviceEnabled &&
        locationState.position != null) {
      setState(() {
        _hasLocation = true;
      });
      return;
    }

    _locationPopupShown = true;

    // Show the location permission popup
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionPopup(
        onLocationUpdated: () {
          setState(() {
            _hasLocation = true;
          });
        },
      ),
    );

    // Check if location was enabled
    final updatedLocationState = ref.read(locationProvider);
    if (updatedLocationState.hasPermission &&
        updatedLocationState.serviceEnabled &&
        updatedLocationState.position != null) {
      setState(() {
        _hasLocation = true;
      });
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (date != null) {
      _dobController.text =
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate date of birth
    try {
      final dob = DateTime.parse(_dobController.text);
      final age = DateTime.now().difference(dob).inDays ~/ 365;
      if (age < 18) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be at least 18 years old')),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid date of birth')),
      );
      return;
    }

    // Check if location is available
    final locationState = ref.read(locationProvider);
    if (!locationState.hasPermission || !locationState.serviceEnabled) {
      // Show location popup again
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LocationPermissionPopup(
          onLocationUpdated: () {
            setState(() {
              _hasLocation = true;
            });
          },
        ),
      );

      // Check again after popup
      final updatedLocationState = ref.read(locationProvider);
      if (!updatedLocationState.hasPermission || !updatedLocationState.serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable location to continue'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    final authNotifier = ref.read(authProvider.notifier);

    await authNotifier.register(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
      gender: _selectedGender ?? 'prefer-not-to-say',
      dateOfBirth: DateTime.parse(_dobController.text),
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      latitude: locationState.position?.latitude,
      longitude: locationState.position?.longitude,
    );

    final state = ref.read(authProvider);
    if (state.isAuthenticated && mounted) {
      context.go(
        '/verify-otp',
        extra: {
          'email': _emailController.text,
          'phone': _phoneController.text.isNotEmpty ? _phoneController.text : null,
          'purpose': 'registration',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final locationState = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Create Account 🎉',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your journey to find love',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Location Status Indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _hasLocation
                          ? Colors.green.withOpacity(0.05)
                          : Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasLocation
                            ? Colors.green.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _hasLocation
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _hasLocation
                                ? Icons.location_on
                                : Icons.location_off,
                            color: _hasLocation
                                ? Colors.green
                                : Colors.orange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _hasLocation
                                    ? '📍 Location Enabled'
                                    : '📍 Location Required',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _hasLocation
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              Text(
                                _hasLocation
                                    ? 'Finding matches near your area'
                                    : 'Enable location to find matches near you',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!_hasLocation)
                          TextButton(
                            onPressed: () {
                              _showLocationPopupIfNeeded();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                            ),
                            child: const Text('Enable'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (authState.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authState.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ref.read(authProvider.notifier).clearError(),
                            child: Icon(
                              Icons.close,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    validator: Validators.required('Full name'),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number (Optional)',
                    hint: 'Enter your phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.people_outline),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(
                        value: 'non-binary',
                        child: Text('Non-Binary'),
                      ),
                      DropdownMenuItem(
                        value: 'prefer-not-to-say',
                        child: Text('Prefer not to say'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your gender';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _dobController,
                    label: 'Date of Birth',
                    hint: 'YYYY-MM-DD',
                    prefixIcon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: _selectDate,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Date of birth is required';
                      }
                      try {
                        final dob = DateTime.parse(value);
                        final age = DateTime.now().difference(dob).inDays ~/ 365;
                        if (age < 18) {
                          return 'You must be at least 18 years old';
                        }
                      } catch (e) {
                        return 'Please enter a valid date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password (min 6 characters)',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  CustomButton(
                    text: 'Create Account',
                    isLoading: authState.isLoading,
                    onPressed: _register,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}