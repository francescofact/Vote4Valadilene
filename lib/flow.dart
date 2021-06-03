
import 'package:flutter/material.dart';
import 'package:steps/steps.dart';
import 'package:v4v/main.dart';

class FlowScreen extends StatefulWidget {
  @override
  _FlowScreenState createState() => _FlowScreenState();
}

class _FlowScreenState extends State<FlowScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Vote4Valiene"),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: Steps(
            direction: Axis.vertical,
            size: 20.0,
            path: {'color': Colors.lightBlue.shade200, 'width': 3.0},
            steps: [
              {
                'color': Colors.white,
                'background': Colors.lightBlue.shade700,
                'label': '1',
                'content': Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Send your vote',
                      style: TextStyle(fontSize: 22.0),
                    ),
                    Text(
                      'Every vote you cast overwrites the previous one',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    SizedBox(height:20.0),
                    ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        ),
                        child: Text("Vote")
                    )
                  ],
                ),
              },
              {
                'color': Colors.white,
                'background': Colors.lightBlue.shade700,
                'label': '2',
                'content': Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Confirm your vote',
                      style: TextStyle(fontSize: 22.0),
                    ),
                    Text(
                      'If you confirm your vote it became valid and unchangable',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    SizedBox(height:20.0),
                    ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        ),
                        child: Text("Confirm")
                    )
                  ],
                )
              },
              {
                'color': Colors.white,
                'background': Colors.lightBlue.shade200,
                'label': '3',
                'content': Image.asset(
                  'assets/wallet.png',
                  width: 250,
                  height: 120,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              }
            ],
          ),
        ));
  }
}