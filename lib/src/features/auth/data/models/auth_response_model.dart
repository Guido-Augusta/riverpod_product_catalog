import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:product_catalog_app/src/features/auth/data/models/user_model.dart';

part 'auth_response_model.freezed.dart';
part 'auth_response_model.g.dart';

@freezed
abstract class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    required int id,
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String gender,
    required String image,
    required String accessToken,
    required String refreshToken,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}

extension AuthResponseModelX on AuthResponseModel {
  UserModel toUser() => UserModel(
    id: id,
    username: username,
    email: email,
    firstName: firstName,
    lastName: lastName,
    gender: gender,
    image: image,
  );
}
