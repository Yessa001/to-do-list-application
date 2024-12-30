import 'package:flutter/material.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavigationBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box),
          label: 'Add Task',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      selectedItemColor: Colors.indigo[900],
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(
        fontSize: 12.0,
        color: Colors.indigo[900],
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11.0,
        color: Colors.grey,
      ),
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      iconSize: 25.0,
    );
  }
}