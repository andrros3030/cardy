library app_stories;

import 'package:flutter/material.dart';
import "package:flutter/widgets.dart";
import "package:flutter/services.dart";
import 'package:card_app_bsk/widgetsSettings.dart';

typedef Duration StoryDuration(int index);
typedef VoidCallback WhenEnded(int index);
typedef Widget SegmentProgressBuilder(BuildContext context, int index, double progress, double gap);

class Story extends StatefulWidget {
  const Story({
    Key key,
    this.momentBuilder,
    this.momentDurationGetter,
    this.momentCount,
    this.onFlashForward,
    this.onFlashBack,
    this.onStoryEnded,
    this.onExited,
    this.startAt = 0,
    this.topOffset = 0,
    this.progressSegmentBuilder = Story.defSegmentProgressBuilder,
    this.progressSegmentGap = 2.0,
    this.progressOpacityDuration = const Duration(milliseconds: 300),
    this.momentSwitcherFraction = 0.33,
    this.fullscreen = true,
    this.autoPlay = true,
    this.showBottomBar = true,
    this.showRegButton = true
  })  : assert(momentCount != null),
        assert(momentCount > 0),
        assert(momentDurationGetter != null),
        assert(momentBuilder != null),
        assert(momentSwitcherFraction != null),
        assert(momentSwitcherFraction >= 0),
        assert(momentSwitcherFraction < double.infinity),
        assert(progressSegmentGap != null),
        assert(progressSegmentGap >= 0),
        assert(progressOpacityDuration != null),
        assert(momentSwitcherFraction < double.infinity),
        assert(startAt != null),
        assert(startAt >= 0),
        assert(startAt < momentCount),
        assert(fullscreen != null),
        super(key: key);
  final bool showRegButton;
  final bool showBottomBar;
  final bool autoPlay;
  final IndexedWidgetBuilder momentBuilder;
  final StoryDuration momentDurationGetter;
  final int momentCount;
  final VoidCallback onFlashForward;
  final VoidCallback onFlashBack;
  final WhenEnded onStoryEnded;
  final VoidCallback onExited;
  final double momentSwitcherFraction;
  final SegmentProgressBuilder progressSegmentBuilder;
  final double progressSegmentGap;
  final Duration progressOpacityDuration;
  final int startAt;
  final double topOffset;
  final bool fullscreen;

  static Widget defSegmentProgressBuilder(
      BuildContext context, int index, double progress, double gap) =>
      Container(
        height: 2.0,
        margin: EdgeInsets.symmetric(horizontal: gap),
        decoration: BoxDecoration(
          color: Color(0x8888888f),
          borderRadius: BorderRadius.circular(1.0),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            color: Color(0x8888888f),
          ),
        ),
      );

  @override
  _StoryState createState() => _StoryState();
}

class _StoryState extends State<Story> with SingleTickerProviderStateMixin {
  AnimationController controller;
  int _currentIdx;
  bool _isInFullscreenMode = false;

  void _switchToNextOrFinish() {
    controller.stop();
    widget.onStoryEnded(_currentIdx);                                           //in future - add data that handles alreadyShown indexes
    if (_currentIdx + 1 >= widget.momentCount && widget.onFlashForward != null)
      widget.onFlashForward();
    else if (_currentIdx + 1 < widget.momentCount) {
      controller.reset();
      setState(() => _currentIdx += 1);
      controller.duration = widget.momentDurationGetter(_currentIdx);
      controller.forward();
    }
    else if (_currentIdx == widget.momentCount - 1) {
      //setState(() => _currentIdx = widget.momentCount-1);
      controller.stop();
    }
  }

  void _switchToPrevOrFinish() {
    controller.stop();
    if (_currentIdx - 1 < 0 && widget.onFlashBack != null) {
      widget.onFlashBack();
    } else {
      controller.reset();
      if (_currentIdx - 1 >= 0) {
        setState(() => _currentIdx -= 1);
      }
      controller.duration = widget.momentDurationGetter(_currentIdx);
      controller.forward();
    }
  }

  void _onTapDown(TapDownDetails details) => controller.stop();

  void _onTapUp(TapUpDetails details) {
    final width = MediaQuery.of(context).size.width;
    if (details.localPosition.dx < width * widget.momentSwitcherFraction) {
      _switchToPrevOrFinish();
    }
    else if (details.localPosition.dx >(width - width * widget.momentSwitcherFraction))
    {
      _switchToNextOrFinish();
    }
    else
      controller.forward();
  }

  void _onLongPress() {
    controller.stop();
    setState(() => _isInFullscreenMode = true);
  }

  void _onLongPressEnd() {
    setState(() => _isInFullscreenMode = false);
    controller.forward();
  }

  void _onDragEnd(DragEndDetails details){
    if(details.primaryVelocity>1000)
      widget.onExited();
    //if(_startDragPos)
  }

  void _onTapCancel(){
    _onLongPressEnd();
  }

  void _onSwipeEnd(DragEndDetails details){
    if(details.primaryVelocity>400)
      _switchToPrevOrFinish();
    else if (details.primaryVelocity<-400)
      _switchToNextOrFinish();
  }

  Future<void> _hideStatusBar() => SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  Future<void> _showStatusBar() => SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

  @override
  void initState() {
    if (widget.fullscreen) {
      _hideStatusBar();
    }
    _currentIdx = widget.startAt;
    controller = AnimationController(
      vsync: this,
      duration: widget.momentDurationGetter(_currentIdx),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.autoPlay) {
        _switchToNextOrFinish();
      }
    });
    controller.forward();
    super.initState();
  }

  @override
  void didUpdateWidget(Story oldWidget) {
    if (widget.fullscreen != oldWidget.fullscreen) {
      if (widget.fullscreen) {
        _hideStatusBar();
      } else {
        _showStatusBar();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.stop();
    if (widget.fullscreen)
      _showStatusBar();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            widget.momentBuilder(
              context,
              _currentIdx < widget.momentCount ? _currentIdx : widget.momentCount - 1,
            ),
            widget.showBottomBar?SizedBox():Positioned(
              top: widget.topOffset,  // ?? MediaQuery.of(context).padding.top,
              left: 8.0 - widget.progressSegmentGap / 2,
              right: 8.0 - widget.progressSegmentGap / 2,
              child: AnimatedOpacity(
                opacity: _isInFullscreenMode ? 0.0 : 1.0,
                duration: widget.progressOpacityDuration,
                child: Row(
                  children: <Widget>[...List.generate(
                    widget.momentCount,
                        (idx) {
                      return Expanded(
                        child: idx == _currentIdx ? AnimatedBuilder(
                          animation: controller,
                          builder: (context, _) {
                            return widget.progressSegmentBuilder(
                              context,
                              idx,
                              controller.value,
                              widget.progressSegmentGap,
                            );
                          },
                        ) : widget.progressSegmentBuilder(
                          context, idx, idx < _currentIdx ? 1.0 : 0.0, widget.progressSegmentGap,
                        ),
                      );
                    },
                  )
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                onLongPress: _onLongPress,
                onLongPressUp: _onLongPressEnd,
                onVerticalDragEnd: _onDragEnd,
                onHorizontalDragEnd: _onSwipeEnd,
              ),
            ),
            widget.showBottomBar?Align(
              alignment: Alignment(0, 0.9),
              child: Container(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(widget.momentCount, (_newIndex) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: _currentIdx==_newIndex||(_currentIdx >= widget.momentCount&&_currentIdx==_newIndex+1)?primaryDark:Colors.white, border: Border.all(color: _currentIdx==_newIndex?primaryDark:disabledGrey, width: 1),), //borderGrey
                            width: 10,
                            height: 10,
                          ),
                        )),
                      ),
                      SizedBox(height: 24,),
                    ],
                  )
              ),
            ):SizedBox(),
          ],
        ),
      ),
    );
  }
}