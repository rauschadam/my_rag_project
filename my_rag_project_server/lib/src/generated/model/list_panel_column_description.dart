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

abstract class ListPanelColumnDescription
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ListPanelColumnDescription._({
    this.id,
    required this.distributionId,
    required this.fieldNameEng,
    required this.fieldNameHun,
    required this.descriptionHun,
    required this.businessDescriptionHun,
    required this.embedding,
  });

  factory ListPanelColumnDescription({
    int? id,
    required int distributionId,
    required String fieldNameEng,
    required String fieldNameHun,
    required String descriptionHun,
    required String businessDescriptionHun,
    required _i1.Vector embedding,
  }) = _ListPanelColumnDescriptionImpl;

  factory ListPanelColumnDescription.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return ListPanelColumnDescription(
      id: jsonSerialization['id'] as int?,
      distributionId: jsonSerialization['distributionId'] as int,
      fieldNameEng: jsonSerialization['fieldNameEng'] as String,
      fieldNameHun: jsonSerialization['fieldNameHun'] as String,
      descriptionHun: jsonSerialization['descriptionHun'] as String,
      businessDescriptionHun:
          jsonSerialization['businessDescriptionHun'] as String,
      embedding:
          _i1.VectorJsonExtension.fromJson(jsonSerialization['embedding']),
    );
  }

  static final t = ListPanelColumnDescriptionTable();

  static const db = ListPanelColumnDescriptionRepository._();

  @override
  int? id;

  int distributionId;

  String fieldNameEng;

  String fieldNameHun;

  String descriptionHun;

  String businessDescriptionHun;

  _i1.Vector embedding;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ListPanelColumnDescription]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ListPanelColumnDescription copyWith({
    int? id,
    int? distributionId,
    String? fieldNameEng,
    String? fieldNameHun,
    String? descriptionHun,
    String? businessDescriptionHun,
    _i1.Vector? embedding,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'distributionId': distributionId,
      'fieldNameEng': fieldNameEng,
      'fieldNameHun': fieldNameHun,
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
      'fieldNameEng': fieldNameEng,
      'fieldNameHun': fieldNameHun,
      'descriptionHun': descriptionHun,
      'businessDescriptionHun': businessDescriptionHun,
      'embedding': embedding.toJson(),
    };
  }

  static ListPanelColumnDescriptionInclude include() {
    return ListPanelColumnDescriptionInclude._();
  }

  static ListPanelColumnDescriptionIncludeList includeList({
    _i1.WhereExpressionBuilder<ListPanelColumnDescriptionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ListPanelColumnDescriptionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ListPanelColumnDescriptionTable>? orderByList,
    ListPanelColumnDescriptionInclude? include,
  }) {
    return ListPanelColumnDescriptionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ListPanelColumnDescription.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ListPanelColumnDescription.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ListPanelColumnDescriptionImpl extends ListPanelColumnDescription {
  _ListPanelColumnDescriptionImpl({
    int? id,
    required int distributionId,
    required String fieldNameEng,
    required String fieldNameHun,
    required String descriptionHun,
    required String businessDescriptionHun,
    required _i1.Vector embedding,
  }) : super._(
          id: id,
          distributionId: distributionId,
          fieldNameEng: fieldNameEng,
          fieldNameHun: fieldNameHun,
          descriptionHun: descriptionHun,
          businessDescriptionHun: businessDescriptionHun,
          embedding: embedding,
        );

  /// Returns a shallow copy of this [ListPanelColumnDescription]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ListPanelColumnDescription copyWith({
    Object? id = _Undefined,
    int? distributionId,
    String? fieldNameEng,
    String? fieldNameHun,
    String? descriptionHun,
    String? businessDescriptionHun,
    _i1.Vector? embedding,
  }) {
    return ListPanelColumnDescription(
      id: id is int? ? id : this.id,
      distributionId: distributionId ?? this.distributionId,
      fieldNameEng: fieldNameEng ?? this.fieldNameEng,
      fieldNameHun: fieldNameHun ?? this.fieldNameHun,
      descriptionHun: descriptionHun ?? this.descriptionHun,
      businessDescriptionHun:
          businessDescriptionHun ?? this.businessDescriptionHun,
      embedding: embedding ?? this.embedding.clone(),
    );
  }
}

class ListPanelColumnDescriptionTable extends _i1.Table<int?> {
  ListPanelColumnDescriptionTable({super.tableRelation})
      : super(tableName: 'list_panel_column_description') {
    distributionId = _i1.ColumnInt(
      'distributionId',
      this,
    );
    fieldNameEng = _i1.ColumnString(
      'fieldNameEng',
      this,
    );
    fieldNameHun = _i1.ColumnString(
      'fieldNameHun',
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

  late final _i1.ColumnString fieldNameEng;

  late final _i1.ColumnString fieldNameHun;

  late final _i1.ColumnString descriptionHun;

  late final _i1.ColumnString businessDescriptionHun;

  late final _i1.ColumnVector embedding;

  @override
  List<_i1.Column> get columns => [
        id,
        distributionId,
        fieldNameEng,
        fieldNameHun,
        descriptionHun,
        businessDescriptionHun,
        embedding,
      ];
}

class ListPanelColumnDescriptionInclude extends _i1.IncludeObject {
  ListPanelColumnDescriptionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ListPanelColumnDescription.t;
}

class ListPanelColumnDescriptionIncludeList extends _i1.IncludeList {
  ListPanelColumnDescriptionIncludeList._({
    _i1.WhereExpressionBuilder<ListPanelColumnDescriptionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ListPanelColumnDescription.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ListPanelColumnDescription.t;
}

class ListPanelColumnDescriptionRepository {
  const ListPanelColumnDescriptionRepository._();

  /// Returns a list of [ListPanelColumnDescription]s matching the given query parameters.
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
  Future<List<ListPanelColumnDescription>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ListPanelColumnDescriptionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ListPanelColumnDescriptionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ListPanelColumnDescriptionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ListPanelColumnDescription>(
      where: where?.call(ListPanelColumnDescription.t),
      orderBy: orderBy?.call(ListPanelColumnDescription.t),
      orderByList: orderByList?.call(ListPanelColumnDescription.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ListPanelColumnDescription] matching the given query parameters.
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
  Future<ListPanelColumnDescription?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ListPanelColumnDescriptionTable>? where,
    int? offset,
    _i1.OrderByBuilder<ListPanelColumnDescriptionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ListPanelColumnDescriptionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ListPanelColumnDescription>(
      where: where?.call(ListPanelColumnDescription.t),
      orderBy: orderBy?.call(ListPanelColumnDescription.t),
      orderByList: orderByList?.call(ListPanelColumnDescription.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ListPanelColumnDescription] by its [id] or null if no such row exists.
  Future<ListPanelColumnDescription?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ListPanelColumnDescription>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ListPanelColumnDescription]s in the list and returns the inserted rows.
  ///
  /// The returned [ListPanelColumnDescription]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ListPanelColumnDescription>> insert(
    _i1.Session session,
    List<ListPanelColumnDescription> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ListPanelColumnDescription>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ListPanelColumnDescription] and returns the inserted row.
  ///
  /// The returned [ListPanelColumnDescription] will have its `id` field set.
  Future<ListPanelColumnDescription> insertRow(
    _i1.Session session,
    ListPanelColumnDescription row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ListPanelColumnDescription>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ListPanelColumnDescription]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ListPanelColumnDescription>> update(
    _i1.Session session,
    List<ListPanelColumnDescription> rows, {
    _i1.ColumnSelections<ListPanelColumnDescriptionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ListPanelColumnDescription>(
      rows,
      columns: columns?.call(ListPanelColumnDescription.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ListPanelColumnDescription]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ListPanelColumnDescription> updateRow(
    _i1.Session session,
    ListPanelColumnDescription row, {
    _i1.ColumnSelections<ListPanelColumnDescriptionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ListPanelColumnDescription>(
      row,
      columns: columns?.call(ListPanelColumnDescription.t),
      transaction: transaction,
    );
  }

  /// Deletes all [ListPanelColumnDescription]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ListPanelColumnDescription>> delete(
    _i1.Session session,
    List<ListPanelColumnDescription> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ListPanelColumnDescription>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ListPanelColumnDescription].
  Future<ListPanelColumnDescription> deleteRow(
    _i1.Session session,
    ListPanelColumnDescription row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ListPanelColumnDescription>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ListPanelColumnDescription>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ListPanelColumnDescriptionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ListPanelColumnDescription>(
      where: where(ListPanelColumnDescription.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ListPanelColumnDescriptionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ListPanelColumnDescription>(
      where: where?.call(ListPanelColumnDescription.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
