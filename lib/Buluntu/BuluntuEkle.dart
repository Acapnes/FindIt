import 'package:bulundum_mobile/Buluntu/FotoBuluntuEkle.dart';
import 'package:bulundum_mobile/Buluntu/QRMenu/QRMenu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class mainBuluntuEkle extends StatelessWidget {
  const mainBuluntuEkle({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 75, left: 30, right: 30),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 5,
                  child: ElevatedButton(
                    child: ListTile(
                      title: Text(
                        "Normal Buluntu Ekle",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      trailing: Icon(
                        Icons.view_list,
                        size: 60,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 5,
                  child: ElevatedButton(
                    child: ListTile(
                      title: Text(
                        "Fotoğraflı ve Sesli Buluntu Ekle",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      trailing: Icon(
                        Icons.add_a_photo,
                        size: 60,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FotoBuluntu()));
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 5,
                  child: ElevatedButton(
                    child: ListTile(
                      title: Text(
                        "QR Kod ile Buluntu Ekle",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      trailing: Icon(
                        Icons.qr_code,
                        size: 60,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => QRMenu()));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
