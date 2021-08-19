import 'dart:io' show File, Platform;
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:yellow_movies/AddOrEditPage.dart';
import 'package:yellow_movies/SignUp.dart';
import 'package:yellow_movies/google_sign_in_provider.dart';
import 'DataBaseFunctions/AllFunctions.dart';
import 'OfflinePage.dart';
import 'component/SwipeAbleList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> showAbleList = [];

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
        elevation: 20,
        title: Text('Yellow Movies'),
        actions: [
          TextButton(
            onPressed: () async {
              callDummy(doNotDelete: true);
            },
            child: Text(
              'Add Dummy',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              var databasesPath = await getDatabasesPath();
              String path = join(databasesPath, 'demo.db');
              await deleteDatabase(path);
              showAbleList = [];
              setState(() {});
            },
            child: Text(
              'Delete all',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              showAbleList.isEmpty
                  ? SizedBox()
                  : Container(
                      height: 40,
                      color: Colors.white,
                      child:
                          Center(child: Text('Swipe on list for more options')),
                    ),
              ...showAbleList,
            ],
          ),
          Center(
            child: top,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (Platform.isAndroid && FirebaseAuth.instance.currentUser == null) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SignUp()));
          } else {
            final moviesTable = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddOrEditPage(
                  adding: true,
                ),
              ),
            );
            if (moviesTable != null) {
              setState(() {
                showAbleList = getList(moviesTable);
              });
            }
          }
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void initState() {
    super.initState();
    initAll();
  }

  Future<void> initAll() async {
    setState(() {
      top = fadingCircle;
    });
    if (await hasNetwork()) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      bool? firstRun = pref.getBool('firstRun');
      if (firstRun == null) {
        firstRun = true;
        pref.setBool('firstRun', false);
        callDummy(doNotDelete: false);
      } else {
        AllFunctions allFunctions = AllFunctions();
        final moviesList = await allFunctions.getDb();
        showAbleList = getList(moviesList);
      }
    } else {
      Navigator.pushReplacement(
        this.context,
        MaterialPageRoute(
          builder: (context) => OfflinePage(),
        ),
      );
    }
    setState(() {
      top = null;
    });
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  List<Widget> getList(moviesList) {
    List<Widget> list = [];
    for (int i = 0; i < moviesList.length; i++) {
      print(moviesList[i]['movie_name']);
      bool _validURL = moviesList[i]['link'] == null
          ? false
          : Uri.parse(moviesList[i]['link']).isAbsolute;
      list.add(
        SwipeAbleList(
          onDelete: () async {
            AllFunctions allFunctions = AllFunctions();
            final moviesListAfterDelete =
                await allFunctions.deleteItem(id: moviesList[i]['id']);
            showAbleList = getList(moviesListAfterDelete);
            setState(() {});
          },
          onEdit: () async {
            final moviesTable = await Navigator.push(
              this.context,
              MaterialPageRoute(
                builder: (context) => AddOrEditPage(
                  adding: false,
                  map: moviesList[i],
                  uri: moviesList[i]['link'],
                  director: moviesList[i]['director_name'],
                  movieName: moviesList[i]['movie_name'],
                ),
              ),
            );
            if (moviesTable != null) {
              setState(() {
                showAbleList = getList(moviesTable);
              });
            }
          },
          title: moviesList[i]['movie_name'],
          subtitle: moviesList[i]['director_name'],
          uri: moviesList[i]['link'],
          children: <Widget>[
            _validURL
                ? Image.network(
                    moviesList[i]['link'],
                  )
                : Image.file(File(moviesList[i]['link'])),
          ],
        ),
      );
    }
    return list;
  }

  void callDummy({doNotDelete}) async {
    AllFunctions allFunctions = AllFunctions();
    showAbleList = allFunctions.getShimmer();
    setState(() {});
    await allFunctions.addDummyRows(doNotDelete: doNotDelete);
    final moviesList = await allFunctions.getDb();
    showAbleList = getList(moviesList);
    setState(() {});
  }
}
