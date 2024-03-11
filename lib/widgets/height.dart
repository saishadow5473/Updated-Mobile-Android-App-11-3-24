import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

String cmToFeetInch(int cm) {
  double inches = (cm) / 2.54;
  int feet = inches ~/ 12;
  int inch = (inches % 12).toInt();
  return feet.toString() + "'" + inch.toString() + '"';
}

class HeightSlider extends StatefulWidget {
  final int maxHeight;
  final int minHeight;
  final int height;
  final String personImagePath;
  final Color primaryColor;
  final Color accentColor;
  final Color numberLineColor;
  final Color currentHeightTextColor;
  final Color sliderCircleColor;
  final ValueChanged<int> onChange;

  const HeightSlider(
      {Key key,
      @required this.height,
      @required this.onChange,
      this.maxHeight = 220,
      this.minHeight = 145,
      this.primaryColor,
      this.accentColor,
      this.numberLineColor,
      this.currentHeightTextColor,
      this.sliderCircleColor,
      this.personImagePath})
      : super(key: key);

  int get totalUnits => maxHeight - minHeight;

  @override
  _HeightSliderState createState() => _HeightSliderState();
}

class _HeightSliderState extends State<HeightSlider> {
  double startDragYOffset;
  int startDragHeight;
  double widgetHeight = 50;
  double labelFontSize = 12.0;

  double get _pixelsPerUnit {
    return _drawingHeight / widget.totalUnits;
  }

  double get _sliderPosition {
    double halfOfBottomLabel = labelFontSize / 2;
    int unitsFromBottom = widget.height - widget.minHeight;
    return halfOfBottomLabel + unitsFromBottom * _pixelsPerUnit;
  }

  double get _drawingHeight {
    double totalHeight = this.widgetHeight;
    double marginBottom = 12.0;
    double marginTop = 12.0;
    return totalHeight - (marginBottom + marginTop + labelFontSize);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: LayoutBuilder(builder: (context, constraints) {
        this.widgetHeight = constraints.maxHeight;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: this._onTapDown,
          onVerticalDragStart: this._onDragStart,
          onVerticalDragUpdate: this._onDragUpdate,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              _drawPersonImage(),
              _drawFtLabels(),
              _drawSlider(),
              _drawLabels(),
            ],
          ),
        );
      }),
    );
  }

  _onTapDown(TapDownDetails tapDownDetails) {
    int height = _globalOffsetToHeight(tapDownDetails.globalPosition);
    widget.onChange(_normalizeHeight(height));
  }

  int _normalizeHeight(int height) {
    return math.max(widget.minHeight, math.min(widget.maxHeight, height));
  }

  int _globalOffsetToHeight(Offset globalOffset) {
    RenderBox getBox = context.findRenderObject();
    Offset localPosition = getBox.globalToLocal(globalOffset);
    double dy = localPosition.dy;
    dy = dy - 12.0 - labelFontSize / 2;
    int height = widget.maxHeight - (dy ~/ _pixelsPerUnit);
    return height;
  }

  _onDragStart(DragStartDetails dragStartDetails) {
    int newHeight = _globalOffsetToHeight(dragStartDetails.globalPosition);
    widget.onChange(newHeight);
    if (this.mounted) {
      setState(() {
        startDragYOffset = dragStartDetails.globalPosition.dy;
        startDragHeight = newHeight;
      });
    }
  }

  _onDragUpdate(DragUpdateDetails dragUpdateDetails) {
    double currentYOffset = dragUpdateDetails.globalPosition.dy;
    double verticalDifference = startDragYOffset - currentYOffset;
    int diffHeight = verticalDifference ~/ _pixelsPerUnit;
    int height = _normalizeHeight(startDragHeight + diffHeight);
    if (this.mounted) {
      setState(() => widget.onChange(height));
    }
  }

  Widget _drawSlider() {
    return Positioned(
      child: HeightSliderInteral(
          height: widget.height,
          primaryColor: widget.primaryColor ?? Theme.of(context).primaryColor,
          accentColor: widget.accentColor ?? Theme.of(context).accentColor,
          currentHeightTextColor:
              widget.currentHeightTextColor ?? Theme.of(context).accentColor,
          sliderCircleColor:
              widget.sliderCircleColor ?? Theme.of(context).primaryColor),
      left: 0.0,
      right: 0.0,
      bottom: _sliderPosition,
    );
  }

  Widget _drawLabels() {
    int labelsToDisplay = widget.totalUnits ~/ 5 + 1;
    List<Widget> labels = List.generate(
      labelsToDisplay,
      (idx) {
        return Text(
          "${widget.maxHeight - 5 * idx} cm",
          style: TextStyle(
            color: widget.numberLineColor ?? Theme.of(context).accentColor,
            fontSize: labelFontSize,
          ),
        );
      },
    );

    return Align(
      alignment: Alignment.centerRight,
      child: IgnorePointer(
        child: Padding(
          padding: EdgeInsets.only(
            right: 12.0,
            bottom: 12.0,
            top: 12.0,
          ),
          child: Column(
            children: labels,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ),
      ),
    );
  }

  String idxcmToFeetInch(int idx) {
    return cmToFeetInch(widget.maxHeight - 5 * idx);
  }

  Widget _drawFtLabels() {
    int labelsToDisplay = (widget.totalUnits) ~/ (5) + 1;
    List<Widget> labels = List.generate(
      labelsToDisplay,
      (idx) {
        return Text(
          idxcmToFeetInch(idx),
          style: TextStyle(
            color: widget.numberLineColor ?? Theme.of(context).accentColor,
            fontSize: labelFontSize,
          ),
        );
      },
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: IgnorePointer(
        child: Padding(
          padding: EdgeInsets.only(
            left: 30.0,
            bottom: 12.0,
            top: 12.0,
          ),
          child: Column(
            children: labels,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
        ),
      ),
    );
  }

  Widget _drawPersonImage() {
    double personImageHeight = _sliderPosition + 12.0;
    if (widget.personImagePath == null) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: SvgPicture.asset(
          "assets/svgs/man.svg",
          package: 'height_slider',
          height: personImageHeight,
          width: personImageHeight / 3,
        ),
      );
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: SvgPicture.asset(
        widget.personImagePath,
        height: personImageHeight,
        width: personImageHeight / 3,
      ),
    );
  }
}

class HeightSliderInteral extends StatelessWidget {
  final int height;
  final Color primaryColor;
  final Color accentColor;
  final Color currentHeightTextColor;
  final Color sliderCircleColor;

  const HeightSliderInteral(
      {Key key,
      @required this.height,
      @required this.primaryColor,
      @required this.accentColor,
      @required this.currentHeightTextColor,
      @required this.sliderCircleColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SliderLabel(
              height: this.height,
              currentHeightTextColor: this.currentHeightTextColor),
          Row(
            children: <Widget>[
              SliderCircle(sliderCircleColor: this.sliderCircleColor),
              Expanded(child: SliderLine(primaryColor: this.primaryColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class SliderLabel extends StatelessWidget {
  final int height;
  final Color currentHeightTextColor;

  const SliderLabel(
      {Key key, @required this.height, @required this.currentHeightTextColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      cmToFeetInch(height) + "/$height CM",
      style: TextStyle(
        fontSize: 16.0,
        color: this.currentHeightTextColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class SliderLine extends StatelessWidget {
  final Color primaryColor;

  const SliderLine({Key key, @required this.primaryColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: List.generate(
          40,
          (i) => Expanded(
                child: Container(
                  height: 2.0,
                  decoration: BoxDecoration(
                      color: i.isEven ? this.primaryColor : Colors.white),
                ),
              )),
    );
  }
}

class SliderCircle extends StatelessWidget {
  final Color sliderCircleColor;

  const SliderCircle({Key key, @required this.sliderCircleColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        color: this.sliderCircleColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.unfold_more,
        color: Colors.white,
        size: 0.6 * 32.0,
      ),
    );
  }
}
