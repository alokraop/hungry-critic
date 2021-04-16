import 'package:flutter/material.dart';

import '../shared/colors.dart';
import 'restaurant.dart';

enum Entity { RESTAURANT, USER }

abstract class EntityCreator<T extends StatefulWidget> extends State<T> {
  Future<bool> createEntity();
}

class CreateEntity extends PopupRoute<String> {
  CreateEntity({this.entity, this.restaurant = false});

  final entity;

  final bool restaurant;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.3);

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => 'creation_flap';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return CreationFlap(
      entity: entity,
      animation: animation,
      type: restaurant ? Entity.RESTAURANT : Entity.USER,
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 150);
}

class CreationFlapDelegate extends SingleChildLayoutDelegate {
  CreationFlapDelegate();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0, size.height - childSize.height);
  }

  @override
  bool shouldRelayout(CreationFlapDelegate oldDelegate) => false;
}

class CreationFlap extends StatefulWidget {
  CreationFlap({
    Key? key,
    required this.type,
    required this.animation,
    this.entity,
  }) : super(key: key);

  final dynamic entity;

  final Entity type;

  final Animation<double> animation;

  @override
  _CreationFlapState createState() => _CreationFlapState();
}

class _CreationFlapState extends State<CreationFlap> with TickerProviderStateMixin {
  late ThemeData _theme;

  late AnimationController _flapC;

  Widget? _flapContents;

  final _formKey = GlobalKey<EntityCreator>();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _flapC = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _flapC.addStatusListener(_onChange);
  }

  _onChange(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _flapContents = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dropKeyboard,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomSingleChildLayout(
          delegate: CreationFlapDelegate(),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: SizeTransition(
                axis: Axis.vertical,
                sizeFactor: widget.animation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSFlap(),
                    _buildFlap(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _dropKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Widget _buildFlap() {
    final content = {
      Entity.RESTAURANT: () => RestaurantForm(key: _formKey, restaurant: widget.entity),
    }[widget.type]
        ?.call();
    final flap = Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.only(bottom: 7.5, top: 12.5),
      decoration: BoxDecoration(
        color: greySwatch[50],
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (content != null) content,
            SizedBox(
              height: 40,
              child: FloatingActionButton.extended(
                label: _loading
                    ? SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          backgroundColor: greySwatch[50],
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        widget.entity == null ? 'CREATE' : 'UPDATE',
                        style: _theme.textTheme.bodyText1?.copyWith(
                          color: greySwatch[50],
                        ),
                      ),
                elevation: 2,
                onPressed: _saveEntity,
              ),
            ),
          ],
        ),
      ),
    );
    return Stack(
      alignment: Alignment.topRight,
      children: [
        flap,
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7.5),
            child: Icon(
              Icons.clear,
              size: 27.5,
              color: greySwatch[800],
            ),
          ),
        ),
      ],
    );
  }

  _buildSFlap() {
    return SizeTransition(
      sizeFactor: _flapC,
      axisAlignment: 1.0,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: greySwatch[700],
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: greySwatch.withOpacity(0.2),
              offset: Offset(-1, -2),
              blurRadius: 0.2,
              spreadRadius: 0.2,
            ),
          ],
        ),
        child: _flapContents,
      ),
    );
  }

  _updateFlap(Widget? contents) {
    if (contents != null) {
      _flapContents = contents;
      _flapC.forward();
      setState(() {});
    } else {
      if (_flapContents != null) {
        _flapC.reverse();
      }
    }
  }

  _saveEntity() async {
    setState(() => _loading = true);
    final success = await _formKey.currentState?.createEntity() ?? false;
    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() => _loading = false);
    }
  }
}
