import 'package:flutter/material.dart';
import './transition.dart';
import './slideshowScreen.dart';
import './heroScreen.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Index Screen'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("スライドショー"),
            trailing: Icon(Icons.keyboard_arrow_right_sharp),
            onTap: () {
              Navigator.of(context)
                  .push(TransitionUtil.createFadeTransition(SlideshowScreen()));
            },
          ),
          ListTile(
            title: Text("Heroアニメーション"),
            trailing: Icon(Icons.keyboard_arrow_right_sharp),
            onTap: () {
              Navigator.of(context)
                  .push(TransitionUtil.createSlideInTransition(HeroScreen()));
            },
          )
        ],
      ),
    );
  }
}
