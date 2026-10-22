// import 'package:flutter/material.dart';
// import 'package:techspiderhunter/includes/Storage.dart';
//
// import '../../global/models/ServerResponse.dart';
// import '../../global/requests/CommonRequest.dart';
// import '../../modules/Category/models/CategoryModel.dart';
//
// /// =======================================================
// /// CATEGORY MODEL
// /// =======================================================
//
// /// =======================================================
// /// CATEGORY API SERVICE
// /// =======================================================
//
// class CategoryService {
//   static Future<List<CategoryModel>> getCategories({
//     required String code,
//     required int businessId,
//     required int level,
//     int? parentId,
//   }) async {
//     try {
//       final ServerResponse response = await CommonRequest.getCommonCategories(
//         code: code,
//         level: level.toString(),
//         parentId: parentId?.toString(),
//       );
//
//       if (response.isError) return [];
//
//       final data = response.data is List ? response.data as List : [];
//
//       return data
//           .whereType<Map<String, dynamic>>()
//           .map((e) => CategoryModel.fromJson(_stringIds(e)))
//           .toList();
//     } catch (e) {
//       print(e);
//
//       return [];
//     }
//   }
//
//   static Map<String, dynamic> _stringIds(Map<String, dynamic> json) {
//     return {
//       ...json,
//       "id": json["id"]?.toString(),
//       "category_type_id": json["category_type_id"]?.toString(),
//       "user_id": json["user_id"]?.toString(),
//     };
//   }
// }
//
// /// =======================================================
// /// SINGLE SELECT CATEGORY WIDGET
// /// =======================================================
//
// class DynamicSingleCategoryWidget extends StatefulWidget {
//   final Function(CategoryModel category) onChanged;
//
//   final String title;
//
//   final int? parentId;
//   final int level;
//   final String code;
//   final String? selectedId;
//
//   const DynamicSingleCategoryWidget({
//     super.key,
//     required this.onChanged,
//     this.parentId,
//     this.selectedId,
//     required this.level,
//     required this.code,
//     this.title = "Select Category",
//   });
//
//   @override
//   State<DynamicSingleCategoryWidget> createState() =>
//       _DynamicSingleCategoryWidgetState();
// }
//
// class _DynamicSingleCategoryWidgetState
//     extends State<DynamicSingleCategoryWidget> {
//   bool isLoading = true;
//
//   List<CategoryModel> categories = [];
//
//   String? selectedValue;
//
//   @override
//   void initState() {
//     super.initState();
//     selectedValue = widget.selectedId;
//
//     loadCategories();
//   }
//
//   @override
//   void didUpdateWidget(covariant DynamicSingleCategoryWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if (oldWidget.selectedId != widget.selectedId) {
//       selectedValue = widget.selectedId;
//     }
//   }
//
//   Future<void> loadCategories() async {
//     isLoading = true;
//
//     setState(() {});
//
//     final businessId =
//         int.tryParse(LocalStorage.read('active_business_id') ?? "");
//
//     categories = businessId == null
//         ? []
//         : await CategoryService.getCategories(
//             code: widget.code,
//             businessId: businessId,
//             level: widget.level,
//             parentId: widget.parentId,
//           );
//
//     if (selectedValue != null &&
//         !categories.any((item) => item.id.toString() == selectedValue)) {
//       selectedValue = null;
//     }
//
//     isLoading = false;
//
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 10),
//         if (isLoading)
//           const Center(
//             child: CircularProgressIndicator(),
//           )
//         else
//           DropdownButtonFormField(
//             initialValue: selectedValue,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             items: categories.map((item) {
//               return DropdownMenuItem(
//                 value: item.id.toString(),
//                 child: Text(
//                   item.name.toString(),
//                 ),
//               );
//             }).toList(),
//             onChanged: (value) {
//               selectedValue = value.toString();
//
//               setState(() {});
//
//               CategoryModel category = categories.firstWhere(
//                 (e) => e.id.toString() == value.toString(),
//               );
//
//               widget.onChanged(category);
//             },
//           ),
//       ],
//     );
//   }
// }
//
// /// =======================================================
// /// MULTI SELECT CATEGORY WIDGET
// /// =======================================================
//
// class DynamicMultiCategoryWidget extends StatefulWidget {
//   final Function(List<CategoryModel> categories) onChanged;
//
//   final String title;
//
//   final int parentId;
//   final int level;
//   final String code;
//
//   const DynamicMultiCategoryWidget({
//     super.key,
//     required this.onChanged,
//     required this.parentId,
//     required this.level,
//     required this.code,
//     this.title = "Select Categories",
//   });
//
//   @override
//   State<DynamicMultiCategoryWidget> createState() =>
//       _DynamicMultiCategoryWidgetState();
// }
//
// class _DynamicMultiCategoryWidgetState
//     extends State<DynamicMultiCategoryWidget> {
//   bool isLoading = true;
//
//   List<CategoryModel> categories = [];
//
//   List<CategoryModel> selectedCategories = [];
//
//   @override
//   void initState() {
//     super.initState();
//
//     loadCategories();
//   }
//
//   Future<void> loadCategories() async {
//     isLoading = true;
//
//     setState(() {});
//
//     final businessId =
//         int.tryParse(LocalStorage.read('active_business_id') ?? "");
//
//     categories = businessId == null
//         ? []
//         : await CategoryService.getCategories(
//             code: widget.code,
//             businessId: businessId,
//             level: widget.level,
//             parentId: widget.parentId,
//           );
//
//     isLoading = false;
//
//     setState(() {});
//   }
//
//   void onSelect(CategoryModel item) {
//     bool alreadySelected = selectedCategories.any(
//       (e) => e.id == item.id,
//     );
//
//     if (alreadySelected) {
//       selectedCategories.removeWhere(
//         (e) => e.id == item.id,
//       );
//     } else {
//       selectedCategories.add(item);
//     }
//
//     setState(() {});
//
//     widget.onChanged(selectedCategories);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 10),
//         if (isLoading)
//           const Center(
//             child: CircularProgressIndicator(),
//           )
//         else
//           Column(
//             children: categories.map((item) {
//               bool isSelected = selectedCategories.any(
//                 (e) => e.id == item.id,
//               );
//
//               return InkWell(
//                 onTap: () {
//                   onSelect(item);
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.only(
//                     bottom: 10,
//                   ),
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: isSelected ? Colors.blue : Colors.grey.shade300,
//                     ),
//                     color: isSelected
//                         ? Colors.blue.withValues(alpha: 0.1)
//                         : Colors.white,
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         isSelected
//                             ? Icons.check_box
//                             : Icons.check_box_outline_blank,
//                         color: isSelected ? Colors.blue : Colors.grey,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           item.name.toString(),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         const SizedBox(height: 16),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: selectedCategories.map(
//             (item) {
//               return ConstrainedBox(
//                 constraints: const BoxConstraints(
//                   maxWidth: 180,
//                 ),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 14,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Flexible(
//                         child: Text(
//                           item.name.toString(),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       InkWell(
//                         onTap: () {
//                           onSelect(item);
//                         },
//                         child: const Icon(
//                           Icons.close,
//                           size: 18,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ).toList(),
//         )
//       ],
//     );
//   }
// }
//
// /// =======================================================
// /// EXAMPLE PAGE
// /// =======================================================
//
// class CategoryExamplePage extends StatelessWidget {
//   const CategoryExamplePage({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Dynamic Categories"),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             /// ==================================
//             /// SINGLE SELECT
//             /// ==================================
//
//             DynamicSingleCategoryWidget(
//               title: "Single Select Category",
//
//               code: "item_category",
//
//               // businessId: 28,
//
//               level: 2,
//
//               parentId: 3,
//
//               onChanged: (category) {
//                 print(
//                   "Selected => ${category.id}",
//                 );
//
//                 print(
//                   "Name => ${category.name}",
//                 );
//               },
//             ),
//
//             const SizedBox(height: 40),
//
//             /// ==================================
//             /// MULTI SELECT
//             /// ==================================
//
//             DynamicMultiCategoryWidget(
//               title: "Multi Select Category",
//               code: "item_category",
//               level: 2,
//               parentId: 3,
//               onChanged: (categories) {
//                 print(categories.map((e) => e.name).toList());
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
