import 'package:flutter/material.dart';
import 'package:bottom_bar_matu/bottom_bar_double_bullet/bottom_bar_double_bullet.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:go_router/go_router.dart';


class WakalaBottomBarWidget extends StatefulWidget {
  @override
  _WakalaBottomBarWidgetState createState() => _WakalaBottomBarWidgetState();
}

class _WakalaBottomBarWidgetState extends State<WakalaBottomBarWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomBarDoubleBullet(
      backgroundColor: Colors.transparent,
      // color: Color(0xFF00A79D),
      color: Colors.orange,
      selectedIndex: _currentIndex,
      items: [
        BottomBarItem(iconData: Icons.mode_of_travel, label: 'Ramani',),
        BottomBarItem(iconData: Icons.work_history, label: 'Miamala'),
        BottomBarItem(iconData: Icons.chat_bubble, label: 'Mawasiliano'),
      ],
      onSelect: (index) {
        setState(() {
          _currentIndex = index;
        });
        final router = GoRouter.of(context);
        if(index == 0)
        {
          router.go('/');
        }
        else if(index == 1)
        {
          router.go('/agent_history');
        }
        else{
          router.go('/agent_communication');
        }
      },
    );
  }
}
