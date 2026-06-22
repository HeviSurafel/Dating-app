import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dating_app/services/match_service.dart';
import 'package:dating_app/services/auth_service.dart';
import 'package:dating_app/models/message_model.dart';
import 'package:dating_app/themes/app_theme.dart';
import 'package:dating_app/screens/chat/chat_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String matchId;

  const ChatScreen({
    super.key,
    required this.matchId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  int _currentUserId = 0;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    try {
      final authService = AuthService();
      final token = await authService.getAccessToken();
      // Decode token to get user ID or fetch from API
      // For now, we'll use a placeholder
      _currentUserId = 1; // Replace with actual user ID from token
    } catch (e) {
      print('Error getting current user: $e');
    }
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final matchService = MatchService();
      final result = await matchService.getMessages(
        int.parse(widget.matchId),
      );

      if (result['success'] == true) {
        setState(() {
          _messages = (result['data'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
              [];
        });
        _scrollToBottom();
      } else {
        _showSnackBar(result['message'] ?? 'Failed to load messages');
      }
    } catch (e) {
      print('Error loading messages: $e');
      _showSnackBar('Failed to load messages');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final matchService = MatchService();
      final result = await matchService.sendMessage(
        int.parse(widget.matchId),
        content,
      );

      if (result['success'] == true) {
        final messageData = result['data'] as Map<String, dynamic>;
        final message = Message.fromJson(messageData);
        if (mounted) {
          setState(() {
            _messages.add(message);
          });
          _messageController.clear();
          _scrollToBottom();
        }
      } else {
        _showSnackBar(result['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      _showSnackBar('Failed to send message');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showChatOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == _currentUserId;
                return ChatBubble(
                  message: message,
                  isMe: isMe,
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 4),
          CircleAvatar(
            backgroundColor: _isSending ? Colors.grey : AppTheme.primaryColor,
            radius: 24,
            child: IconButton(
              icon: _isSending
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.send, color: Colors.white),
              // FIXED: Use null when sending instead of disabling
              onPressed: _isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Block User'),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Chat'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteChat();
                },
              ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.orange),
                title: const Text('Report User'),
                onTap: () {
                  Navigator.pop(context);
                  _reportUser();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Photo'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement photo attachment
                },
              ),
              ListTile(
                leading: const Icon(Icons.gif, color: Colors.purple),
                title: const Text('GIF'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement GIF attachment
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.green),
                title: const Text('Location'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement location attachment
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _blockUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Block User'),
          content: const Text('Are you sure you want to block this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Block'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final matchService = MatchService();
        final result = await matchService.blockMatch(int.parse(widget.matchId));

        if (result['success'] == true) {
          if (mounted) {
            Navigator.pop(context);
            _showSnackBar('User blocked successfully');
          }
        } else {
          _showSnackBar(result['message'] ?? 'Failed to block user');
        }
      } catch (e) {
        print('Error blocking user: $e');
        _showSnackBar('Failed to block user');
      }
    }
  }

  Future<void> _deleteChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Chat'),
          content: const Text('Are you sure you want to delete this chat?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final matchService = MatchService();
        final result = await matchService.unmatch(int.parse(widget.matchId));

        if (result['success'] == true) {
          if (mounted) {
            Navigator.pop(context);
            _showSnackBar('Chat deleted successfully');
          }
        } else {
          _showSnackBar(result['message'] ?? 'Failed to delete chat');
        }
      } catch (e) {
        print('Error deleting chat: $e');
        _showSnackBar('Failed to delete chat');
      }
    }
  }

  Future<void> _reportUser() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Why are you reporting this user?'),
              const SizedBox(height: 16),
              ...['Inappropriate', 'Spam', 'Harassment', 'Fake Profile', 'Other']
                  .map((option) => ListTile(
                title: Text(option),
                onTap: () => Navigator.pop(context, option),
              ))
                  .toList(),
            ],
          ),
        );
      },
    );

    if (reason != null) {
      // Implement report logic
      _showSnackBar('User reported for: $reason');
    }
  }
}