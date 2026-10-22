import 'package:get/get.dart';
import '../database/db_helper.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  final DBHelper _dbHelper = DBHelper();

  final userList = <UserModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  /// Offline-First Data Loading
  Future<void> loadUsers() async {
    if (userList.isEmpty) {
      isLoading.value = true;
    }

    try {
      // 1. Instant load from SQLite local database
      final localRows = await _dbHelper.getUsers(limit: 50);
      if (localRows.isNotEmpty) {
        userList.value = localRows.map((e) => UserModel.fromJson(e)).toList();
      }

      // 2. Fetch fresh from backend (if needed) and cache to SQLite
      // e.g. final response = await api.getUsers();
      // await _dbHelper.saveUsers(response.data);
    } catch (_) {
      // Error handling
    } finally {
      isLoading.value = false;
    }
  }

  /// Add new user to local SQLite
  Future<void> addUser(String name, String email) async {
    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch % 100000,
      'name': name,
      'email': email,
    };

    await _dbHelper.saveUsers([newUser]);
    userList.insert(0, UserModel.fromJson(newUser));
  }

  /// Search users with SQLite filter
  Future<void> searchUsers(String query) async {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      loadUsers();
      return;
    }

    final filtered = await _dbHelper.getUsers(search: query, limit: 30);
    userList.value = filtered.map((e) => UserModel.fromJson(e)).toList();
  }
}
