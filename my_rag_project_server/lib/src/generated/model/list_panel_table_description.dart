/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class ListPanelTableDescription
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = ListPanelTableDescriptionTable();

  static const db = ListPanelTableDescriptionRepository._();

  @override
  int? id;

  int distributionId;

  String nameHun;

  String descriptionHun;

  String businessDescriptionHun;

  _i1.Vector embedding;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'distributionId': distributionId,
      'nameHun': nameHun,
      'descriptionHun': descriptionHun,
      'businessDescriptionHun': businessDescriptionHun,
      'embedding': embedding.toJson(),
    };
  }

  static ListPanelTableDescriptionInclude include() {
    return ListPanelTableDescriptionInclude._();
  }

  static ListPanelTableDescriptionIncludeList includeList({
    _i1.WhereExpressionBuilder<ListPanelTableDescriptionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ListPanelTableDescriptionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ListPanelTableDescriptionTable>? orderByList,
    ListPanelTableDescriptionInclude? include,
  }) {
    return ListPanelTableDescriptionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ListPanelTableDescription.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ListPanelTableDescription.t),
      include: include,
    );
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

class ListPanelTableDescriptionTable extends _i1.Table<int?> {
  ListPanelTableDescriptionTable({super.tableRelation})
      : super(tableName: 'list_panel_table_description') {
    distributionId = _i1.ColumnInt(
      'distributionId',
      this,
    );
    nameHun = _i1.ColumnString(
      'nameHun',
      this,
    );
    descriptionHun = _i1.ColumnString(
      'descriptionHun',
      this,
    );
    businessDescriptionHun = _i1.ColumnString(
      'businessDescriptionHun',
      this,
    );
    embedding = _i1.ColumnVector(
      'embedding',
      this,
      dimension: 768,
    );
  }

  late final _i1.ColumnInt distributionId;

  late final _i1.ColumnString nameHun;

  late final _i1.ColumnString descriptionHun;

  late final _i1.ColumnString businessDescriptionHun;

  late final _i1.ColumnVector embedding;

  @override
  List<_i1.Column> get columns => [
        id,
        distributionId,
        nameHun,
        descriptionHun,
        businessDescriptionHun,
        embedding,
      ];
}

class ListPanelTableDescriptionInclude extends _i1.IncludeObject {
  ListPanelTableDescriptionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ListPanelTableDescription.t;
}

class ListPanelTableDescriptionIncludeList extends _i1.IncludeList {
  ListPanelTableDescriptionIncludeList._({
    _i1.WhereExpressionBuilder<ListPanelTableDescriptionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ListPanelTableDescription.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ListPanelTableDescription.t;
}

class ListPanelTableDescriptionRepository {
  const ListPanelTableDescriptionRepository._();

  /// Returns a list of [ListPanelTableDescription]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<ListPanelTableDescription>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ListPanelTableDescriptionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ListPanelTableDescriptionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ListPanelTableDescriptionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ListPanelTableDescription>(
      where: where?.call(ListPanelTableDescription.t),
      orderBy: orderBy?.call(ListPanelTableDescription.t),
      orderByList: orderByList?.call(ListPanelTableDescription.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ListPanelTableDescription] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<ListPanelTableDescription?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ListPanelTableDescriptionTable>? where,
    int? offset,
    _i1.OrderByBuilder<ListPanelTableDescriptionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ListPanelTableDescriptionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ListPanelTableDescription>(
      where: where?.call(ListPanelTableDescription.t),
      orderBy: orderBy?.call(ListPanelTableDescription.t),
      orderByList: orderByList?.call(ListPanelTableDescription.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ListPanelTableDescription] by its [id] or null if no such row exists.
  Future<ListPanelTableDescription?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ListPanelTableDescription>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ListPanelTableDescription]s in the list and returns the inserted rows.
  ///
  /// The returned [ListPanelTableDescription]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ListPanelTableDescription>> insert(
    _i1.Session session,
    List<ListPanelTableDescription> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ListPanelTableDescription>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ListPanelTableDescription] and returns the inserted row.
  ///
  /// The returned [ListPanelTableDescription] will have its `id` field set.
  Future<ListPanelTableDescription> insertRow(
    _i1.Session session,
    ListPanelTableDescription row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ListPanelTableDescription>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ListPanelTableDescription]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ListPanelTableDescription>> update(
    _i1.Session session,
    List<ListPanelTableDescription> rows, {
    _i1.ColumnSelections<ListPanelTableDescriptionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ListPanelTableDescription>(
      rows,
      columns: columns?.call(ListPanelTableDescription.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ListPanelTableDescription]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ListPanelTableDescription> updateRow(
    _i1.Session session,
    ListPanelTableDescription row, {
    _i1.ColumnSelections<ListPanelTableDescriptionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ListPanelTableDescription>(
      row,
      columns: columns?.call(ListPanelTableDescription.t),
      transaction: transaction,
    );
  }

  /// Deletes all [ListPanelTableDescription]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ListPanelTableDescription>> delete(
    _i1.Session session,
    List<ListPanelTableDescription> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ListPanelTableDescription>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ListPanelTableDescription].
  Future<ListPanelTableDescription> deleteRow(
    _i1.Session session,
    ListPanelTableDescription row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ListPanelTableDescription>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ListPanelTableDescription>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ListPanelTableDescriptionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ListPanelTableDescription>(
      where: where(ListPanelTableDescription.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ListPanelTableDescriptionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ListPanelTableDescription>(
      where: where?.call(ListPanelTableDescription.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
