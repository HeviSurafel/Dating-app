// lib/providers/location_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

class LocationState {
  final Position? position;
  final bool hasPermission;
  final bool serviceEnabled;
  final bool isLoading;

  LocationState({
    this.position,
    this.hasPermission = false,
    this.serviceEnabled = false,
    this.isLoading = false,
  });

  LocationState copyWith({
    Position? position,
    bool? hasPermission,
    bool? serviceEnabled,
    bool? isLoading,
  }) {
    return LocationState(
      position: position ?? this.position,
      hasPermission: hasPermission ?? this.hasPermission,
      serviceEnabled: serviceEnabled ?? this.serviceEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState()) {
    _checkInitialLocation();
  }

  Future<void> _checkInitialLocation() async {
    state = state.copyWith(isLoading: true);

    try {
      final hasPermission = await _checkPermission();
      if (hasPermission) {
        final serviceEnabled = await _checkService();
        if (serviceEnabled) {
          final position = await _getLocation();
          if (position != null) {
            state = state.copyWith(
              position: position,
              hasPermission: true,
              serviceEnabled: true,
              isLoading: false,
            );
            return;
          }
        }
      }
      state = state.copyWith(
        hasPermission: hasPermission,
        serviceEnabled: false,
        isLoading: false,
      );
    } catch (e) {
      print('❌ Initial location check error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> _checkPermission() async {
    final permission = await Permission.location.status;
    return permission == PermissionStatus.granted;
  }

  Future<bool> _checkService() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> _getLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      print('❌ Get location error: $e');
      return null;
    }
  }

  Future<bool> requestPermission() async {
    state = state.copyWith(isLoading: true);

    try {
      final status = await Permission.location.request();
      final hasPermission = status == PermissionStatus.granted;

      if (hasPermission) {
        final serviceEnabled = await _checkService();
        if (serviceEnabled) {
          final position = await _getLocation();
          if (position != null) {
            state = state.copyWith(
              position: position,
              hasPermission: true,
              serviceEnabled: true,
              isLoading: false,
            );
            return true;
          }
        }
        state = state.copyWith(
          hasPermission: true,
          serviceEnabled: false,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          hasPermission: false,
          serviceEnabled: false,
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      print('❌ Request permission error: $e');
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<bool> checkService() async {
    state = state.copyWith(isLoading: true);

    try {
      final serviceEnabled = await _checkService();
      if (serviceEnabled) {
        final position = await _getLocation();
        if (position != null) {
          state = state.copyWith(
            position: position,
            serviceEnabled: true,
            isLoading: false,
          );
          return true;
        }
      }
      state = state.copyWith(
        serviceEnabled: false,
        isLoading: false,
      );
      return false;
    } catch (e) {
      print('❌ Check service error: $e');
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<Position?> getCurrentLocation() async {
    state = state.copyWith(isLoading: true);

    try {
      final position = await _getLocation();
      if (position != null) {
        state = state.copyWith(
          position: position,
          hasPermission: true,
          serviceEnabled: true,
          isLoading: false,
        );
        return position;
      }
      state = state.copyWith(isLoading: false);
      return null;
    } catch (e) {
      print('❌ Get current location error: $e');
      state = state.copyWith(isLoading: false);
      return null;
    }
  }

  void resetLocation() {
    state = LocationState();
  }
}