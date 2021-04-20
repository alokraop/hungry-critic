import 'package:flutter/widgets.dart';
import 'package:hungry_critic/blocs/pending_review.dart';
import 'package:hungry_critic/blocs/review.dart';
import 'package:hungry_critic/blocs/users.dart';

import '../blocs/account.dart';
import '../blocs/restaurant.dart';

class BlocsContainer extends InheritedWidget {
  final AccountBloc aBloc;
  final RestaurantBloc rBloc;
  final ReviewBloc reBloc;
  final PendingReviewBloc pBloc;
  final UserBloc uBloc;
  final Widget child;

  BlocsContainer({
    Key? key,
    required this.aBloc,
    required this.rBloc,
    required this.uBloc,
    required this.reBloc,
    required this.pBloc,
    required this.child,
  }) : super(key: key, child: child);

  static BlocsContainer of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BlocsContainer>()!;
  }

  @override
  bool updateShouldNotify(BlocsContainer oldWidget) => false;
}
