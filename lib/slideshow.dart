import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';

enum SlideshowAnimationType {
  Horizontal,
  Fade,
}

class Slideshow extends StatefulWidget {
  const Slideshow(
      {required this.images,
      this.autoplay = false,
      this.animationType = SlideshowAnimationType.Horizontal,
      this.autoplayInterval = const Duration(milliseconds: 5000),
      Key? key})
      : super(key: key);
  // スライドショーで使用する画像リスト
  final List<Image> images;
  // 自動的にスライドショーを再生するかどうか
  final bool autoplay;
  // 自動スライドショーのインターバル設定
  final Duration autoplayInterval;
  // アニメーションタイプの指定
  final SlideshowAnimationType animationType;

  @override
  _SlideshowState createState() => _SlideshowState();
}

class _SlideshowState extends State<Slideshow> {
  int _currentIndex = 0;
  int _numSlide = 0;
  ScrollController _scrollController = ScrollController();
  Timer? _timer;
  Offset _offset = Offset(0, 0);
  Offset _touchDownOffset = Offset(0, 0);
  Offset _tmpSlideOffset = Offset(0, 0);
  Offset _velocity = Offset(0, 0);
  Offset _moveDiff = Offset(0, 0);
  double _velocityThreshold = 30.0;
  double _moveThreshold = 100;
  @override
  void initState() {
    _numSlide = widget.images.length;
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void startTimer() {
    if (widget.autoplay) {
      _timer?.cancel();
      _timer = Timer.periodic(widget.autoplayInterval, (timer) {
        onNext();
      });
    }
  }

  void onNext() {
    _timer?.cancel();
    setState(() {
      if (_currentIndex >= _numSlide - 1) {
        _currentIndex = _numSlide - 1;
      } else {
        _currentIndex = _currentIndex + 1;
      }
    });
    updatePosition();
  }

  void onPrev() {
    _timer?.cancel();
    setState(() {
      if (_currentIndex <= 0) {
        _currentIndex = 0;
      } else {
        _currentIndex = _currentIndex - 1;
      }
    });
    updatePosition();
  }

  void updatePosition() {
    if (widget.animationType != SlideshowAnimationType.Horizontal) return;
    double position = MediaQuery.of(context).size.width * _currentIndex;
    _scrollController
        .animateTo(position,
            duration: Duration(milliseconds: 500), curve: Curves.easeOutCubic)
        .then((value) => startTimer());
  }

  bool isShowPrev() {
    return _currentIndex > 0;
  }

  bool isShowNext() {
    return _currentIndex < _numSlide - 1;
  }

  // 画像エリアのwidget
  Widget getImageWidget() {
    return Container(
      width: 600,
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          getImageChangeWidget(),
          Align(
              alignment: const Alignment(1, 0),
              child: Visibility(
                  visible: isShowNext(),
                  child: NextButton(
                      active: _currentIndex < _numSlide - 1, onTap: onNext))),
          Align(
            alignment: const Alignment(-1, 0),
            child: Visibility(
                visible: isShowPrev(),
                child: PrevButton(active: _currentIndex > 0, onTap: onPrev)),
          ),
        ],
      ),
    );
  }

  // フェード切り替え用の画像リストを取得する
  List<Widget> getImageAllWidget() {
    List<Widget> list = [];
    for (int i = 0; i < widget.images.length; i++) {
      list.add(FadeObject(
        item: widget.images[i],
        visible: i == _currentIndex,
        onFadeoutComplete: () => {
          if (widget.autoplay) {startTimer()}
        },
      ));
    }

    return list;
  }

  List<Widget> getImageList() {
    List<Widget> list = [];
    widget.images.forEach((element) {
      list.add(Container(
        width: MediaQuery.of(context).size.width,
        child: element,
      ));
    });
    return list;
  }

  // アニメーションタイプに応じたwidgetを取得する
  Widget getImageChangeWidget() {
    if (widget.animationType == SlideshowAnimationType.Horizontal) {
      return GestureDetector(
          onPanStart: (details) {
            _timer?.cancel();
            _tmpSlideOffset = Offset(_scrollController.offset, _offset.dy);
            _touchDownOffset = details.localPosition;
          },
          onPanUpdate: (details) {
            setState(() {
              _moveDiff = _touchDownOffset - details.localPosition;
              _offset = Offset(
                  _tmpSlideOffset.dx +
                      (_touchDownOffset.dx - details.localPosition.dx),
                  0);
            });
            _velocity = details.delta;
            (_offset.dx / MediaQuery.of(context).size.width).round();
            _scrollController.jumpTo(_offset.dx);
          },
          onPanEnd: (details) {
            _tmpSlideOffset = Offset(_scrollController.offset, _offset.dy);
            _touchDownOffset = Offset(0, 0);
            if (_velocity.dx < -_velocityThreshold ||
                _moveDiff.dx > _moveThreshold) {
              onNext();
            } else if (_velocity.dx > _velocityThreshold ||
                _moveDiff.dx < -_moveThreshold) {
              onPrev();
            } else {
              updatePosition();
            }
          },
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            children: getImageList(),
          ));
    } else {
      return Stack(
        fit: StackFit.passthrough,
        children: getImageAllWidget(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      getImageWidget(),
      SlideshowController(
          currentIndex: _currentIndex,
          numItems: _numSlide,
          onChanged: (value) {
            setState(() {
              _currentIndex = value;
              updatePosition();
            });
          }),
    ]);
  }
}

// スライドショーの操作を管理する
class SlideshowController extends StatefulWidget {
  const SlideshowController(
      {this.currentIndex = 0,
      this.numItems = 0,
      required this.onChanged,
      Key? key})
      : super(key: key);
  final int numItems;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  _SlideshowControllerState createState() => _SlideshowControllerState();
}

class _SlideshowControllerState extends State<SlideshowController> {
  bool _active = false;
  List<Widget> _items = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _items = createItems();
  }

  void _handleChange(int newValue) {
    widget.onChanged(newValue);
  }

  List<Widget> createItems() {
    List<Widget> items = [];
    for (int i = 0; i < widget.numItems; i++) {
      items.add(SlideshowControllerItem(
        id: i,
        onChanged: _handleChange,
        active: widget.currentIndex == i,
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: createItems(),
        ));
  }
}

class SlideshowControllerItem extends StatelessWidget {
  const SlideshowControllerItem(
      {Key? key,
      required this.onChanged,
      required this.id,
      this.active = false})
      : super(key: key);
  final ValueChanged<int> onChanged;
  final int id;
  final bool active;

  void _handleTap() {
    onChanged(id);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _handleTap,
        child: Container(
            width: 16.0,
            height: 16.0,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: active ? Colors.lightBlue[500] : Colors.grey[600])));
  }
}

class NextButton extends StatelessWidget {
  const NextButton({Key? key, required this.active, required this.onTap})
      : super(key: key);
  final Function onTap;
  final bool active;

  void _handleTap() {
    if (active) {
      onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: _handleTap,
        icon: Icon(
          Icons.arrow_forward_ios,
          size: 30.0,
          color: Colors.white,
        ));
  }
}

class PrevButton extends StatelessWidget {
  const PrevButton({Key? key, required this.active, required this.onTap})
      : super(key: key);
  final Function onTap;
  final bool active;

  void _handleTap() {
    if (active) {
      onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: _handleTap,
        icon: Icon(
          Icons.arrow_back_ios,
          size: 30.0,
          color: Colors.white,
        ));
  }
}

// フェード切り替え用のwidgetを生成する
class FadeObject extends StatefulWidget {
  const FadeObject(
      {required this.item,
      this.visible = false,
      this.onFadeoutComplete,
      Key? key})
      : super(key: key);
  final bool visible;
  final Widget item;
  final Function? onFadeoutComplete;
  @override
  _FadeObjectState createState() => _FadeObjectState();
}

class _FadeObjectState extends State<FadeObject> {
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(seconds: 1),
      opacity: widget.visible ? 1 : 0,
      child: widget.item,
      onEnd: () => {
        if (!widget.visible)
          {
            if (widget.onFadeoutComplete != null) {widget.onFadeoutComplete!()}
          }
      },
    );
  }
}
