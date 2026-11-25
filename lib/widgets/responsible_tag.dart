import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ResponsibleTag extends StatelessWidget {
  final String penanggungJawab;
  final bool isSmall;

  const ResponsibleTag({
    super.key,
    required this.penanggungJawab,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label = penanggungJawab;

    if (penanggungJawab.contains('Wanita')) {
      bgColor = const Color(0xFFF9EAE1);
      textColor = AppColors.wanita;
    } else if (penanggungJawab.contains('Pria')) {
      bgColor = const Color(0xFFE8F1F5);
      textColor = AppColors.pria;
    } else {
      bgColor = const Color(0xFFEBF5EE);
      textColor = AppColors.keduanya;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmall ? 6 : 8,
            height: isSmall ? 6 : 8,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
