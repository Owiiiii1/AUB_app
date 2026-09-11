import 'package:flutter/material.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/core/media/safe_https_url.dart';

class AubAvatar extends StatelessWidget {
  const AubAvatar({
    super.key,
    required this.size,
    this.photoUrl,
    this.name,
    this.showActiveDot = false,
  });

  final double size;
  final String? photoUrl;
  final String? name;
  final bool showActiveDot;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    final avatar = CircleAvatar(
      radius: size / 2,
      backgroundColor: AubColors.surfaceSubtle,
      backgroundImage: isSafeHttpsUrl(photoUrl) ? NetworkImage(photoUrl!) : null,
      onBackgroundImageError: isSafeHttpsUrl(photoUrl) ? (_, _) {} : null,
      child: isSafeHttpsUrl(photoUrl)
          ? null
          : Text(
              initials,
              style: AubText.labelMd.copyWith(
                fontFamily: AubFonts.display,
                fontSize: size * 0.34,
                color: AubColors.navy,
              ),
            ),
    );

    if (!showActiveDot) {
      return avatar;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: AubColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AubColors.surfaceIvory, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String? value) {
    final parts = (value ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'A';
    }
    String first(String value) => value.substring(0, 1).toUpperCase();
    if (parts.length == 1) {
      return first(parts.first);
    }
    return '${first(parts.first)}${first(parts.last)}';
  }
}
