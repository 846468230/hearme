import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert' as convert;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'audio_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class WordsAudioDetect extends StatefulWidget {
  WordsAudioDetect({Key key}) : super(key: key);
  _WordsAudioDetectState createState() => new _WordsAudioDetectState();
}

class _WordsAudioDetectState extends State<WordsAudioDetect> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: new Text("文字转语音功能"), //Text("图片中文字转语音"),
        ),
        body: new Container(
          constraints: new BoxConstraints.expand(),
          child: new PageDisplay(),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/bg3.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ));
  }
}

class PageDisplay extends StatefulWidget {
  PageDisplay({Key key}) : super(key: key);
  _PageDisplay createState() => new _PageDisplay();
}

class _PageDisplay extends State<PageDisplay> {
  var _imgPath;
  var abPath;
  var Audiourl;
  var playurl;
  bool ispermined = true;
  String textprint;
  AudioPlayer audioPlayer = new AudioPlayer();
  AudioProvider audioProvider;
  List<Result> results = [];
  Widget resultsWidget = new Text("");
  bool isbase = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    
    return new Center(
      //scrollDirection: Axis.vertical,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
            width: 200.0,
            height: 200.0,
            padding: const EdgeInsets.all(
                20.0), //I used some padding without fixed width and height
            margin: EdgeInsets.only(bottom: 40),
            decoration: new BoxDecoration(
              shape: BoxShape
                  .circle, // You can use like this way or like the below line
              //borderRadius: new BorderRadius.circular(100.0),
              color: Colors.green,
            ),
            child: new FlatButton(
                /*height: 200.0,
              minWidth: 200.0,
              color: Colors.green,*/
                textColor: Colors.white,
                child: new Text(
                  "拍照",
                  textScaleFactor: 2.4,
                ),
                onPressed:
                    _takePhoto), // You can add a Icon instead of text also, like below.
            //child: new Icon(Icons.arrow_forward, size: 50.0, color: Colors.black38)),
          ),

          new Container(
            margin: EdgeInsets.only(bottom: 40),
            child: new MaterialButton(
              height: 100.0,
              minWidth: 220.0,
              color: Colors.green,
              textColor: Colors.white,
              child: new Text(
                "查看检测进度",
                textScaleFactor: 1.8,
              ),
              onPressed: () {
                setState(() {
                  resultsWidget = _resultView();
                });
              },
            ),
          ),
          resultsWidget,
        ],
      ),
    );
  }

  Widget _resultView() {
    if(ispermined==false){
      return new MaterialButton(
        height: 60.0,
        minWidth: 220.0,
        color: Colors.green,
        textColor: Colors.white,
        child: new Text(
          "您禁止了拍照，请于隐私中打开",
          textScaleFactor: 1.4,
        ),
        onPressed: () {},
      ); 
    }
    if (_imgPath == null) {
      /*return new Text(
        "您还没有拍摄图片",
        textScaleFactor: 1.4,
      );*/
      return new MaterialButton(
        height: 60.0,
        minWidth: 220.0,
        color: Colors.green,
        textColor: Colors.white,
        child: new Text(
          "您还没有拍摄图片",
          textScaleFactor: 1.4,
        ),
        onPressed: () {},
      );
    }
    if (playurl == null)
    {
      //audioProvider = new AudioProvider("http://39.106.181.61:9000" + Audiourl);
      textprint = "正在下载音频";
    }
    else if(playurl != null) {
      //audioProvider = new AudioProvider("http://39.106.181.61:9000" + Audiourl);
      
      return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new MaterialButton(
            height: 100.0,
            minWidth: 100.0,
            color: Colors.green,
            textColor: Colors.white,
            child: new Text(
              "播放",
              textScaleFactor: 1.4,
            ),
            onPressed: play,
          ),
          new MaterialButton(
            height: 100.0,
            minWidth: 100.0,
            color: Colors.green,
            textColor: Colors.white,
            child: new Text(
              "停止",
              textScaleFactor: 1.4,
            ),
            onPressed: stop,
          ),
          /*IconButton(
            iconSize: 56.0,
            icon: Icon(Icons.play_arrow),
            color: Colors.red,
            onPressed: play,
          ),
          IconButton(
            iconSize: 56.0,
            icon: Icon(Icons.stop),
            color: Colors.green,
            onPressed: stop,
          )*/
        ],
      );
    }
    return new MaterialButton(
      height: 80.0,
      minWidth: 220.0,
      color: Colors.green,
      textColor: Colors.white,
      child: new Text(
        textprint,
        textScaleFactor: 1.4,
        softWrap: true,
      ),
      onPressed: () {},
    );
  }

  stop() async {
    await audioPlayer.stop();
  }

  play() async {
    //String localUrl = await audioProvider.load();
    //audioPlayer.play(localUrl, isLocal: true);
    int result = await audioPlayer.play(playurl);
    if (result == 1) {
      // success
    }
  }

  Future<void> _baseTheFile(path) async {
    var imageString = await image2Base64(path);
    postNet_2("http://39.106.181.61:9000/audio/", imageString);
    //print(imageString);
  }

  void postNet_2(url_post, data) async {
    var params = Map<String, String>();
    params["img"] = data;
    var client = http.Client();
    var response; 
    try{
      Audiourl = null;
      audioProvider = null;
      playurl = null;
      textprint="正在检测,稍作等待再次点击查看检测进度";
      response = await client.post(url_post, body: params);
      var content = response.body;
      //print(content);
      Audiourl = content;
      playurl = "http://39.106.181.61:9000" + Audiourl;
    } on SocketException catch(e){
      textprint="网络已经断开连接，请连接网络";
    }

    
  }

  _handleData(jsondata) {
    List ress = convert.json.decode(jsondata);
    results = [];
    for (var item in ress) {
      var rul = Result(item['keyword'], item['root']);
      results.add(rul);
    }
  }

  _detectThing() {
    _openGallery();
    isbase = true;
    //print(abPath);
  }

  _takePhoto() async {

    var image;
    try{
      image = await ImagePicker.pickImage(source: ImageSource.camera);
      ispermined = true;
    } catch(e){
      ispermined = false;
      print('aaaa');
    }
    
    //try {
      abPath = image.path;
    //} catch (e) {
    //  print("didn't take a photo");
    //}
    _imgPath = image;
    _baseTheFile(abPath);
    textprint = "正在检测中,请再次点击";
  }

  /*
  * 通过图片路径将图片转换成Base64字符串
  */
  Future image2Base64(String path) async {
    File file = new File(path);
    List<int> imageBytes = await testCompressFile(file);
    return convert.base64Encode(imageBytes);
  }

  Future<List<int>> testCompressFile(File file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 85,
    );
    //print(file.lengthSync());
    //print(result.length);
    return result;
  }

  _openGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    try {
      abPath = image.path;
    } catch (e) {
      //print("didn't pick a photo");
    }
    setState(() {
      _imgPath = image;
    });
  }

  Widget _ImageView(imgPath) {
    if (imgPath == null) {
      return Center(
        child: Text("请选择图片或拍照"),
      );
    } else {
      return Image.file(
        imgPath,
      );
    }
  }
}

class Result {
  String keyword;
  String root;
  Result(this.keyword, this.root);
}