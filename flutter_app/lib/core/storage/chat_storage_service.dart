import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlutterChatMessage {
  FlutterChatMessage({
    required this.id,
    required this.text,
    required this.isBot,
    required this.timestamp,
    this.reasoning,
    this.showThinking = false,
  });

  final String id;
  final String text;
  final bool isBot;
  final String timestamp;
  final String? reasoning;
  bool showThinking;

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isBot': isBot,
        'timestamp': timestamp,
        'reasoning': reasoning,
      };

  factory FlutterChatMessage.fromJson(Map<String, dynamic> json) =>
      FlutterChatMessage(
        id: json['id'] as String,
        text: json['text'] as String,
        isBot: json['isBot'] as bool,
        timestamp: json['timestamp'] as String,
        reasoning: json['reasoning'] as String?,
      );
}

class FlutterChatThread {
  FlutterChatThread({
    required this.id,
    required this.title,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  final String id;
  String title;
  final String role;
  final String createdAt;
  String updatedAt;
  final List<FlutterChatMessage> messages;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'role': role,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory FlutterChatThread.fromJson(Map<String, dynamic> json) =>
      FlutterChatThread(
        id: json['id'] as String,
        title: json['title'] as String,
        role: json['role'] as String,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
        messages: (json['messages'] as List)
            .map((m) => FlutterChatMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}

class ChatStorageService {
  ChatStorageService(this._prefs);

  static const String _key = 'schookeep_flutter_chat_threads_v1';
  final SharedPreferences _prefs;

  List<FlutterChatThread> getThreads({String? role}) {
    try {
      final raw = _prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final List list = jsonDecode(raw) as List;
      final threads =
          list.map((item) => FlutterChatThread.fromJson(item as Map<String, dynamic>)).toList();
      if (role != null) {
        return threads.where((t) => t.role == role).toList();
      }
      return threads;
    } catch (e) {
      debugPrint('Failed to parse chat threads: $e');
      return [];
    }
  }

  Future<void> saveThread(FlutterChatThread thread) async {
    try {
      final threads = getThreads();
      final index = threads.indexWhere((t) => t.id == thread.id);
      if (index >= 0) {
        threads[index] = thread;
      } else {
        threads.insert(0, thread);
      }
      final jsonStr = jsonEncode(threads.map((t) => t.toJson()).toList());
      await _prefs.setString(_key, jsonStr);
    } catch (e) {
      debugPrint('Failed to save chat thread: $e');
    }
  }

  Future<void> deleteThread(String id) async {
    try {
      final threads = getThreads().where((t) => t.id != id).toList();
      final jsonStr = jsonEncode(threads.map((t) => t.toJson()).toList());
      await _prefs.setString(_key, jsonStr);
    } catch (e) {
      debugPrint('Failed to delete chat thread: $e');
    }
  }

  FlutterChatThread createNewThread({String role = 'general', bool isRTL = false}) {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'AM' : 'PM';
    final timeStr = '$h:$m $period';

    final greetingText = isRTL
        ? 'مرحباً بك! أنا مساعد سكوكيب الذكي (SchooKeep AI). كيف يمكنني مساعدتك اليوم؟'
        : 'Hello! I am SchooKeep AI. How can I help you today?';

    final newThread = FlutterChatThread(
      id: 'thread_${DateTime.now().millisecondsSinceEpoch}',
      title: isRTL ? 'محادثة جديدة' : 'New Chat',
      role: role,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      messages: [
        FlutterChatMessage(
          id: '1',
          text: greetingText,
          isBot: true,
          timestamp: timeStr,
        ),
      ],
    );

    saveThread(newThread);
    return newThread;
  }
}
