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

abstract class MockCountryData
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = MockCountryDataTable();

  static const db = MockCountryDataRepository._();

  @override
  int? id;

  String countryName;

  String isoCode;

  bool isEuMember;

  bool isNatoMember;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'countryName': countryName,
      'isoCode': isoCode,
      'isEuMember': isEuMember,
      'isNatoMember': isNatoMember,
    };
  }

  static MockCountryDataInclude include() {
    return MockCountryDataInclude._();
  }

  static MockCountryDataIncludeList includeList({
    _i1.WhereExpressionBuilder<MockCountryDataTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MockCountryDataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MockCountryDataTable>? orderByList,
    MockCountryDataInclude? include,
  }) {
    return MockCountryDataIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MockCountryData.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MockCountryData.t),
      include: include,
    );
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

class MockCountryDataTable extends _i1.Table<int?> {
  MockCountryDataTable({super.tableRelation})
      : super(tableName: 'mock_country_data') {
    countryName = _i1.ColumnString(
      'countryName',
      this,
    );
    isoCode = _i1.ColumnString(
      'isoCode',
      this,
    );
    isEuMember = _i1.ColumnBool(
      'isEuMember',
      this,
    );
    isNatoMember = _i1.ColumnBool(
      'isNatoMember',
      this,
    );
  }

  late final _i1.ColumnString countryName;

  late final _i1.ColumnString isoCode;

  late final _i1.ColumnBool isEuMember;

  late final _i1.ColumnBool isNatoMember;

  @override
  List<_i1.Column> get columns => [
        id,
        countryName,
        isoCode,
        isEuMember,
        isNatoMember,
      ];
}

class MockCountryDataInclude extends _i1.IncludeObject {
  MockCountryDataInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => MockCountryData.t;
}

class MockCountryDataIncludeList extends _i1.IncludeList {
  MockCountryDataIncludeList._({
    _i1.WhereExpressionBuilder<MockCountryDataTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MockCountryData.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => MockCountryData.t;
}

class MockCountryDataRepository {
  const MockCountryDataRepository._();

  /// Returns a list of [MockCountryData]s matching the given query parameters.
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
  Future<List<MockCountryData>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MockCountryDataTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MockCountryDataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MockCountryDataTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<MockCountryData>(
      where: where?.call(MockCountryData.t),
      orderBy: orderBy?.call(MockCountryData.t),
      orderByList: orderByList?.call(MockCountryData.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [MockCountryData] matching the given query parameters.
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
  Future<MockCountryData?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MockCountryDataTable>? where,
    int? offset,
    _i1.OrderByBuilder<MockCountryDataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MockCountryDataTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<MockCountryData>(
      where: where?.call(MockCountryData.t),
      orderBy: orderBy?.call(MockCountryData.t),
      orderByList: orderByList?.call(MockCountryData.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [MockCountryData] by its [id] or null if no such row exists.
  Future<MockCountryData?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<MockCountryData>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [MockCountryData]s in the list and returns the inserted rows.
  ///
  /// The returned [MockCountryData]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<MockCountryData>> insert(
    _i1.Session session,
    List<MockCountryData> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<MockCountryData>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [MockCountryData] and returns the inserted row.
  ///
  /// The returned [MockCountryData] will have its `id` field set.
  Future<MockCountryData> insertRow(
    _i1.Session session,
    MockCountryData row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MockCountryData>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MockCountryData]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MockCountryData>> update(
    _i1.Session session,
    List<MockCountryData> rows, {
    _i1.ColumnSelections<MockCountryDataTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MockCountryData>(
      rows,
      columns: columns?.call(MockCountryData.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MockCountryData]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MockCountryData> updateRow(
    _i1.Session session,
    MockCountryData row, {
    _i1.ColumnSelections<MockCountryDataTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MockCountryData>(
      row,
      columns: columns?.call(MockCountryData.t),
      transaction: transaction,
    );
  }

  /// Deletes all [MockCountryData]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MockCountryData>> delete(
    _i1.Session session,
    List<MockCountryData> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MockCountryData>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MockCountryData].
  Future<MockCountryData> deleteRow(
    _i1.Session session,
    MockCountryData row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MockCountryData>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MockCountryData>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<MockCountryDataTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MockCountryData>(
      where: where(MockCountryData.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MockCountryDataTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MockCountryData>(
      where: where?.call(MockCountryData.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
