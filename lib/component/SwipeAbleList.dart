import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yellow_movies/component/ExpandListView.dart';

class SwipeAbleList extends StatelessWidget {
  final title;
  final subtitle;
  final uri;
  final children;
  final onDelete;
  final onEdit;

  SwipeAbleList({
    this.title = 'Movie title',
    this.subtitle = 'subtitle',
    this.uri,
    this.children,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    bool _validURL = uri == null ? false : Uri.parse(uri).isAbsolute;
    return Material(
      elevation: 10,
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: ExpandListView(
          title: title,
          subtitle: subtitle,
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            child: _validURL
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(uri),
                        fit: BoxFit.fill,
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: FileImage(File(uri)),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
          ),
          children: children == null ? <Widget>[] : children,
        ),
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Edit',
            color: Colors.blue,
            icon: Icons.edit,
            onTap: onEdit,
          ),
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}
