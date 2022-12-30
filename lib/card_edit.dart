import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardEditPage extends StatefulWidget {
  final String title;

  const CardEditPage({super.key, required this.title});

  @override
  State<CardEditPage> createState() => _CardEditPageState();
}

class _CardEditPageState extends State<CardEditPage> {
  late FirebaseFirestore db = FirebaseFirestore.instance;

  Widget list_builder = ListView();

  final text_front_card_controller = TextEditingController();
  final text_back_card_controller = TextEditingController();
  final text_pack_card_controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCardData();
    list_builder = ListView();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    text_front_card_controller.dispose();
    text_back_card_controller.dispose();
    text_pack_card_controller.dispose();
    super.dispose();
  }

  void getCardData() {
    db
        .collection('study-deck')
        .doc(widget.title)
        .collection('cards')
        .get()
        .then((value) {
      setState(() {
        list_builder = ListView.builder(
          itemCount: value.size,
          itemBuilder: ((context, index) {
            return ListTile(
              title: Text(value.docs.elementAt(index)['front']),
              onTap: () {},
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: TextField(
                controller: text_front_card_controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the front card name',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: TextField(
                controller: text_back_card_controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the back card name',
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: TextField(
                    controller: text_pack_card_controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter the pack card name',
                    ),
                  ),
                )),
                IconButton(
                  onPressed: () {
                    setState(() {
                      db
                          .collection('study-deck')
                          .doc(widget.title)
                          .collection('cards')
                          .doc()
                          .set({
                        'id': FieldValue.serverTimestamp(),
                        'front': text_front_card_controller.text,
                        'back': text_back_card_controller.text,
                        'pack': text_pack_card_controller.text,
                      }).then((value) {
                        text_front_card_controller.clear();
                        text_back_card_controller.clear();
                        text_pack_card_controller.clear();
                        getCardData();
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
