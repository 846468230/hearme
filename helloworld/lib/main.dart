import 'package:flutter/material.dart';
import 'things_detect.dart';
import 'words_detect.dart';
import 'words_to_audio.dart';

Future<void> main() async {

  // Get a specific camera from the list of available cameras.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "HearText",
      theme: ThemeData(primaryColor: Colors.green),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("聆听"),
          centerTitle: true,
        ),
        body: new HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new ListView(children: <Widget>[
      new Image.asset(
        'images/bg1.jpg',
        height: 240.0,
        fit: BoxFit.cover,
      ),
      new Container(
        padding: const EdgeInsets.all(32.0),
        child: new Text(
          '''
        本应用集成了识别图片中物体,识别图片中的文字,识别图片中的文字,并将文字转换成语音三个功能。使用时可以直接调用系统的相机进行拍照,然后自动检测。也可以从系统相册中选择图片进行检测。
        ''',
          textScaleFactor: 1.4,
          softWrap: true,
        ),
      ),
      new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10),
                ),
                new Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.camera),
                      color: Colors.green,
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new ThingsDetect()));
                      },
                    ),
                    new MaterialButton(
                      height: 50.0,
                      minWidth: 100.0,
                      textColor: Colors.green,
                      child: new Text(
                        "物体识别",
                        textScaleFactor: 1.4,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new ThingsDetect()));
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                ),
                new Column(
                  children: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.camera_enhance),
                      color: Colors.green,
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new WordsDetect()));
                      },
                    ),
                    new MaterialButton(
                      height: 50.0,
                      minWidth: 100.0,
                      textColor: Colors.green,
                      child: new Text(
                        "文字识别",
                        textScaleFactor: 1.4,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new WordsDetect()));
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                ),
                new Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.mic),
                      color: Colors.green,
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new WordsAudioDetect()));
                      },
                    ),
                    new MaterialButton(
                      height: 50.0,
                      minWidth: 100.0,
                      textColor: Colors.green,
                      child: new Text(
                        "图文转语音",
                        textScaleFactor: 1.4,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new WordsAudioDetect()));
                      },
                    )
                  ],
                ),
              ])
        ],
      ),
    ]);
  }
}
