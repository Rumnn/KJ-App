import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../appTheme.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _ctrl = PageController();
  int _page = 0;
  final List<_OnboardPage> _pages = const [
    _OnboardPage(icon: '漢', title: 'Master Kanji', subtitle: 'Learn All 2,136 JLPT Kanji\nFrom N5 To N1, Step By Step!', color: AppTheme.accent),
    _OnboardPage(icon: '字', title: 'JLPT Ready', subtitle: 'Kanji Organized By JLPT Level!\nTrack Your Progress At Each Stage!', color: AppTheme.accent),
    _OnboardPage(icon: '覚', title: 'Quiz & Flashcards', subtitle: 'Reinforce Memory With Spaced\nRepetition & Adaptive Quizzes!', color: AppTheme.accent),
    _OnboardPage(icon: '書', title: 'Write & Practice', subtitle: 'Practice Writing Strokes & Get\nInstant AI Handwriting Feedback!', color: AppTheme.accent),
  ];
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (mounted) context.go('/auth/login');
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        PageView.builder(
          controller: _ctrl,
          onPageChanged: (i) => setState(() => _page = i),
          itemCount: _pages.length,
          itemBuilder: (_, i) => _OnboardPageView(page: _pages[i]),
        ),
        Positioned(
          top: 56,
          right: 20,
          child: TextButton(
            onPressed: _finish,
            child: const Text('Skip', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ),
        ),
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Column(
            children: [
              SmoothPageIndicator(
                controller: _ctrl,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                  activeDotColor: _pages[_page].color,
                  dotColor: AppTheme.border,
                  spacing: 6,
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _page == _pages.length - 1
                  ? ElevatedButton(
                    onPressed: _finish,
                    child: const Text('Get Started'),
                  )
                  : ElevatedButton(
                    onPressed: () => _ctrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                    child: const Text('Next'),
                  ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
class _OnboardPage {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  const _OnboardPage({required this.icon, required this.title, required this.subtitle, required this.color});
}
class _OnboardPageView extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardPageView({required this.page});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppTheme.background, page.color.withValues(alpha: 0.08)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [page.color.withValues(alpha: 0.25), Colors.transparent]),
              border: Border.all(color: page.color.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: Text(page.icon, style: TextStyle(fontSize: 64, color: page.color)),
            ),
          ),
          const SizedBox(height: 40),
          Text(page.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
        ],
      ),
    ),
  );
}