class AppConstants {
  static const String appName = 'Dating App';
  static const String appVersion = '1.0.0';

  // Limits
  static const int maxPhotos = 6;
  static const int maxBioLength = 500;
  static const int maxMessageLength = 1000;
  static const int defaultSwipeLimit = 50;

  // Timeouts
  static const int otpExpirySeconds = 600; // 10 minutes

  // Genders
  static const List<String> genders = [
    'male',
    'female',
    'non-binary',
    'prefer-not-to-say',
  ];

  // Looking for
  static const List<String> lookingFor = [
    'friendship',
    'casual',
    'relationship',
    'marriage',
    'not-sure',
  ];

  // Gender preferences
  static const List<String> genderPreferences = [
    'male',
    'female',
    'both',
    'non-binary',
    'any',
  ];

  // Interest categories
  static const List<String> interestCategories = [
    'Art & Culture',
    'Books & Writing',
    'Cooking & Food',
    'Dancing',
    'Fashion',
    'Fitness & Gym',
    'Gaming',
    'Hiking & Outdoors',
    'Music',
    'Photography',
    'Sports',
    'Travel',
    'Yoga & Meditation',
    'Movies & TV',
    'Pets & Animals',
    'Volunteering',
    'Entrepreneurship',
    'Technology',
    'Science',
    'Politics',
  ];
}