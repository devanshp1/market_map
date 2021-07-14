import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:market_map/backend/sharable.dart';
import 'package:market_map/screens/home.dart';
import '../../backend/database.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  final bool newuser;
  @override
  Profile({
    this.newuser,
  }) : super();

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController cncontrol = TextEditingController();
  final _form = GlobalKey<FormState>();
  String email;
  String cn;
  String cpn;
  String address;
  String phno;
  bool edit = true;
  String gst;
  GeoPoint loc;
  final _phoneController = TextEditingController();
  final _cpnController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();

  bool _isLoading = false;

  Future choseFile(BuildContext mcontext, Dbservice db) async {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        isScrollControlled: true,
        context: mcontext,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
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
                        setState(() {
                          _isLoading = true;
                        });
                        await ImagePicker()
                            .getImage(source: ImageSource.gallery)
                            .then((value) {
                          image = File(value.path);
                          return image;
                        });
                        try {
                          await uploadFile(mcontext, db.uid);
                        } catch (e) {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  title: Text('Upload'),
                                  content: Text('Image not updated'),
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
                        setState(() {
                          _isLoading = false;
                        });
                        await db.updateimage(uploadedFileURL: uploadedFileURL);
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
                        Navigator.of(context).pop();
                        setState(() {
                          _isLoading = true;
                        });
                        await ImagePicker()
                            .getImage(source: ImageSource.camera)
                            .then((value) {
                          print(value.path);
                          image = File(value.path);
                          return image;
                        });
                        try {
                          await uploadFile(mcontext, db.uid);
                        } catch (e) {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  title: Text('Upload'),
                                  content: Text('Image not updated'),
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
                        setState(() {
                          _isLoading = false;
                        });
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    Dbservice db = Dbservice(uid: user.uid);

    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Scaffold(
            //appbar
            appBar: PreferredSize(
              preferredSize: Size(double.infinity, 60),
              child: AppBar(automaticallyImplyLeading: false,
                shape: BeveledRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
                elevation: 10,
                backgroundColor: Theme.of(context).primaryColor,
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Create Profile'),
                ),
              ),
            ),
            body: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(12.0),
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Form(
                    key: _form,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 15),
                            CircleAvatar(
                              radius: 75,
                              backgroundImage: image == null
                                  ? AssetImage('assets/l.jpg')
                                  : NetworkImage(uploadedFileURL),
                            ),
                            Visibility(
                              visible: edit,
                              child: FloatingActionButton(
                                onPressed: () async {
                                  await choseFile(context, db);
                                },
                                tooltip: 'Pick',
                                child: Icon(Icons.add_a_photo),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Divider(height: 5),
                        //textfield for company name
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (val) {
                            cn = val;
                          },
                          controller: cncontrol,
                          validator: (val) =>
                              val.length < 1 ? 'It is Empty' : null,
                          maxLines: 1,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.people_outline),
                              labelText: 'Company Name',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)))),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        //textfield for  name
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (val) {
                            cpn = val;
                          },
                          controller: _cpnController,
                          validator: (val) =>
                              val.length < 1 ? 'It is Empty' : null,
                          maxLines: 1,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person_pin),
                              labelText: 'contact person' + "'s name",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)))),
                        ),
                        SizedBox(height: 15),
                        //textfield for  address
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (val) {
                            address = val;
                          },
                          controller: _addressController,
                          validator: (val) =>
                              val.length < 1 ? 'It is Empty' : null,
                          maxLines: 3,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.home),
                              labelText: 'address',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)))),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        //textfield for  email
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          maxLines: 1,
                          onChanged: (val) {
                            email = val;
                          },
                          controller: _emailController,
                          validator: (val) =>
                              val.length < 1 ? 'It is Empty' : null,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              labelText: 'Email Id',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)))),
                        ),
                        SizedBox(height: 15),
                        //textfield for  gst makegsr int
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (val) {
                            gst = val;
                          },
                          controller: _gstController,
                          validator: (val) {
                            if (val.length < 1) {
                              return 'Empty Field';
                            } else {
                              return null;
                            }
                          },
                          maxLines: 1,
                          decoration: InputDecoration(

                              // prefixIcon: Icon(Icons.Gs),
                              labelText: 'Gst no.',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)))),
                        ),
                        SizedBox(height: 15),
                        //textfield for  phone
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          maxLength: 10,
                          onChanged: (value) => phno = value,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            filled: false,
                            fillColor: Colors.blue[200].withOpacity(0.4),
                            labelText: "Phone number",
                          ),
                          controller: _phoneController,
                          validator: (val) {
                            final isDigitsOnly = int.tryParse(val);
                            if (isDigitsOnly != null) {
                              if (val.length < 10) {
                                return 'Less than 10 digits,please check the number';
                              } else if (val.length > 10) {
                                return 'More than 10 digits,please check the number';
                              } else {
                                return null;
                              }
                            } else if (isDigitsOnly == null) {
                              return 'Only enter digits';
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 15),
                        //location button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton(
                            style: elevatedbutton,
                            onPressed: () async {
                              await getLocation(
                                context,
                              );
                              setState(() {
                                loc = GeoPoint(lat, lon);
                              });
                              if (loc != null) {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Loction'),
                                        content: Text('Current Location saved'),
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
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.location_searching),
                                  Text('Get Location'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        //update,cancel buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              //overflowDirection: VerticalDirection.down,
                              children: <Widget>[
                                ElevatedButton.icon(
                                  style: elevatedbutton,
                                  onPressed: () {
                                    setState(() {
                                      cncontrol.clear();
                                      _cpnController.clear();
                                      _addressController.clear();
                                      _emailController.clear();
                                      _gstController.clear();
                                      _phoneController.clear();
                                    });
                                  },
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Colors.black,
                                  ),
                                  label: Text(
                                    'Cancel',
                                  ),
                                ),
                                Spacer(),
                                ElevatedButton.icon(
                                  style: elevatedbutton,
                                  onPressed: () async {
                                    if (_form.currentState.validate()) {
                                      // ignore: unused_local_variable
                                      dynamic result = await db.createuser(
                                          context: context,
                                          companyName: cn,
                                          gst: gst,
                                          email: email,
                                          contactname: cpn,
                                          otherphno: phno,
                                          address: address,
                                          loc: GeoPoint(lat, lon));
                                      await db.updateimage(
                                          uploadedFileURL: uploadedFileURL);
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => HomePage(
                                                    uid: db.uid,
                                                  )));
                                    }
                                  },
                                  icon: Icon(
                                    Icons.file_upload,
                                    color: Colors.black,
                                  ),
                                  label: Text(
                                    'Confirm',
                                  ),
                                ),
                              ]),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          Visibility(
              visible: _isLoading,
              child: Positioned(
                right: 0,
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Center(
                      child: CircularProgressIndicator(
                    strokeWidth: 10,
                  )),
                ),
              )),
        ],
      ),
    );
  }
}
