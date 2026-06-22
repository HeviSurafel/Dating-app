// lib/screens/matches/matches_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dating_app/services/match_service.dart';
import 'package:dating_app/models/match_model.dart';
import 'package:dating_app/themes/app_theme.dart';
import 'package:dating_app/models/message_model.dart';

// Provider for matches state management
final matchesProvider = StateNotifierProvider<MatchesNotifier, MatchesState>((ref) {
  return MatchesNotifier();
});

class MatchesState {
  final List<Match> matches;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final Map<int, int> unreadCounts;

  MatchesState({
    this.matches = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.unreadCounts = const {},
  });

  MatchesState copyWith({
    List<Match>? matches,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool? hasMore,
    int? currentPage,
    Map<int, int>? unreadCounts,
  }) {
    return MatchesState(
      matches: matches ?? this.matches,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }
}

class MatchesNotifier extends StateNotifier<MatchesState> {
  final MatchService _matchService = MatchService();
  bool _isLoadingMore = false;
  static const int _pageSize = 20;
  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(seconds: 2);

  MatchesNotifier() : super(MatchesState());

  Future<void> loadMatches({bool refresh = false}) async {
    if (!_canMakeRequest()) {
      return;
    }

    if (refresh) {
      state = state.copyWith(isRefreshing: true, error: null);
    } else if (state.matches.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _matchService.getMatches();

      if (result['success'] == true) {
        final newMatches = result['data'] as List<Match>? ?? [];
        final totalCount = result['total'] as int? ?? 0;

        _lastRequestTime = DateTime.now();

        if (refresh) {
          state = state.copyWith(
            matches: newMatches,
            isLoading: false,
            isRefreshing: false,
            error: null,
            currentPage: 1,
            hasMore: newMatches.length < totalCount,
          );
          await _loadUnreadCounts();
        } else {
          final existingIds = state.matches.map((m) => m.id).toSet();
          final uniqueNewMatches = newMatches.where((m) => !existingIds.contains(m.id)).toList();

          state = state.copyWith(
            matches: [...state.matches, ...uniqueNewMatches],
            isLoading: false,
            isRefreshing: false,
            error: null,
            currentPage: state.currentPage + 1,
            hasMore: state.matches.length + uniqueNewMatches.length < totalCount,
          );
        }
      } else {
        final message = result['message'] as String? ?? 'Failed to load matches';
        if (message.toLowerCase().contains('too many requests') ||
            message.toLowerCase().contains('rate limit')) {
          state = state.copyWith(
            isLoading: false,
            isRefreshing: false,
            error: 'Too many requests. Please wait a moment and try again.',
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            isRefreshing: false,
            error: message,
          );
        }
      }
    } catch (e) {
      print('❌ Matches load error: $e');
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: 'Unable to load matches. Please check your connection.',
      );
    }
  }

  Future<void> _loadUnreadCounts() async {
    try {
      final result = await _matchService.getUnreadCounts();
      if (result['success'] == true) {
        final counts = result['data'] as Map<String, dynamic>? ?? {};
        final unreadMap = <int, int>{};
        counts.forEach((key, value) {
          unreadMap[int.parse(key)] = value as int;
        });
        state = state.copyWith(unreadCounts: unreadMap);
      }
    } catch (e) {
      print('❌ Error loading unread counts: $e');
    }
  }

  Future<void> refreshMatches() async {
    await loadMatches(refresh: true);
  }

  Future<void> loadMoreMatches() async {
    if (_isLoadingMore || !state.hasMore || state.isLoading || state.isRefreshing) {
      return;
    }

    if (!_canMakeRequest()) {
      return;
    }

    _isLoadingMore = true;
    await loadMatches(refresh: false);
    _isLoadingMore = false;
  }

  bool _canMakeRequest() {
    if (_lastRequestTime == null) return true;
    final elapsed = DateTime.now().difference(_lastRequestTime!);
    return elapsed >= _minRequestInterval;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void updateUnreadCount(int matchId, int count) {
    final newCounts = Map<int, int>.from(state.unreadCounts);
    if (count == 0) {
      newCounts.remove(matchId);
    } else {
      newCounts[matchId] = count;
    }
    state = state.copyWith(unreadCounts: newCounts);
  }
}

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // ✅ Use WidgetsBinding to delay the provider modification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatches();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    if (_isInitialLoad) {
      final notifier = ref.read(matchesProvider.notifier);
      await notifier.loadMatches(refresh: true);
      _isInitialLoad = false;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMatches();
    }
  }

  Future<void> _loadMoreMatches() async {
    final notifier = ref.read(matchesProvider.notifier);
    await notifier.loadMoreMatches();
  }

  Future<void> _refreshMatches() async {
    final notifier = ref.read(matchesProvider.notifier);
    await notifier.refreshMatches();
  }

  void _retryLoad() {
    final notifier = ref.read(matchesProvider.notifier);
    notifier.clearError();
    _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Matches',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
            tooltip: 'Search matches',
          ),
          IconButton(
            icon: state.isRefreshing
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.refresh),
            onPressed: state.isRefreshing ? null : _refreshMatches,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(MatchesState state) {
    if (state.isLoading && state.matches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading matches...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (state.error != null && state.matches.isEmpty) {
      return _buildErrorWidget(state.error!);
    }

    if (state.matches.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshMatches,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.matches.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.matches.length) {
            return _buildLoadingMore();
          }
          final match = state.matches[index];
          final unreadCount = state.unreadCounts[match.id] ?? 0;
          return _buildMatchCard(match, unreadCount);
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    final isRateLimit = error.toLowerCase().contains('too many requests') ||
        error.toLowerCase().contains('rate limit');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isRateLimit ? Icons.timer : Icons.error_outline,
              size: 80,
              color: isRateLimit ? Colors.orange : Colors.grey[400],
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
            if (isRateLimit) ...[
              const SizedBox(height: 8),
              Text(
                'Please wait a moment before trying again',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _retryLoad,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    context.go('/home/swipe');
                  },
                  icon: const Icon(Icons.favorite),
                  label: const Text('Start Swiping'),
                ),
              ],
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Matches Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start swiping to find your perfect match!',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/home/swipe');
            },
            icon: const Icon(Icons.favorite),
            label: const Text('Start Swiping'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMore() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard(Match match, int unreadCount) {
    final Color avatarColor = _getAvatarColor(match.id);

    final String matchedUserName = match.matchedUser?.name ?? 'Unknown';
    final int? matchedUserAge = match.matchedUser?.age;
    final bool isOnline = match.matchedUser?.isOnline ?? false;
    final String? profilePicture = match.matchedUser?.profilePicture;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.go('/home/chat/${match.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: avatarColor,
                    backgroundImage: profilePicture != null
                        ? NetworkImage(profilePicture)
                        : null,
                    child: profilePicture == null
                        ? Text(
                      _getInitials(matchedUserName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  ),
                  if (isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            matchedUserName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (matchedUserAge != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '• $matchedUserAge',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (match.lastMessage != null) ...[
                          Expanded(
                            child: Text(
                              _getLastMessageText(match.lastMessage!),
                              style: TextStyle(
                                color: unreadCount > 0
                                    ? Colors.black
                                    : Colors.grey[600],
                                fontSize: 14,
                                fontWeight: unreadCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else ...[
                          Text(
                            '💬 No messages yet',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (match.lastMessageAt != null) ...[
                    Text(
                      _formatDate(match.lastMessageAt!),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  if (unreadCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLastMessageText(Message message) {
    final content = message.content.isNotEmpty
        ? message.content
        : '📷 Photo';
    return message.isMine ? 'You: $content' : content;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color _getAvatarColor(int id) {
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
    ];
    return colors[id % colors.length];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7}w';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  void _showSearchDialog() {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Matches'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Filter matches locally
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${ref.read(matchesProvider).matches.length} matches',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final query = searchController.text.trim();
              if (query.isNotEmpty) {
                // Search logic
              }
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}