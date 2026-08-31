import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:product_catalog_app/src/features/auth/data/models/user_model.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(UserModel user) = Authenticated;
  const factory AuthState.unauthenticated([String? message]) = Unauthenticated;
}
