// lib/screens/swipe/swipe_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dating_app/providers/swipe_provider.dart';
import 'package:dating_app/screens/swipe/swipe_card.dart';
import 'package:dating_app/services/match_service.dart';
import 'package:dating_app/models/profile_model.dart';
import 'package:dating_app/themes/app_theme.dart';

class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key});

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final MatchService _matchService = MatchService();
  bool _isProcessing = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfiles();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    final notifier = ref.read(swipeProvider.notifier);
    await notifier.loadProfiles(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(swipeProvider);

    return Scaffold(
      body: _buildBody(state),
      bottomNavigationBar: _isProcessing
          ? const SizedBox.shrink()
          : _buildBottomBar(state),
    );
  }

  Widget _buildBody(SwipeState state) {
    if (state.isLoading && state.profiles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Finding people near you...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (state.error != null && state.profiles.isEmpty) {
      return _buildErrorWidget(state.error!);
    }

    if (state.profiles.isEmpty) {
      return _buildEmptyState();
    }

    // Load more when approaching the end
    if (state.profiles.length < 5 && state.hasMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(swipeProvider.notifier).loadMoreProfiles();
      });
    }

    return Column(
      children: [
        // Header
        _buildHeader(state),

        // Cards
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                // Load more when reaching the end
                if (index >= state.profiles.length - 2 && state.hasMore) {
                  ref.read(swipeProvider.notifier).loadMoreProfiles();
                }
              },
              itemCount: state.profiles.length,
              itemBuilder: (context, index) {
                final profile = state.profiles[index];
                final isTopCard = index == _currentPage;
                final isNextCard = index == _currentPage + 1;

                return SwipeCard(
                  key: ValueKey(profile.userId),
                  profile: profile,
                  isTopCard: isTopCard,
                  isNextCard: isNextCard,
                  onSwipeLeft: () => _handleSwipe(profile, 'pass'),
                  onSwipeRight: () => _handleSwipe(profile, 'like'),
                  onSuperLike: () => _handleSwipe(profile, 'super-like'),
                );
              },
            ),
          ),
        ),

        // Loading indicator
        if (state.isLoading && state.profiles.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(SwipeState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Discover',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          Row(
            children: [
              if (state.totalCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${state.profiles.length} remaining',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _loadProfiles,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ],
      ),
    );
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
              onPressed: () {
                ref.read(swipeProvider.notifier).clearError();
                _loadProfiles();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
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
              Icons.people_outline,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No more profiles',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new people nearby',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _loadProfiles,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  context.go('/home/matches');
                },
                icon: const Icon(Icons.chat),
                label: const Text('Your Matches'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(SwipeState state) {
    final hasProfiles = state.profiles.isNotEmpty && _currentPage < state.profiles.length;
    final currentProfile = hasProfiles ? state.profiles[_currentPage] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass button
          _buildActionButton(
            icon: Icons.close,
            color: Colors.red,
            onPressed: hasProfiles && !_isProcessing && currentProfile != null
                ? () => _handleSwipe(currentProfile, 'pass')
                : null,
          ),

          // Super Like button
          _buildActionButton(
            icon: Icons.star,
            color: Colors.blue,
            onPressed: hasProfiles && !_isProcessing && currentProfile != null
                ? () => _handleSwipe(currentProfile, 'super-like')
                : null,
          ),

          // Like button
          _buildActionButton(
            icon: Icons.favorite,
            color: Colors.green,
            onPressed: hasProfiles && !_isProcessing && currentProfile != null
                ? () => _handleSwipe(currentProfile, 'like')
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 30, color: color),
        onPressed: onPressed,
        iconSize: 30,
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _handleSwipe(Profile profile, String action) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final notifier = ref.read(swipeProvider.notifier);

    try {
      bool success = false;

      switch (action) {
        case 'like':
          success = await notifier.like(profile.userId);
          break;
        case 'pass':
          success = await notifier.pass(profile.userId);
          break;
        case 'super-like':
          success = await notifier.superLike(profile.userId);
          break;
        default:
          return;
      }

      if (success) {
        final state = ref.read(swipeProvider);
        if (state.isMatch) {
          _showMatchDialog(profile);
        }
        _showSwipeFeedback(profile, action);

        // Animate to next card
        if (_currentPage < state.profiles.length) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to swipe. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Swipe error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while swiping'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isProcessing = false;
    }
  }

  void _showSwipeFeedback(Profile profile, String action) {
    String message;
    Color color;

    switch (action) {
      case 'like':
        message = 'You liked ${profile.displayName}! ❤️';
        color = Colors.green;
        break;
      case 'super-like':
        message = '🌟 Super Like sent to ${profile.displayName}!';
        color = Colors.blue;
        break;
      case 'pass':
        message = 'Passed on ${profile.displayName} 👋';
        color = Colors.grey;
        break;
      default:
        return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showMatchDialog(Profile profile) {
    final name = profile.displayName;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated hearts
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.pink,
                        size: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.pink,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'It\'s a Match! 🎉',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You and $name liked each other!',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(swipeProvider.notifier).resetMatch();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Keep Swiping'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(swipeProvider.notifier).resetMatch();
                        Navigator.pop(context);
                        context.go('/home/matches');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Say Hi!'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}