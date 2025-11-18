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

abstract class TestModel
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = TestModelTable();

  static const db = TestModelRepository._();

  @override
  int? id;

  String message;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'message': message,
    };
  }

  static TestModelInclude include() {
    return TestModelInclude._();
  }

  static TestModelIncludeList includeList({
    _i1.WhereExpressionBuilder<TestModelTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TestModelTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TestModelTable>? orderByList,
    TestModelInclude? include,
  }) {
    return TestModelIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TestModel.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(TestModel.t),
      include: include,
    );
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

class TestModelTable extends _i1.Table<int?> {
  TestModelTable({super.tableRelation}) : super(tableName: 'test_model') {
    message = _i1.ColumnString(
      'message',
      this,
    );
  }

  late final _i1.ColumnString message;

  @override
  List<_i1.Column> get columns => [
        id,
        message,
      ];
}

class TestModelInclude extends _i1.IncludeObject {
  TestModelInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => TestModel.t;
}

class TestModelIncludeList extends _i1.IncludeList {
  TestModelIncludeList._({
    _i1.WhereExpressionBuilder<TestModelTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TestModel.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => TestModel.t;
}

class TestModelRepository {
  const TestModelRepository._();

  /// Returns a list of [TestModel]s matching the given query parameters.
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
  Future<List<TestModel>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TestModelTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TestModelTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TestModelTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<TestModel>(
      where: where?.call(TestModel.t),
      orderBy: orderBy?.call(TestModel.t),
      orderByList: orderByList?.call(TestModel.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [TestModel] matching the given query parameters.
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
  Future<TestModel?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TestModelTable>? where,
    int? offset,
    _i1.OrderByBuilder<TestModelTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TestModelTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<TestModel>(
      where: where?.call(TestModel.t),
      orderBy: orderBy?.call(TestModel.t),
      orderByList: orderByList?.call(TestModel.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [TestModel] by its [id] or null if no such row exists.
  Future<TestModel?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<TestModel>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [TestModel]s in the list and returns the inserted rows.
  ///
  /// The returned [TestModel]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<TestModel>> insert(
    _i1.Session session,
    List<TestModel> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<TestModel>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [TestModel] and returns the inserted row.
  ///
  /// The returned [TestModel] will have its `id` field set.
  Future<TestModel> insertRow(
    _i1.Session session,
    TestModel row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<TestModel>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [TestModel]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<TestModel>> update(
    _i1.Session session,
    List<TestModel> rows, {
    _i1.ColumnSelections<TestModelTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<TestModel>(
      rows,
      columns: columns?.call(TestModel.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TestModel]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TestModel> updateRow(
    _i1.Session session,
    TestModel row, {
    _i1.ColumnSelections<TestModelTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<TestModel>(
      row,
      columns: columns?.call(TestModel.t),
      transaction: transaction,
    );
  }

  /// Deletes all [TestModel]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<TestModel>> delete(
    _i1.Session session,
    List<TestModel> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<TestModel>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [TestModel].
  Future<TestModel> deleteRow(
    _i1.Session session,
    TestModel row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TestModel>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<TestModel>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<TestModelTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<TestModel>(
      where: where(TestModel.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TestModelTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<TestModel>(
      where: where?.call(TestModel.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
