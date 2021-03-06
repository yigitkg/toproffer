import 'dart:async';

import 'package:flutter/material.dart';
import 'package:login/app/home/models/campaign_model.dart';
import 'package:login/app/services/database.dart';
import 'package:login/common_widgets/platform_alert_dialog.dart';

class CampaignDetailsCustomerPage extends StatefulWidget {
  CampaignDetailsCustomerPage(
      {Key key, this.title, @required this.campaign, @required this.database})
      : super(key: key);
  final String title;
  final CampaignModel campaign;
  final Database database;

  @override
  _CampaignDetailsCustomerPage createState() => _CampaignDetailsCustomerPage();
}

class _CampaignDetailsCustomerPage extends State<CampaignDetailsCustomerPage> {
  TextEditingController codeInputController;
  bool code = false;
  bool checkTime = true;
  DateTime now = DateTime.now();

  @override
  void initState() {
    codeInputController = TextEditingController();
    if (widget.campaign.campaignType == "Permenant") {
      time();
    }
  }

  void time() {
    var currentDay = now.day;
    String curDay;
    if (currentDay == 1) {
      curDay = "Mon";
    }
    if (currentDay == 2) {
      curDay = "Tue";
    }
    if (currentDay == 3) {
      curDay = "Wed";
    }
    if (currentDay == 4) {
      curDay = "Thu";
    }
    if (currentDay == 5) {
      curDay = "Fri";
    }
    if (currentDay == 6) {
      curDay = "Sat";
    }
    if (currentDay == 7) {
      curDay = "Sun";
    }
    var campaignStartingHour =
        int.parse(widget.campaign.startingHour.substring(10, 12));
    var currentHour = now.hour;
    var campaignEndingHour =
        int.parse(widget.campaign.endingHour.substring(10, 12));
    var campaignStartingMinutes =
        int.parse(widget.campaign.startingHour.substring(13, 15));
    var currentMinutes = now.minute;
    var campaignEndingMinutes =
        int.parse(widget.campaign.endingHour.substring(13, 15));
    
      if (widget.campaign.campaignDays.contains(curDay)) {
        if (currentHour > campaignStartingHour &&
            currentHour < campaignEndingHour) {
          setState(() {
            checkTime = true;
          });
        } else if (currentHour == campaignStartingHour) {
          if (currentMinutes > campaignStartingMinutes) {
            setState(() {
              checkTime = true;
            });
          } else {
            setState(() {
              checkTime = false;
            });
          }
        } else if (currentHour == campaignEndingHour) {
          if (currentMinutes < campaignEndingMinutes) {
            setState(() {
              checkTime = true;
            });
          } else {
            setState(() {
              checkTime = false;
            });
          }
        } else {
          setState(() {
            checkTime = false;
          });
        }
      } else {
        setState(() {
          checkTime = false;
        });
      }
    
  }

  Future<void> submitCode() async {
    var code = await widget.database.getCodeFuture(widget.campaign);
    final codeText = codeInputController.text;
    print('code text is $codeText, code is $code');

    if (codeText == code) {
      DateTime now = DateTime.now().toUtc().add(Duration(hours: 3));
      String campaignHour;
      int count1 = 0;
      int count2 = 0;

      List<String> hours = [
        '01:00 - 09:00',
        '09:00 - 11:00',
        '11:00 - 13:00',
        '13:00 - 15:00',
        '15:00 - 17:00',
        '17:00 - 19:00',
        '19:00 - 21:00',
        '21:00 - 23:00',
        '23:00 - 01:00'
      ];
      if (now.hour >= 1 && now.hour < 9) {
        campaignHour = '01:00 - 09:00';
      } else if (now.hour >= 9 && now.hour < 11) {
        campaignHour = '09:00 - 11:00';
      } else if (now.hour >= 11 && now.hour < 13) {
        campaignHour = '11:00 - 13:00';
      } else if (now.hour >= 13 && now.hour < 15) {
        campaignHour = '13:00 - 15:00';
      } else if (now.hour >= 15 && now.hour < 17) {
        campaignHour = '15:00 - 17:00';
      } else if (now.hour >= 17 && now.hour < 19) {
        campaignHour = '17:00 - 19:00';
      } else if (now.hour >= 19 && now.hour < 21) {
        campaignHour = '19:00 - 21:00';
      } else if (now.hour >= 21 && now.hour < 23) {
        campaignHour = '21:00 - 23:00';
      } else if (now.hour >= 23 || now.hour < 1) {
        campaignHour = '23:00 - 01:00';
      }

      try {
        var read = await widget.database.getUsedCampaigns(
            now.weekday, widget.campaign.campaignCategory1, campaignHour);
        
        setState(() {
          count1 = int.parse(read);
          count1 += 1;
        });

        if (!widget.campaign.campaignCategory2.contains("Optional")) {
          var read = await widget.database.getUsedCampaigns(
              now.weekday, widget.campaign.campaignCategory2, campaignHour);
          print(read);
          setState(() {
            count2 = int.parse(read);
            count2 += 1;
          });
        }
      } catch (e) {
        rethrow;
      }
      
      try {
        print('read');
        await widget.database.addUsedCampaigns({
          'day': now.weekday,
          'campaign_category': widget.campaign.campaignCategory1,
          'hour': campaignHour,
          'count': count1,
        });
        print('read2');
        if (!widget.campaign.campaignCategory2.contains("Optional")) {
          await widget.database.addUsedCampaigns({
            'day': now.weekday,
            'campaign_category': widget.campaign.campaignCategory2,
            'hour': campaignHour,
            'count': count2,
          });
        }
        print('read3');
        Navigator.of(context).pop();
      } catch (e) {
        rethrow;
      }
    } else {
      print('code is not valid');
      PlatformAlertDialog(
              title: 'Given code is not valid.',
              content: 'Ask waiters to give verified code. ',
              defaultActionText: 'OK')
          .show(context);
    }
  }

  Row _useCodeTextField() {
    return Row(children: <Widget>[
      Container(
        padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
        width: 250,
        child: TextField(
          controller: codeInputController,
          decoration: InputDecoration(
              labelText: 'Use the code',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                  fontSize: 13.0),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[900]))),
        ),
      ),
      Container(
        width: 100,
        child: FlatButton(
          color: Colors.blue,
          textColor: Colors.white,
          disabledColor: Colors.grey,
          disabledTextColor: Colors.black,
          padding: EdgeInsets.fromLTRB(1.0, 2, 1, 2),
          splashColor: Colors.blueAccent,
          onPressed: () {
            submitCode();
          },
          child: Text(
            "Submit Code",
            style: TextStyle(fontSize: 13.0),
          ),
        ),
      )
    ]);
  }

  void changeCode() {
    setState(() {
      code = true;
    });
  }

  List<Widget> _campaignDays(List<dynamic> campaignDays) {
    List<Widget> list = new List<Widget>();
    for (var days in campaignDays) {
      list.add(new Text(
        ' $days ',
        style: TextStyle(fontSize: 18, color: Colors.redAccent),
      ));
    }
    return list;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Campaign Details'),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Container(
            height: 150,
            width: 150,
            child: Image(image: NetworkImage("${widget.campaign.imageUrl}")),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            '${widget.campaign.title}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.blue,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(40),
            //height: 150,
            width: 150,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.campaign.content}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: Text("${widget.campaign.campaignCategory1}",
                  style: TextStyle(fontSize: 16, color: Colors.redAccent))),
          widget.campaign.campaignCategory2.contains("Optional")
              ? Container()
              : Container(
                  alignment: Alignment.center,
                  child: Text(
                    "${widget.campaign.campaignCategory2}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
          SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '₺ ${widget.campaign.oldPrice.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: new TextStyle(
                  color: Colors.black,
                  decoration: TextDecoration.lineThrough,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' -> ₺ ${widget.campaign.newPrice.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Container(
            child: widget.campaign.campaignType == "Momentarily"
                ? Container()
                : Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                _campaignDays(widget.campaign.campaignDays),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "${widget.campaign.startingHour.substring(10, 12)}:${widget.campaign.startingHour.substring(13, 15)} - ",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${widget.campaign.endingHour.substring(10, 12)}:${widget.campaign.endingHour.substring(13, 15)}",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            height: 40,
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                checkTime
                    ? OutlineButton(
                        borderSide: BorderSide(
                          color: Colors.blue[200],
                          width: 3.0,
                          style: BorderStyle.solid,
                        ),
                        color: Colors.blue,
                        child: new Text(
                          "USE CODE",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        onPressed: () => changeCode(),
                        shape: new RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.blue,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: new BorderRadius.circular(20.0),
                        ),
                      )
                    : FlatButton(
                        disabledColor: Colors.red,
                        child: new Text(
                          "Campaign Time Invalid",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: null,
                        shape: new RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.white,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: new BorderRadius.circular(20.0),
                        ),
                      )
              ],
            ),
          ),
          code
              ? _useCodeTextField()
              : Text(
                  'Use the code server gives to you.',
                  style: TextStyle(color: Colors.blue[900], height: 4),
                  textAlign: TextAlign.center,
                )
        ],
      ),
    );
  }
}
