import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WeightSlider extends StatelessWidget {
  final int weight;
  final int minWeight;
  final int maxWeight;
  final double width;
  final ValueChanged<int> onChange;

  const WeightSlider(
      {Key key,
      this.weight = 80,
      this.minWeight = 30,
      this.maxWeight = 130,
      this.width,
      @required this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(64),
      child: WeightBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return constraints.isTight
                ? Container()
                : WeightSliderInternal(
                    minValue: this.minWeight,
                    maxValue: this.maxWeight,
                    value: this.weight,
                    onChange: this.onChange,
                    width: this.width ?? constraints.maxWidth,
                  );
          },
        ),
      ),
    );
  }
}

class WeightSliderInternal extends StatelessWidget {
  WeightSliderInternal({
    Key key,
    @required this.minValue,
    @required this.maxValue,
    @required this.value,
    @required this.onChange,
    @required this.width,
  })  : scrollController = new ScrollController(
          initialScrollOffset: (value - minValue) * width / 3,
        ),
        super(key: key);

  final int minValue;
  final int maxValue;
  final int value;
  final ValueChanged<int> onChange;
  final double width;
  final ScrollController scrollController;

  double get itemExtent => width / 3;

  int _indexToValue(int index) => minValue + (index - 1);

  @override
  build(BuildContext context) {
    int itemCount = (maxValue - minValue) + 3;
    return NotificationListener(
      onNotification: _onNotification,
      child: new ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemExtent: itemExtent,
        itemCount: itemCount,
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          int itemValue = _indexToValue(index);
          bool isExtra = index == 0 || index == itemCount - 1;

          return isExtra
              ? new Container()
              : GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => _animateTo(itemValue, durationMillis: 50),
                  child: FittedBox(
                    child: Text(
                      itemValue.toString(),
                      style: _getTextStyle(context, itemValue),
                    ),
                    fit: BoxFit.scaleDown,
                  ),
                );
        },
      ),
    );
  }

  TextStyle _getDefaultTextStyle() {
    return new TextStyle(
      color: Colors.black, //Color.fromRGBO(196, 197, 203, 1.0),
      fontSize: 16.0,
    );
  }

  TextStyle _getHighlightTextStyle(BuildContext context) {
    return new TextStyle(
      color: Theme.of(context).primaryColor,
      fontSize: 44.0,
    );
  }

  TextStyle _getTextStyle(BuildContext context, int itemValue) {
    return itemValue == value
        ? _getHighlightTextStyle(context)
        : _getDefaultTextStyle();
  }

  bool _userStoppedScrolling(Notification notification) {
    return notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle &&
        scrollController.position.activity is! HoldScrollActivity;
  }

  _animateTo(int valueToSelect, {int durationMillis = 200}) {
    double targetExtent = (valueToSelect - minValue) * itemExtent;
    scrollController.animateTo(
      targetExtent,
      duration: new Duration(milliseconds: durationMillis),
      curve: Curves.decelerate,
    );
  }

  int _offsetToMiddleIndex(double offset) => (offset + width / 2) ~/ itemExtent;

  int _offsetToMiddleValue(double offset) {
    int indexOfMiddleElement = _offsetToMiddleIndex(offset);
    int middleValue = _indexToValue(indexOfMiddleElement);
    middleValue = math.max(minValue, math.min(maxValue, middleValue));

    return middleValue;
  }

  bool _onNotification(Notification notification) {
    if (notification is ScrollNotification) {
      int middleValue = _offsetToMiddleValue(notification.metrics.pixels);
      if (_userStoppedScrolling(notification)) {
        _animateTo(middleValue);
      }

      if (middleValue != value && this.onChange != null) {
        this.onChange(middleValue);
      }
    }

    return true;
  }
}

class WeightBackground extends StatelessWidget {
  final Widget child;

  const WeightBackground({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Container(
          height: 120.0,
          decoration: BoxDecoration(
            color: Colors.black12, //Color.fromRGBO(244, 244, 244, 1.0),
            borderRadius: new BorderRadius.circular(50.0),
          ),
          child: child,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("KGs"),
        ),
        SvgPicture.asset(
          'assets/svgs/arrow.svg',
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
}
