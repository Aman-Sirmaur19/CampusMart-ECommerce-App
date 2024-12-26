import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helper/constants.dart';
import 'my_store.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  late List<Map<String, dynamic>> _pages;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = [
      {
        'page': const MyStore(itemType: ItemType.sale),
      },
      {
        'page': const MyStore(itemType: ItemType.rental),
      },
      {
        'page': const MyStore(itemType: ItemType.lost),
      },
    ];
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedPageIndex,
        type: BottomNavigationBarType.shifting,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            backgroundColor: Colors.black87,
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined),
            backgroundColor: Colors.black87,
            label: 'Rentals',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search_circle),
            backgroundColor: Colors.black87,
            label: 'Lost Items',
          ),
        ],
      ),
    );
  }
}
