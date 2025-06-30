import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AnimatedSliderItem extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String logoUrl;
  final String genre;
  final String language;

  const AnimatedSliderItem(
      {required this.imageUrl,
      required this.title,
      required this.logoUrl,
      required this.genre,
      required this.language});

  @override
  State<AnimatedSliderItem> createState() => AnimatedSliderItemState();
}

class AnimatedSliderItemState extends State<AnimatedSliderItem>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<Offset> _logoOffset;
  late AnimationController _genreController;
  late Animation<Offset> _genreOffset;
  late AnimationController _langController;
  late Animation<Offset> _langOffset;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoOffset = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Right to left
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _genreController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _genreOffset = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _genreController, curve: Curves.easeOut));

    _langController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _langOffset = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _langController, curve: Curves.easeOut));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _genreController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _langController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _genreController.dispose();
    _langController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle onTap logic here
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: [0.7, 1.0], // Adjust where the fade starts
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  placeholder: (_, __) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.grey[300]),
                  ),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.error, size: 50),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned(
                bottom: 25,
                left: 50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SlideTransition(
                      position: _logoOffset,
                      child: widget.logoUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.logoUrl,
                              height: 40,
                              placeholder: (_, __) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 100,
                                  height: 40,
                                  //color: Colors.grey[300],
                                ),
                              ),
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.error, color: Colors.white),
                            )
                          : const SizedBox(),
                    ),
                    const SizedBox(height: 8),
                    SlideTransition(
                      position: _genreOffset,
                      child: Row(
                        children: [
                          Text(
                            widget.genre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                )
                              ],
                            ),
                          ),
                          const Text(
                            " | ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                )
                              ],
                            ),
                          ),
                          Text(
                            widget.language,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
