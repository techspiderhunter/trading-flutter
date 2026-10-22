import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

// ================================================================
// TEXT FORM INPUT
// ================================================================

class TextFormInput extends StatelessWidget {
  final TextEditingController? controller;
  final String placeholder;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? color;
  final int? maxLines;
  final bool? isDense;

  const TextFormInput({
    Key? key,
    this.controller,
    required this.placeholder,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isPassword = false,
    this.color,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines,
    this.isDense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      validator: validator,
      maxLines: isPassword ? 1 : maxLines,
      decoration: InputDecoration(
        isDense: isDense,

        hintText: placeholder,

        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),

        filled: true,
        fillColor: Colors.white,

// --------------------------------------------------------
// NORMAL BORDER
// --------------------------------------------------------

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),

// --------------------------------------------------------
// FOCUSED BORDER
// --------------------------------------------------------

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1E52FE),
            width: 1.3,
          ),
        ),

// --------------------------------------------------------
// ERROR BORDER
// --------------------------------------------------------

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.3,
          ),
        ),

        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ================================================================
// DROPDOWN SEARCH
// ================================================================

class FormDropdownSearch extends StatelessWidget {
  final String placeholder;
  final List<String> items;
  final String? selectedItem;
  final bool showSearchBox;
  final void Function(String?)? onChanged;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;

  const FormDropdownSearch({
    Key? key,
    required this.placeholder,
    required this.items,
    this.selectedItem,
    this.showSearchBox = true,
    this.onChanged,
    this.prefixIcon,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
// ==========================================================
// ITEMS
// ==========================================================

      items: (filter, loadProps) {
        return items;
      },

// ==========================================================
// SELECTED ITEM
// ==========================================================

      selectedItem: selectedItem,

// ==========================================================
// CHANGE
// ==========================================================

      onSaved: onChanged,

// ==========================================================
// VALIDATOR
// ==========================================================

      validator: validator,

// ==========================================================
// POPUP
// ==========================================================

      popupProps: PopupProps.menu(
        showSearchBox: showSearchBox,

        constraints: const BoxConstraints(
          maxHeight: 300,
        ),

        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search...",
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1E52FE),
              ),
            ),
          ),
        ),

// ========================================================
// POPUP ITEM
// ========================================================

        itemBuilder: (
          BuildContext context,
          String item,
          bool isDisabled,
          bool isSelected,
        ) {
          return ListTile(
            dense: true,
            title: Text(
              item,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            trailing: isSelected
                ? const Icon(
                    Icons.check,
                    size: 18,
                    color: Color(0xFF1E52FE),
                  )
                : null,
            enabled: !isDisabled,
          );
        },
      ),

// ==========================================================
// DROPDOWN BUILDER
// ==========================================================

      dropdownBuilder: (
        BuildContext context,
        String? selectedItem,
      ) {
        return Text(
          selectedItem ?? placeholder,
          style: TextStyle(
            fontSize: 14,
            color: selectedItem == null ? Colors.grey : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },

// ==========================================================
// DECORATION
// ==========================================================

      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          hintText: placeholder,

          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),

          prefixIcon: prefixIcon,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),

          filled: true,
          fillColor: Colors.white,

// ------------------------------------------------------
// NORMAL BORDER
// ------------------------------------------------------

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),

// ------------------------------------------------------
// FOCUSED BORDER
// ------------------------------------------------------

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF1E52FE),
              width: 1.3,
            ),
          ),

// ------------------------------------------------------
// ERROR BORDER
// ------------------------------------------------------

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
