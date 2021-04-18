import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/account.dart';
import '../../shared/colors.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    Key? key,
    required this.user,
    this.onUpdate,
    this.onBlock,
    this.onDelete,
  }) : super(key: key);

  final User user;

  final Function(User)? onUpdate;

  final Function(User)? onBlock;

  final Function(User)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 12.5, right: 12.5, bottom: 20),
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: greySwatch[50],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: greySwatch[800].withOpacity(0.4),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);
    final method = describeEnum(user.settings.method).toLowerCase();
    return Column(
      children: [
        SizedBox(height: 12.5),
        Row(
          children: [
            Image.asset(
              'assets/images/methods/$method.png',
              width: 30,
            ),
            SizedBox(width: 7.5),
            Text(user.name ?? '', style: theme.textTheme.subtitle1),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 62.5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: swatch, width: 1),
                        color: swatch),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    alignment: Alignment.center,
                    child: Text(
                      describeEnum(user.role),
                      style: theme.textTheme.caption?.copyWith(
                        color: greySwatch[50],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 7.5, right: 7.5, top: 5),
          child: Divider(thickness: 1),
        ),
        _buildActions(context),
      ],
    );
  }

  _buildActions(BuildContext context) {
    return Row(
      children: [
        _buildUpdate(context),
        _buildBlock(context),
        _buildDelete(context),
      ],
    );
  }

  _buildUpdate(BuildContext context) {
    return _buildSection(context, 'EDIT', Icons.edit, () => onUpdate?.call(user));
  }

  _buildBlock(BuildContext context) {
    final label = user.settings.blocked ? 'UNBLOCK' : 'BLOCK';
    final icon = user.settings.blocked ? Icons.bolt : Icons.block;
    return _buildSection(context, label, icon, () => onBlock?.call(user));
  }

  _buildDelete(BuildContext context) {
    return _buildSection(context, 'DELETE', Icons.delete, () => onUpdate?.call(user));
  }

  _buildSection(
    BuildContext context,
    String label,
    IconData icon,
    Function() onTap,
  ) {
    final theme = Theme.of(context);
    return Flexible(
      fit: FlexFit.tight,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 12.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: swatch, size: 20),
              SizedBox(width: 5),
              Text(
                label,
                style: theme.textTheme.bodyText2?.copyWith(color: swatch),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
