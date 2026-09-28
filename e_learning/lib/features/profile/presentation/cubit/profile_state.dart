import 'package:e_learning/features/auth/data/models/app_user_model.dart';

class ProfileState {
  final bool isLoading;
  final AppUserModel? user;
  final String? error;

  const ProfileState({required this.isLoading, this.user, this.error});

  factory ProfileState.initial() => const ProfileState(isLoading: true);

  ProfileState copyWith({bool? isLoading, AppUserModel? user, String? error}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}