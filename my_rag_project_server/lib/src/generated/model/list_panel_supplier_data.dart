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

abstract class ListPanelSupplierData
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = ListPanelSupplierDataTable();

  static const db = ListPanelSupplierDataRepository._();

  @override
  int? id;

  String vendorName;

  String countryCode;

  String category;

  String amount;

  DateTime lastActivity;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'vendorName': vendorName,
      'countryCode': countryCode,
      'category': category,
      'amount': amount,
      'lastActivity': lastActivity.toJson(),
    };
  }

  static ListPanelSupplierDataInclude include() {
    return ListPanelSupplierDataInclude._();
  }

  static ListPanelSupplierDataIncludeList includeList({
    _i1.WhereExpressionBuilder<ListPanelSupplierDataTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ListPanelSupplierDataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ListPanelSupplierDataTable>? orderByList,
    ListPanelSupplierDataInclude? include,
  }) {
    return ListPanelSupplierDataIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ListPanelSupplierData.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ListPanelSupplierData.t),
      include: include,
    );
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

class ListPanelSupplierDataTable extends _i1.Table<int?> {
  ListPanelSupplierDataTable({super.tableRelation})
      : super(tableName: 'list_panel_suplier_data') {
    vendorName = _i1.ColumnString(
      'vendorName',
      this,
    );
    countryCode = _i1.ColumnString(
      'countryCode',
      this,
    );
    category = _i1.ColumnString(
      'category',
      this,
    );
    amount = _i1.ColumnString(
      'amount',
      this,
    );
    lastActivity = _i1.ColumnDateTime(
      'lastActivity',
      this,
    );
  }

  late final _i1.ColumnString vendorName;

  late final _i1.ColumnString countryCode;

  late final _i1.ColumnString category;

  late final _i1.ColumnString amount;

  late final _i1.ColumnDateTime lastActivity;

  @override
  List<_i1.Column> get columns => [
        id,
        vendorName,
        countryCode,
        category,
        amount,
        lastActivity,
      ];
}

class ListPanelSupplierDataInclude extends _i1.IncludeObject {
  ListPanelSupplierDataInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ListPanelSupplierData.t;
}

class ListPanelSupplierDataIncludeList extends _i1.IncludeList {
  ListPanelSupplierDataIncludeList._({
    _i1.WhereExpressionBuilder<ListPanelSupplierDataTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ListPanelSupplierData.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ListPanelSupplierData.t;
}

class ListPanelSupplierDataRepository {
  const ListPanelSupplierDataRepository._();

  /// Returns a list of [ListPanelSupplierData]s matching the given query parameters.
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
  Future<List<ListPanelSupplierData>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ListPanelSupplierDataTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ListPanelSupplierDataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ListPanelSupplierDataTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ListPanelSupplierData>(
      where: where?.call(ListPanelSupplierData.t),
      orderBy: orderBy?.call(ListPanelSupplierData.t),
      orderByList: orderByList?.call(ListPanelSupplierData.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ListPanelSupplierData] matching the given query parameters.
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
  Future<ListPanelSupplierData?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ListPanelSupplierDataTable>? where,
    int? offset,
    _i1.OrderByBuilder<ListPanelSupplierDataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ListPanelSupplierDataTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ListPanelSupplierData>(
      where: where?.call(ListPanelSupplierData.t),
      orderBy: orderBy?.call(ListPanelSupplierData.t),
      orderByList: orderByList?.call(ListPanelSupplierData.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ListPanelSupplierData] by its [id] or null if no such row exists.
  Future<ListPanelSupplierData?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ListPanelSupplierData>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ListPanelSupplierData]s in the list and returns the inserted rows.
  ///
  /// The returned [ListPanelSupplierData]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ListPanelSupplierData>> insert(
    _i1.Session session,
    List<ListPanelSupplierData> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ListPanelSupplierData>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ListPanelSupplierData] and returns the inserted row.
  ///
  /// The returned [ListPanelSupplierData] will have its `id` field set.
  Future<ListPanelSupplierData> insertRow(
    _i1.Session session,
    ListPanelSupplierData row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ListPanelSupplierData>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ListPanelSupplierData]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ListPanelSupplierData>> update(
    _i1.Session session,
    List<ListPanelSupplierData> rows, {
    _i1.ColumnSelections<ListPanelSupplierDataTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ListPanelSupplierData>(
      rows,
      columns: columns?.call(ListPanelSupplierData.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ListPanelSupplierData]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ListPanelSupplierData> updateRow(
    _i1.Session session,
    ListPanelSupplierData row, {
    _i1.ColumnSelections<ListPanelSupplierDataTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ListPanelSupplierData>(
      row,
      columns: columns?.call(ListPanelSupplierData.t),
      transaction: transaction,
    );
  }

  /// Deletes all [ListPanelSupplierData]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ListPanelSupplierData>> delete(
    _i1.Session session,
    List<ListPanelSupplierData> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ListPanelSupplierData>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ListPanelSupplierData].
  Future<ListPanelSupplierData> deleteRow(
    _i1.Session session,
    ListPanelSupplierData row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ListPanelSupplierData>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ListPanelSupplierData>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ListPanelSupplierDataTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ListPanelSupplierData>(
      where: where(ListPanelSupplierData.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ListPanelSupplierDataTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ListPanelSupplierData>(
      where: where?.call(ListPanelSupplierData.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
