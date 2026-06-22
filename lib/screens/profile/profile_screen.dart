// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dating_app/providers/user_provider.dart';
import 'package:dating_app/models/profile_model.dart';
import 'package:dating_app/themes/app_theme.dart';

import '../../models/user_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final notifier = ref.read(userProvider.notifier);
    await notifier.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProvider);

    return Scaffold(
      body: _buildBody(state),
    );
  }

  Widget _buildBody(UserState state) {
    if (state.isLoading) {
      return const Center(
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
      );
    }

    if (state.error != null) {
      return _buildErrorWidget(state.error!);
    }

    if (state.profile == null) {
      return _buildEmptyState();
    }

    return _buildProfileContent(state.profile!);
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No profile data',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/home/profile/edit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(Profile profile) {
    final user = profile.user;

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () => context.go('/home/settings'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.black),
              onPressed: () => context.go('/home/profile/edit'),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeader(user),
          ),
        ),

        // Profile Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bio
                if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      user.bio!,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Stats Row
                Row(
                  children: [
                    _buildStatCard(
                      Icons.photo_library,
                      'Photos',
                      profile.photos?.length.toString() ?? '0',
                    ),
                    _buildStatCard(
                      Icons.favorite,
                      'Interests',
                      profile.interests?.length.toString() ?? '0',
                    ),
                    _buildStatCard(
                      Icons.verified,
                      'Verified',
                      user?.isVerified == true ? '✓' : '✗',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // About Section
                _buildDetailSection(
                  title: 'About Me',
                  icon: Icons.person_outline,
                  children: [
                    _buildDetailItem('Looking for', profile.lookingFor ?? 'Not specified'),
                    _buildDetailItem('Gender', user?.gender ?? 'Not specified'),
                    _buildDetailItem('Age', user?.age != null ? '${user!.age} years' : 'Not specified'),
                  ],
                ),
                const SizedBox(height: 16),

                // Lifestyle Section
                _buildDetailSection(
                  title: 'Lifestyle',
                  icon: Icons.self_improvement_outlined,
                  children: [
                    _buildDetailItem('Occupation', profile.occupation ?? 'Not specified'),
                    _buildDetailItem('Education', profile.education ?? 'Not specified'),
                    _buildDetailItem('Religion', profile.religion ?? 'Not specified'),
                    _buildDetailItem('Smoking', profile.smoking ?? 'Not specified'),
                    _buildDetailItem('Drinking', profile.drinking ?? 'Not specified'),
                    _buildDetailItem('Fitness Level', profile.fitnessLevel ?? 'Not specified'),
                  ],
                ),
                const SizedBox(height: 16),

                // Family Section
                _buildDetailSection(
                  title: 'Family',
                  icon: Icons.family_restroom_outlined,
                  children: [
                    _buildDetailItem('Has Kids', profile.hasKids ? 'Yes' : 'No'),
                    _buildDetailItem('Wants Kids', profile.wantsKids ? 'Yes' : 'No'),
                  ],
                ),
                const SizedBox(height: 16),

                // Preferences Section
                _buildDetailSection(
                  title: 'Preferences',
                  icon: Icons.settings_outlined,
                  children: [
                    _buildDetailItem('Looking for', profile.lookingFor ?? 'Not specified'),
                    _buildDetailItem('Interested in', profile.genderPreference ?? 'Not specified'),
                    _buildDetailItem('Age Range', '${profile.minAgePreference ?? 18} - ${profile.maxAgePreference ?? 99}'),
                    _buildDetailItem('Max Distance', '${profile.maxDistanceKm ?? 50} km'),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(User? user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Picture
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: user?.profilePicture != null
                        ? NetworkImage(user!.profilePicture!)
                        : null,
                    child: user?.profilePicture == null
                        ? Text(
                      user?.name?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                        : null,
                  ),
                ),
                if (user?.isVerified == true)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Name and Age
            Text(
              '${user?.name ?? 'Unknown'}${user?.age != null ? ', ${user!.age}' : ''}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // Location
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${user?.latitude != null ? '📍 ' : ''}Active now',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}