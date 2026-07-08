import 'package:flutter/material.dart';
import 'package:isanzure_mobile/views/home/widgets/home_header.dart';
import 'package:isanzure_mobile/views/home/widgets/popular_trips.dart';
import 'package:isanzure_mobile/views/home/widgets/search_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  late final AnimationController _mountCtrl;

  double _headerParallax = 0;
  double _headerOpacity = 1;

  late final Animation<double> _searchFade;
  late final Animation<Offset> _searchSlide;
  late final Animation<double> _tripsFade;
  late final Animation<Offset> _tripsSlide;

  @override
  void initState() {
    super.initState();

    _mountCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _searchFade = CurvedAnimation(
      parent: _mountCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _searchSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mountCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    ));

    _tripsFade = CurvedAnimation(
      parent: _mountCtrl,
      curve: const Interval(0.3, 0.85, curve: Curves.easeOut),
    );
    _tripsSlide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mountCtrl,
      curve: const Interval(0.3, 0.85, curve: Curves.easeOut),
    ));

    _scrollCtrl.addListener(_onScroll);
    _mountCtrl.forward();
  }

  void _onScroll() {
    final offset = _scrollCtrl.offset;
    final parallax = (offset / 180).clamp(0.0, 1.0);
    final opacity = (1.0 - offset / 120).clamp(0.0, 1.0);
    if (parallax != _headerParallax || opacity != _headerOpacity) {
      setState(() {
        _headerParallax = parallax;
        _headerOpacity = opacity;
      });
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _mountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            HomeHeader(
              parallax: _headerParallax,
              contentOpacity: _headerOpacity,
            ),

            // ── Overlapping content via Transform (visual only, no layout hack) ──
            Transform.translate(
              offset: const Offset(0, -100),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _searchFade,
                      child: SlideTransition(
                        position: _searchSlide,
                        child: const SearchCard(),
                      ),
                    ),

                    const SizedBox(height: 28),

                    FadeTransition(
                      opacity: _tripsFade,
                      child: SlideTransition(
                        position: _tripsSlide,
                        child: const PopularTrips(),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Compensate for the -100 translate gap at the bottom
            const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}
