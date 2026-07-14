import 'package:flutter/material.dart';

import 'onboarding_data.dart';
import 'onboarding_service.dart';

/// A full-screen, multi-chapter onboarding walkthrough.
///
/// Renders as a modal route on top of the current page. The user can:
///   - swipe or use the Next/Previous buttons to move between steps,
///   - jump to any chapter via the chapter strip at the top,
///   - skip the tour entirely (marks it as completed),
///   - replay the tour later from the sidebar.
///
/// The overlay is self-contained — it manages its own PageController and
/// state. The host page just calls `DuniyaOnboardingOverlay.show(context)`.
class DuniyaOnboardingOverlay extends StatefulWidget {
  const DuniyaOnboardingOverlay({super.key, this.startChapterIndex = 0});

  /// Index into [kOnboardingChapters] to start at. Defaults to 0 (the
  /// very first chapter). Use this to deep-link to a specific chapter
  /// when the user taps "Take Tour" from a particular page.
  final int startChapterIndex;

  /// Convenience method — pushes the overlay as a full-screen modal.
  static Future<void> show(BuildContext context, {int startChapterIndex = 0}) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: DuniyaOnboardingOverlay(
              startChapterIndex: startChapterIndex,
            ),
          );
        },
      ),
    );
  }

  @override
  State<DuniyaOnboardingOverlay> createState() =>
      _DuniyaOnboardingOverlayState();
}

class _DuniyaOnboardingOverlayState extends State<DuniyaOnboardingOverlay> {
  late final List<OnboardingPage> _pages;
  late final PageController _pageController;
  late int _currentIndex;
  late final int _startIndex;

  @override
  void initState() {
    super.initState();
    _pages = kOnboardingFlattenedPages();
    // Find the first page of the requested chapter.
    _startIndex = 0;
    if (widget.startChapterIndex > 0 &&
        widget.startChapterIndex < kOnboardingChapters.length) {
      final targetChapterId = kOnboardingChapters[widget.startChapterIndex].id;
      for (var i = 0; i < _pages.length; i++) {
        if (_pages[i].chapter.id == targetChapterId && _pages[i].isDivider) {
          _startIndex = i;
          break;
        }
      }
    }
    _currentIndex = _startIndex;
    _pageController = PageController(initialPage: _startIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index < 0 || index >= _pages.length) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _next() {
    if (_currentIndex < _pages.length - 1) {
      _goToPage(_currentIndex + 1);
    } else {
      _finish();
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      _goToPage(_currentIndex - 1);
    }
  }

  Future<void> _skip() async {
    await OnboardingService.instance.markTourCompleted();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _finish() async {
    await OnboardingService.instance.markTourCompleted();
    // Mark every chapter as seen.
    for (final chapter in kOnboardingChapters) {
      await OnboardingService.instance.markChapterSeen(chapter.id);
    }
    if (mounted) Navigator.of(context).pop();
  }

  /// Jump to the first page (divider) of a chapter by index.
  void _jumpToChapter(int chapterIndex) {
    if (chapterIndex < 0 || chapterIndex >= kOnboardingChapters.length) return;
    final targetId = kOnboardingChapters[chapterIndex].id;
    for (var i = 0; i < _pages.length; i++) {
      if (_pages[i].chapter.id == targetId && _pages[i].isDivider) {
        _goToPage(i);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentIndex];
    final chapter = page.chapter;
    final isLastPage = _currentIndex == _pages.length - 1;
    final progress = (_currentIndex + 1) / _pages.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A0533)
                  : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 48,
                  offset: const Offset(0, 24),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                children: [
                  // ─── Top bar: chapter strip + skip ───
                  _buildChapterStrip(chapter, progress),
                  // ─── Page content ───
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (context, i) {
                        final p = _pages[i];
                        return p.isDivider
                            ? _ChapterDividerPage(chapter: p.chapter)
                            : _StepPage(chapter: p.chapter, step: p.step!);
                      },
                    ),
                  ),
                  // ─── Bottom nav ───
                  _buildBottomNav(isLastPage),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChapterStrip(OnboardingChapter currentChapter, double progress) {
    final currentChapterIndex = kOnboardingChapters.indexOf(currentChapter);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (var i = 0; i < kOnboardingChapters.length; i++)
                  GestureDetector(
                    onTap: () => _jumpToChapter(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: i == currentChapterIndex
                            ? _lerpGradientColor(kOnboardingChapters[i])
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: i == currentChapterIndex
                              ? _lerpGradientColor(kOnboardingChapters[i])
                              : Colors.black.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Text(
                        kOnboardingChapters[i].title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: i == currentChapterIndex
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: i == currentChapterIndex
                              ? Colors.white
                              : Colors.black54,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Skip button
          TextButton(
            onPressed: _skip,
            style: TextButton.styleFrom(
              foregroundColor: Colors.black54,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Skip',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _lerpGradientColor(OnboardingChapter c) {
    return Color.lerp(c.gradient[0], c.gradient[1], 0.5)!;
  }

  Widget _buildBottomNav(bool isLastPage) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Previous
          if (_currentIndex > 0)
            TextButton.icon(
              onPressed: _previous,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black54,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            )
          else
            const SizedBox(width: 80),
          const Spacer(),
          // Page dots
          _buildPageDots(),
          const Spacer(),
          // Next / Finish
          isLastPage
              ? _buildFinishButton()
              : _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton.icon(
      onPressed: _next,
      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
      label: const Text('Next'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9900FF),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildFinishButton() {
    return ElevatedButton.icon(
      onPressed: _finish,
      icon: const Icon(Icons.rocket_launch_rounded, size: 18),
      label: const Text('Get Started'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  /// Compact dot indicator — shows 6 dots (one per chapter), the current
  /// chapter is filled, the rest are outline. This is more readable than
  /// a dot per page when there are 15+ pages.
  Widget _buildPageDots() {
    final currentChapter = _pages[_currentIndex].chapter;
    final currentChapterIndex = kOnboardingChapters.indexOf(currentChapter);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < kOnboardingChapters.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == currentChapterIndex ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == currentChapterIndex
                  ? const Color(0xFF9900FF)
                  : i < currentChapterIndex
                      ? const Color(0xFF9900FF).withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ],
    );
  }
}

/// The divider page shown at the start of each chapter — a big gradient
/// header with the chapter icon, title, and subtitle.
class _ChapterDividerPage extends StatelessWidget {
  const _ChapterDividerPage({required this.chapter});
  final OnboardingChapter chapter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Big gradient icon circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: chapter.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: chapter.gradient[0].withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              chapter.icon,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 28),
          // Chapter number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: chapter.gradient[0].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Chapter ${kOnboardingChapters.indexOf(chapter) + 1} of ${kOnboardingChapters.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: chapter.gradient[0],
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            chapter.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1A0533),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            chapter.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          // "What you'll learn" preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What you\'ll learn',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: chapter.gradient[0],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                ...chapter.steps.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: chapter.gradient[0].withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(s.icon, size: 12, color: chapter.gradient[0]),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.headline,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// A step page — shows the step's icon, headline, body, and bullet list.
class _StepPage extends StatelessWidget {
  const _StepPage({required this.chapter, required this.step});
  final OnboardingChapter chapter;
  final OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon header with gradient
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: chapter.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(step.icon, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: chapter.gradient[0],
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.headline,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF1A0533),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Body
          Text(
            step.body,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 20),
          // Bullets
          ...step.bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : const Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
