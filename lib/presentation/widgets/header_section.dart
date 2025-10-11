import 'package:flutter/material.dart';
import 'package:flutter_application_capstone/core/widgets/app_text.dart';
import 'package:flutter_application_capstone/core/widgets/app_colors.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('lib/assets/images/user_avatar.png'),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            AppText(
              "Danu Firda",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            AppText(
              "User Application",
              style: TextStyle(fontSize: 14, color: AppColors.greyPrimary),
            ),
          ],
        ),
      ],
    );
  }
}
