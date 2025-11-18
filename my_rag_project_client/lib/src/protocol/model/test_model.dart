/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class TestModel implements _i1.SerializableModel {
  TestModel._({
    this.id,
    required this.message,
  });

  factory TestModel({
    int? id,
    required String message,
  }) = _TestModelImpl;

  factory TestModel.fromJson(Map<String, dynamic> jsonSerialization) {
    return TestModel(
      id: jsonSerialization['id'] as int?,
      message: jsonSerialization['message'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String message;

  /// Returns a shallow copy of this [TestModel]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TestModel copyWith({
    int? id,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'message': message,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TestModelImpl extends TestModel {
  _TestModelImpl({
    int? id,
    required String message,
  }) : super._(
          id: id,
          message: message,
        );

  /// Returns a shallow copy of this [TestModel]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TestModel copyWith({
    Object? id = _Undefined,
    String? message,
  }) {
    return TestModel(
      id: id is int? ? id : this.id,
      message: message ?? this.message,
    );
  }
}
