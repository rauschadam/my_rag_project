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

abstract class ListPanelSupplierData implements _i1.SerializableModel {
  ListPanelSupplierData._({
    this.id,
    required this.vendorName,
    required this.countryCode,
    required this.category,
    required this.amount,
    required this.lastActivity,
  });

  factory ListPanelSupplierData({
    int? id,
    required String vendorName,
    required String countryCode,
    required String category,
    required String amount,
    required DateTime lastActivity,
  }) = _ListPanelSupplierDataImpl;

  factory ListPanelSupplierData.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return ListPanelSupplierData(
      id: jsonSerialization['id'] as int?,
      vendorName: jsonSerialization['vendorName'] as String,
      countryCode: jsonSerialization['countryCode'] as String,
      category: jsonSerialization['category'] as String,
      amount: jsonSerialization['amount'] as String,
      lastActivity:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastActivity']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String vendorName;

  String countryCode;

  String category;

  String amount;

  DateTime lastActivity;

  /// Returns a shallow copy of this [ListPanelSupplierData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ListPanelSupplierData copyWith({
    int? id,
    String? vendorName,
    String? countryCode,
    String? category,
    String? amount,
    DateTime? lastActivity,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vendorName': vendorName,
      'countryCode': countryCode,
      'category': category,
      'amount': amount,
      'lastActivity': lastActivity.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ListPanelSupplierDataImpl extends ListPanelSupplierData {
  _ListPanelSupplierDataImpl({
    int? id,
    required String vendorName,
    required String countryCode,
    required String category,
    required String amount,
    required DateTime lastActivity,
  }) : super._(
          id: id,
          vendorName: vendorName,
          countryCode: countryCode,
          category: category,
          amount: amount,
          lastActivity: lastActivity,
        );

  /// Returns a shallow copy of this [ListPanelSupplierData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ListPanelSupplierData copyWith({
    Object? id = _Undefined,
    String? vendorName,
    String? countryCode,
    String? category,
    String? amount,
    DateTime? lastActivity,
  }) {
    return ListPanelSupplierData(
      id: id is int? ? id : this.id,
      vendorName: vendorName ?? this.vendorName,
      countryCode: countryCode ?? this.countryCode,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}
