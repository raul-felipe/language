import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:language/card_edit.dart';
import 'package:dropdown_search/dropdown_search.dart';

class UserDeckEditPage extends StatefulWidget {
  final String title;

  const UserDeckEditPage({super.key, required this.title});

  @override
  State<UserDeckEditPage> createState() => _UserDeckEditPageState();
}

class _UserDeckEditPageState extends State<UserDeckEditPage> {
  CollectionReference user_collection =
      FirebaseFirestore.instance.collection('users');
  CollectionReference deck_collection =
      FirebaseFirestore.instance.collection('study-deck');

  Widget list_builder = ListView();
  Widget dropdown_builder = DropdownSearch();

  final text_controller = TextEditingController();

  String selected_deck_id = "";

  @override
  void initState() {
    super.initState();
    getUserDeckData();
    list_builder = ListView();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    text_controller.dispose();
    super.dispose();
  }

  void getDeckData(List<String> user_deck_id_list) {
    deck_collection.get().then((value) {
      List<String> deck_id_list = value.docs.map((e) => e.id).toList();
      // List<String> remain_user_deck_id_list = deck_id_list
      //     .where((element) => user_deck_id_list.contains(element))
      //     .toList();

      List<QueryDocumentSnapshot<Object?>> user_deck_doc_list = value.docs
          .where((element) => user_deck_id_list.contains(element.id))
          .toList();

      List<QueryDocumentSnapshot<Object?>> remain_user_deck_doc_list = value
          .docs
          .where((element) => user_deck_id_list.contains(element.id) == false)
          .toList();

      List<String> dropdowm_list = remain_user_deck_doc_list
          .map((e) => (e.data() as Map)['deck-name'].toString())
          .toList();

      setState(() {
        dropdown_builder = DropdownSearch<String>(
          items: dropdowm_list,
          selectedItem: "-",
          dropdownDecoratorProps: const DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: "Available Decks",
            ),
          ),
          onChanged: (value) {
            selected_deck_id = remain_user_deck_doc_list
                .elementAt(dropdowm_list.indexOf(value.toString()))
                .id;
          },
        );

        list_builder = ListView.builder(
          itemCount: user_deck_doc_list.length,
          itemBuilder: ((context, index) {
            return ListTile(
              title: Text(user_deck_doc_list.elementAt(index)['deck-name']),
              onTap: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => CardEditPage(
                //         title: user_deck_doc_list.elementAt(index).id),
                //   ),
                // );
              },
            );
          }),
        );
      });
    });
  }

  void getUserDeckData() {
    user_collection
        .doc(widget.title)
        .collection('study-deck')
        .get()
        .then((value) {
      //quando concluir de carregar a lista de ID dos decks do usuario carrega a lista de decks gerais

      getDeckData(value.docs.map((e) => e.id).toList());
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
                Expanded(child: dropdown_builder),
                IconButton(
                  onPressed: () {
                    if (selected_deck_id != "") {
                      var user_deck_reference = user_collection
                          .doc(widget.title)
                          .collection('study-deck')
                          .doc(selected_deck_id);
                      user_deck_reference.set({"deck-id": selected_deck_id});

                      deck_collection
                          .doc(selected_deck_id)
                          .collection('cards')
                          .get()
                          .then((value) {
                        var card_iterator = value.docs.iterator;
                        while (card_iterator.moveNext()) {
                          user_deck_reference
                              .collection('cards')
                              .doc(card_iterator.current.id)
                              .set({
                            // 'card-id': card_iterator.current.id,
                            'last-review': DateUtils.dateOnly(DateTime.now()),
                            'learn-situation': 'new-card',
                            'next-review': DateUtils.dateOnly(DateTime.now()),
                            'strike-sequence': 0,
                          });
                        }
                      });

                      setState(() {
                        dropdown_builder = DropdownSearch(
                          selectedItem: "",
                        );
                        selected_deck_id = "";
                        getUserDeckData();
                      });
                    }
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
