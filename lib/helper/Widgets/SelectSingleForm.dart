import 'package:flutter/material.dart';

class SelectSingleForm extends StatefulWidget {
  final String label;
  final String hint;
  final String? value;
  final List<Map<String, dynamic>> items;
  final Function(String?) onChanged;

  const SelectSingleForm({
    Key? key,
    required this.label,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
  }) : super(key: key);

  @override
  State<SelectSingleForm> createState() => _SelectSingleFormState();
}

class _SelectSingleFormState extends State<SelectSingleForm> {
  String? selectedLabel;

  @override
  void initState() {
    super.initState();
    _setInitialLabel();
  }

  @override
  void didUpdateWidget(covariant SelectSingleForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setInitialLabel();
  }

  void _setInitialLabel() {
    final selectedItem = widget.items.firstWhere(
          (e) => e['value'] == widget.value,
      orElse: () => {},
    );

    selectedLabel = selectedItem.isNotEmpty ? selectedItem['label'] : null;
  }

  void _openBottomSheet() {
    TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredList = List.from(widget.items);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: 400,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// 🔍 Search Box
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          filteredList = widget.items
                              .where((item) => item['label']
                              .toString()
                              .toLowerCase()
                              .contains(val.toLowerCase()))
                              .toList();
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    /// 📋 List
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text("No results found"))
                          : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];

                          return ListTile(
                            title: Text(item['label']),
                            onTap: () {
                              widget.onChanged(item['value']);
                              setState(() {
                                selectedLabel = item['label'];
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        /// Select Box
        GestureDetector(
          onTap: _openBottomSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedLabel ?? widget.hint,
                  style: TextStyle(
                    color: selectedLabel == null
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}