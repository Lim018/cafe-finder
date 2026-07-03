import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Bintang rating read-only.
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool showValue;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.showValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final filled = i < rating.floor();
          final half = !filled && i < rating && (rating - rating.floor()) >= 0.3;
          return Icon(
            half ? Icons.star_half_rounded : (filled ? Icons.star_rounded : Icons.star_border_rounded),
            color: AppTheme.starColor,
            size: size,
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.9,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ]
      ],
    );
  }
}

/// Bintang rating interaktif — tap untuk pilih rating.
class InteractiveRatingStars extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int> onRatingChanged;
  final double size;

  const InteractiveRatingStars({
    super.key,
    this.initialRating = 5,
    required this.onRatingChanged,
    this.size = 40,
  });

  @override
  State<InteractiveRatingStars> createState() =>
      _InteractiveRatingStarsState();
}

class _InteractiveRatingStarsState extends State<InteractiveRatingStars> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final selected = i < _rating;
        return GestureDetector(
          onTap: () {
            setState(() => _rating = i + 1);
            widget.onRatingChanged(i + 1);
          },
          child: AnimatedScale(
            scale: selected ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                selected ? Icons.star_rounded : Icons.star_border_rounded,
                color: AppTheme.starColor,
                size: widget.size,
              ),
            ),
          ),
        );
      }),
    );
  }
}
