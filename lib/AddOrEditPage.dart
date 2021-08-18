import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yellow_movies/DataBaseFunctions/AllFunctions.dart';
import 'package:yellow_movies/authentication_service.dart';

class AddOrEditPage extends StatefulWidget {
  final adding;
  final uri;
  final movieName;
  final director;
  final map;

  AddOrEditPage({
    @required this.adding,
    this.uri,
    this.movieName,
    this.director,
    this.map,
  });

  @override
  _AddOrEditPageState createState() => _AddOrEditPageState();
}

class _AddOrEditPageState extends State<AddOrEditPage> {
  final picker = ImagePicker();
  TextEditingController movieNameCon = TextEditingController();
  TextEditingController directorCon = TextEditingController();
  bool movieError = false;
  bool directorError = false;
  var src;
  var link;
  bool validLink = false;

  @override
  void initState() {
    super.initState();
    movieNameCon.text = widget.movieName == null ? '' : widget.movieName;
    directorCon.text = widget.director == null ? '' : widget.director;
    link = widget.uri;
    bool _validURL = link == null ? false : Uri.parse(link).isAbsolute;
    validLink = _validURL;
  }

  var top;

  final fadingCircle = SpinKitFadingCircle(
    itemBuilder: (BuildContext context, int index) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: index.isEven ? Colors.blue : Colors.blue,
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.adding ? 'Add' : 'Edit Info'),
        actions: widget.adding? [
          TextButton(
            onPressed: () async {
              AuthenticationService authService =
                  AuthenticationService(FirebaseAuth.instance);
              setState(() {
                top = fadingCircle;
              });
              await authService.signOut();
              Navigator.pop(context);
              setState(() {
                top = null;
              });
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ]:[],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  getImage();
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Center(
                    child: link == null
                        ? Icon(
                            Icons.add_a_photo,
                            size: 40,
                          )
                        : validLink
                            ? Image.network(link)
                            : Image.file(File(link)),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: movieNameCon,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            errorText: movieError ? 'Field required' : null,
                            filled: true,
                            prefixIcon: Icon(
                              Icons.movie,
                              color: Colors.blue,
                            ),
                            hintText: 'Title Of Movie',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: directorCon,
                          decoration: InputDecoration(
                            errorText: directorError ? 'Field required' : null,
                            fillColor: Colors.white,
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.blue,
                            ),
                            filled: true,
                            hintText: 'Directed by',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          print('pressed');
                          if (movieNameCon.text.isEmpty) {
                            setState(() {
                              movieError = true;
                            });
                            return;
                          } else {
                            movieError = false;
                          }
                          if (directorCon.text.isEmpty) {
                            directorError = true;
                            setState(() {
                              directorError = true;
                            });
                            return;
                          } else {
                            directorError = false;
                          }
                          AllFunctions allFunctions = AllFunctions();
                          if (widget.adding) {
                            print('Adding');
                            final moviesTable = await allFunctions.addItem(
                              director: directorCon.text,
                              link: link,
                              name: movieNameCon.text,
                            );
                            Navigator.pop(context, moviesTable);
                            return;
                          } else {
                            print('Edit');
                            final moviesTable = await allFunctions.updateItem(
                              id: widget.map['id'],
                              name: movieNameCon.text,
                              director: directorCon.text,
                              link: link,
                            );
                            Navigator.pop(context, moviesTable);
                            return;
                          }
                        },
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              widget.adding ? 'ADD' : 'EDIT',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: top,
          ),
        ],
      ),
    );
  }

  Future getImage() async {
    // ignore: deprecated_member_use
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        src = pickedFile.path;
        link = pickedFile.path;
        bool _validURL = Uri.parse(link).isAbsolute;
        validLink = _validURL;
        setState(() {});
      } else {
        print('No image selected.');
      }
    });
  }
}
