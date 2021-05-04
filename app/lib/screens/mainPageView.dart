import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/logic/databaseBloc.dart';
import 'homeScreen.dart';
import 'searchScreen.dart';
import 'addScreen.dart';
import 'activityScreen.dart';
import 'profileScreen.dart';

class MainPageView extends StatefulWidget {

  final DatabaseBloc databaseBloc;
  
  MainPageView({@required this.databaseBloc});

  @override
  _MainPageViewState createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {

  PageController pageController = PageController();
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          HomeScreen(databaseBloc: widget.databaseBloc),
          SearchScreen(databaseBloc: widget.databaseBloc),
          AddScreen(databaseBloc: widget.databaseBloc),
          ActivityScreen(databaseBloc: widget.databaseBloc),
          ProfileScreen(databaseBloc: widget.databaseBloc),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        activeColor: Theme.of(context).primaryColor,
        onTap: (tappedIndex) {
          setState(() {
            pageIndex = tappedIndex;
          });
          pageController.animateToPage(
            pageIndex,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded)),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded)),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline_outlined)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }
}
