import '../widgets/DeskUi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/user_controller.dart';
import '../themes/AppColors.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    return Scaffold(
      appBar: DeskAppBar(group: 'Utility', actions: [
        IconButton(
            tooltip: 'Reload from SQLite',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.loadUsers)
      ]),
      body: Column(
        children: [
          const DeskHero(
              title: 'Local users.',
              subtitle: 'Manage the existing local SQLite records.'),
          const SizedBox(height: 24),
          // Search & Filter Box
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
                decoration:
                    deskInputDecoration(hintText: 'Search users locally…'),
                onChanged: controller.searchUsers),
          ),

          // User List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.userList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.userList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open_rounded,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        controller.searchQuery.value.isNotEmpty
                            ? 'No users match "${controller.searchQuery.value}"'
                            : 'No local users found.\nTap + below to add a record to SQLite.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'DeskSans', color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadUsers,
                child: ListView.separated(
                  itemCount: controller.userList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = controller.userList[index];
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: DeskRow(
                            title: user.name,
                            subtitle: '${user.email} · #${user.id}',
                            icon: Icons.person_outline_rounded));
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          nameController.clear();
          emailController.clear();
          showDialog(
            context: context,
            builder: (ctx) => Dialog(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const DeskHero(
                              title: 'Add User to SQLite',
                              subtitle: 'Existing local-only utility'),
                          const SizedBox(height: 25),
                          const DeskLabel('Full name'),
                          TextField(
                              controller: nameController,
                              decoration:
                                  deskInputDecoration(hintText: 'Enter name')),
                          const SizedBox(height: 24),
                          const DeskLabel('Email address'),
                          TextField(
                              controller: emailController,
                              decoration: deskInputDecoration(
                                  hintText: 'name@example.com')),
                          const SizedBox(height: 24),
                          DeskButton(
                              label: 'Save to SQLite',
                              onPressed: () {
                                final name = nameController.text.trim();
                                final email = emailController.text.trim();
                                if (name.isNotEmpty && email.isNotEmpty) {
                                  controller.addUser(name, email);
                                  Navigator.pop(ctx);
                                }
                              }),
                          const SizedBox(height: 20),
                          DeskButton(
                              label: 'Cancel',
                              secondary: true,
                              onPressed: () => Navigator.pop(ctx))
                        ]))),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add User',
            style: TextStyle(fontFamily: 'DeskSans', color: Colors.white)),
      ),
    );
  }
}
