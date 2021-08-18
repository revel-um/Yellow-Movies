import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color teal = Color(0xFF3CD1BB);

class ExpandListView extends StatelessWidget {
  final collapsedColor;
  final expandedColor;
  final children;
  final title;
  final iconColor;
  final leading;
  final trailing;
  final outerPadding;
  final initiallyExpanded;
  final subtitle;

  ExpandListView({
    this.collapsedColor = Colors.white,
    this.title = 'Title',
    this.expandedColor = Colors.white,
    @required this.children,
    this.iconColor = Colors.black,
    this.leading,
    this.trailing,
    this.outerPadding = 8.0,
    this.initiallyExpanded = false,
    this.subtitle = 'Subtitle',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          maintainState: false,
          initiallyExpanded: initiallyExpanded,
          iconColor: iconColor,
          backgroundColor: expandedColor,
          collapsedBackgroundColor: collapsedColor,
          title: Text(title == null ? 'title' : title),
          subtitle: Text(subtitle == null ? 'subtitle' : subtitle),
          leading: leading,
          trailing: trailing,
          children: children,
        ),
      ],
    );
  }
}
