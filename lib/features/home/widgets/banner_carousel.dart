import 'dart:async';

import 'package:flutter/material.dart';

class BannerCarousel extends StatefulWidget {
  final List<String> bannerList;
  final double? height;
  final BorderRadius? borderRadius;
  final bool showIndicator;
  final bool autoScroll;
  final Duration? autoScrollDuration;

  const BannerCarousel({
    super.key,
    required this.bannerList,
    this.height = 200,
    this.borderRadius,
    this.showIndicator = true,
    this.autoScroll = true,
    this.autoScrollDuration = const Duration(seconds: 3),
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  int currentIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    if (widget.autoScroll && widget.bannerList.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(
      widget.autoScrollDuration!,
          (timer) {
        if (currentIndex < widget.bannerList.length - 1) {
          currentIndex++;
        } else {
          currentIndex = 0;
        }
        _pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {});
      },
    );
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _restartAutoScroll() {
    _stopAutoScroll();
    if (widget.autoScroll && widget.bannerList.length > 1) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);

    return GestureDetector(
      onTapDown: (_) => _stopAutoScroll(),
      onTapUp: (_) => _restartAutoScroll(),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // PageView for images
            PageView.builder(
              controller: _pageController,
              itemCount: widget.bannerList.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
                _restartAutoScroll();
              },
              itemBuilder: (_, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = (_pageController.page ?? 0) - index;
                      value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                    }
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: ClipRRect(
                          borderRadius: borderRadius,
                          child: Stack(
                            children: [
                              // Image with loading state
                              Image.network(
                                widget.bannerList[index],
                                width: double.infinity,
                                height: widget.height,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                        color: Color(0xFF0066FF),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Gradient overlay
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: borderRadius,
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.5),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Page number indicator (top right)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${index + 1}/${widget.bannerList.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
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
                );
              },
            ),

            // Dots Indicator
            if (widget.showIndicator && widget.bannerList.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.bannerList.length,
                        (index) => GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: currentIndex == index ? 6 : 4,
                        width: currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: currentIndex == index ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Navigation Arrows (if more than 1 banner)
            if (widget.bannerList.length > 1)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Previous Button
                      AnimatedOpacity(
                        opacity: currentIndex > 0 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: GestureDetector(
                          onTap: currentIndex > 0 ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          } : null,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.black87,
                              size: 24,
                            ),
                          ),
                        ),
                      ),

                      // Next Button
                      AnimatedOpacity(
                        opacity: currentIndex < widget.bannerList.length - 1 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: GestureDetector(
                          onTap: currentIndex < widget.bannerList.length - 1 ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          } : null,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.black87,
                              size: 24,
                            ),
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
    );
  }
}