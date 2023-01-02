import 'package:flutter/material.dart';
import 'package:language/main.dart';
import 'package:ruby_text/ruby_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewPage extends StatefulWidget {
  final String user_id;
  final String deck_id;

  const ReviewPage({super.key, required this.user_id, required this.deck_id});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  CollectionReference user_collection =
      FirebaseFirestore.instance.collection('users');
  CollectionReference deck_collection =
      FirebaseFirestore.instance.collection('study-deck');

  var cartas = [
    {
      "id": "001",
      "frente": "リンゴを食[た]べる",
      "tras": "TABERU",
      "pacote": "料理",
      "proxima_revisao": DateTime.parse("2022-12-14"),
      "ultima_revisao": DateTime.parse("2020-01-02"),
      "sequencia": 2,
      "aprendizado": "aprendido",
    },
    // {
    //   "id": "002",
    //   "frente": "食事",
    //   "tras": "SHOKUJI",
    //   "pacote": "料理",
    //   "proxima_revisao": DateTime.parse("2022-12-17"),
    //   "ultima_revisao": DateTime.parse("2020-01-02"),
    //   "sequencia": 4,
    //   "aprendizado": "aprendido",
    // },
    // {
    //   "id": "003",
    //   "frente": "料理",
    //   "tras": "RYOURI",
    //   "pacote": "料理",
    //   "proxima_revisao": DateTime.parse("2022-12-14"),
    //   "ultima_revisao": DateTime.parse("2020-01-02"),
    //   "sequencia": 0,
    //   "aprendizado": "nao_aprendido",
    // },
    // {
    //   "id": "004",
    //   "frente": "ご飯",
    //   "tras": "GOHAN",
    //   "pacote": "料理",
    //   "proxima_revisao": DateTime.parse("2022-12-14"),
    //   "ultima_revisao": DateTime.parse("2020-01-02"),
    //   "sequencia": 0,
    //   "aprendizado": "nao_aprendido",
    // },
    // {
    //   "id": "005",
    //   "frente": "食べ物",
    //   "tras": "TABEMONO",
    //   "pacote": "料理",
    //   "proxima_revisao": DateTime.parse("2022-12-14"),
    //   "ultima_revisao": DateTime.parse("2020-01-02"),
    //   "sequencia": 0,
    //   "aprendizado": "esquecido",
    // },
    // {
    //   "id": "006",
    //   "frente": "箸",
    //   "tras": "HASHI",
    //   "pacote": "料理",
    //   "proxima_revisao": DateTime.parse("2022-12-14"),
    //   "ultima_revisao": DateTime.parse("2020-01-02"),
    //   "sequencia": 0,
    //   "aprendizado": "esquecido",
    // },
    // {
    //   "id": "007",
    //   "frente": "皿",
    //   "tras": "SARA",
    //   "pacote": "料理",
    //   "proxima_revisao": DateTime.parse("2022-12-12"),
    //   "ultima_revisao": DateTime.parse("2020-01-02"),
    //   "sequencia": 0,
    //   "aprendizado": "esquecido",
    // },
    // {
    //   "id": "008",
    //   "frente": "食品",
    //   "tras": "SHOKUHIN",
    //   "pacote": "料理",
    //   "proxima_revisao": DateTime.parse("2022-12-12"),
    //   "ultima_revisao": DateTime.parse("2020-01-02"),
    //   "sequencia": 0,
    //   "aprendizado": "esquecido",
    // },
    // {
    //   "id": "009",
    //   "frente": "夕食",
    //   "tras": "YUUSHOKU",
    //   "pacote": "料理",
    //   "proxima_revisao": DateTime.parse("2022-12-12"),
    //   "ultima_revisao": DateTime.parse("2020-01-02"),
    //   "sequencia": 0,
    //   "aprendizado": "esquecido",
    // }
  ];

  List listReview(List list) {
    List listReview = [];
    for (var element in list) {
      if (element["learn-situation"] == "learned" &&
          element["next-review"]
                  .compareTo(DateUtils.dateOnly(DateTime.now())) <=
              0) {
        listReview.add(element);
      }
    }
    for (var element in list) {
      if (element["learn-situation"] == "forgotten") {
        listReview.add(element);
      }
    }
    for (var element in list) {
      if (element["learn-situation"] == "new-card") {
        listReview.add(element);
      }
    }

    //volta pro menu caso não haja mais cartas
    if (listReview.isEmpty) {
      listReview.add({"front": ""});
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => showReviewFinishedDialog(),
      );
    }

    return listReview;
  }

  var list_review = [];

  var current_card = 0;

  late Widget bottom_buttons;

  late Widget back_card;

  void nextCard(String answerType, int sequence) {
    print(list_review);
    setState(() {
      bottom_buttons = showBackCardButton();
      back_card = hideBackCardWidget();

      //atualiza campos da carta
      list_review[current_card]["next-review"] =
          DateUtils.dateOnly(DateTime.now()).add(
              Duration(days: list_review[current_card]["strike-sequence"]));
      if (answerType == "learned") sequence++;
      list_review[current_card]["strike-sequence"] = sequence;
      list_review[current_card]["learn-situation"] = answerType;
      list_review[current_card]["last-review"] =
          DateUtils.dateOnly(DateTime.now());

      //chama a próxima carta
      current_card++;
      if (!(list_review.length > current_card)) {
        current_card = 0;
        list_review = listReview(list_review);
      }
    });
  }

  void getCards() {
    user_collection
        .doc(widget.user_id)
        .collection('study-deck')
        .doc(widget.deck_id)
        .collection('cards')
        .get()
        .then((value) async {
      var cardIterator = value.docs.iterator;
      List cardsList = [];
      while (cardIterator.moveNext()) {
        await deck_collection
            .doc(widget.deck_id)
            .collection('cards')
            .doc(cardIterator.current.id)
            .get()
            .then((value) {
          cardsList.add({
            'id': cardIterator.current.id,
            'last-review': cardIterator.current.data()['last-review'],
            'learn-situation': cardIterator.current.data()['learn-situation'],
            'next-review': cardIterator.current.data()['next-review'],
            'strike-sequence': cardIterator.current.data()['strike-sequence'],
            'front': value.data()!['front'],
            'back': value.data()!['back'],
            'pack': value.data()!['pack'],
          });
        });
      }
      setState(() {
        list_review = listReview(cardsList);
      });
    });
  }

  Widget showAnswerButton() {
    return Container(
      color: Colors.amber,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //errado
            ElevatedButton(
                onPressed: () {
                  nextCard("forgotten", 0);
                },
                child: Icon(Icons.cancel)),
            //repetir
            ElevatedButton(
                onPressed: () {
                  nextCard("review", 1);
                },
                child: Icon(Icons.repeat_on_outlined)),
            //aprendido
            ElevatedButton(
                onPressed: () {
                  nextCard(
                      "learned", list_review[current_card]["strike-sequence"]);
                },
                child: Icon(Icons.check_box)),
          ],
        ),
      ),
    );
  }

  Widget showBackCardButton() {
    return Container(
      color: Colors.amber,
      child: Center(
        child: ElevatedButton(
            onPressed: () {
              setState(() {
                bottom_buttons = showAnswerButton();
                back_card = showBackCardWidget();
              });
            },
            child: Icon(Icons.arrow_circle_right_outlined)),
      ),
    );
  }

  Widget showBackCardWidget() {
    return Container(
      color: Colors.blue,
      child: Center(
          child: Text(list_review[current_card]["back"],
              style: TextStyle(fontSize: 24))),
    );
  }

  Widget hideBackCardWidget() {
    return Container(
      color: Colors.blue,
    );
  }

  Widget rubyText(String text) {
    List<RubyTextData> rubyTextList = [];

    var it = text.runes.iterator;

    while (it.moveNext()) {
      String furigana = "";
      String letter = it.currentAsString;

      if (it.moveNext() && it.currentAsString == '[') {
        while (it.moveNext() && it.currentAsString != ']') {
          furigana = furigana + it.currentAsString;
        }
        it.moveNext();
      }
      it.movePrevious();

      rubyTextList.add(RubyTextData(
        letter,
        ruby: furigana,
      ));
    }

    return RubyText(
      rubyTextList,
      style: const TextStyle(fontSize: 24),
    );
  }

  AlertDialog showReviewFinishedDialog() {
    return AlertDialog(
      title: const Text('Review has finished'),
      content: const Text('You have no more cards to review'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => MyHomePage(title: widget.title),
            //   ),
            // );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // list_review = listReview(cartas);
    getCards();
    back_card = hideBackCardWidget();
    bottom_buttons = showBackCardButton();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user_id),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.deepOrange,
                child: Center(
                  child: rubyText(list_review[current_card]["front"]),
                  // child: Text(list_review[current_card]["frente"],
                  //     style: TextStyle(fontSize: 42)),
                ),
              ),
              flex: 2,
            ),
            Expanded(
              child: back_card,
              flex: 4,
            ),
            Expanded(
              // ignore: sort_child_properties_last
              child: bottom_buttons,
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }
}
