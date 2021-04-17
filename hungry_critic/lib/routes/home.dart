import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../blocs/account.dart';
import '../flaps/creation_flap.dart';
import '../models/account.dart';
import '../models/restaurant.dart';
import '../shared/colors.dart';
import 'profile.dart';
import 'restaurants/restaurant_list.dart';
import 'users/users_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.bloc,
    required this.onLogout,
  }) : super(key: key);

  final AccountBloc bloc;

  final Function() onLogout;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ThemeData _theme;

  int _selectedIndex = 0;

  final _pageC = PageController(initialPage: 0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: StreamBuilder(
        stream: widget.bloc.accountStream,
        initialData: widget.bloc.account,
        builder: (BuildContext context, AsyncSnapshot<Account> snap) {
          final data = snap.data;
          if (data == null) return Container();
          return Scaffold(
            backgroundColor: Color(0xffe8e8e8),
            body: _buildPages(data.role),
            bottomNavigationBar: BottomNavigationBar(
              items: _populateItems(data.role),
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() => _selectedIndex = index);
                _pageC.animateToPage(
                  _selectedIndex,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
            floatingActionButton: _findButton(data.role),
          );
        },
      ),
    );
  }

  _buildPages(UserRole role) {
    return PageView(
      controller: _pageC,
      onPageChanged: (index) => setState(() => _selectedIndex = index),
      children: _populatePages(role),
    );
  }

  List<Widget> _populatePages(UserRole role) {
    final showUsers = role == UserRole.ADMIN;
    return [
      RestaurantList(onUpdate: _createRestaurant),
      if (showUsers) UsersList(onUpdate: _openUser),
      ProfilePage(onLogout: widget.onLogout),
    ];
  }

  List<BottomNavigationBarItem> _populateItems(UserRole role) {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.restaurant),
        label: 'Restaurants',
      ),
      if (role == UserRole.ADMIN)
        BottomNavigationBarItem(
          icon: Icon(Icons.supervised_user_circle),
          label: 'Users',
        ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Me',
      ),
    ];
  }

  _findButton(UserRole role) {
    if (role == UserRole.CUSTOMER) return null;
    if(_selectedIndex != 0) return null;
    return _buildButton('RESTAURANT', Icons.add, () => _createRestaurant());
  }

  _buildButton(String label, IconData icon, Function()? onTap) {
    final tag = ValueKey(label);
    return FloatingActionButton.extended(
      key: tag,
      heroTag: tag,
      onPressed: onTap,
      label: Text(
        label,
        style: _theme.textTheme.bodyText2?.copyWith(
          color: greySwatch[50],
        ),
      ),
      icon: Icon(icon, color: greySwatch[50]),
      elevation: 4,
    );
  }

  _createRestaurant([Restaurant? restaurant]) {
    Navigator.of(context).push(CreateEntity(restaurant: true, entity: restaurant));
  }

  _openUser([Account? account]) {
    Navigator.of(context).push(
      CreateEntity(restaurant: false, entity: account),
    );
  }
}
