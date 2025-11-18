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

abstract class ListPanelTableDescription implements _i1.SerializableModel {
  ListPanelTableDescription._({
    this.id,
    required this.distributionId,
    required this.nameHun,
    required this.descriptionHun,
    required this.businessDescriptionHun,
    required this.embedding,
  });

  factory ListPanelTableDescription({
    int? id,
    required int distributionId,
    required String nameHun,
    required String descriptionHun,
    required String businessDescriptionHun,
    required _i1.Vector embedding,
  }) = _ListPanelTableDescriptionImpl;

  factory ListPanelTableDescription.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return ListPanelTableDescription(
      id: jsonSerialization['id'] as int?,
      distributionId: jsonSerialization['distributionId'] as int,
      nameHun: jsonSerialization['nameHun'] as String,
      descriptionHun: jsonSerialization['descriptionHun'] as String,
      businessDescriptionHun:
          jsonSerialization['businessDescriptionHun'] as String,
      embedding:
          _i1.VectorJsonExtension.fromJson(jsonSerialization['embedding']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int distributionId;

  String nameHun;

  String descriptionHun;

  String businessDescriptionHun;

  _i1.Vector embedding;

  /// Returns a shallow copy of this [ListPanelTableDescription]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ListPanelTableDescription copyWith({
    int? id,
    int? distributionId,
    String? nameHun,
    String? descriptionHun,
    String? businessDescriptionHun,
    _i1.Vector? embedding,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'distributionId': distributionId,
      'nameHun': nameHun,
      'descriptionHun': descriptionHun,
      'businessDescriptionHun': businessDescriptionHun,
      'embedding': embedding.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ListPanelTableDescriptionImpl extends ListPanelTableDescription {
  _ListPanelTableDescriptionImpl({
    int? id,
    required int distributionId,
    required String nameHun,
    required String descriptionHun,
    required String businessDescriptionHun,
    required _i1.Vector embedding,
  }) : super._(
          id: id,
          distributionId: distributionId,
          nameHun: nameHun,
          descriptionHun: descriptionHun,
          businessDescriptionHun: businessDescriptionHun,
          embedding: embedding,
        );

  /// Returns a shallow copy of this [ListPanelTableDescription]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ListPanelTableDescription copyWith({
    Object? id = _Undefined,
    int? distributionId,
    String? nameHun,
    String? descriptionHun,
    String? businessDescriptionHun,
    _i1.Vector? embedding,
  }) {
    return ListPanelTableDescription(
      id: id is int? ? id : this.id,
      distributionId: distributionId ?? this.distributionId,
      nameHun: nameHun ?? this.nameHun,
      descriptionHun: descriptionHun ?? this.descriptionHun,
      businessDescriptionHun:
          businessDescriptionHun ?? this.businessDescriptionHun,
      embedding: embedding ?? this.embedding.clone(),
    );
  }
}
