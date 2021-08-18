import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AllFunctions {
  Future<void> addDummyRows({@required doNotDelete}) async {
    final movies = [
      'Iron Man',
      'Iron Man 2',
      'Iron Man 3',
      'Thor',
      'Thor: The Dark World',
      'Thor: Ragnarok',
    ];
    final directors = [
      'Jon Favreau',
      'Jon Favreau',
      'Shane Black',
      'Kenneth Branagh',
      'Alan Taylor',
      'Taika Waititi'
    ];
    final url = [
      'https://upload.wikimedia.org/wikipedia/en/0/02/Iron_Man_%282008_film%29_poster.jpg',
      'https://upload.wikimedia.org/wikipedia/en/e/ed/Iron_Man_2_poster.jpg',
      'https://upload.wikimedia.org/wikipedia/en/1/19/Iron_Man_3_poster.jpg',
      'https://upload.wikimedia.org/wikipedia/en/9/95/Thor_%28film%29_poster.jpg',
      'https://upload.wikimedia.org/wikipedia/en/7/7f/Thor_The_Dark_World_poster.jpg',
      'https://upload.wikimedia.org/wikipedia/en/7/7d/Thor_Ragnarok_poster.jpg'
    ];
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');
    if (!doNotDelete) {
      await deleteDatabase(path);
    }
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE Movies (id INTEGER PRIMARY KEY, movie_name TEXT, director_name TEXT, link STRING)');
    });
    await database.transaction((txn) async {
      for (int i = 0; i < 6; i++) {
        await txn.rawInsert(
            'INSERT INTO Movies(movie_name, director_name, link) VALUES(?, ?, ?)',
            [movies[i], directors[i], url[i]]);
      }
    });
  }

  Future<List<Map>> addItem(
      {@required name, @required director, @required link}) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE Movies (id INTEGER PRIMARY KEY, movie_name TEXT, director_name TEXT, link STRING)');
    });
    await database.transaction((txn) async {
      int count = await txn.rawInsert(
          'INSERT INTO Movies(movie_name, director_name, link) VALUES(?, ?, ?)',
          [
            name,
            director,
            link == null
                ? 'https://www.fostercity.org/sites/default/files/styles/gallery500/public/imageattachments/parksrec/page/10791/thursday_movie.png?itok=XakMswGX'
                : link
          ]);
      print(count);
    });
    List<Map> moviesTable = await database.rawQuery('SELECT * FROM Movies');
    print(moviesTable);
    return moviesTable;
  }

  Future<List<Map>> getDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE Movies (id INTEGER PRIMARY KEY, movie_name TEXT, director_name TEXT, link STRING)');
    });
    List<Map> moviesTable = await database.rawQuery('SELECT * FROM Movies');
    return moviesTable;
  }

  Future<List<Map>> deleteItem({@required id}) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE Movies (id INTEGER PRIMARY KEY, movie_name TEXT, director_name TEXT, link STRING)');
    });

    await database.rawDelete('DELETE FROM Movies WHERE id = ?', [id]);

    List<Map> moviesTable = await database.rawQuery('SELECT * FROM Movies');
    return moviesTable;
  }

  Future<List<Map>> updateItem(
      {@required id,
      @required name,
      @required director,
      @required link}) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE Movies (id INTEGER PRIMARY KEY, movie_name TEXT, director_name TEXT, link STRING)');
    });
    await database.rawUpdate(
        'UPDATE Movies SET movie_name = ?, director_name = ?, link = ? WHERE id = ?',
        [
          name,
          director,
          link == null
              ? 'https://www.fostercity.org/sites/default/files/styles/gallery500/public/imageattachments/parksrec/page/10791/thursday_movie.png?itok=XakMswGX'
              : link,
          id
        ]);
    List<Map> moviesTable = await database.rawQuery('SELECT * FROM Movies');
    return moviesTable;
  }

  List<Widget> getShimmer() {
    List<Widget> shimmers = [];
    for (int i = 0; i < 7; i++) {
      Widget listObj = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 80,
          child: Row(
            children: [
              SizedBox(
                height: 60,
                width: 60,
                child: Shimmer.fromColors(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  baseColor: Colors.white,
                  highlightColor: Colors.grey,
                ),
              ),
              SizedBox(width: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                      width: 100,
                      child: Shimmer.fromColors(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        baseColor: Colors.white,
                        highlightColor: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 10,
                      width: 200,
                      child: Shimmer.fromColors(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        baseColor: Colors.white,
                        highlightColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      shimmers.add(listObj);
    }
    return shimmers;
  }
}
