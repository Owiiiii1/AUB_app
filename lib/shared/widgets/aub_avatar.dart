import 'package:flutter/material.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/core/media/authenticated_image.dart';
import 'package:aub/core/media/authenticated_media_url.dart';

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
    final initialsText = Text(
      initials,
      style: AubText.labelMd.copyWith(
        fontFamily: AubFonts.display,
        fontSize: size * 0.34,
        color: AubColors.navy,
      ),
    );
    final placeholder = CircleAvatar(
      radius: size / 2,
      backgroundColor: AubColors.surfaceSubtle,
      child: initialsText,
    );
    final avatar = isAuthenticatedMediaUrl(photoUrl)
        ? SizedBox(
            width: size,
            height: size,
            child: ClipOval(
              child: AuthenticatedImage(
                url: photoUrl!,
                placeholder: placeholder,
              ),
            ),
          )
        : placeholder;

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
