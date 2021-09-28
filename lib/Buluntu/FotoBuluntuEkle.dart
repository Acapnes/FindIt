import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bulundum_mobile/Buluntu/BuluntuListele.dart';
import 'package:bulundum_mobile/Controllers/Colors/primaryColors.dart';
import 'package:bulundum_mobile/Controllers/FunctionManager/mainFM.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart' as ap;
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MainFoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: kPrimaryColor,
          accentColor: kPrimaryColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Ubuntu'),
      home: Scaffold(
        body: FotoBuluntu(),
      ),
      builder: EasyLoading.init(),
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}

class FotoBuluntu extends StatefulWidget {
  @override
  _FotoBuluntuState createState() => _FotoBuluntuState();
}

class _FotoBuluntuState extends State<FotoBuluntu> {
  final imagePicker = ImagePicker();
  ScrollController _bodyScrollController = ScrollController();
  ScrollController _listScrollController = ScrollController();
  TextEditingController _hotelController = TextEditingController();
  var image;
  var imajlarArray = [];
  var mixedArray = [];
  List<AltEsyaNew> AltArray = [];
  int _activeindex = -1;
  double listViewSize = 0;
  File imageFile;
  String imageData, img64 = "";

  Timer _timer;
  double _progress;

  int secondController=200;


  bool _isRecording = false;
  bool _isPaused = false;
  final _audioRecorder = Record();
  bool isRecording = false;
  int _recordDuration = 0, _pathIndex = 0;
  String RecordString = "Ses Kaydını Başlat",mesaj;
  bool isPlaying = false,mainInsert=true;

  Icon elIcon = Icon(Icons.mic);
  Color elColor = Colors.blueAccent;

  AltEsyaNew altesya = AltEsyaNew();


  double itemExtend = 0;

  bool done = false;

  final _audioPlayer = ap.AudioPlayer();
  StreamSubscription<ap.PlayerState> _playerStateChangedSubscription;
  StreamSubscription<Duration> _durationChangedSubscription;
  StreamSubscription<Duration> _positionChangedSubscription;



  getImageAltEsya(int altIndex) async {
    final image = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (image != null) {
        imageFile = File(image.path);
        imageData = base64Encode(imageFile.readAsBytesSync());
        imajlarArray[altIndex].add(imageData);
        mixedArray[altIndex].add(["image",imageData]);
        imajlarArray;
      }
    });
  }

  getImageMainBuluntu() async {
    final image = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (image != null) {
        imageFile = File(image.path);
        imageData = base64Encode(imageFile.readAsBytesSync());
        imajlarArray[0].add(imageData);
        mixedArray[0].add(["image",imageData]);
        setState(() {
          imajlarArray;
        });
      }
    });
  }

  AltEsyaEkle() {
    setState(() {
      this._activeindex++;
      AltArray.add(new AltEsyaNew());
      imajlarArray.add([]);
      mixedArray.add([]);
      print(mixedArray.length);
    });
  }

  @override
  void initState() {
    final status = Permission.microphone.request();
    imajlarArray.add([]);
    mixedArray.add([]);
  }

  @override
  void dispose(){
    super.dispose();
  }

  _showAlertDialogHotel(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Container(
              child: Column(
                children: <Widget>[
                  Text("Lütfen kaydetmek istediğiniz oda numarasını giriniz."),
                  TextField(
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    controller: _hotelController,
                    decoration: InputDecoration(hintText: ''),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                onPressed: (){
                  Navigator.pop(context);
                  Upload();
                },
                child: Text("Tamamla"),
              ),
            ],
          );
        }
    );
    print(_hotelController.text);
  }

  HotelControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.get("CompanyType") != "ctHotel"){
      _showAlertDialogHotel();
    }
  }

  Upload() async {
    //EasyLoading.show(status: 'Loading...',);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var body = {
      'sk1':prefs.get("sk1"),
      'sk2':prefs.get("sk2"),
    };
    int ustsayac = 0;
    int altsayac = 0;
    for (ustsayac = 0; ustsayac < mixedArray.length; ustsayac++) {
      if (mixedArray[ustsayac].length > 0) {
        for (altsayac = 0;
        altsayac < mixedArray[ustsayac].length;
        altsayac++) {
          for(int enAltSayac = 0; enAltSayac < 2; enAltSayac++){
            print([ustsayac,altsayac,enAltSayac]);
            body["items[$ustsayac][$altsayac][$enAltSayac]"] = mixedArray[ustsayac][altsayac][enAltSayac];
            if(prefs.get("CompanyType") == "ctHotel"){
              body["RoomNumber"]= _hotelController.text;
            }
          }
        }
      }
    }
    /*var response = await http.post(
        Uri.parse(
            "https://dev.bulundum.com/api/v3/items/create"),*/
    var response = await http.post(
        Uri.parse(
            setUrl("create")),
        body: body);
    if (response.statusCode == 200) {
      print(body);
      //EasyLoading.showSuccess('Great Success!');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Yükleme başarılı bir şekilde gerçekleşti")));
    } else {
      print("Hata");
    }
  }

  animateToBot() async {
    final double end = _bodyScrollController.position.maxScrollExtent + 600;
    _bodyScrollController.animateTo(end,
        duration: Duration(milliseconds: 800), curve: Curves.easeInOut);
  }

  Future<void> startRecord() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print("Mikrofon izni verildi");
    }
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
          _recordDuration = 0;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> stopRecord(int pathIndex) async {
    final path = await _audioRecorder.stop();

    if(mainInsert==true)
    {
      mixedArray[0].add(["Sound",path]);
      setState(() {
        mixedArray;
      });
    } else if(mainInsert==false){
      mixedArray[_pathIndex+1].add(["Sound",path]);
      setState(() {
        mixedArray;
      });
    }

    //_audioPlayer.setUrl(path);

    setState(() => _isRecording = false);
  }

  Future<void> pauseRecord() async {
    await _audioRecorder.pause();

    setState(() => _isPaused = true);
  }

  Future<void> resumeRecord() async {
    await _audioRecorder.resume();

    setState(() => _isPaused = false);
  }

// ******** Play Codes ********

  Future<void> play() {
    return _audioPlayer.play();
  }

  Future<void> pause() {
    return _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    return _audioPlayer.seek(const Duration(milliseconds: 0));
  }

  void showRecordMenu(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter mystate
                  /*You can rename this!*/) {
                return Container(
                    height: 100,
                    child: Stack(
                        children: <Widget>[
                          Container(
                            child: Center(
                              child: ElevatedButton(
                                child: Container(
                                  width: 175,
                                  height: 50,
                                  child: Row(
                                    children: [
                                      Icon(elIcon.icon,color: elColor,),
                                      Padding(
                                          padding: EdgeInsets.only(left: 20),
                                          child: Text(RecordString,style: TextStyle(color: elColor),)),
                                    ],
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                    elevation: 20,
                                    primary: Colors.white70,
                                    minimumSize: Size(175,50),
                                    side: BorderSide(width: 2.0, color: elColor,)
                                ),
                                onPressed: () {
                                  mystate(() {
                                    if (_isRecording || _isPaused) {
                                      RecordString = "Ses Kaydını Başlat";
                                      elIcon = Icon(Icons.mic);
                                      elColor = Colors.blueAccent;
                                    } else {
                                      elColor = Colors.redAccent;
                                      elIcon = Icon(Icons.stop);
                                      RecordString = "Ses Kaydını Durdur";
                                    }
                                  });
                                  _isRecording ? stopRecord(_pathIndex) : startRecord();
                                },
                              ),
                            ),
                          ),
                        ]));
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24)/2.7;
    final double itemWidth = size.width / 2;
    return Scaffold(
        backgroundColor: kPrimaryColor,
        floatingActionButton: SizedBox(
          width: 120,
          height: 55,
          child: ElevatedButton(
            onPressed: () {

              listViewSize = 600 * (AltArray.length + 1).toDouble();
              _activeindex = AltArray.length - 1;
              AltEsyaEkle();
              animateToBot();
            },
            child: Container(
              child: Column(
                children: [
                  Icon(
                    Icons.add,
                    size: 30,
                  ),
                  Text(
                    "Alt Eşya Ekle",
                  )
                ],
              ),
            ),
          ),
        ),
        appBar: AppBar(elevation: 0,title:Text("Resimli ve Sesli Buluntu Ekle"),centerTitle: true,
          leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MainBuluntuList()));
          },),),
        body: SingleChildScrollView(
          controller: _bodyScrollController,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width-10,
                  height: (MediaQuery.of(context).size.height-200) ,
                  child: Card(
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height - 280,
                          child: mixedArray[0].isEmpty
                              ? GestureDetector(
                            child: Center(
                                child: Text(
                                  "Fotoğraf veya Sesli Kayıt Eklenmedi",
                                  style: TextStyle(fontSize: 18),
                                )),
                          )
                              : Container(
                            height: MediaQuery.of(context).size.height - 200,
                            child: SingleChildScrollView(
                              child: GridView.count(
                                //childAspectRatio: (itemWidth / itemHeight),
                                shrinkWrap: true,
                                primary: true,
                                crossAxisCount: 2,
                                physics: NeverScrollableScrollPhysics(),
                                children: List.generate(
                                    mixedArray[0].length, (index) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    child: Container(
                                      child: mixedArray[0][index][0] != "image" ?
                                      Card(
                                        child: Container(
                                          child: Column(
                                            children: [
                                              ListTile(
                                                title: Text("Ana eşyanın ses kaydı"),
                                              ),
                                              Container(
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                        height: 65,
                                                        margin: EdgeInsets.only(bottom: 10),
                                                        child: ListTile(
                                                          title: Text("Kayıt Türü"),
                                                          subtitle: Text("M4a"),
                                                        )),
                                                    Container(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.spaceAround,
                                                        children: <Widget>[
                                                          ElevatedButton(
                                                            child: Icon(Icons.play_arrow),
                                                            onPressed: () {
                                                              setState(() {
                                                                isPlaying = !isPlaying;
                                                              });
                                                              _audioPlayer.setFilePath(mixedArray[0][index][1]);
                                                              if (!_audioPlayer.playerState.playing) {
                                                                play();
                                                              }
                                                            },
                                                          ),
                                                          ElevatedButton(
                                                            child: Icon(
                                                                Icons.delete),
                                                            onPressed: () {
                                                              _showAlertDialogDelete(0,index);
                                                              //mixedArray[0].removeAt(index);
                                                              setState(() {
                                                                mixedArray;
                                                              });
                                                            },
                                                          ),

                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ): Card(
                                        child: Container(
                                          child: Stack(
                                            children: [
                                              Container(
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: PopupMenuButton(
                                                      iconSize: 20,
                                                      onSelected: (value){
                                                        if(value==2){
                                                          _showAlertDialogDelete(0,index);
                                                          setState(() {
                                                            mixedArray;
                                                          });
                                                        }else if(value==1){

                                                        }
                                                      },
                                                      itemBuilder: (context) => [
                                                        // *******Düzenleme Butonu****
                                                        /*PopupMenuItem(
                                                                              child:
                                                                              Row(
                                                                                children: [
                                                                                  Icon(Icons.edit),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 8.0),
                                                                                    child: Text("Düzenle"),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              value: 1,
                                                                            ),*/
                                                        PopupMenuItem(
                                                          child:
                                                          Row(
                                                            children: [
                                                              Icon(Icons.delete),
                                                              Padding(
                                                                padding: const EdgeInsets.only(left:8.0),
                                                                child: Text("Sil"),
                                                              ),
                                                            ],
                                                          ),
                                                          value: 2,
                                                        ),
                                                      ]),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.center,
                                                child: Container(
                                                  margin: EdgeInsets.only(right: 20),
                                                  height: 165,
                                                  child: Image.memory(
                                                      base64Decode(
                                                          mixedArray[0][index][1])),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          width: MediaQuery.of(context).size.width - 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Align(
                                child: Container(
                                  height: 55,
                                  width: 70,
                                  child: ElevatedButton(
                                    style: ButtonStyle(),
                                    onPressed: () {
                                      getImageMainBuluntu();
                                    },
                                    child: Icon(
                                      Icons.add_a_photo,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                child: Container(
                                  height: 55,
                                  width: 70,
                                  child: ElevatedButton(
                                    style: ButtonStyle(),
                                    onPressed: () {
                                      setState(() {
                                        mainInsert = true;
                                        _pathIndex = 0;
                                      });
                                      showRecordMenu(context);
                                    },
                                    child: Icon(
                                      Icons.mic,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                child: Container(
                                  height: 55,
                                  width: 70,
                                  child: ElevatedButton(
                                    style: ButtonStyle(),
                                    onPressed: () {
                                      _showAlertDialogYesNo();
                                    },
                                    child: Icon(
                                      Icons.upload_file,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: listViewSize,
                  margin: EdgeInsets.only(top: 20, left: 10, right: 10,),
                  child: ListView.builder(
                    controller: _listScrollController,
                    shrinkWrap: true,
                    itemCount: AltArray.length == null ? 0 : AltArray.length,
                    itemBuilder: (context, indexAlt) {
                      return Container(
                          child: Card(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: 25, top: 25),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          (indexAlt + 1).toString() + ". Alt Eşya",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _showAlertDialogDeleteAltEsya(indexAlt);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 15, top: 15),
                                        child: Align(
                                            alignment: Alignment.topRight,
                                            child: Icon(
                                              Icons.delete,
                                              size: 35,
                                              color: Colors.blueAccent,
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 450,
                                  child: Container(
                                    child: mixedArray[indexAlt + 1].isEmpty
                                        ? Center(
                                      child: Text(
                                        "Fotoğraf veya Sesli Kayıt Eklenmedi",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    )
                                        : SingleChildScrollView(
                                      child: Container(
                                        margin: EdgeInsets.only(top: 10),
                                        child: GridView.count(
                                          //childAspectRatio: (itemWidth / itemHeight),
                                          shrinkWrap: true,
                                          primary: true,
                                          crossAxisCount: 2,
                                          physics: NeverScrollableScrollPhysics(),
                                          children: List.generate(mixedArray[indexAlt + 1].length, (i) {
                                            return Container(
                                              width: MediaQuery.of(context).size.width,
                                              child: mixedArray[indexAlt+1][i][0] != "image"  ?
                                              Card(
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        title: Text("Ana eşyanın ses kaydı"),
                                                      ),
                                                      Container(
                                                        child: Column(
                                                          children: <Widget>[
                                                            Container(
                                                                height: 65,
                                                                margin: EdgeInsets.only(bottom: 10),
                                                                child: ListTile(
                                                                  title: Text("Kayıt Türü"),
                                                                  subtitle: Text("M4a"),
                                                                )),
                                                            Container(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment.spaceAround,
                                                                children: <Widget>[
                                                                  ElevatedButton(
                                                                    child: Icon(Icons.play_arrow),
                                                                    onPressed: () {
                                                                      setState(() {
                                                                        isPlaying = !isPlaying;
                                                                      });
                                                                      _audioPlayer.setFilePath(mixedArray[indexAlt+1][i][1]);
                                                                      if (!_audioPlayer.playerState.playing) {
                                                                        play();
                                                                      }
                                                                    },
                                                                  ),
                                                                  ElevatedButton(
                                                                    child: Icon(
                                                                        Icons.delete),
                                                                    onPressed: () {
                                                                      _showAlertDialogDelete(indexAlt+1,i);
                                                                      //mixedArray[indexAlt+1].removeAt(i);
                                                                      setState(() {
                                                                        mixedArray;
                                                                      });
                                                                    },
                                                                  ),

                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ): Card(
                                                child: Container(
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        child: Align(
                                                          alignment: Alignment.topRight,
                                                          child: PopupMenuButton(
                                                              iconSize: 20,
                                                              onSelected: (value){
                                                                if(value==2){
                                                                  _showAlertDialogDelete(indexAlt+1,i);
                                                                  //mixedArray[indexAlt+1].removeAt(i);
                                                                  setState(() {
                                                                    mixedArray;
                                                                  });
                                                                }else if(value==1){

                                                                }
                                                              },
                                                              itemBuilder: (context) => [
                                                                PopupMenuItem(
                                                                  child:
                                                                  Row(
                                                                    children: [
                                                                      Icon(Icons.edit),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(left: 8.0),
                                                                        child: Text("Düzenle"),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  value: 1,
                                                                ),
                                                                PopupMenuItem(
                                                                  child:
                                                                  Row(
                                                                    children: [
                                                                      Icon(Icons.delete),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(left:8.0),
                                                                        child: Text("Sil"),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  value: 2,
                                                                ),
                                                              ]),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment.center,
                                                        child: Container(
                                                          margin: EdgeInsets.only(right: 20),
                                                          height: 165,
                                                          child: Image.memory(
                                                              base64Decode(
                                                                  mixedArray[indexAlt+1][i][1])),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),);
                                          }),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 10, bottom: 10, top: 30),
                                        height: 50,
                                        width: 80,
                                        child: ElevatedButton(
                                          style: ButtonStyle(),
                                          onPressed: () {
                                            getImageAltEsya(indexAlt + 1);
                                          },
                                          child: Icon(
                                            Icons.add_a_photo,
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 10, bottom: 10, top: 30),
                                        height: 50,
                                        width: 80,
                                        child: ElevatedButton(
                                          style: ButtonStyle(),
                                          onPressed: () {
                                            setState(() {
                                              mainInsert = false;
                                              _pathIndex = indexAlt;
                                            });
                                            showRecordMenu(context);
                                          },
                                          child: Icon(
                                            Icons.mic,
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  _showAlertDialogYesNo(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Text("Seçtiklerinizi Yüklemek İstediğinizden Emin Misiniz?")),
            actions: <Widget>[
              MaterialButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  if(prefs.get("CompanyType") != "ctHotel") {
                    Navigator.pop(context);
                    _showAlertDialogHotel();
                  }else{
                    Navigator.pop(context);
                    Upload();
                  }

                },
                child: Text("Evet"),
              ),
              MaterialButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Hayır"),
              ),
            ],
          );
        }
    );
  }

  _showAlertDialogDelete(int ustIndex,int altIndex){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Container(
                margin: EdgeInsets.only(bottom: 20),
                child: mixedArray[ustIndex][altIndex][0] != "image"  ? Text("Resmi silmek istediğinize emin misiniz?") : Text("Sesli kaydı silmek istediğinize emin misiniz?")),
            actions: <Widget>[
              MaterialButton(
                onPressed: (){
                  Navigator.pop(context);
                  mixedArray[ustIndex].removeAt(altIndex);
                  setState(() {
                    mixedArray;
                  });
                },
                child: Text("Evet"),
              ),
              MaterialButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Hayır"),
              ),
            ],
          );
        }
    );
  }
  _showAlertDialogDeleteAltEsya(int esyaIndex){
    showDialog(
        context: context,
        builder: (BuildContext context){
          int length = mixedArray[esyaIndex+1].length;
          return AlertDialog(
            title: Container(
                margin: EdgeInsets.only(bottom: 20),
                child: mixedArray[esyaIndex+1].isEmpty ? Text((esyaIndex).toString()+". Alt Eşyayı silmek istiyor musunuz?")
                    : Text((esyaIndex+1).toString()+". Alt Eşyayı içindeki kayıtlarla birlikte silmek istiyor musunuz?")),
            actions: <Widget>[
              MaterialButton(
                onPressed: (){
                  Navigator.pop(context);
                  for(int altIndex = length-1 ; altIndex > -1;altIndex--){
                    mixedArray[esyaIndex+1].removeAt(altIndex);
                  }
                  AltArray.removeAt(esyaIndex);
                  mixedArray.removeAt(esyaIndex+1);
                  print(mixedArray);
                  setState(() {
                    mixedArray;
                    AltArray;
                    listViewSize -= 600;

                  });
                },
                child: Text("Evet"),
              ),
              MaterialButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Hayır"),
              ),
            ],
          );
        }
    );
  }
}

class AltEsyaNew {
}