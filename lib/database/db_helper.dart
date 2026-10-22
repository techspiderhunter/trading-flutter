import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ClientMessageModel.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    _database = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        // 1. Users Table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            name TEXT,
            email TEXT
          )
        ''');

        // 2. Official Communications / Broadcast Messages Table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY,
            group_id TEXT,
            sender TEXT,
            subject TEXT,
            preview TEXT,
            message TEXT,
            attachment TEXT,
            attachment_url TEXT,
            date TEXT,
            is_unread INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS messages (
              id INTEGER PRIMARY KEY,
              group_id TEXT,
              sender TEXT,
              subject TEXT,
              preview TEXT,
              message TEXT,
              attachment TEXT,
              attachment_url TEXT,
              date TEXT,
              is_unread INTEGER DEFAULT 0
            )
          ''');
        }
        if (oldVersion < 3) {
          try {
            await db.execute('ALTER TABLE messages ADD COLUMN group_id TEXT;');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE messages ADD COLUMN preview TEXT;');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE messages ADD COLUMN attachment TEXT;');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE messages ADD COLUMN attachment_url TEXT;');
          } catch (_) {}
        }
      },
    );

    return _database!;
  }

  // =========================================================================
  // MESSAGES (OFFICIAL ADVISORIES & BROADCASTS) CACHING
  // =========================================================================

  /// Save or replace fresh messages in SQLite batch
  Future<void> saveMessages(List<ClientMessageModel> messagesList) async {
    if (messagesList.isEmpty) return;

    final db = await database;
    final batch = db.batch();

    for (final msg in messagesList) {
      batch.insert(
        'messages',
        msg.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get cached messages from SQLite with optional Filter and Limit
  Future<List<ClientMessageModel>> getMessages({
    int? limit,
    bool? onlyUnread,
    String? search,
  }) async {
    final db = await database;

    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (onlyUnread == true) {
      whereClauses.add('is_unread = ?');
      whereArgs.add(1);
    }

    if (search != null && search.trim().isNotEmpty) {
      whereClauses.add('(subject LIKE ? OR message LIKE ? OR sender LIKE ?)');
      final term = '%${search.trim()}%';
      whereArgs.addAll([term, term, term]);
    }

    final String? whereString =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'id DESC',
      limit: limit,
    );

    return maps.map((map) => ClientMessageModel.fromMap(map)).toList();
  }

  /// Mark single message as read in local SQLite
  Future<void> markMessageAsRead(int id) async {
    final db = await database;
    await db.update(
      'messages',
      {'is_unread': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark all messages as read in local SQLite
  Future<void> markAllMessagesAsRead() async {
    final db = await database;
    await db.update('messages', {'is_unread': 0});
  }

  /// Clear messages table
  Future<void> clearMessages() async {
    final db = await database;
    await db.delete('messages');
  }

  // =========================================================================
  // USERS CACHING
  // =========================================================================

  /// Data save ya update karo
  Future<void> saveUsers(List<Map<String, dynamic>> users) async {
    final db = await database;
    final batch = db.batch();

    for (final user in users) {
      batch.insert(
        'users',
        user,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Local database se data read karo
  Future<List<Map<String, dynamic>>> getUsers({
    int? limit,
    String? search,
  }) async {
    final db = await database;

    if (search != null && search.trim().isNotEmpty) {
      return await db.query(
        'users',
        where: 'name LIKE ? OR email LIKE ?',
        whereArgs: ['%$search%', '%$search%'],
        orderBy: 'id DESC',
        limit: limit,
      );
    }

    return await db.query(
      'users',
      orderBy: 'id DESC',
      limit: limit,
    );
  }
}