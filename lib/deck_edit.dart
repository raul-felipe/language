import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:language/card_edit.dart';

class DeckEditPage extends StatefulWidget {
  final String title;

  const DeckEditPage({super.key, required this.title});

  @override
  State<DeckEditPage> createState() => _DeckEditPageState();
}

class _DeckEditPageState extends State<DeckEditPage> {
  late FirebaseFirestore db = FirebaseFirestore.instance;

  Widget list_builder = ListView();

  final text_controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDeckData();
    list_builder = ListView();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    text_controller.dispose();
    super.dispose();
  }

  void getDeckData() {
    db.collection('study-deck').get().then((value) {
      setState(() {
        list_builder = ListView.builder(
          itemCount: value.size,
          itemBuilder: ((context, index) {
            return ListTile(
              title: Text(value.docs.elementAt(index)['deck-name']),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        CardEditPage(title: value.docs.elementAt(index).id),
                  ),
                );
              },
            );
          }),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Center(
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextField(
                    controller: text_controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter the deck name',
                    ),
                  ),
                )),
                IconButton(
                  onPressed: () {
                    setState(() {
                      db.collection('study-deck').doc().set({
                        'deck-id': FieldValue.serverTimestamp(),
                        'deck-name': text_controller.text,
                      }).then((value) {
                        text_controller.clear();
                        getDeckData();
                      });
                    });
                  },
                  icon: const Icon(Icons.add),
                )
              ],
            ),
            Expanded(child: list_builder),
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
