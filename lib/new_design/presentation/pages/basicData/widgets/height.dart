import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HeightSlider extends StatelessWidget {
  final int weight;
  final int minWeight;
  final int maxWeight;
  final double width;
  final ValueChanged<int> onChange;

  const HeightSlider(
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
      padding: const EdgeInsets.all(64),
      child: WeightBackground(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return constraints.isTight
                ? Container()
                : HeightSliderInternal(
                    minValue: minWeight,
                    maxValue: maxWeight,
                    value: weight,
                    onChange: onChange,
                    width: width ?? constraints.maxWidth,
                  );
          },
        ),
      ),
    );
  }
}

class HeightSliderInternal extends StatelessWidget {
  HeightSliderInternal({
    Key key,
    @required this.minValue,
    @required this.maxValue,
    @required this.value,
    @required this.onChange,
    @required this.width,
  })  : scrollController = ScrollController(
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
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemExtent: itemExtent,
        itemCount: itemCount,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          int itemValue = _indexToValue(index);
          bool isExtra = index == 0 || index == itemCount - 1;

          return isExtra
              ? Container()
              : GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => _animateTo(itemValue, durationMillis: 50),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      itemValue.toString(),
                      style: _getTextStyle(context, itemValue),
                    ),
                  ),
                );
        },
      ),
    );
  }

  TextStyle _getDefaultTextStyle() {
    return const TextStyle(
      color: Colors.black, //Color.fromRGBO(196, 197, 203, 1.0),
      fontSize: 16.0,
    );
  }

  TextStyle _getHighlightTextStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).primaryColor,
      fontSize: 44.0,
    );
  }

  TextStyle _getTextStyle(BuildContext context, int itemValue) {
    return itemValue == value ? _getHighlightTextStyle(context) : _getDefaultTextStyle();
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
      duration: Duration(milliseconds: durationMillis),
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

      if (middleValue != value && onChange != null) {
        onChange(middleValue);
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
          height: 90.0,
          decoration: BoxDecoration(
            color: Colors.black12, //Color.fromRGBO(244, 244, 244, 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: child,
        ),
        SvgPicture.asset(
          'assets/svgs/arrow.svg',
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
}
