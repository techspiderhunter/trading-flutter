import 'package:flutter/material.dart';
import 'package:techspiderhunter/helper/Widgets/ColorPalette.dart';

import 'package:techspiderhunter/helper/Widgets/TextStyle.dart';


class FormInputDate extends StatelessWidget {
  const FormInputDate({
    Key? key,
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.autoFocus,
    this.placeholder
  }) : super(key: key);

  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool? autoFocus;
  final String? placeholder;
  final Function(dynamic)? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(1900),
          lastDate: lastDate ?? DateTime(2101),
        );
        if (pickedDate != null && onChanged != null) {
          onChanged!(pickedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical:12, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: kcGray),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Text(
              value != null
                  ? "${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}"
                  : (placeholder ?? "Select Date"),
              style: TextStyl.bodyXs?.copyWith(fontSize: 16,color: Colors.grey),
            ),
            const SizedBox(width: 10),
            Spacer(),
            const Icon(Icons.calendar_month_outlined, size: 20, color: kcPrimary,),
          ],
        ),
      ),
    );
  }
}



