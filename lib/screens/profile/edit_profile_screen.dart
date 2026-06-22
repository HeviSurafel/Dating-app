// lib/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/models/profile_model.dart';
import 'package:dating_app/themes/app_theme.dart';
import 'package:dating_app/widgets/custom_button.dart';
import 'package:dating_app/widgets/custom_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _occupationController = TextEditingController();
  final _educationController = TextEditingController();
  final _religionController = TextEditingController();
  final _heightController = TextEditingController();
  final _aboutMeController = TextEditingController();

  // Dropdown values
  String? _selectedGender;
  String? _selectedLookingFor;
  String? _selectedGenderPreference;
  String? _selectedSmoking;
  String? _selectedDrinking;
  String? _selectedFitnessLevel;

  // Boolean values
  bool _hasKids = false;
  bool _wantsKids = false;

  // Range values
  int _minAge = 18;
  int _maxAge = 99;
  int _maxDistance = 50;

  bool _isLoading = false;
  bool _isSaving = false;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    _religionController.dispose();
    _heightController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final userService = UserService();
      final result = await userService.getProfile();

      if (result['success'] == true) {
        final profile = result['data'] as Profile?;
        setState(() {
          _profile = profile;
          _populateFields(profile);
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateFields(Profile? profile) {
    if (profile == null) return;

    final user = profile.user;
    _nameController.text = user?.name ?? '';
    _bioController.text = profile.bio ?? '';
    _occupationController.text = profile.occupation ?? '';
    _educationController.text = profile.education ?? '';
    _religionController.text = profile.religion ?? '';
    _heightController.text = profile.heightCm?.toString() ?? '';
    _aboutMeController.text = profile.bio ?? '';

    _selectedGender = user?.gender;
    _selectedLookingFor = profile.lookingFor;
    _selectedGenderPreference = profile.genderPreference;
    _selectedSmoking = profile.smoking;
    _selectedDrinking = profile.drinking;
    _selectedFitnessLevel = profile.fitnessLevel;
    _hasKids = profile.hasKids;
    _wantsKids = profile.wantsKids;
    _minAge = profile.minAgePreference ?? 18;
    _maxAge = profile.maxAgePreference ?? 99;
    _maxDistance = profile.maxDistanceKm ?? 50;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userService = UserService();

      // Update user
      await userService.updateUser({
        'name': _nameController.text,
        'gender': _selectedGender,
      });

      // Update profile
      final profileData = {
        'bio': _bioController.text,
        'lookingFor': _selectedLookingFor,
        'genderPreference': _selectedGenderPreference,
        'minAgePreference': _minAge,
        'maxAgePreference': _maxAge,
        'maxDistanceKm': _maxDistance,
        'occupation': _occupationController.text,
        'education': _educationController.text,
        'religion': _religionController.text,
        'smoking': _selectedSmoking,
        'drinking': _selectedDrinking,
        'hasKids': _hasKids,
        'wantsKids': _wantsKids,
        'heightCm': int.tryParse(_heightController.text),
        'fitnessLevel': _selectedFitnessLevel,
        'aboutMe': _aboutMeController.text,
      };

      final result = await userService.updateProfile(profileData);

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully! ✅'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
              SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _isSaving
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            )
                : TextButton(
              onPressed: _saveProfile,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfo(),
              const SizedBox(height: 16),
              _buildBioSection(),
              const SizedBox(height: 16),
              _buildPreferencesSection(),
              const SizedBox(height: 16),
              _buildLifestyleSection(),
              const SizedBox(height: 16),
              _buildFamilySection(),
              const SizedBox(height: 16),
              _buildActionButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.people_outline),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'non-binary', child: Text('Non-Binary')),
                DropdownMenuItem(
                  value: 'prefer-not-to-say',
                  child: Text('Prefer not to say'),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedGender = value);
              },
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _heightController,
              label: 'Height (cm)',
              hint: 'Enter your height in cm',
              prefixIcon: Icons.straighten,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'About You',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _bioController,
              label: 'Bio',
              hint: 'Write a short bio (max 150 characters)',
              prefixIcon: Icons.text_fields,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _aboutMeController,
              label: 'About Me',
              hint: 'Tell people more about yourself',
              prefixIcon: Icons.article_outlined,
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Preferences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLookingFor,
              decoration: const InputDecoration(
                labelText: 'Looking for',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: 'friendship', child: Text('Friendship')),
                DropdownMenuItem(value: 'casual', child: Text('Casual Dating')),
                DropdownMenuItem(value: 'relationship', child: Text('Relationship')),
                DropdownMenuItem(value: 'marriage', child: Text('Marriage')),
                DropdownMenuItem(value: 'not-sure', child: Text('Not Sure')),
              ],
              onChanged: (value) {
                setState(() => _selectedLookingFor = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedGenderPreference,
              decoration: const InputDecoration(
                labelText: 'Interested in',
                prefixIcon: Icon(Icons.people),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Men')),
                DropdownMenuItem(value: 'female', child: Text('Women')),
                DropdownMenuItem(value: 'both', child: Text('Both')),
                DropdownMenuItem(value: 'non-binary', child: Text('Non-Binary')),
                DropdownMenuItem(value: 'any', child: Text('Everyone')),
              ],
              onChanged: (value) {
                setState(() => _selectedGenderPreference = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Min Age',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        value: _minAge,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                        ),
                        items: List.generate(40, (index) => index + 18)
                            .map((age) => DropdownMenuItem(
                          value: age,
                          child: Text(age.toString()),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _minAge = value ?? 18);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Max Age',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        value: _maxAge,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                        ),
                        items: List.generate(40, (index) => index + 18)
                            .map((age) => DropdownMenuItem(
                          value: age,
                          child: Text(age.toString()),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _maxAge = value ?? 99);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Max Distance',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      '$_maxDistance km',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _maxDistance.toDouble(),
                  min: 5,
                  max: 200,
                  divisions: 39,
                  activeColor: AppTheme.primaryColor,
                  label: '$_maxDistance km',
                  onChanged: (value) {
                    setState(() => _maxDistance = value.toInt());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.self_improvement_outlined,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Lifestyle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSmoking,
              decoration: const InputDecoration(
                labelText: 'Smoking',
                prefixIcon: Icon(Icons.smoke_free),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: 'never', child: Text('Never')),
                DropdownMenuItem(value: 'occasionally', child: Text('Occasionally')),
                DropdownMenuItem(value: 'regularly', child: Text('Regularly')),
                DropdownMenuItem(value: 'prefer-not-to-say', child: Text('Prefer not to say')),
              ],
              onChanged: (value) {
                setState(() => _selectedSmoking = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedDrinking,
              decoration: const InputDecoration(
                labelText: 'Drinking',
                prefixIcon: Icon(Icons.local_drink),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: 'never', child: Text('Never')),
                DropdownMenuItem(value: 'occasionally', child: Text('Occasionally')),
                DropdownMenuItem(value: 'regularly', child: Text('Regularly')),
                DropdownMenuItem(value: 'prefer-not-to-say', child: Text('Prefer not to say')),
              ],
              onChanged: (value) {
                setState(() => _selectedDrinking = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedFitnessLevel,
              decoration: const InputDecoration(
                labelText: 'Fitness Level',
                prefixIcon: Icon(Icons.fitness_center),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: 'sedentary', child: Text('Sedentary')),
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'very-active', child: Text('Very Active')),
                DropdownMenuItem(value: 'prefer-not-to-say', child: Text('Prefer not to say')),
              ],
              onChanged: (value) {
                setState(() => _selectedFitnessLevel = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.family_restroom_outlined,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Family',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSwitchListTile(
              title: 'Have Kids',
              subtitle: 'Do you have children?',
              value: _hasKids,
              onChanged: (value) {
                setState(() => _hasKids = value);
              },
            ),
            _buildSwitchListTile(
              title: 'Want Kids',
              subtitle: 'Do you want children in the future?',
              value: _wantsKids,
              onChanged: (value) {
                setState(() => _wantsKids = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchListTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
            ),
            child: _isSaving
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              'Save Changes',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}