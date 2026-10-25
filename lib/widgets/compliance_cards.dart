import 'package:flutter/material.dart';
import '../themes/colors.dart';
import 'desk_exact.dart';

class ComplianceStatus extends StatelessWidget {
  final String title;
  final String description;
  final String reference;
  final Color color;
  final IconData icon;
  const ComplianceStatus(
      {super.key,
      required this.title,
      required this.description,
      required this.reference,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.22))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 23)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: deskText.copyWith(
                        fontSize: 16,
                        color: color,
                        fontWeight: FontWeight.w600))),
            Icon(Icons.shield_outlined,
                size: 19, color: color.withValues(alpha: 0.5)),
          ]),
          const SizedBox(height: 12),
          Text(description,
              style: deskText.copyWith(
                  fontSize: 12, color: AppColors.textSecondary, height: 1.6)),
          if (reference.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(8)),
                child: Text('Reference · $reference',
                    style: deskText.copyWith(
                        fontSize: 11, fontWeight: FontWeight.w500))),
          ],
        ]),
      );
}

class ComplianceGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const ComplianceGroup(
      {super.key,
      required this.title,
      required this.icon,
      required this.children});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 17, 18, 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x06192542),
                  blurRadius: 12,
                  offset: Offset(0, 4))
            ]),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, color: AppColors.primary, size: 17)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(title,
                    style: deskText.copyWith(
                        fontSize: 13, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 13),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 3),
          ...children,
        ]),
      );
}

class ComplianceField extends StatelessWidget {
  final String label;
  final String value;
  const ComplianceField(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: LayoutBuilder(builder: (context, constraints) {
          final caption = Text(label,
              style: deskText.copyWith(
                  fontSize: 11, color: AppColors.textSecondary));
          final content = Text(value,
              style: deskText.copyWith(
                  fontSize: 13, fontWeight: FontWeight.w500, height: 1.5));
          if (constraints.maxWidth < 270 ||
              MediaQuery.textScalerOf(context).scale(13) > 17) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [caption, const SizedBox(height: 4), content]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 4, child: caption),
            const SizedBox(width: 14),
            Expanded(flex: 6, child: content),
          ]);
        }),
      );
}

class ComplianceDocumentTile extends StatelessWidget {
  final String title;
  final bool attached;
  final VoidCallback? onPreview;
  const ComplianceDocumentTile(
      {super.key, required this.title, required this.attached, this.onPreview});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
              onTap: attached ? onPreview : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    const Icon(Icons.description_outlined,
                        color: AppColors.primary, size: 23),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(title,
                              style: deskText.copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 3),
                          Text(attached ? 'Tap to preview' : 'Not attached',
                              style: deskText.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                        ])),
                    if (attached && onPreview != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.visibility_outlined,
                          size: 18, color: AppColors.primary),
                    ],
                  ])))));
}
