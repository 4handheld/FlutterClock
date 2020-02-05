// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'package:flutter_svg/flutter_svg.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  double _width = 1;
  Timer _timer;
  var inspirationalQuote = '';

  static const weather_svg = {
    'sunny': 'assets/svg_weather/cloud_sunny.svg',
    'cloudy': 'assets/svg_weather/clouds.svg',
    'foggy': 'assets/svg_weather/fog.svg',
    'rainy': 'assets/svg_weather/rain.svg',
    'snowy': 'assets/svg_weather/snow.svg',
    'thunderstorm': 'assets/svg_weather/storm.svg',
    'windy': 'assets/svg_weather/wind.svg',
  };

  static const horoscope_expire_date = [
    20,
    19,
    21,
    20,
    21,
    21,
    23,
    23,
    23,
    23,
    22,
    22
  ];
  static const horoscope_svg = [
    'assets/starsigns/aquarius.svg',
    'assets/starsigns/pisces.svg',
    'assets/starsigns/aries.svg',
    'assets/starsigns/taurus.svg',
    'assets/starsigns/gemini.svg',
    'assets/starsigns/cancer.svg',
    'assets/starsigns/leo.svg',
    'assets/starsigns/virgo.svg',
    'assets/starsigns/libra.svg',
    'assets/starsigns/scorpio.svg',
    'assets/starsigns/sagittarius.svg',
    'assets/starsigns/capricorn.svg',
  ];

  final inspirationalQuotes = [
    'Time and tide wait for no man',
    'Make haste while the sun shines',
    'Time is what you make of it',
    'The longer you wait, the worse it gets'
  ];

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
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
      _now = DateTime.now();
      inspirationalQuote =
          inspirationalQuotes[((_now.minute) % inspirationalQuotes.length)];

      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  String _getStarSignImage() {
    var month = _now.month - 1;
    var day = _now.day;
    if (day < horoscope_expire_date[month]) {
      month = (month + 11) % 12;
    }
    return horoscope_svg[month];
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    final clockFace = AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: <Widget>[
            //the hour hand
            Container(
              width: double.infinity,
              height: double.infinity,
              child: CircularProgressIndicator(
                semanticsLabel: "Hour${_now.hour > 0 ? 's' : ''}",
                semanticsValue: "${_now.hour}",
                value: ((((_now.hour) % 12) == 0 ? 12 : (_now.hour) % 12) / 12),
                valueColor: AlwaysStoppedAnimation(
                  Colors.deepOrange,
                ),
                strokeWidth: _width / 50,
              ),
            ),

            //the minutes hand
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(_width / 50),
              child: CircularProgressIndicator(
                semanticsLabel: "Minute${_now.minute > 0 ? 's' : ''}",
                semanticsValue: "${_now.minute}",
                value: _now.minute == 0 ? 1 : (_now.minute) / 60,
                valueColor: AlwaysStoppedAnimation(Colors.amber),
                strokeWidth: _width / 50,
              ),
            ),

            //the seconds hand
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(_width / 25),
              child: CircularProgressIndicator(
                semanticsLabel: "Second${_now.second > 0 ? 's' : ''}",
                semanticsValue: "${_now.second}",
                value:  _now.second == 0 ? 1 : (_now.second / 60),
                strokeWidth: _width / 50,
                valueColor: AlwaysStoppedAnimation(Colors.blue),
              ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              child: Text(
                "${DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_now)}:${DateFormat('mm').format(_now)} ${_now.hour >= 12 ? 'PM' : 'AM'}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  decorationStyle: TextDecorationStyle.dotted,
                  fontSize: _width / 15,
                  fontFamily: 'josefin_sans',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ));

    final clockMeta2 = Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      height: double.infinity,
      width: double.infinity,
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.all(2),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
              decoration: BoxDecoration(
                color: Colors.indigo[800],
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    child: SvgPicture.asset(
                      weather_svg[_condition],
                      semanticsLabel: 'The weather is $_condition',
                      alignment: Alignment.center,
                      width: _width / 1,
                      height: _width / 1,
                    ),
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 9),
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  )),
                  Expanded(
                      child: Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Semantics.fromProperties(
                      properties: SemanticsProperties(
                        value:
                            'Temperature is $_temperature within the range of $_temperatureRange ',
                      ),
                      child: Text(
                        '$_temperature',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _width / 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            ),
          ),
          Expanded(
              child: Semantics.fromProperties(
            properties: SemanticsProperties(
                value:
                    ' Today is${DateFormat(DateFormat.WEEKDAY).format(_now)}, ${_now.day},${DateFormat(DateFormat.MONTH).format(_now)},'
                    '${_now.year}, '),
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.indigo[700],
                  image: DecorationImage(
                      image: AssetImage(_getStarSignImage()),
                      fit: BoxFit.contain)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 5, 20, 5),
                    child: Text(
                      " ${DateFormat(DateFormat.ABBR_WEEKDAY).format(_now)}, ${_now.day}",
                      textAlign: TextAlign.right,
                      semanticsLabel: '',
                      style: TextStyle(
                          color: Colors.white,
                          decorationStyle: TextDecorationStyle.dotted,
                          fontSize: _width / 30,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'playfair_display'),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 5, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            "${DateFormat(DateFormat.ABBR_MONTH).format(_now)}, ${_now.year}",
                            textAlign: TextAlign.right,
                            semanticsLabel: '',
                            style: TextStyle(
                              color: Colors.white,
                              decorationStyle: TextDecorationStyle.dotted,
                              fontSize: _width / 30,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'josefin_sans',
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(5, 0, 10, 0),
                            child: SvgPicture.asset(
                              _getStarSignImage(),
                              alignment: Alignment.center,
                              color: Colors.orange,
                              width: _width / 30,
                              height: _width / 30,
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          )),
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                color: Colors.indigo[800],
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    child: Semantics.fromProperties(
                      properties:
                          SemanticsProperties(value: 'Inspirational Quote,,, '),
                      child: Text(
                        ' : $inspirationalQuote',
                        style: TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'courier_prime',
                          fontSize: _width / 45,
                        ),
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 9),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      child: new Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: clockFace,
                ),
              ),
              AspectRatio(
                aspectRatio: 2 / 3,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: clockMeta2,
                ),
              ),
            ],
          )),
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.indigo[900],
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(212, 63, 141, 1),
              Color.fromRGBO(2, 80, 197, 1)
            ]),
      ),
    );
  }
}
