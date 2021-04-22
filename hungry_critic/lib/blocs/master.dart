import 'package:hungry_critic/blocs/account.dart';
import 'package:hungry_critic/blocs/pending_review.dart';
import 'package:hungry_critic/blocs/restaurant.dart';
import 'package:hungry_critic/blocs/review.dart';
import 'package:hungry_critic/blocs/users.dart';

class MasterBloc {
  MasterBloc({
    required this.aBloc,
    required this.rBloc,
    required this.reBloc,
    required this.uBloc,
    required this.pBloc,
  });

  AccountBloc aBloc;

  RestaurantBloc rBloc;

  ReviewBloc reBloc;

  UserBloc uBloc;

  PendingReviewBloc pBloc;
}
