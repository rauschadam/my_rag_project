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
import '../model/chat_message_type.dart' as _i2;
import '../model/chat_session.dart' as _i3;

abstract class ChatMessage implements _i1.SerializableModel {
  ChatMessage._({
    this.id,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.chatSessionId,
    this.chatSession,
  });

  factory ChatMessage({
    int? id,
    required String message,
    required _i2.ChatMessageType type,
    required DateTime createdAt,
    required int chatSessionId,
    _i3.ChatSession? chatSession,
  }) = _ChatMessageImpl;

  factory ChatMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMessage(
      id: jsonSerialization['id'] as int?,
      message: jsonSerialization['message'] as String,
      type: _i2.ChatMessageType.fromJson((jsonSerialization['type'] as int)),
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      chatSessionId: jsonSerialization['chatSessionId'] as int,
      chatSession: jsonSerialization['chatSession'] == null
          ? null
          : _i3.ChatSession.fromJson(
              (jsonSerialization['chatSession'] as Map<String, dynamic>)),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String message;

  _i2.ChatMessageType type;

  DateTime createdAt;

  int chatSessionId;

  _i3.ChatSession? chatSession;

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatMessage copyWith({
    int? id,
    String? message,
    _i2.ChatMessageType? type,
    DateTime? createdAt,
    int? chatSessionId,
    _i3.ChatSession? chatSession,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'message': message,
      'type': type.toJson(),
      'createdAt': createdAt.toJson(),
      'chatSessionId': chatSessionId,
      if (chatSession != null) 'chatSession': chatSession?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMessageImpl extends ChatMessage {
  _ChatMessageImpl({
    int? id,
    required String message,
    required _i2.ChatMessageType type,
    required DateTime createdAt,
    required int chatSessionId,
    _i3.ChatSession? chatSession,
  }) : super._(
          id: id,
          message: message,
          type: type,
          createdAt: createdAt,
          chatSessionId: chatSessionId,
          chatSession: chatSession,
        );

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatMessage copyWith({
    Object? id = _Undefined,
    String? message,
    _i2.ChatMessageType? type,
    DateTime? createdAt,
    int? chatSessionId,
    Object? chatSession = _Undefined,
  }) {
    return ChatMessage(
      id: id is int? ? id : this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      chatSessionId: chatSessionId ?? this.chatSessionId,
      chatSession: chatSession is _i3.ChatSession?
          ? chatSession
          : this.chatSession?.copyWith(),
    );
  }
}
