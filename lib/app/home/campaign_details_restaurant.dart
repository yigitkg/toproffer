import 'package:flutter/material.dart';
import 'package:login/app/home/campaign_code.dart';
import 'package:login/app/home/models/campaign_model.dart';
import 'package:login/app/services/database.dart';
import 'package:login/common_widgets/form_submit_button.dart';
import 'package:login/common_widgets/platform_alert_dialog.dart';

class CampaignDetailsRestaurantPage extends StatefulWidget {
  CampaignDetailsRestaurantPage(
      {Key key, this.title, @required this.campaign, @required this.database})
      : super(key: key);
  final String title;
  final CampaignModel campaign;
  final Database database;
  @override
  _CampaignDetailsRestaurantPage createState() =>
      _CampaignDetailsRestaurantPage();
}

class _CampaignDetailsRestaurantPage
    extends State<CampaignDetailsRestaurantPage> {
  bool codeButton = false;
  bool checkAvailability = false;
  DateTime now = DateTime.now();
  void checkDate() {
    Duration dur = now.difference(widget.campaign.releaseDate);
    Duration oneDay = Duration(minutes: 1440);
    if (dur >= oneDay) {
      setState(() {
        checkAvailability = true;
      });
    }
  }

  void exception() {
    PlatformAlertDialog(
            title: 'Campaign cannot be deleted',
            content: 'It can be deleted 1 day after the campaign is created.',
            defaultActionText: 'OK')
        .show(context);
  }

  void removeCampaign() async {
    await widget.database.deleteCampaign(widget.campaign);
  }

  void updateCodeButton() {
    setState(() {
      codeButton = true;
    });
  }

  Widget getCode() {
    var code = widget.database.getCode(widget.campaign);
    return StreamBuilder(
        stream: code,
        builder: (context, snapshot) {
          return CampaignCode(code: snapshot.data);
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
            child: Image(
              image: NetworkImage("${widget.campaign.imageUrl}")
            ),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' -> ₺ ${widget.campaign.newPrice.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
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
                OutlineButton(
                  borderSide: BorderSide(
                    color: Colors.blue[200],
                    width: 3.0,
                    style: BorderStyle.solid,
                  ),
                  color: Colors.blue,
                  child: new Text(
                    "GET CODE",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  onPressed: () => updateCodeButton(),
                  shape: new RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.blue,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: new BorderRadius.circular(20.0),
                  ),
                ),
              ],
            ),
          ),
          codeButton
              ? getCode()
              : Text(
                  'Press for getting campaign code',
                  style: TextStyle(color: Colors.blue[900], height: 4),
                  textAlign: TextAlign.center,
                ),
          Container(
            width: 150,
            height: 40,
            child: FlatButton(
              color: Colors.red,
              child: new Text(
                "Delete Campaign",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: checkAvailability ? removeCampaign : exception,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
