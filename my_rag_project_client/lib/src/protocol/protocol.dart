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
import 'greeting.dart' as _i2;
import 'model/chat_message.dart' as _i3;
import 'model/chat_message_type.dart' as _i4;
import 'model/chat_session.dart' as _i5;
import 'model/list_panel_column_description.dart' as _i6;
import 'model/list_panel_supplier_data.dart' as _i7;
import 'model/list_panel_table_description.dart' as _i8;
import 'model/rag_document.dart' as _i9;
import 'model/rag_document_type.dart' as _i10;
import 'model/test_model.dart' as _i11;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i12;
export 'greeting.dart';
export 'model/chat_message.dart';
export 'model/chat_message_type.dart';
export 'model/chat_session.dart';
export 'model/list_panel_column_description.dart';
export 'model/list_panel_supplier_data.dart';
export 'model/list_panel_table_description.dart';
export 'model/rag_document.dart';
export 'model/rag_document_type.dart';
export 'model/test_model.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i2.Greeting) {
      return _i2.Greeting.fromJson(data) as T;
    }
    if (t == _i3.ChatMessage) {
      return _i3.ChatMessage.fromJson(data) as T;
    }
    if (t == _i4.ChatMessageType) {
      return _i4.ChatMessageType.fromJson(data) as T;
    }
    if (t == _i5.ChatSession) {
      return _i5.ChatSession.fromJson(data) as T;
    }
    if (t == _i6.ListPanelColumnDescription) {
      return _i6.ListPanelColumnDescription.fromJson(data) as T;
    }
    if (t == _i7.ListPanelSupplierData) {
      return _i7.ListPanelSupplierData.fromJson(data) as T;
    }
    if (t == _i8.ListPanelTableDescription) {
      return _i8.ListPanelTableDescription.fromJson(data) as T;
    }
    if (t == _i9.RAGDocument) {
      return _i9.RAGDocument.fromJson(data) as T;
    }
    if (t == _i10.RAGDocumentType) {
      return _i10.RAGDocumentType.fromJson(data) as T;
    }
    if (t == _i11.TestModel) {
      return _i11.TestModel.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Greeting?>()) {
      return (data != null ? _i2.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ChatMessage?>()) {
      return (data != null ? _i3.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ChatMessageType?>()) {
      return (data != null ? _i4.ChatMessageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ChatSession?>()) {
      return (data != null ? _i5.ChatSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.ListPanelColumnDescription?>()) {
      return (data != null
          ? _i6.ListPanelColumnDescription.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i7.ListPanelSupplierData?>()) {
      return (data != null ? _i7.ListPanelSupplierData.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i8.ListPanelTableDescription?>()) {
      return (data != null
          ? _i8.ListPanelTableDescription.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i9.RAGDocument?>()) {
      return (data != null ? _i9.RAGDocument.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.RAGDocumentType?>()) {
      return (data != null ? _i10.RAGDocumentType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.TestModel?>()) {
      return (data != null ? _i11.TestModel.fromJson(data) : null) as T;
    }
    try {
      return _i12.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.Greeting) {
      return 'Greeting';
    }
    if (data is _i3.ChatMessage) {
      return 'ChatMessage';
    }
    if (data is _i4.ChatMessageType) {
      return 'ChatMessageType';
    }
    if (data is _i5.ChatSession) {
      return 'ChatSession';
    }
    if (data is _i6.ListPanelColumnDescription) {
      return 'ListPanelColumnDescription';
    }
    if (data is _i7.ListPanelSupplierData) {
      return 'ListPanelSupplierData';
    }
    if (data is _i8.ListPanelTableDescription) {
      return 'ListPanelTableDescription';
    }
    if (data is _i9.RAGDocument) {
      return 'RAGDocument';
    }
    if (data is _i10.RAGDocumentType) {
      return 'RAGDocumentType';
    }
    if (data is _i11.TestModel) {
      return 'TestModel';
    }
    className = _i12.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i2.Greeting>(data['data']);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i3.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatMessageType') {
      return deserialize<_i4.ChatMessageType>(data['data']);
    }
    if (dataClassName == 'ChatSession') {
      return deserialize<_i5.ChatSession>(data['data']);
    }
    if (dataClassName == 'ListPanelColumnDescription') {
      return deserialize<_i6.ListPanelColumnDescription>(data['data']);
    }
    if (dataClassName == 'ListPanelSupplierData') {
      return deserialize<_i7.ListPanelSupplierData>(data['data']);
    }
    if (dataClassName == 'ListPanelTableDescription') {
      return deserialize<_i8.ListPanelTableDescription>(data['data']);
    }
    if (dataClassName == 'RAGDocument') {
      return deserialize<_i9.RAGDocument>(data['data']);
    }
    if (dataClassName == 'RAGDocumentType') {
      return deserialize<_i10.RAGDocumentType>(data['data']);
    }
    if (dataClassName == 'TestModel') {
      return deserialize<_i11.TestModel>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i12.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
