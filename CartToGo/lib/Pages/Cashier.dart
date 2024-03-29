import 'package:carttogo/main.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:io';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcomePage.dart';
import 'paymentCompletion.dart';

class Cashier extends StatelessWidget {
  const Cashier({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    void _showMyDialog() async {
      return showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return Directionality(
                textDirection: TextDirection.rtl,
                child: Dialog(
                    elevation: 0,
                    backgroundColor: Color(0xffffffff),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(height: 15),
                      const Text("هل تريد تسجيل الخروج؟",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 15),
                      Divider(
                        height: 1,
                        color: Colors.black,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: InkWell(
                              highlightColor: Colors.grey[200],
                              onTap: () async {
                                await FirebaseAuth.instance.signOut();
                                print(
                                    "UID: ${FirebaseAuth.instance.currentUser?.uid}");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WelcomePage()));
                              },
                              child: Center(
                                  child: const Text("خروج",
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Color(0xFFFE4A49),
                                        fontWeight: FontWeight.bold,
                                      ))))),
                      Divider(
                        height: 1,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: InkWell(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15.0),
                                  bottomRight: Radius.circular(15.0)),
                              highlightColor: Colors.grey[200],
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Center(
                                  child: Text("إلغاء",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w400,
                                      )))))
                    ])));
          });
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white24,
          title: const Text(
            "دفع الفاتورة",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'CartToGo',
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(3),
                      textStyle: MaterialStateProperty.all(const TextStyle(
                          fontSize: 14,
                          fontFamily: 'CartToGo',
                          fontWeight: FontWeight.bold)),
                      fixedSize: MaterialStateProperty.all(const Size(70, 10)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0))),
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      foregroundColor: MaterialStateProperty.all(Colors.white)),
                  onPressed: () async {
                    _showMyDialog();
                  },
                  child: const Text('خروج')),
            ),
          ],
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage('assets/images/barcode.png')),
              SizedBox(height: 40.0),
              //start scanning butoon
              ElevatedButton(
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(8.0),
                      textStyle: MaterialStateProperty.all(const TextStyle(
                          fontSize: 23, fontFamily: 'CartToGo')),
                      fixedSize: MaterialStateProperty.all(const Size(270, 45)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0))),
                      backgroundColor: MaterialStateProperty.all(appColor),
                      foregroundColor: MaterialStateProperty.all(Colors.white)),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const scanInovice(),
                    ));
                  },
                  child: const Text('البدأ بدفع الفاتورة')),
              //end of start scanning button
            ]));
  }
}

class scanInovice extends StatefulWidget {
  const scanInovice({Key? key}) : super(key: key);
  @override
  State<scanInovice> createState() => _scanInoviceState();
}

class _scanInoviceState extends State<scanInovice> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: false,
            iconTheme: IconThemeData(
              color: appColor,
            ),
            backgroundColor: Colors.white,
            title: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Cashier()));
                },
                child: const Text("عـودة",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CartToGo',
                    )))),
        backgroundColor: Colors.white24,
        body: Column(children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
              flex: 1,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Center(
                        child: const Text(
                            'قم بمسح الرمز الشريطي للفاتورة لاتمام عملية الدفع',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 21)))
                  ]))
        ]));
  }

  Widget _buildQrView(BuildContext context) {
    // check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
            borderColor: appColor,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: scanArea),
        onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p));
  }

  void _onQRViewCreated(QRViewController controller) {
    int check = 0;
    setState(() {
      this.controller = controller;
    });

//if the scanner has read the barcode return to "add new prduct page"
    controller.scannedDataStream.listen((scanData) {
      check++;
      if (check == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PaymentCompletion(scanData.code.toString())));
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يوجد سماح من الكاميرا')));
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

