import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatChatTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return formatTime(date);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (messageDate.year == today.year) {
      return DateFormat('MMM d').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  static String getGenderText(String gender) {
    switch (gender) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'non-binary':
        return 'Non-Binary';
      case 'prefer-not-to-say':
        return 'Prefer not to say';
      default:
        return 'Not specified';
    }
  }

  static String getLookingForText(String? lookingFor) {
    switch (lookingFor) {
      case 'friendship':
        return 'Making Friends';
      case 'casual':
        return 'Casual Dating';
      case 'relationship':
        return 'Serious Relationship';
      case 'marriage':
        return 'Marriage';
      default:
        return 'Not Sure Yet';
    }
  }

  static List<String> getGenderPreferences(String? genderPreference) {
    switch (genderPreference) {
      case 'male':
        return ['Men'];
      case 'female':
        return ['Women'];
      case 'both':
        return ['Men', 'Women'];
      case 'non-binary':
        return ['Non-Binary'];
      default:
        return ['Everyone'];
    }
  }

  static String formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).round()}m';
    }
    return '${distance.toStringAsFixed(1)}km';
  }

  static bool isOnline(DateTime? lastActive) {
    if (lastActive == null) return false;
    final diff = DateTime.now().difference(lastActive);
    return diff.inMinutes < 5;
  }
}