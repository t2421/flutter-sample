import './transition.dart';
import 'package:flutter/material.dart';

class HeroScreen extends StatelessWidget {
  const HeroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Hero Screen'),
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            CardObject(
              image: Image.asset('images/slide_1.jpg'),
              title: "タイトル",
              description: "詳細",
              id: "1",
              onTap: () {
                Navigator.of(context)
                    .push(TransitionUtil.createFadeTransition(DetailScreen()));
              },
            ),
            CardObject(
              image: Image.asset('images/slide_2.jpg'),
              title: "タイトル2",
              description: "詳細2",
              id: "2",
              onTap: () {
                Navigator.of(context)
                    .push(TransitionUtil.createFadeTransition(DetailScreen2()));
              },
            )
          ],
        ));
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail1 Screen'),
      ),
      body: ListView(
        children: [
          Hero(tag: 'image_1', child: Image.asset('images/slide_1.jpg')),
          Container(
              padding: EdgeInsets.all(20),
              child: Hero(
                  tag: 'text_1',
                  child: Container(
                      child: Text('タイトル',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black)))))
        ],
      ),
    );
  }
}

class DetailScreen2 extends StatelessWidget {
  const DetailScreen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail2 Screen'),
      ),
      body: ListView(
        children: [
          Hero(tag: 'image_2', child: Image.asset('images/slide_2.jpg')),
          Container(
              padding: EdgeInsets.all(20),
              child: Hero(
                  tag: 'text_2',
                  child: Container(
                      child: Text('タイトル2',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black)))))
        ],
      ),
    );
  }
}

class CardObject extends StatelessWidget {
  const CardObject(
      {required this.image,
      this.id = "",
      this.title = "",
      this.description = "",
      this.onTap,
      Key? key})
      : super(key: key);
  final String id;
  final Image image;
  final String title;
  final String description;
  final Function? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (this.onTap != null) {
          this.onTap!();
        }
      },
      borderRadius: BorderRadius.circular(5),
      child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Column(
            children: [
              Hero(
                tag: 'image_$id',
                child: image,
              ),
              Container(
                padding:
                    EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Hero(
                      tag: "text_$id",
                      child: Container(
                        child: Text(
                          title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                height: 1,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey)),
              ),
              Container(
                width: double.infinity,
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                child: Text(
                  description,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 12),
                ),
              )
            ],
          )),
    );
  }
}
