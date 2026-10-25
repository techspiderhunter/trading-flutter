import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../themes/colors.dart';
import '../../../widgets/DeskUi.dart';
import '../controllers/SplashControllers.dart';

class SplashIndex extends StatefulWidget {
  const SplashIndex({super.key});

  @override
  State<SplashIndex> createState() => _SplashIndexState();
}

class _SplashIndexState extends State<SplashIndex>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            body: Center(
                child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 592),
                            child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Center(
                                              child: Container(
                                                  width: 100,
                                                  height: 100,
                                                  alignment: Alignment.center,
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape: BoxShape
                                                              .circle,
                                                          color: AppColors
                                                              .primary),
                                                  child: Text(
                                                      'T',
                                                      style: deskText.copyWith(
                                                          fontSize: 48,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              Colors.white)))),
                                          const SizedBox(height: 30),
                                          Text('Research, with clarity.',
                                              textAlign: TextAlign.center,
                                              style: deskText.copyWith(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 8),
                                          Text('TRADING · RESEARCH DESK',
                                              textAlign: TextAlign.center,
                                              style: deskText.copyWith(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary)),
                                          const SizedBox(height: 40),
                                          const SizedBox(
                                              width: 180,
                                              child: LinearProgressIndicator(
                                                  minHeight: 3,
                                                  backgroundColor:
                                                      AppColors.border,
                                                  color: AppColors.primary)),
                                          const SizedBox(height: 20),
                                          Text('Preparing your workspace',
                                              textAlign: TextAlign.center,
                                              style: deskText.copyWith(
                                                  fontSize: 13,
                                                  color:
                                                      AppColors.textSecondary)),
                                        ]))))))));
      },
    );
  }
}
