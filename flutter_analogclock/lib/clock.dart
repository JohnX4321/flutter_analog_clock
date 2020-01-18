import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';

class AnalogClock extends StatefulWidget {

  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState()=>_AnalogClockState();
}


final Color bgColor=Colors.white;

enum LineType {hour,minute,second}


class _AnalogClockState extends State<AnalogClock> {

  double hour=0,minute=0,seconds=0;
  DateTime _now=DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }


  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }


  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now=DateTime.now();
      _timer=Timer(
        Duration(seconds: 1)-Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
      // Hour hand.
      primaryColor: Color(0xFF4285F4),
      // Minute hand.
      highlightColor: Color(0xFF8AB4F8),
      // Second hand.
      accentColor: Color(0xFF669DF6),
      backgroundColor: Color(0xFFD2E3FC),
    )
        : Theme.of(context).copyWith(
      primaryColor: Color(0xFFD2E3FC),
      highlightColor: Color(0xFF4285F4),
      accentColor: Color(0xFF8AB4F8),
      backgroundColor: Color(0xFF3C4043),
    );
    final time = DateFormat.Hms().format(DateTime.now());
    final weatherInfo = DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_temperature),
          Text(_temperatureRange),
          Text(_condition),
          Text(_location),
        ],
      ),
    );


    return Semantics.fromProperties(properties: SemanticsProperties(
      label: 'Analog clock with time $time',
      value: time,
    ),
      child: Container(
        color: bgColor,
        child: Column(

          children: <Widget>[

            Spacer(),

            Spacer(),

            Center(

              child: Container(

                height: 310,

                width: 310,

                decoration: BoxDecoration(

                    color: Colors.white,

                    shape: BoxShape.circle,

                    boxShadow: [

                      BoxShadow(

                          color: Colors.black26.withOpacity(0.04),

                          blurRadius: 10,

                          offset: Offset(-12, 0),

                          spreadRadius: 2

                      ),

                      BoxShadow(

                          color: Colors.black26.withOpacity(0.04),

                          blurRadius: 10,

                          offset: Offset(12, 0),

                          spreadRadius: 5

                      ),

                    ]

                ),

                child: Padding(

                  padding: const EdgeInsets.all(8.0),

                  child: CustomPaint(

                    painter: LinesPainter(),

                    child: Container(

                      margin: const EdgeInsets.all(32.0),

                      decoration: BoxDecoration(

                          color: bgColor,

                          shape: BoxShape.circle,

                          boxShadow: [

                            BoxShadow(

                                color: Colors.black26.withOpacity(0.03),

                                blurRadius: 5,

                                spreadRadius: 8

                            ),

                          ]

                      ),

                      child: CustomPaint(

                        painter: TimeLinesPainter(

                            lineType: LineType.minute,

                            tick: _now.minute

                        ),

                        child: CustomPaint(

                          painter: TimeLinesPainter(

                              lineType: LineType.hour,

                              tick: _now.hour

                          ),

                          child: CustomPaint(

                              painter: TimeLinesPainter(

                                  lineType: LineType.second,

                                  tick: _now.second

                              )

                          ),

                        ),

                      ),

                    ),

                  ),

                ),

              ),

            ),



            SizedBox(height: 40,),

            Text("Luanda", style: TextStyle(

              color: Colors.redAccent,

              fontSize: 32,

            ),),

            Text("${hour.round()}:${minute.round()} ${TimeOfDay.fromDateTime(_now).period == DayPeriod.am ? 'AM' : 'PM'}", style: TextStyle(

              color: Colors.black,

              fontSize: 50,

            )),

            Spacer()

          ],

        ),
      ),

    );

  }


}










class LinesPainter extends CustomPainter{



  final Paint linePainter;



  final double lineHeight = 8;

  final int maxLines = 30;



  LinesPainter():

        linePainter = Paint()

          ..color = Colors.redAccent

          ..style = PaintingStyle.stroke

          ..strokeWidth = 1.5;



  @override

  void paint(Canvas canvas, Size size) {

    canvas.translate(size.width/2, size.height/2);



    canvas.save();



    final radius = size.width/2;



    List.generate(maxLines, (i){

      canvas.drawLine(

          Offset(0,  radius),

          Offset(0, radius - 8),

          linePainter

      );

      canvas.rotate(2 * pi / maxLines);

    });



    canvas.restore();

  }



  @override

  bool shouldRepaint(CustomPainter oldDelegate) => true;

}


class TimeLinesPainter extends CustomPainter {

  final Paint linePainter;
  final Paint hourPainter;
  final Paint minutePainter;
  final int tick;
  final LineType lineType;

  TimeLinesPainter({this.tick,this.lineType}):
        linePainter=Paint()
          ..color=Colors.redAccent
          ..style=PaintingStyle.stroke
          ..strokeWidth=2.5,
        minutePainter=Paint()
          ..color=Colors.black38
          ..style=PaintingStyle.stroke
          ..strokeWidth=3.5,
        hourPainter=Paint()
          ..color=Colors.black
          ..style=PaintingStyle.stroke
          ..strokeWidth=4.5;


  @override

  void paint(Canvas canvas, Size size) {

    final radius = size.width / 2;



    canvas.translate(radius, radius);



    switch(lineType){

      case LineType.hour:

        canvas.rotate(24 * pi * tick );

        canvas.drawPath(_hourPath(radius), hourPainter);

        break;

      case LineType.minute:

        canvas.rotate(2 * pi * tick );

        canvas.drawPath(_minutePath(radius), minutePainter);

        break;

      case LineType.second:

        canvas.rotate(2 * pi * tick );

        canvas.drawPath(_secondPath(radius), linePainter);

        canvas.drawShadow(_secondPath(radius), Colors.black26, 100, true);



        break;

    }

  }



  Path _hourPath(double radius){

    return Path()

      ..lineTo(0, -((radius/1.4)/2))

      ..close();

  }



  Path _minutePath(double radius){

    return Path()

      ..lineTo(0, -(radius/1.4))

      ..close();

  }



  Path _secondPath(double radius){

    return Path()

      ..lineTo(0, -(radius+10))

      ..close();

  }



  @override

  bool shouldRepaint(CustomPainter oldDelegate) => true;


}

