import 'package:flutter/material.dart';
import '../themes/colors.dart';

const deskText = TextStyle(
    fontFamily: 'DeskSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0);

String deskWrap(String value, int width) {
  return value.split('\n').map((paragraph) {
    final lines = <String>[];
    var line = '';
    for (final word in paragraph.split(' ')) {
      if (line.isNotEmpty && '$line $word'.length > width) {
        lines.add(line);
        line = word;
      } else {
        line = line.isEmpty ? word : '$line $word';
      }
    }
    lines.add(line);
    return lines.join('\n');
  }).join('\n');
}

String deskStatusLabel(String value) {
  final words = value
      .trim()
      .replaceAll('_', ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);
  return words
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

class DeskAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String group;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool dashboard;
  const DeskAppBar(
      {super.key,
      required this.group,
      this.onBack,
      this.actions,
      this.dashboard = false});
  @override
  Size get preferredSize => const Size.fromHeight(68);
  @override
  Widget build(BuildContext context) => AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 68,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leadingWidth: 72,
        leading: Padding(
            padding:
                const EdgeInsets.only(left: 24, top: 16, bottom: 16, right: 12),
            child: Material(
                color: AppColors.textHeading,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: dashboard
                        ? null
                        : onBack ?? () => Navigator.maybePop(context),
                    child: Center(
                        child: dashboard
                            ? const Text('T',
                                style: TextStyle(
                                    fontFamily: 'DeskSans',
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white))
                            : const Icon(Icons.arrow_back_rounded,
                                color: Colors.white, size: 19))))),
        title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TRADING',
                  style: TextStyle(
                      fontFamily: 'DeskSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHeading)),
              const SizedBox(height: 2),
              Text(group.toUpperCase(),
                  style: const TextStyle(
                      fontFamily: 'DeskSans',
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary)),
            ]),
        actions: [
          if (actions == null)
            Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    color: const Color(0xFFF1F3FA),
                    borderRadius: BorderRadius.circular(15)),
                child: const ExcludeSemantics(
                    child: Icon(Icons.refresh_rounded,
                        size: 21, color: AppColors.primary))),
          ...?actions,
          const SizedBox(width: 24)
        ],
      );
}

class DeskBody extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  const DeskBody({super.key, required this.children, this.onRefresh});
  @override
  Widget build(BuildContext context) {
    final scroll = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        child: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 40),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children)))));
    return SafeArea(
        top: false,
        child: onRefresh == null
            ? scroll
            : RefreshIndicator(onRefresh: onRefresh!, child: scroll));
  }
}

class DeskNote extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  const DeskNote(
      {super.key,
      required this.title,
      required this.description,
      this.color = AppColors.primary,
      this.icon = Icons.north_east_rounded});
  @override
  Widget build(BuildContext context) => Container(
        constraints:
            BoxConstraints(minHeight: 94 + (description.length ~/ 34) * 21.0),
        padding: const EdgeInsets.fromLTRB(16, 17, 16, 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 20, color: color)),
            const SizedBox(width: 13),
            Expanded(
                child: Text(title,
                    style: deskText.copyWith(
                        fontSize: 15,
                        color: color,
                        fontWeight: FontWeight.w600)))
          ]),
          const SizedBox(height: 12),
          Text(deskWrap(description, 38),
              style: deskText.copyWith(
                  fontSize: 13, color: AppColors.textSecondary, height: 1.62)),
        ]),
      );
}

class DeskSection extends StatelessWidget {
  final String title;
  const DeskSection(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Expanded(
            child: Text(title.toUpperCase(),
                style: deskText.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3)))
      ]));
}

class DeskRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  const DeskRow(
      {super.key,
      required this.title,
      this.subtitle,
      this.icon = Icons.north_east_rounded,
      this.onTap,
      this.trailing});
  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          boxShadow: const [
            BoxShadow(color: Color(0xFFE8ECF5), offset: Offset(0, 3))
          ]),
      child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(19),
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(19),
              child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 86),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 18),
                      child: Row(children: [
                        Container(
                            width: 43,
                            height: 45,
                            decoration: BoxDecoration(
                                color: AppColors.cardBlue,
                                borderRadius: BorderRadius.circular(14)),
                            child:
                                Icon(icon, color: AppColors.primary, size: 22)),
                        const SizedBox(width: 13),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(title,
                                  style: deskText.copyWith(
                                      fontWeight: FontWeight.w600)),
                              if (subtitle != null && subtitle!.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(subtitle!,
                                    style: deskText.copyWith(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                        height: 1.7))
                              ],
                            ])),
                        const SizedBox(width: 8),
                        trailing ??
                            const Icon(Icons.chevron_right_rounded,
                                color: Color(0xFF8894AB), size: 20),
                      ]))))));
}

class DeskAttachmentAction extends StatelessWidget {
  final VoidCallback onPressed;
  const DeskAttachmentAction({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.centerRight,
      child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.primaryLight,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.attach_file_rounded, size: 16),
            const SizedBox(width: 6),
            Flexible(
                child: Text('View attachment',
                    style: deskText.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary))),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 17),
          ])));
}

class DeskMessageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String message;
  final VoidCallback? onAttachment;
  const DeskMessageCard(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.message,
      this.onAttachment});

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.article_outlined,
                  size: 19, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: deskText.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: deskText.copyWith(
                        fontSize: 11, color: AppColors.textSecondary)),
              ])),
        ]),
        const SizedBox(height: 16),
        Text(message,
            style: deskText.copyWith(
                fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
        if (onAttachment != null) ...[
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 10),
          DeskAttachmentAction(onPressed: onAttachment!),
        ],
      ]));
}

class DeskButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool loading;
  const DeskButton(
      {super.key,
      required this.label,
      this.icon,
      this.onPressed,
      this.secondary = false,
      this.loading = false});
  @override
  Widget build(BuildContext context) => Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(17), boxShadow: [
        BoxShadow(
            color:
                secondary ? const Color(0xFFE5E8F1) : const Color(0xFFDAD4F6),
            offset: const Offset(0, 4))
      ]),
      child: Material(
          color: secondary
              ? Colors.white
              : onPressed == null
                  ? AppColors.surfaceSecondary
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          clipBehavior: Clip.antiAlias,
          child: Ink(
              decoration: BoxDecoration(
                  gradient: !secondary && onPressed != null
                      ? AppColors.primaryGradient
                      : null,
                  borderRadius: BorderRadius.circular(17),
                  border:
                      secondary ? Border.all(color: AppColors.border) : null),
              child: InkWell(
                  onTap: onPressed,
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 53),
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(19, 12, 15, 12),
                          child: Row(children: [
                            if (icon != null) ...[
                              Icon(icon,
                                  size: 21,
                                  color: secondary || onPressed == null
                                      ? AppColors.primary
                                      : Colors.white),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                                child: Text(label,
                                    style: deskText.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: secondary || onPressed == null
                                            ? AppColors.textPrimary
                                            : Colors.white))),
                            const SizedBox(width: 10),
                            Container(
                                width: 30,
                                height: 29,
                                decoration: BoxDecoration(
                                    color: secondary
                                        ? const Color(0xFFF1F0FA)
                                        : const Color(0xFF8778EA),
                                    borderRadius: BorderRadius.circular(10)),
                                child: loading
                                    ? const Padding(
                                        padding: EdgeInsets.all(7),
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : Icon(Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: secondary
                                            ? AppColors.primary
                                            : Colors.white)),
                          ])))))));
}

class DeskInputMarker extends StatelessWidget {
  const DeskInputMarker({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(
      width: 32,
      child: Center(
          child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Color(0xFFB9AFEF),
                  borderRadius: BorderRadius.all(Radius.circular(3))),
              child: SizedBox(width: 6, height: 17))));
}

InputDecoration deskInputDecoration(
        {String? hintText,
        Widget? suffixIcon,
        bool enabled = true,
        String? errorText,
        Widget? prefixIcon}) =>
    InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      enabled: enabled,
      errorText: errorText,
      prefixIcon: prefixIcon ?? const DeskInputMarker(),
      prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      filled: true,
      fillColor: enabled ? Colors.white : const Color(0xFFE7EBF3),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
      hintStyle:
          deskText.copyWith(fontSize: 14, color: AppColors.textSecondary),
      border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: AppColors.border)),
      enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: AppColors.border)),
      disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: AppColors.border)),
      focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
      errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(color: AppColors.error)),
    );

class DeskLabel extends StatelessWidget {
  final String text;
  const DeskLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: deskText.copyWith(
              fontSize: 12,
              height: 1.25,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600)));
}

class DeskRecord extends StatelessWidget {
  final String label;
  final String value;
  const DeskRecord(this.label, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: deskText.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: deskText),
        ]),
      );
}

class DeskUpload extends StatelessWidget {
  final String title;
  final bool attached;
  final VoidCallback? onTap;
  final VoidCallback? onPreview;
  final String hint;
  const DeskUpload(
      {super.key,
      required this.title,
      required this.onTap,
      this.onPreview,
      this.attached = false,
      this.hint = 'PDF / JPG · up to 5 MB'});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(13)),
                child: Icon(
                    attached ? Icons.check_rounded : Icons.arrow_upward_rounded,
                    color: AppColors.primary,
                    size: 23)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: deskText.copyWith(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(attached ? 'Document attached' : hint,
                      style: deskText.copyWith(
                          fontSize: 10, color: AppColors.textSecondary)),
                ]))
          ]),
          const SizedBox(height: 15),
          Wrap(spacing: 8, runSpacing: 8, children: [
            InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF1EEFF),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                        attached
                            ? 'Replace · Camera / Gallery'
                            : 'Camera / Gallery',
                        style: deskText.copyWith(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)))),
            if (attached && onPreview != null)
              TextButton(onPressed: onPreview, child: const Text('Preview')),
          ]),
        ]),
      );
}

class DeskSheetContent extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  const DeskSheetContent(
      {super.key, required this.title, this.subtitle, required this.children});
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: SafeArea(
            top: false,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.9),
                child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 15, 24, 32),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                              child: Container(
                                  width: 46,
                                  height: 4,
                                  decoration: BoxDecoration(
                                      color: AppColors.border,
                                      borderRadius: BorderRadius.circular(2)))),
                          const SizedBox(height: 23),
                          DeskHero(title: title, subtitle: subtitle),
                          const SizedBox(height: 25),
                          ...children,
                        ])))),
      );
}

/// Compact, unboxed page heading shared by screens and dialogs.
/// The legacy name keeps existing callers compatible without a hero card.
class DeskHero extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String eyebrow;
  final Widget? trailing;

  const DeskHero(
      {super.key,
      required this.title,
      this.subtitle,
      this.eyebrow = 'TRADING / RESEARCH DESK',
      this.trailing});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: deskText.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHeading,
                  height: 1.3)),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(subtitle!,
                style: deskText.copyWith(
                    fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
          ],
          if (trailing != null) ...[const SizedBox(height: 8), trailing!],
        ],
      );
}
