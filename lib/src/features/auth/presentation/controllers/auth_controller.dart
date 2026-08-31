import 'package:product_catalog_app/src/core/exceptions/app_exceptions.dart';
import 'package:product_catalog_app/src/core/storage/token_storage.dart';
import 'package:product_catalog_app/src/features/auth/data/auth_repository.dart';
import 'package:product_catalog_app/src/features/auth/data/models/auth_response_model.dart';
import 'package:product_catalog_app/src/features/auth/presentation/controllers/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    Future.microtask(() => _checkAuthStatus());
    return const AuthState.initial();
  }

  Future<void> _checkAuthStatus() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final accessToken = await tokenStorage.getAccessToken();

    if (accessToken == null) {
      state = const AuthState.unauthenticated();
      return;
    }

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.getCurrentUser(accessToken: accessToken);
      state = AuthState.authenticated(user);
    } on AppException catch (_) {
      await tokenStorage.clearTokens();
      state = const AuthState.unauthenticated();
    } catch (_) {
      await tokenStorage.clearTokens();
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AuthState.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.login(
        username: username,
        password: password,
      );

      final tokenStorage = ref.read(tokenStorageProvider);
      await tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      state = AuthState.authenticated(response.toUser());
    } on AppException catch (e) {
      state = AuthState.unauthenticated(e.message);
    } catch (e) {
      state = AuthState.unauthenticated(e.toString());
    }
  }

  Future<void> logout() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    await tokenStorage.clearTokens();
    state = const AuthState.unauthenticated();
  }
}
