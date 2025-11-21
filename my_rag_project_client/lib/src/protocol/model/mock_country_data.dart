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

abstract class MockCountryData implements _i1.SerializableModel {
  MockCountryData._({
    this.id,
    required this.countryName,
    required this.isoCode,
    required this.isEuMember,
    required this.isNatoMember,
  });

  factory MockCountryData({
    int? id,
    required String countryName,
    required String isoCode,
    required bool isEuMember,
    required bool isNatoMember,
  }) = _MockCountryDataImpl;

  factory MockCountryData.fromJson(Map<String, dynamic> jsonSerialization) {
    return MockCountryData(
      id: jsonSerialization['id'] as int?,
      countryName: jsonSerialization['countryName'] as String,
      isoCode: jsonSerialization['isoCode'] as String,
      isEuMember: jsonSerialization['isEuMember'] as bool,
      isNatoMember: jsonSerialization['isNatoMember'] as bool,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String countryName;

  String isoCode;

  bool isEuMember;

  bool isNatoMember;

  /// Returns a shallow copy of this [MockCountryData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MockCountryData copyWith({
    int? id,
    String? countryName,
    String? isoCode,
    bool? isEuMember,
    bool? isNatoMember,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'countryName': countryName,
      'isoCode': isoCode,
      'isEuMember': isEuMember,
      'isNatoMember': isNatoMember,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MockCountryDataImpl extends MockCountryData {
  _MockCountryDataImpl({
    int? id,
    required String countryName,
    required String isoCode,
    required bool isEuMember,
    required bool isNatoMember,
  }) : super._(
          id: id,
          countryName: countryName,
          isoCode: isoCode,
          isEuMember: isEuMember,
          isNatoMember: isNatoMember,
        );

  /// Returns a shallow copy of this [MockCountryData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MockCountryData copyWith({
    Object? id = _Undefined,
    String? countryName,
    String? isoCode,
    bool? isEuMember,
    bool? isNatoMember,
  }) {
    return MockCountryData(
      id: id is int? ? id : this.id,
      countryName: countryName ?? this.countryName,
      isoCode: isoCode ?? this.isoCode,
      isEuMember: isEuMember ?? this.isEuMember,
      isNatoMember: isNatoMember ?? this.isNatoMember,
    );
  }
}
