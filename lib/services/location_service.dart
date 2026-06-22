// lib/services/location_service.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as location_package;

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final location_package.Location _location = location_package.Location();

  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<PermissionStatus> getPermissionStatus() async {
    return await Permission.location.status;
  }

  /// Request location permission
  Future<PermissionStatus> requestPermission() async {
    final status = await Permission.location.request();
    _permissionGranted = status;
    return status;
  }

  /// Open device location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Get current location with full checks
  Future<Position?> getCurrentLocation({
    bool requirePermission = true,
    bool requireService = true,
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled');
        return null;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permissions are permanently denied');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      print('📍 Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

  /// Check all location requirements and handle accordingly
  Future<LocationStatus> checkLocationRequirements() async {
    // Check if service is enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationStatus.serviceDisabled;
    }

    // Check permission
    PermissionStatus permissionStatus = await getPermissionStatus();
    if (permissionStatus == PermissionStatus.denied) {
      return LocationStatus.permissionDenied;
    } else if (permissionStatus == PermissionStatus.granted) {
      return LocationStatus.ready;
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      return LocationStatus.permissionPermanentlyDenied;
    }

    return LocationStatus.unknown;
  }

  /// Request location with user-friendly dialogs - FIXED VERSION
  Future<LocationRequestResult> requestLocationWithDialog(
      BuildContext context, {
        bool showServiceDialog = true,
        bool showPermissionDialog = true,
      }) async {
    // Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled && showServiceDialog) {
      bool result = await _showLocationServiceDialog(context);
      if (result) {
        // Wait for user to enable location
        bool enabled = await _waitForLocationService();
        if (!enabled) {
          return LocationRequestResult(
            success: false,
            message: 'Location services not enabled',
          );
        }
      } else {
        return LocationRequestResult(
          success: false,
          message: 'Location services required',
        );
      }
    }

    // Check permission
    PermissionStatus permissionStatus = await getPermissionStatus();

    if (permissionStatus == PermissionStatus.denied) {
      // Request permission
      PermissionStatus requested = await requestPermission();

      if (requested == PermissionStatus.granted) {
        // Permission granted, get location
        Position? position = await getCurrentLocation();
        if (position != null) {
          return LocationRequestResult(
            success: true,
            message: 'Location obtained successfully',
            position: position,
          );
        } else {
          return LocationRequestResult(
            success: false,
            message: 'Failed to get location',
          );
        }
      } else if (requested == PermissionStatus.permanentlyDenied) {
        bool result = await _showPermanentlyDeniedDialog(context);
        if (result) {
          await openAppSettings();
        }
        return LocationRequestResult(
          success: false,
          message: 'Location permission permanently denied',
        );
      } else {
        return LocationRequestResult(
          success: false,
          message: 'Location permission denied',
        );
      }
    } else if (permissionStatus == PermissionStatus.granted) {
      // Permission already granted, get location
      Position? position = await getCurrentLocation();
      if (position != null) {
        return LocationRequestResult(
          success: true,
          message: 'Location obtained successfully',
          position: position,
        );
      } else {
        return LocationRequestResult(
          success: false,
          message: 'Failed to get location',
        );
      }
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      bool result = await _showPermanentlyDeniedDialog(context);
      if (result) {
        await openAppSettings();
      }
      return LocationRequestResult(
        success: false,
        message: 'Location permission permanently denied',
      );
    }

    return LocationRequestResult(
      success: false,
      message: 'Unknown location error',
    );
  }

  Future<bool> _showLocationServiceDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Required'),
        content: const Text(
          'This app needs location services to find people near you. '
              'Please enable location services in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              Geolocator.openLocationSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showPermanentlyDeniedDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission has been permanently denied. '
              'Please enable it in app settings to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _waitForLocationService() async {
    int attempts = 0;
    while (attempts < 30) {
      bool enabled = await isLocationServiceEnabled();
      if (enabled) return true;
      await Future.delayed(const Duration(seconds: 1));
      attempts++;
    }
    return false;
  }
}

enum LocationStatus {
  ready,
  serviceDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  unknown,
}

class LocationRequestResult {
  final bool success;
  final String message;
  final Position? position;

  LocationRequestResult({
    required this.success,
    required this.message,
    this.position,
  });
}