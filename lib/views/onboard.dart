// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, unnecessary_statements, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/ScUtil.dart';

enum Side { left, top, right, bottom }

class GooeyCarousel extends StatefulWidget {
  final List<Widget> children;

  GooeyCarousel({this.children}) : super();

  @override
  GooeyCarouselState createState() => GooeyCarouselState();
}

class GooeyCarouselState extends State<GooeyCarousel>
    with SingleTickerProviderStateMixin {
  int _index = 0; // index of the base (bottom) child
  int _dragIndex; // index of the top child
  Offset _dragOffset; // starting offset of the drag
  double _dragDirection; // +1 when dragging left to right, -1 for right to left
  bool _dragCompleted; // has the drag successfully resulted in a swipe
  Image _blueImage;
  Image _redImage;
  Image _greenImage;
  Image _blueBg;
  Image _redBg;
  Image _greenBg;

  GooeyEdge _edge;
  Ticker _ticker;
  GlobalKey _key = GlobalKey();

  @override
  void initState() {
    _edge = GooeyEdge(count: 25);
    _ticker = createTicker(_tick)..start();
    _blueImage = Image.asset(
      'assets/images/blue.png',
    );
    _redImage = Image.asset(
      'assets/images/red.png',
    );
    _greenImage = Image.asset(
      'assets/images/green.png',
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration duration) {
    _edge.tick(duration);
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: false);
    return Container(
      color: AppColors.appBackgroundColor,
      child: GestureDetector(
          key: _key,
          onPanDown: (details) => _handlePanDown(details, _getSize()),
          onPanUpdate: (details) => _handlePanUpdate(details, _getSize()),
          onPanEnd: (details) => _handlePanEnd(details, _getSize()),
          child: Stack(
            children: <Widget>[
              cards(_index % 3),
              _dragIndex == null
                  ? SizedBox()
                  : ClipPath(
                      child: cards(_dragIndex % 3),
                      clipBehavior: Clip.hardEdge,
                      clipper: GooeyEdgeClipper(_edge, margin: 10.0),
                    ),
            ],
          )),
    );
  }

  Widget cards(int index) {
    if (index == 1) {
      return ContentCard(
        index: index,
        image: _redImage,
        color: Color.fromARGB(255, 240, 101, 79),
        altColor: Color(0xFF45DF51), //Colors.orange,
        title: AppTexts.page2title,
        subtitle: AppTexts.page2sub,
      );
    }
    if (index == 0) {
      return ContentCard(
        index: index,
        color: Color.fromARGB(255, 53, 101, 248),
        altColor: Color(0xFF45DF51),
        image: _blueImage,
        title: AppTexts.page1title,
        subtitle: AppTexts.page1sub,
      );
    }
    if (index == 2) {
      return ContentCard(
        index: index,
        color: Color.fromARGB(255, 5, 100, 1),
        image: _greenImage,
        altColor: Color(0xFF45DF51), //Colors.orange,
        title: AppTexts.page3title,
        subtitle: AppTexts.page3sub,
      );
    }
    return Container();
  }

  Size _getSize() {
    final RenderBox box = _key.currentContext.findRenderObject();
    return box.size;
  }

  void _handlePanDown(DragDownDetails details, Size size) {
    if (_dragIndex != null && _dragCompleted) {
      _index = _dragIndex;
    }
    _dragIndex = null;
    _dragOffset = details.localPosition;
    _dragCompleted = false;
    _dragDirection = 0;

    _edge.farEdgeTension = 0.0;
    _edge.edgeTension = 0.01;
    _edge.reset();
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    double dx = details.globalPosition.dx - _dragOffset.dx;

    if (!_isSwipeActive(dx)) {
      return;
    }
    if (_isSwipeComplete(dx, size.width)) {
      return;
    }

    if (_dragDirection == -1) {
      dx = size.width + dx;
    }
    _edge.applyTouchOffset(Offset(dx, details.localPosition.dy), size);
  }

  bool _isSwipeActive(double dx) {
    // check if a swipe is just starting:
    if (_dragDirection == 0.0 && dx.abs() > 20.0) {
      _dragDirection = dx.sign;
      _edge.side = _dragDirection == 1.0 ? Side.left : Side.right;
      if (this.mounted) {
        setState(() {
          _dragIndex = _index - _dragDirection.toInt();
        });
      }
    }
    return _dragDirection != 0.0;
  }

  bool _isSwipeComplete(double dx, double width) {
    if (_dragDirection == 0.0) {
      return false;
    } // haven't started
    if (_dragCompleted) {
      return true;
    } // already done

    // check if swipe is just completed:
    double availW = _dragOffset.dx;
    if (_dragDirection == 1) {
      availW = width - availW;
    }
    double ratio = dx * _dragDirection / availW;

    if (ratio > 0.5 && availW / width > 0.5) {
      _dragCompleted = true;
      _edge.farEdgeTension = 0.01;
      _edge.edgeTension = 0.0;
      _edge.applyTouchOffset();
    }
    return _dragCompleted;
  }

  void _handlePanEnd(DragEndDetails details, Size size) {
    _edge.applyTouchOffset();
  }
}

class ContentCard extends StatefulWidget {
  final Color color;
  final Color altColor;
  final int index;
  final Widget image;
  final Widget background;
  final String title;
  final String subtitle;

  ContentCard(
      {this.color,
      this.index,
      this.image,
      this.background,
      this.title = "",
      this.subtitle,
      this.altColor})
      : super();

  @override
  _ContentCardState createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  Ticker _ticker;
  @override
  void initState() {
    _ticker = Ticker((d) {
      if (this.mounted) {
        setState(() {});
      }
    })
      ..start();
    super.initState();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var time = DateTime.now().millisecondsSinceEpoch / 2000;
    var scaleX = 1.2 + sin(time) * .05;
    var scaleY = 1.2 + cos(time) * .07;
    var offsetY = 20 + cos(time) * 20;
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: <Widget>[
        Container(
            color: AppColors.appBackgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: Container(
                  child: widget.image,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.white,
                )),
                _buildPageIndicator(this.widget.index),
                _buildBottomContent(),
              ],
            ))
      ],
    );
  }

  Widget _buildPageIndicator(int index) {
    return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _indicator(0),
            SizedBox(
              width: 10,
            ),
            _indicator(1),
            SizedBox(
              width: 10,
            ),
            _indicator(2),
          ],
        ));
  }

  Widget _indicator(int idx) {
    BoxDecoration _selected =
        BoxDecoration(color: Colors.grey, shape: BoxShape.circle);
    BoxDecoration _unselected = BoxDecoration(
      border: Border.all(color: Colors.grey),
      shape: BoxShape.circle,
    );
    return Container(
      decoration: this.widget.index == idx ? _selected : _unselected,
      height: 10,
      width: 10,
    );
  }

  Widget _buildBottomContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              decoration: TextDecoration.none,
              height: 1.2,
              color: widget.color,
              fontSize: ScUtil().setSp(24),
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            )),
        Padding(padding: EdgeInsets.all(5)),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
          child: Text(widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: ScUtil().setSp(15),
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Poppins',
                  color: Colors.grey)),
        ),
        Padding(
          padding: EdgeInsets.all(40),
          child: MaterialButton(
            minWidth: 10,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: AppColors.primaryAccentColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(AppTexts.getstart,
                  style: TextStyle(
                      fontSize: ScUtil().setSp(16),
                      letterSpacing: .8,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
            onPressed: () => Navigator.of(context).pushNamed(Routes.Semail),
          ),
        )
      ],
    );
  }
}

class GooeyEdge {
  List<_GooeyPoint> points;
  Side side;
  double edgeTension = 0.01;
  double farEdgeTension = 0.0;
  double touchTension = 0.1;
  double pointTension = 0.25;
  double damping = 0.9;
  double maxTouchDistance = 0.15;
  int lastT = 0;

  FractionalOffset touchOffset;

  GooeyEdge({count = 10, this.side = Side.left}) {
    points = [];
    for (int i = 0; i < count; i++) {
      points.add(_GooeyPoint(0.0, i / (count - 1)));
    }
  }

  void reset() {
    points.forEach((pt) => pt.x = pt.velX = pt.velY = 0.0);
  }

  void applyTouchOffset([Offset offset, Size size]) {
    if (offset == null) {
      touchOffset = null;
      return;
    }
    FractionalOffset o = FractionalOffset.fromOffsetAndSize(offset, size);
    if (side == Side.left) {
      touchOffset = o;
    } else if (side == Side.right) {
      touchOffset = FractionalOffset(1.0 - o.dx, 1.0 - o.dy);
    } else if (side == Side.top) {
      touchOffset = FractionalOffset(o.dy, 1.0 - o.dx);
    } else {
      touchOffset = FractionalOffset(1.0 - o.dy, o.dx);
    }
  }

  Path buildPath(Size size, {double margin = 0.0}) {
    if (points == null || points.length == 0) {
      return null;
    }

    Matrix4 mtx = _getTransform(size, margin);

    Path path = Path();
    int l = points.length;
    Offset pt = _GooeyPoint(-margin, 1.0).toOffset(mtx), pt1;
    path.moveTo(pt.dx, pt.dy); // bl

    pt = _GooeyPoint(-margin, 0.0).toOffset(mtx);
    path.lineTo(pt.dx, pt.dy); // tl

    pt = points[0].toOffset(mtx);
    path.lineTo(pt.dx, pt.dy); // tr

    pt1 = points[1].toOffset(mtx);
    path.lineTo(pt.dx + (pt1.dx - pt.dx) / 2, pt.dy + (pt1.dy - pt.dy) / 2);

    for (int i = 2; i < l; i++) {
      pt = pt1;
      pt1 = points[i].toOffset(mtx);
      double midX = pt.dx + (pt1.dx - pt.dx) / 2;
      double midY = pt.dy + (pt1.dy - pt.dy) / 2;
      path.quadraticBezierTo(pt.dx, pt.dy, midX, midY);
    }

    path.lineTo(pt1.dx, pt1.dy); // br
    path.close(); // bl

    return path;
  }

  void tick(Duration duration) {
    if (points == null || points.length == 0) {
      return;
    }
    int l = points.length;
    double t = min(1.5, (duration.inMilliseconds - lastT) / 1000 * 60);
    lastT = duration.inMilliseconds;
    double dampingT = pow(damping, t);

    for (int i = 0; i < l; i++) {
      _GooeyPoint pt = points[i];
      pt.velX -= pt.x * edgeTension * t;
      pt.velX += (1.0 - pt.x) * farEdgeTension * t;
      if (touchOffset != null) {
        double ratio =
            max(0.0, 1.0 - (pt.y - touchOffset.dy).abs() / maxTouchDistance);
        pt.velX += (touchOffset.dx - pt.x) * touchTension * ratio * t;
      }
      if (i > 0) {
        _addPointTension(pt, points[i - 1].x, t);
      }
      if (i < l - 1) {
        _addPointTension(pt, points[i + 1].x, t);
      }
      pt.velX *= dampingT;
    }

    for (int i = 0; i < l; i++) {
      _GooeyPoint pt = points[i];
      pt.x += pt.velX * t;
    }
  }

  Matrix4 _getTransform(Size size, double margin) {
    bool vertical = side == Side.top || side == Side.bottom;
    double w = (vertical ? size.height : size.width) + margin * 2;
    double h = (vertical ? size.width : size.height) + margin * 2;

    Matrix4 mtx = Matrix4.identity()
      ..translate(-margin, 0.0)
      ..scale(w, h);
    if (side == Side.top) {
      mtx
        ..rotateZ(pi / 2)
        ..translate(0.0, -1.0);
    } else if (side == Side.right) {
      mtx
        ..rotateZ(pi)
        ..translate(-1.0, -1.0);
    } else if (side == Side.bottom) {
      mtx
        ..rotateZ(pi * 3 / 2)
        ..translate(-1.0, 0.0);
    }

    return mtx;
  }

  void _addPointTension(_GooeyPoint pt0, double x, double t) {
    pt0.velX += (x - pt0.x) * pointTension * t;
  }
}

class _GooeyPoint {
  double x;
  double y;
  double velX = 0.0;
  double velY = 0.0;

  _GooeyPoint([this.x = 0.0, this.y = 0.0]);

  Offset toOffset([Matrix4 transform]) {
    Offset o = Offset(x, y);
    if (transform == null) {
      return o;
    }
    return MatrixUtils.transformPoint(transform, o);
  }
}

class GooeyEdgeClipper extends CustomClipper<Path> {
  GooeyEdge edge;
  double margin;

  GooeyEdgeClipper(this.edge, {this.margin = 0.0}) : super();

  @override
  Path getClip(Size size) {
    return edge.buildPath(size, margin: margin);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
