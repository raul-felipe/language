import 'package:flutter/material.dart';
import 'package:language/deck_edit.dart';
import 'package:language/review.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:language/user_deck_edit.dart';
import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'ISI　暗記'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List list = ['Kanji N4', 'Vocabulary N4', 'Phrases N4'];

  @override
  void initState() {
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    super.initState();
  }

  Dialog showDeckDetailsDialog(context, index) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        // height: MediaQuery.of(context).size.height * 0.5,
        // width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'New Cards ',
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Cards to learn',
              ),
            ),
            const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'Cards to review',
                )),
            Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ReviewPage(title: list[index].toString()),
                        ),
                      );
                    },
                    child: const Icon(Icons.start_rounded))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.mode_edit_outline_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DeckEditPage(title: 'Deck Edit'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const UserDeckEditPage(title: 'ffQopJNIYgLjhdfuWc0Y'),
                ),
              );
            },
          )
        ],
      ),
      body: Center(
          child: ListView.builder(
              itemCount: list.length,
              itemBuilder: ((context, index) {
                return ListTile(
                  title: Text(list[index]),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          showDeckDetailsDialog(context, index),
                    );
                  },
                );
              }))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
