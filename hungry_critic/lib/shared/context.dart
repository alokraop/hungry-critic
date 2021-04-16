import 'package:flutter/widgets.dart';

import '../blocs/account.dart';
import '../blocs/restaurant.dart';

class BlocsContainer extends InheritedWidget {
  final AccountBloc aBloc;
  final RestaurantBloc rBloc;
  final Widget child;

  BlocsContainer({
    Key? key,
    required this.aBloc,
    required this.rBloc,
    required this.child,
  }) : super(key: key, child: child);

  static BlocsContainer of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BlocsContainer>()!;
  }

  @override
  bool updateShouldNotify(BlocsContainer oldWidget) => false;
}
