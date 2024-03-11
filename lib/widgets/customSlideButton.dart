import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class CustomSlideButton extends StatefulWidget {
  CustomSlideButton(
      {Key key,
      @required this.initialValue,
      @Deprecated('use minValue:0 instead') this.withNaturalNumbers = false,
      this.withBackground = true,
      @required this.onChanged,
      this.direction = Axis.horizontal,
      this.withSpring = true,
      this.counterTextColor = Colors.white,
      this.dragButtonColor = const Color(0xFF9874f8),
      this.iconsColor = Colors.white,
      this.backGroundColor = Colors.white10,
      this.withPlusMinus = false,
      this.firstIncrementDuration = const Duration(milliseconds: 250),
      this.secondIncrementDuration = const Duration(milliseconds: 100),
      this.speedTransitionLimitCount = 3,
      this.maxValue = 50,
      this.minValue = -50,
      this.withFastCount = false,
      @required this.stepperValue,
      this.customFoodServingType,
      @required this.editMeal,
      this.onCountChange})
      : super(key: key);

  final Axis direction;

  double initialValue;
  final bool withNaturalNumbers;
  final bool withBackground;
  double stepperValue;

  final Duration firstIncrementDuration;
  final Duration secondIncrementDuration;
  final int speedTransitionLimitCount;

  final ValueChanged<double> onChanged;
  final ValueChanged<double> onCountChange;

  final bool withSpring;
  final bool withPlusMinus;
  final bool withFastCount;
  final double maxValue;
  double minValue;

  final Color counterTextColor;
  final Color dragButtonColor;
  final Color iconsColor;
  final Color backGroundColor;
//for custom Food
  final String customFoodServingType;
  final bool editMeal;
  @override
  _Stepper2State createState() => _Stepper2State();
}

class _Stepper2State extends State<CustomSlideButton> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;
  double _value;
  double countAdd = 1;
  double _startAnimationPosX;
  double _startAnimationPosY;
  bool isTimerEnable = true;
  bool isReadyToFastAnim = true;
  bool isChanged = false;
  @override
  void initState() {
    super.initState();
    quantityChanger(widget.customFoodServingType);
    widget.minValue = widget.withNaturalNumbers ? 0 : widget.minValue;
    // _value = widget.initialValue ?? 0.0;
    // widget.stepperValue = _value;
    _controller = AnimationController(vsync: this, lowerBound: -0.5, upperBound: 0.5);
    _controller.value = 0.0;
    _controller.addListener(() {});
    print(widget.maxValue);
    if (widget.direction == Axis.horizontal) {
      _animation =
          Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(1.5, 0.0)).animate(_controller);
    } else {
      _animation =
          Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.0, 1.5)).animate(_controller);
    }

    //print("widget.stepperValue ${widget.stepperValue}");
  }

  double incrementAndDecrement = 0.5;
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.direction == Axis.horizontal) {
      _animation =
          Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(1.5, 0.0)).animate(_controller);
    } else {
      _animation =
          Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.0, 1.5)).animate(_controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: widget.direction == Axis.horizontal ? 210.0 : 90.0,
          height: widget.direction == Axis.horizontal ? 90.0 : 210.0,
          child: Material(
            type: MaterialType.canvas,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(60.0),
            color: widget.withBackground == true
                ? widget.backGroundColor == null
                    ? Colors.black12.withOpacity(0.2)
                    : widget.backGroundColor
                : Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                    left: widget.direction == Axis.horizontal ? 10.0 : null,
                    bottom: widget.direction == Axis.horizontal ? null : 10.0,
                    child: widget.direction == Axis.horizontal
                        ? GestureDetector(
                            onTap: () {
                              if (widget.minValue == widget.stepperValue) {
                                countAdd = 1;
                              }
                              //Subraction Part 🏳‍🌈
                              !widget.editMeal
                                  ? {
                                      widget.customFoodServingType == null
                                          ? {
                                              if (widget.minValue <= widget.stepperValue &&
                                                  widget.stepperValue < incrementAndDecrement)
                                                {
                                                  widget.stepperValue =
                                                      widget.stepperValue - incrementAndDecrement,
                                                  countAdd--
                                                }
                                              else
                                                widget.direction == Axis.horizontal
                                                    ? widget.stepperValue > widget.minValue
                                                        ? {
                                                            widget.stepperValue =
                                                                widget.stepperValue -
                                                                    widget.initialValue,
                                                            countAdd--
                                                          }
                                                        : widget.stepperValue
                                                    : widget.stepperValue < widget.maxValue
                                                        ? {
                                                            widget.stepperValue =
                                                                widget.stepperValue =
                                                                    widget.stepperValue +
                                                                        widget.initialValue,
                                                            countAdd--
                                                          }
                                                        : widget.stepperValue
                                            }
                                          : {
                                              widget.stepperValue > incrementAndDecrement
                                                  ? {
                                                      widget.stepperValue -= incrementAndDecrement,
                                                      countAdd--
                                                    }
                                                  : widget.stepperValue
                                            },
                                      widget.onChanged(widget.stepperValue),
                                      widget.onCountChange(countAdd),
                                      setState(() {})
                                    }
                                  : {
                                      widget.initialValue <= widget.minValue
                                          ? widget.initialValue
                                          : widget.initialValue =
                                              widget.initialValue - widget.stepperValue,
                                      countAdd--,
                                      widget.onChanged(widget.initialValue),
                                      widget.onCountChange(countAdd),
                                      setState(() {})
                                    };
                            },
                            child: Icon(
                                widget.withPlusMinus == false
                                    ? Icons.keyboard_arrow_left
                                    : Icons.remove,
                                size: 40.0,
                                color: widget.iconsColor))
                        : GestureDetector(
                            onTap: () {
                              if (widget.minValue == widget.stepperValue) {
                                countAdd = 1;
                              }
                              //Subraction Part 🏳‍🌈
                              if (widget.customFoodServingType == null) {
                                if (widget.minValue >= widget.stepperValue &&
                                    widget.stepperValue > incrementAndDecrement) {
                                  widget.stepperValue = widget.stepperValue - incrementAndDecrement;
                                  countAdd--;
                                } else
                                  widget.direction == Axis.horizontal
                                      ? widget.stepperValue > widget.minValue
                                          ? {
                                              widget.stepperValue =
                                                  widget.stepperValue - widget.initialValue,
                                              countAdd--
                                            }
                                          : widget.stepperValue
                                      : widget.stepperValue < widget.maxValue
                                          ? {
                                              widget.stepperValue = widget.stepperValue =
                                                  widget.stepperValue + widget.initialValue,
                                              countAdd++
                                            }
                                          : widget.stepperValue;
                              } else {
                                widget.stepperValue > incrementAndDecrement
                                    ? {widget.stepperValue -= incrementAndDecrement, countAdd--}
                                    : widget.stepperValue;
                              }
                              // widget.minValue >= widget.stepperValue && widget.stepperValue > 0.25
                              //     ? widget.stepperValue = widget.stepperValue - 0.25
                              //     : widget.stepperValue;
                              widget.onChanged(widget.stepperValue);
                              widget.onCountChange(countAdd);
                              setState(() {});
                            },
                            child: Icon(
                                widget.withPlusMinus == false
                                    ? Icons.keyboard_arrow_down
                                    : Icons.remove,
                                size: 40.0,
                                color: widget.iconsColor)),
                  ),
                  Positioned(
                    right: widget.direction == Axis.horizontal ? 10.0 : null,
                    top: widget.direction == Axis.horizontal ? null : 10.0,
                    child: widget.direction == Axis.horizontal
                        ? GestureDetector(
                            onTap: () {
                              //Addition Part 🏳‍🌈
                              if (widget.minValue == widget.stepperValue) {
                                countAdd = 1;
                              }
                              if (widget.customFoodServingType == null) {
                                if (widget.minValue >= widget.stepperValue &&
                                    widget.stepperValue > incrementAndDecrement &&
                                    widget.stepperValue != widget.minValue) {
                                  widget.stepperValue = widget.stepperValue + 0.5;
                                  countAdd++;
                                } else if (widget.stepperValue == incrementAndDecrement &&
                                    !widget.editMeal) {
                                  widget.stepperValue += incrementAndDecrement;
                                  countAdd++;
                                } else
                                  widget.direction == Axis.horizontal
                                      ? widget.stepperValue < widget.maxValue &&
                                              widget.initialValue < widget.maxValue
                                          ? {
                                              widget.stepperValue =
                                                  widget.stepperValue + widget.initialValue,
                                              countAdd++
                                            }
                                          : widget.stepperValue
                                      : widget.stepperValue > widget.minValue
                                          ? {
                                              widget.stepperValue =
                                                  widget.stepperValue - widget.initialValue,
                                              countAdd--
                                            }
                                          : widget.stepperValue;
                              } else {
                                widget.stepperValue < widget.maxValue &&
                                        widget.initialValue < widget.maxValue
                                    ? {widget.stepperValue += incrementAndDecrement, countAdd++}
                                    : widget.stepperValue;
                              }
                              widget.onChanged(widget.stepperValue);
                              widget.onCountChange(countAdd);
                              setState(() {});
                            },
                            child: Icon(
                                widget.withPlusMinus == false
                                    ? Icons.keyboard_arrow_right
                                    : Icons.add,
                                size: 40.0,
                                color: widget.iconsColor))
                        : GestureDetector(
                            onTap: () {
                              if (widget.minValue == widget.stepperValue) {
                                countAdd = 1;
                              }
                              //Addition Part 🏳‍🌈
                              if (widget.customFoodServingType == null) {
                                if (widget.minValue >= widget.stepperValue &&
                                    widget.stepperValue > incrementAndDecrement &&
                                    widget.stepperValue != widget.minValue) {
                                  widget.stepperValue = widget.stepperValue + 0.5;
                                } else if (widget.stepperValue == incrementAndDecrement) {
                                  widget.stepperValue += incrementAndDecrement;
                                } else
                                  widget.direction == Axis.horizontal
                                      ? widget.stepperValue < widget.maxValue
                                          ? widget.stepperValue =
                                              widget.stepperValue + widget.initialValue
                                          : widget.stepperValue
                                      : widget.stepperValue > widget.minValue
                                          ? widget.stepperValue =
                                              widget.stepperValue - widget.initialValue
                                          : widget.stepperValue;
                              } else {
                                widget.stepperValue < widget.maxValue
                                    ? widget.stepperValue =
                                        widget.stepperValue + incrementAndDecrement
                                    : widget.stepperValue;
                              }
                              widget.onChanged(widget.stepperValue);
                              widget.onCountChange(countAdd);
                              // widget.minValue >= widget.stepperValue && widget.stepperValue > 0.25
                              //     ? widget.stepperValue = widget.stepperValue + 0.25
                              //     : widget.stepperValue;
                              setState(() {});
                            },
                            child: Icon(
                                widget.withPlusMinus == false ? Icons.keyboard_arrow_up : Icons.add,
                                size: 40.0,
                                color: widget.iconsColor)),
                  ),
                  GestureDetector(
                    onHorizontalDragStart: _onPanStart,
                    onHorizontalDragUpdate: _onPanUpdate,
                    onHorizontalDragEnd: _onPanEnd,
                    child: SlideTransition(
                      position: _animation,
                      child: Material(
                        color: widget.dragButtonColor,
                        shape: const CircleBorder(),
                        elevation: 5.0,
                        child: Center(
                          child: !widget.editMeal
                              ? Text(
                                  '${widget.stepperValue}',
                                  key: ValueKey<double>(widget.stepperValue),
                                  style: TextStyle(color: widget.counterTextColor, fontSize: 25.0),
                                )
                              : Text(
                                  '${widget.initialValue}',
                                  key: ValueKey<double>(widget.initialValue),
                                  style: TextStyle(color: widget.counterTextColor, fontSize: 25.0),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double offsetFromGlobalPos(Offset globalPosition) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset local = box.globalToLocal(globalPosition);
    _startAnimationPosX = ((local.dx * 0.75) / box.size.width) - 0.4;
    _startAnimationPosY = ((local.dy * 0.75) / box.size.height) - 0.4;
    //print(_controller.value);
    if (widget.direction == Axis.horizontal) {
      return ((local.dx * 0.75) / box.size.width) - 0.4;
    } else {
      return ((local.dy * 0.75) / box.size.height) - 0.4;
    }
  }

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
    _controller.value = offsetFromGlobalPos(details.globalPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    double value = offsetFromGlobalPos(details.globalPosition);
    isReadyToFastAnim = true;
    if (value <= -0.1923) {
      _controller.value = -0.1923;
      _startAnimationPosX = -0.1923;
      _startAnimationPosY = -0.1923;
      if (widget.withFastCount) fastCount();
    } else if (value >= 0.1923) {
      _controller.value = 0.1923;
      _startAnimationPosX = 0.1923;
      _startAnimationPosY = 0.1923;
      if (widget.withFastCount) fastCount();
    } else {
      isReadyToFastAnim = false;
      _controller.value = offsetFromGlobalPos(details.globalPosition);
    }
  }

  fastCount() {
    if (isTimerEnable) {
      isTimerEnable = false;
      bool isHor = widget.direction == Axis.horizontal;
      Timer(Duration(milliseconds: 100), () {
        if (isReadyToFastAnim) {
          int velocitLimit = 0;
          Timer.periodic(widget.firstIncrementDuration, (timer) {
            if (isReadyToFastAnim == false) {
              timer.cancel();
              isReadyToFastAnim = true;
            }
            if (velocitLimit > widget.speedTransitionLimitCount) {
              timer.cancel();
            }
            velocitLimit++;
            if (_controller.value <= -0.1923) {
              isHor
                  ? widget.stepperValue > widget.minValue
                      ? {
                          widget.stepperValue = widget.stepperValue - widget.initialValue,
                          countAdd--
                        }
                      : widget.stepperValue
                  : widget.stepperValue < widget.maxValue
                      ? {
                          widget.stepperValue = widget.stepperValue + widget.initialValue,
                          countAdd++
                        }
                      : widget.stepperValue;
            } else if (_controller.value >= 0.1923) {
              isHor
                  ? widget.stepperValue < widget.maxValue
                      ? {
                          widget.stepperValue = widget.stepperValue + widget.initialValue,
                          countAdd++
                        }
                      : widget.stepperValue
                  : widget.stepperValue > widget.minValue
                      ? {widget.stepperValue--, countAdd--}
                      : widget.stepperValue;
            }
          });
          Timer.periodic(widget.secondIncrementDuration, (timer) {
            if (isReadyToFastAnim == false) {
              timer.cancel();
              isReadyToFastAnim = true;
            }
            if (velocitLimit > widget.speedTransitionLimitCount) {
              if (_controller.value <= -0.1923) {
                isHor
                    ? widget.stepperValue > widget.minValue
                        ? widget.stepperValue = widget.stepperValue - incrementAndDecrement
                        : widget.stepperValue
                    : widget.stepperValue < widget.maxValue
                        ? widget.stepperValue = widget.stepperValue + incrementAndDecrement
                        : widget.stepperValue;
              } else if (_controller.value >= 0.1923) {
                isHor
                    ? widget.stepperValue < widget.maxValue
                        ? widget.stepperValue = widget.stepperValue + incrementAndDecrement
                        : widget.stepperValue
                    : widget.stepperValue > widget.minValue
                        ? widget.stepperValue = widget.stepperValue - incrementAndDecrement
                        : widget.stepperValue;
              }
            }
          });
        }
      });
      setState(() {});
    }

    /*if(isfastCount == true){
      bool isHor = widget.direction == Axis.horizontal;
      bool changed = false;
      Future.
      setState(() => isHor ? widget.stepperValue-- : widget.stepperValue++);
      changed = true;
      }
    }*/
  }

  void _onPanEnd(DragEndDetails details) {
    _controller.stop();
    isReadyToFastAnim = false;
    isTimerEnable = true;
    bool isHor = widget.direction == Axis.horizontal;
    isChanged = false;
    if (widget.minValue == widget.stepperValue) {
      countAdd = 1;
    }
    if (_controller.value <= -0.1923) {
      _controller.value = -0.1923;
      if (widget.customFoodServingType != null) {
        !widget.editMeal
            ? isHor
                ? widget.stepperValue > incrementAndDecrement
                    ? {widget.stepperValue -= incrementAndDecrement, countAdd--}
                    : widget.stepperValue
                : widget.stepperValue < widget.maxValue
                    ? {widget.stepperValue += incrementAndDecrement, countAdd++}
                    : widget.stepperValue
            : widget.initialValue >= widget.maxValue
                ? widget.initialValue
                : widget.initialValue = widget.initialValue + widget.stepperValue;
      } else
        !widget.editMeal
            ? isHor
                ? widget.stepperValue > widget.minValue
                    ? {widget.stepperValue -= widget.initialValue, countAdd--}
                    : widget.stepperValue
                : widget.stepperValue < widget.maxValue
                    ? {widget.stepperValue += widget.initialValue, countAdd++}
                    : widget.stepperValue
            : {
                widget.initialValue <= widget.minValue
                    ? widget.initialValue
                    : widget.initialValue = widget.initialValue - widget.stepperValue,
              };
      isChanged = true;
    } else if (_controller.value >= 0.1923) {
      _controller.value = 0.1923;
      if (widget.customFoodServingType != null) {
        isHor
            ? widget.stepperValue < widget.maxValue
                ? {widget.stepperValue += incrementAndDecrement, countAdd++}
                : widget.stepperValue
            : widget.stepperValue > incrementAndDecrement
                ? {widget.stepperValue -= incrementAndDecrement, countAdd--}
                : widget.stepperValue;
      } else
        !widget.editMeal
            ? isHor
                ? widget.stepperValue < widget.maxValue
                    ? {widget.stepperValue += widget.initialValue, countAdd++}
                    : widget.stepperValue
                : widget.stepperValue > widget.minValue
                    ? {widget.stepperValue -= widget.initialValue, countAdd--}
                    : widget.stepperValue
            : widget.initialValue >= widget.maxValue
                ? widget.initialValue
                : widget.initialValue = widget.initialValue + widget.stepperValue;
      isChanged = true;
    }
    if (widget.withSpring) {
      final SpringDescription _kDefaultSpring = new SpringDescription.withDampingRatio(
        mass: 0.9,
        stiffness: 250.0,
        ratio: 0.6,
      );
      if (widget.direction == Axis.horizontal) {
        _controller.animateWith(SpringSimulation(_kDefaultSpring, _startAnimationPosX, 0.0, 0.0));
      } else {
        _controller.animateWith(SpringSimulation(_kDefaultSpring, _startAnimationPosY, 0.0, 0.0));
      }
    } else {
      _controller.animateTo(0.0, curve: Curves.bounceOut, duration: Duration(milliseconds: 500));
    }

    if (isChanged && widget.onChanged != null) {
      !widget.editMeal
          ? widget.onChanged(widget.stepperValue)
          : widget.onChanged(widget.initialValue);
      widget.onCountChange(countAdd);
    }
    setState(() {});
  }

  quantityChanger(String str) {
    if (str != null)
      switch (str.toLowerCase().trim()) {
        case "cup":
          widget.initialValue = 0.5;
          widget.minValue = 0.5;
          break;
        case "small cup":
          widget.initialValue = 0.5;
          widget.minValue = 0.5;
          break;
        case "katori":
          widget.initialValue = 1;
          widget.minValue = 1;
          break;
        case "large cup":
          widget.initialValue = 0.5;
          widget.minValue = 0.5;
          break;
        case "tea cup":
          widget.initialValue = 1;
          widget.minValue = 1;
          break;
        case "glass":
          widget.initialValue = 0.5;
          widget.minValue = 0.5;
          break;
        case "large glass":
          widget.initialValue = 0.5;
          widget.minValue = 0.5;
          break;
        case "tea spoon":
          widget.initialValue = 1;
          widget.minValue = 1;
          break;
        case "table spoon":
          widget.initialValue = 1;
          widget.minValue = 1;
          break;
        case "gms":
          widget.initialValue = 5;
          widget.minValue = 5;
          break;

        default:
          widget.initialValue = 0.5;
          widget.minValue = 0.5;
      }
    incrementAndDecrement = widget.initialValue;
    setState(() {});
  }
}

quantityAsign(String str) {
  switch (str.toLowerCase().trim()) {
    case "cup":
      return 0.5;
      break;
    case "small cup":
      return 0.5;
      break;
    case "katori":
      return 1.0;
      break;
    case "large cup":
      return 0.5;
      break;
    case "tea cup":
      return 1.0;
      break;
    case "glass":
      return 0.5;
      break;
    case "large glass":
      return 0.5;
      break;
    case "tea spoon":
      return 1.0;
      break;
    case "table spoon":
      return 1.0;
      break;
    case "gms":
      return 5.0;
      break;

    default:
      return 0.5;
  }
}
