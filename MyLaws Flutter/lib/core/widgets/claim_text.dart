import 'package:flutter/material.dart';
import '../../domain/models/claim.dart';
import '../theme/app_colors.dart';
import 'source_chip.dart';

class ClaimText extends StatelessWidget {
  final List<Claim> claims;
  final bool isBangla;

  const ClaimText({
    super.key,
    required this.claims,
    required this.isBangla,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: claims.map((claim) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                claim.text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(width: 4),
              ...claim.sourceIds.map(
                (id) => SourceChip(
                  sourceId: id,
                  isBangla: isBangla,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
