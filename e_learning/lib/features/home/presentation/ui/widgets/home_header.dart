import 'package:e_learning/core/colors/colors.dart';
import 'package:e_learning/core/widgets/common/user_avatar.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notification_state.dart';
import 'package:e_learning/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:e_learning/features/shell/presenation/cubit/nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const c = MyColors();
    final width = MediaQuery.sizeOf(context).width;

    final name = context.select<ProfileCubit, String>(
          (cubit) => cubit.state.user?.name ?? '',
    );

    final logoSize = width < 600 ? 34.0 : 36.0;
    final avatarSize = width < 600 ? 36.0 : 38.0;
    final titleSize = width < 600 ? 17.0 : 18.0;

    return Row(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            gradient: c.heroGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.swap_horiz_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'SkillSwap',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
        const Spacer(),
        BlocBuilder<NotificationCubit, NotificationState>(
          buildWhen: (previous, current) =>
          previous.unreadCount != current.unreadCount,
          builder: (context, state) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/notifications'),
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: c.textPrimary,
                  ),
                ),
                if (state.unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: c.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        state.unreadCount > 9
                            ? '9+'
                            : '${state.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => context.read<NavCubit>().select(4),
          child: UserAvatar(
            name: name,
            size: avatarSize,
          ),
        ),
      ],
    );
  }
}