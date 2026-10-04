import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../login/login_view.dart';

class TaskoraSplashView extends StatefulWidget {
  const TaskoraSplashView({super.key});

  @override
  State<TaskoraSplashView> createState() => _TaskoraSplashViewState();
}

class _TaskoraSplashViewState extends State<TaskoraSplashView>
    with SingleTickerProviderStateMixin {
  static const _darkNavy = Color(0xFF1B2B4F);
  static const _cyan = Color(0xFF59CDC7);
  static const _teal = Color(0xFF3AB7BE);
  static const _oceanBlue = Color(0xFF4B7FC7);

  late final AnimationController _controller;
  @override
void initState() {
  super.initState();

  _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4800),
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TaskoraLoginView(),
          ),
        );
      }
    });

  _controller.forward();
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _portion(double value, double start, double end) {
    return ((value - start) / (end - start)).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final size = MediaQuery.sizeOf(context);
          final safeArea = MediaQuery.paddingOf(context);
          final timeline = _controller.value;
          final logoProgress = Curves.easeOutBack.transform(
            _portion(timeline, 0, 0.28),
          );
          final subtitleProgress = Curves.easeOutCubic.transform(
            _portion(timeline, 0.28, 0.48),
          );
          final barOpacity = Curves.easeIn.transform(
            _portion(timeline, 0.16, 0.3),
          );
          final loadingProgress = Curves.easeInOut.transform(
            _portion(timeline, 0.12, 1),
          );

          final titleTop = safeArea.top + 28;
          final logoTop =
              math.max(titleTop + 72, size.height * 0.285).toDouble();
          final barBottom = safeArea.bottom + 28;
          final subtitleBottomLimit = size.height - barBottom - 64;
          final preferredLogoSize =
              (size.shortestSide * 0.46).clamp(128.0, 224.0).toDouble();
          final availableLogoSize = math
              .max(112.0, subtitleBottomLimit - logoTop - 44)
              .toDouble();
          final logoSize = math.min(preferredLogoSize, availableLogoSize).toDouble();
          final subtitleTop = logoTop + logoSize + 24;
          final pulse = (math.sin(timeline * math.pi * 6) + 1) / 2;
          final auraScale = 1.01 + (pulse * 0.09);
          final logoOpacity = logoProgress.clamp(0.0, 1.0).toDouble();
          final auraOpacity = logoOpacity * (0.68 + (pulse * 0.18));

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_cyan, _teal, _oceanBlue],
                stops: [0, 0.5, 1],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: titleTop,
                  left: 24,
                  right: 24,
                  child: _AnimatedTitle(progress: timeline),
                ),
                Positioned(
                  top: logoTop - ((logoSize * 0.19) * (1 - logoProgress)),
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Transform.scale(
                      scale: auraScale,
                      child: Opacity(
                        opacity: auraOpacity,
                        child: Container(
                          width: logoSize * 1.38,
                          height: logoSize * 1.38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFA1F4D7).withOpacity(0.52),
                                const Color(0xFF7BE2D3).withOpacity(0.22),
                                Colors.transparent,
                              ],
                              stops: const [0, 0.48, 1],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9AF1DC).withOpacity(0.48),
                                blurRadius: logoSize * 0.42,
                                spreadRadius: logoSize * 0.04,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: logoTop,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: logoOpacity,
                      child: Transform.scale(
                        scale: lerpDouble(0.7, 1.0, logoProgress)!,
                        child: Image.asset(
                          'assets/images/taskora_logo.png',
                          key: const ValueKey('taskora_splash_logo'),
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: subtitleTop + (18 * (1 - subtitleProgress)),
                  left: 24,
                  right: 24,
                  child: Opacity(
                    opacity: subtitleProgress,
                    child: const Text(
                      'STUDY & PRODUCTIVITY',
                      key: ValueKey('taskora_splash_subtitle'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _darkNavy,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.55,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: barBottom,
                  child: Center(
                    child: Opacity(
                      opacity: barOpacity,
                      child: _LoadingBar(progress: loadingProgress),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedTitle extends StatelessWidget {
  const _AnimatedTitle({required this.progress});

  final double progress;

  double _letterProgress(int index) {
    // A 91ms cadence makes each letter visibly complete before the next begins.
    const stagger = 0.019;
    const duration = 0.016;
    final start = index * stagger;
    return ((progress - start) / duration).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    const letters = 'TASKORA';

    return Semantics(
      label: letters,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(letters.length, (index) {
          final letterProgress = Curves.easeOutBack.transform(
            _letterProgress(index),
          );
          final opacity = letterProgress.clamp(0.0, 1.0).toDouble();

          return Transform.translate(
            offset: Offset(0, -16 * (1 - letterProgress)),
            child: Transform.scale(
              scale: lerpDouble(0.78, 1.0, letterProgress)!,
              child: Opacity(
                opacity: opacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.65),
                  child: Text(
                    letters[index],
                    key: ValueKey('taskora_title_letter_$index'),
                    style: GoogleFonts.outfit(
                      color: Color(0xFF1B2B4F),
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.34;

    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: width * progress,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [Color(0xFF79F1D6), Color(0xFF43D1E6), Color(0xFF528AE8)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF83F1DD).withOpacity(0.8),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
