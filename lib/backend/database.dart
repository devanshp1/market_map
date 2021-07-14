import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocation/geolocation.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

bool error = false;
String buyerName;
String buyerPhno;
String buyeremail;

class Dbservice {
  final String uid;
  String buyerPhno;
  String buyeremail;
  Dbservice({this.uid});
  final CollectionReference reference =
      FirebaseFirestore.instance.collection('Users/AppUsers/Buyers');
  final CollectionReference order =
      FirebaseFirestore.instance.collection('Orders');

  Future<String> getname() async {
    var document = reference.doc(uid).get();
    return await document.then((doc) {
      buyerName = doc.data()['Name'];
      buyerPhno = doc.data()['other phone no'];
      buyeremail = doc.data()['email'];

      return buyerName;
    });
  }

  Future placeorder({
    BuildContext context,
    String orderid,
    List<String> idprod,
    String idcust,
    String status,
    String remark,
    List<int> totalamt,
    int ordertotal,
    List<int> quantity,
    List<int> rate,
    String custName,
    List<String> packing,
    List<String> category,
    List<String> prodname,
    String sellerid,
    String add,
  }) async {
    try {
      var dt = DateFormat.yMMMd().format(DateTime.now());
      print(dt);
      return await order.doc(orderid).set({
        "productID": idprod,
        'customerID': idcust,
        "remark": remark ?? 'no remarks',
        'status': status,
        'orderTotal': ordertotal,
        'totalAmount': totalamt,
        'quantity': quantity,
        'productName': prodname,
        'mrp': rate,
        'orderDate': dt,
        'buyerName': custName,
        'netWeight': packing,
        'category': category,
        'orderID': orderid,
        'timeStamp': Timestamp.now(),
        'sellerID': sellerid,
        'deliveryAddress': add,
      });
    } catch (e) {
      print(e);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Could not update,please try again later'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('ok'))
              ],
            );
          });
      error = true;
    }
  }

  Future confirmdelivery({final String sellerid, final String orderid}) async {
    final CollectionReference order1 = order
        .where('customerID', isEqualTo: uid)
        .where('orderid', isEqualTo: orderid);
    return await order1.doc().update({'status': 'delivered'});
  }

  Future createuser({
    BuildContext context,
    final String email,
    final String companyName,
    final String contactname,
    final String gst,
    final GeoPoint loc,
    final String otherphno,
    final String address,
  }) async {
    try {
      return await reference.doc(uid).set({
        "Company's Name": companyName,
        'GST': gst,
        "email": email,
        'Name': contactname,
        'other phone no': otherphno,
        'Geo-location': loc,
        'Address': address
      });
    } catch (e) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Could not update,please try again later'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('ok'))
              ],
            );
          });
    }
  }

  Future updateimage({String uploadedFileURL, BuildContext context}) async {
    try {
      return await reference
          .doc(uid)
          .update({'Selfie': uploadedFileURL}).whenComplete(
              () => print('$uploadedFileURL ins'));
    } catch (e) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Could not update Image,please try again later'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('ok'))
              ],
            );
          });
    }

 
  }

  Stream<UserData> get data {
    return reference.doc(uid).snapshots().map((snap) => UserData(
          contactname: snap.data()['Name'],
          gst: snap.data()['GST'],
          email: snap.data()['email'],
          companyName: snap.data()["Company's Name"],
          otherphno: snap.data()['other phone no'],
          address: snap.data()['Address'],
          loc: snap.data()['Geo-location'],
          image: snap.data()['Selfie'],
        ));
  }
}

class CustomerOrder {
  String idprod;
  String idcust;
  String status;
  String remark;
  double totalamt;
  double quantity;
  double rate;
  DateTime orderdt;
  CustomerOrder();
}

class UserData {
  final String email;
  final String companyName;
  final String contactname;
  final String gst;
  final GeoPoint loc;
  final String otherphno;
  final String address;
  final String image;
  UserData(
      {this.email,
      this.gst,
      this.contactname,
      this.companyName,
      this.loc,
      this.otherphno,
      this.address,
      this.image});
}
//geolocation below

GeoPoint coords;
double lat;
double lon;
GeoPoint cord;
getPermission() async {
  final GeolocationResult result = await Geolocation.requestLocationPermission(
      permission:
          const LocationPermission(android: LocationPermissionAndroid.fine));

  return result;
}

getLocation(BuildContext context) {
  return getPermission().then((result) {
    if (result.isSuccessful) {
      final coords =
          Geolocation.currentLocation(accuracy: LocationAccuracy.best)
              .listen((res) {
        if (res.isSuccessful) {
          lon = res.location.longitude;
          lat = res.location.latitude;
       
          cord = GeoPoint(lat, lon);
         
return cord;
        }
      });

      return coords;
    }
  });
}


//for Image upload
bool load = false;
String uploadedFileURL;
File image;
Future chooseFile(BuildContext mcontext, Dbservice db) async {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      isScrollControlled: true,
      context: mcontext,
      builder: (BuildContext context) {
        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          width: double.infinity,
          height: 200,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10),
                  FloatingActionButton(
                    onPressed: () async {
                      load = true;
                      await ImagePicker()
                          .getImage(source: ImageSource.gallery)
                          .then((value) {
                        image = File(value.path);
                        return image;
                      });
                      Navigator.of(context).pop();

                      return image;
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    splashColor: Colors.greenAccent[700],
                    child: Icon(Icons.image),
                  ),
                  Text('Gallery'),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 10),
                  FloatingActionButton(
                    onPressed: () async {
                      load = true;
                      Navigator.of(context).pop();

                      await ImagePicker()
                          .getImage(source: ImageSource.camera)
                          .then((value) {
                        print("$value.path jjhhlklhjlh");
                        print(value.path);
                        image = File(value.path);
                        return image;
                      });
                      await uploadFile(mcontext, db.uid);
                      await db.updateimage(uploadedFileURL: uploadedFileURL);
                      return image;
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    splashColor: Colors.greenAccent[700],
                    child: Icon(Icons.camera),
                  ),
                  Text('Camera'),
                ],
              ),
            ],
          ),
        );
      });
  return image;
}

Future uploadFile(BuildContext context, String uid) async {
  StorageReference storageReference = FirebaseStorage.instance
      .ref()
      .child('users/buyers/$uid/${path.basename(image.path)}}');
  print(image.path);
  StorageUploadTask uploadTask = storageReference.putFile(image);
  await uploadTask.onComplete;

  //if(uploadTask.isSuccessful){

  await storageReference.getDownloadURL().then((fileURL) {
    final uploadFileURL = fileURL;
    return uploadedFileURL = uploadFileURL;
  });
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          title: Text('Upload'),
          content: Text('Image updated'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('ok'))
          ],
        );
      });
  return uploadedFileURL;
}

