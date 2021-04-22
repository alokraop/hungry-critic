import 'package:flutter/widgets.dart';
import '../blocs/master.dart';

class BlocsContainer extends InheritedWidget {
  final MasterBloc blocs;

  BlocsContainer({
    Key? key,
    required this.blocs,
    required Widget child,
  }) : super(key: key, child: child);

  static MasterBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BlocsContainer>()!.blocs;
  }

  @override
  bool updateShouldNotify(BlocsContainer oldWidget) => false;
}
