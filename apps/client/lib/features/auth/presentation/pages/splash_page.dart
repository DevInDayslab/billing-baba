import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _loadingAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _loadingAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final isDesktop = w >= 900;
            final isTablet = w >= 600 && w < 900;

            final logoSize = isDesktop ? 250.0 : isTablet ? 190.0 : 140.0;
            final welcomeFontSize =
                isDesktop ? 42.0 : isTablet ? 36.0 : 28.0;
            final brandFontSize =
                isDesktop ? 48.0 : isTablet ? 40.0 : 32.0;
            final taglineFontSize =
                isDesktop ? 18.0 : isTablet ? 16.0 : 14.0;
            final loadingBarWidth =
                isDesktop ? 320.0 : isTablet ? 260.0 : 200.0;
            final contentWidth =
                isDesktop ? 560.0 : isTablet ? 480.0 : double.infinity;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? AppSpacing.xxl : AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(height: isDesktop ? AppSpacing.xxl : AppSpacing.xl),

                      // Welcome to Billing Baba
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: Column(
                            children: [
                              Text(
                                'Welcome to',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: welcomeFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.3,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'Billing Baba',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: brandFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isDesktop ? AppSpacing.lg : AppSpacing.md),

                      // Tagline
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Text(
                          'Your silent partner in\nprofessional retail management',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: taglineFontSize,
                            color: AppColors.textSecondary,
                            height: 1.6,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),

                      SizedBox(height: isDesktop ? 56.0 : AppSpacing.xxl),

                      // Loading bar
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: SizedBox(
                            width: loadingBarWidth,
                            height: isDesktop ? 5.0 : 4.0,
                            child: AnimatedBuilder(
                              animation: _loadingAnim,
                              builder: (context, _) => LinearProgressIndicator(
                                value: _loadingAnim.value,
                                backgroundColor: Colors.grey.shade200,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
