import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scan_blp/common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qrscan/qrscan.dart' as scanner;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scan BLP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'QR Scan BLP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController? _outputController;

  @override
  initState() {
    super.initState();
    this._outputController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40, // Image radius
                child: Image.asset('assets/images/brilliantpy_logo.jpg'),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: this._outputController,
                maxLines: 2,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.qr_code),
                  hintText:
                      'The barcode or qrcode you scan will be displayed in this area.',
                  hintStyle: TextStyle(fontSize: 15),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 7, vertical: 15),
                ),
              ),
              SizedBox(height: 20),
              this._buttonGroup(),
              SizedBox(height: 20),
              TextButton(
                  onPressed: () async {
                    String qr_str = this._outputController!.text;
                    if (qr_str == "") {
                      return;
                    }
                    String _name = qr_str.split("||:||")[0].trim();
                    String _index = qr_str.split("||:||")[1].trim();
                    String req_url_full = req_url +
                        "?action=checked&name=$_name&index=$_index&key=$key";
                    print("zzz $req_url_full");
                    await launchUrl(Uri.parse(req_url_full),
                        mode: LaunchMode.externalApplication);
                  },
                  child: Text("Confirm Check in")),
            ],
          ),
        ));
  }

  Widget _buttonGroup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        SizedBox(
          child: TextButton(
            onPressed: _scan,
            child: Text("Scan"),
          ),
        ),
        SizedBox(
          child: TextButton(
            onPressed: _scanPhoto,
            child: Text("Find Image"),
          ),
        ),
      ],
    );
  }

  Future _scan() async {
    await Permission.camera.request();
    String? barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      this._outputController!.text = barcode;
    }
  }

  Future _scanPhoto() async {
    await Permission.storage.request();
    String barcode = await scanner.scanPhoto();
    this._outputController!.text = barcode;
  }
}
