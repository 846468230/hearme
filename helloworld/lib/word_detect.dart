import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert' as convert;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class WordsDetect extends StatefulWidget {
  WordsDetect({Key key}) : super(key: key);
  _WordsDetectState createState() => new _WordsDetectState();
}

class _WordsDetectState extends State<WordsDetect> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: new Text("照片文字识别"),
        ),
        body: new Container(
          constraints: new BoxConstraints.expand(),
          child: WordPageDisplay(),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/bg3.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ));
  }
}

class WordPageDisplay extends StatefulWidget {
  WordPageDisplay({Key key}) : super(key: key);
  _WordPageDisplay createState() => new _WordPageDisplay();
}

class _WordPageDisplay extends State<WordPageDisplay> {
  var _imgPath;
  var abPath;
  List<Result> results = [];
  Widget resultsWidget = new Text("");
  bool isbase = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (abPath != null && isbase) {
      _baseTheFile(abPath);
      isbase = false;
    }
    return new SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
              margin: EdgeInsets.all(20),
              child: _ImageView(_imgPath),
              decoration: new BoxDecoration(
                border: new Border.all(
                    color: Color(0xFFFF0000), width: 4), // 边色与边宽度
                color: Color(0xFF9E9E9E), // 底色
                //        borderRadius: new BorderRadius.circular((20.0)), // 圆角度
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey,
                      offset: Offset(5.0, 5.0),
                      blurRadius: 10.0,
                      spreadRadius: 2.0),
                  BoxShadow(color: Color(0x9900FF00), offset: Offset(1.0, 1.0)),
                  BoxShadow(color: Color(0xFF0000FF))
                ],
              )),
          new MaterialButton(
              height: 35.0,
              minWidth: 220.0,
              color: Colors.green,
              textColor: Colors.white,
              child: new Text(
                "拍照",
                textScaleFactor: 1.4,
              ),
              onPressed: _takePhoto),
          new MaterialButton(
              height: 35.0,
              minWidth: 220.0,
              color: Colors.green,
              textColor: Colors.white,
              child: new Text(
                "选择想要检测的图片",
                textScaleFactor: 1.4,
              ),
              onPressed: _detectThing),
          new MaterialButton(
            height: 35.0,
            minWidth: 220.0,
            color: Colors.green,
            textColor: Colors.white,
            child: new Text(
              "查看结果",
              textScaleFactor: 1.4,
            ),
            onPressed: () {
              setState(() {
                resultsWidget = _resultView();
              });
            },
          ),
          resultsWidget,
        ],
      ),
    );
  }

  Widget _resultView() {
    if(_imgPath == null){
      return new Text(
        '还没有选择图片',
        textScaleFactor: 1.0,
      );
    }
    if (results != []) {
      List<Widget> res = [];
      res.add(Text("当前的检测结果为:", textScaleFactor: 1.4));
      List<Widget> words = [];
      for (var item in results) {
        words.add(
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(
            item.word,
            textScaleFactor: 1.4,
            softWrap: true,
          ),
        ]));
      }

      res.add(
        Container(
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: words,
            ),
            decoration: new BoxDecoration(
              border:
                  new Border.all(color: Color(0xFFFF0000), width: 4), // 边色与边宽度
              color: Colors.green[50], // 底色
              //        borderRadius: new BorderRadius.circular((20.0)), // 圆角度
              boxShadow: [
                BoxShadow(
                    color: Colors.grey,
                    offset: Offset(5.0, 5.0),
                    blurRadius: 10.0,
                    spreadRadius: 2.0),
                BoxShadow(color: Color(0x9900FF00), offset: Offset(1.0, 1.0)),
                BoxShadow(color: Color(0xFF0000FF))
              ],
            )),
      );

      return new SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: res,
          ));
    }
  }

  Future<void> _baseTheFile(path) async {
    var imageString = await image2Base64(path);
    postNet_2("http://39.106.181.61:9000/word/", imageString);
    //print(imageString);
  }

  void postNet_2(url_post, data) async {
    var params = Map<String, String>();
    params["img"] = data;
    var client = http.Client();
    var response = await client.post(url_post, body: params);
    var content = response.body;
    //print(content);
    _handleData(content);
  }

  _handleData(jsondata) {
    List ress = convert.json.decode(jsondata);
    results = [];
    for (var item in ress) {
      var rul = Result(item['words']);
      results.add(rul);
    }
  }

  _detectThing() {
    _openGallery();
    isbase = true;
    print(abPath);
  }

  _takePhoto() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    try {
      abPath = image.path;
      isbase = true;
    } catch (e) {
      print("didn't take a photo");
    }
    setState(() {
      _imgPath = image;
    });
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
    print(file.lengthSync());
    print(result.length);
    return result;
  }

  _openGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    try {
      abPath = image.path;
    } catch (e) {
      print("didn't pick a photo");
    }
    setState(() {
      _imgPath = image;
    });
  }

  Widget _ImageView(imgPath) {
    if (imgPath == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("请选择图片或拍照", textScaleFactor: 1.2,),
          Text("(读取照片数据时需要一定时间)", textScaleFactor: 1.0,),
          Text("请耐心等待", textScaleFactor: 1.0,)
        ],
      );
    } else {
      return Image.file(
        imgPath,
      );
    }
  }
}

class Result {
  String word;
  Result(this.word);
}
