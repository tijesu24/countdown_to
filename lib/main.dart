import 'dart:async';
import 'package:numberpicker/numberpicker.dart';
import 'package:date_time_picker/date_time_picker.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer _timer;
  int pickerValue = 50;
  int timerInitial = 0;
  int endValue = 0;
  int timerCurrDurationSec = 0;
  bool isTimerActive = false;
  String errorMessage = '';

  final dateInPastErrorMSG = "The Date and Time is in the past";

  TextEditingController dateCtl = TextEditingController();

  @override
  void dispose() {
    isTimerActive = false;
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    //If timer is called while timer is still running, we will have a problem
    if (_timer != null) {
      if (_timer.isActive) {
        _timer.cancel();
      }
    }

    isTimerActive = true;
    // So as to show initial value
    setState(() {
      timerCurrDurationSec = 0;
      timerInitial = pickerValue;
    });

    const secDuration = Duration(seconds: 1);
    _timer = Timer.periodic(secDuration, (timer) {
      if (timerCurrDurationSec == endValue) {
        timer.cancel();
        isTimerActive = false;
      } else {
        //Decrease counter
        setState(() {
          timerCurrDurationSec--;
        });
      }
    });
  }

  stopTimer() {}

  @override
  void initState() {
    super.initState();
    dateCtl.text = DateTime.now().toIso8601String();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: buildTimerScreenWidget(),
      ),
    );
  }

  Column buildTimerScreenWidget() {
    return Column(
      children: <Widget>[
        TextField(
            controller: dateCtl,
            decoration: InputDecoration(
              labelText: "Date of visit",
            ),
            onTap: () async {
              DateTime date = DateTime.parse(dateCtl.text);
              FocusScope.of(context).requestFocus(new FocusNode());

              date = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2050));

              if (date != null) dateCtl.text = date.toIso8601String();
            }),
        DateTimePicker(
          type: DateTimePickerType.dateTime,
          // initialValue: dateCtl.text,
          controller: dateCtl,
          dateLabelText: 'Date',
          timeLabelText: "Hour",
          firstDate: DateTime.now(),
          lastDate: DateTime(2050),
          // onChanged: (val) => dateCtl.text = val,
        ),
        RaisedButton(
          onPressed: () {
            if (!isTimerActive &&
                DateTime.parse(dateCtl.text).isAfter(DateTime.now())) {
              //If timer is not active and Date is in future
              setState(() {
                errorMessage = '';
              });
              isTimerActive = !isTimerActive;
            }
            //If Timer is active, stop
            else if (isTimerActive)
              isTimerActive = !isTimerActive;

            //If Timer is not active and date is in past
            else
              setState(() {
                errorMessage = dateInPastErrorMSG;
              });
          },
          child: !isTimerActive ? Text("start") : Text("stop"),
        ),
        Text(errorMessage),
        StreamBuilder(
            stream: Stream.periodic(Duration(seconds: 1), (i) => i),
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              String dateString = '';
              if (isTimerActive == true) {
                DateFormat format = DateFormat("mm:ss");
                int now = DateTime.now().millisecondsSinceEpoch;
                int target =
                    DateTime.parse(dateCtl.text).millisecondsSinceEpoch;
                Duration remaining = Duration(milliseconds: target - now);
                dateString =
                    '${remaining.inHours}:${format.format(DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds))}';
                print(dateString);
              } else
                dateString = "00:00";

              return Container(
                color: Colors.greenAccent.withOpacity(0.3),
                alignment: Alignment.center,
                child: Text(dateString),
              );
            }),
        SizedBox(
          child: CircularProgressIndicator(
            value: timerInitial == 0
                ? 0
                : (timerInitial - timerCurrDurationSec) / timerInitial,
            backgroundColor: Colors.cyan,
          ),
          height: 100,
          width: 100,
        )
      ],
    );
  }
}
