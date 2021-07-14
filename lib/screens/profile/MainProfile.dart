import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../backend/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MProfile extends StatefulWidget {
  final uid;
  MProfile({this.uid});
  @override
  _MProfileState createState() => _MProfileState();
}

class _MProfileState extends State<MProfile> {
  bool _isLoading = false;
  final _form = GlobalKey<FormState>();

  String email;
  String cn;
  String cpn;
  String address;
  String phno;
  String gst;
  GeoPoint loc;
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
                          print("$value jjhhlklhjlh");
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
                          print("$value.path jjhhlklhjlh");
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

  @override
  Widget build(BuildContext context) {
    Dbservice db = Dbservice(uid: widget.uid);
    UserData ud;
    final bot = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(double.infinity, 60),
              child: AppBar(
                shape: BeveledRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(10)),
                ),
                elevation: 10,
                backgroundColor: Theme.of(context).primaryColor,
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Profile'),
                ),
              ),
            ),
            body: Container(
              child: ListView(shrinkWrap: true, children: <Widget>[
                //  Center(       child: Text('Profile'),        ),
                StreamBuilder<UserData>(
                    stream: db.data,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                            //height: MediaQuery.of(context).size.height / 2,
                            child: Center(
                                child: CircularProgressIndicator(
                          backgroundColor: Colors.black,
                        )));
                      } else {
                        ud = snapshot.data;
                        //print(ud.image);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(height: 10),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Scaffold(
                                                    appBar: AppBar(
                                                        title: Text(
                                                            'Profile Picture')),
                                                    body: Container(
                                                        child: Center(
                                                      child: Container(
                                                          child: Image(
                                                        image: ud.image != null
                                                            ? NetworkImage(
                                                                ud.image)
                                                            : AssetImage(
                                                                'l.jpg'),
                                                      )),
                                                    )),
                                                  )));
                                    },
                                    child: CircleAvatar(
                                        radius: 70,
                                        backgroundImage: ud.image != null
                                            ? NetworkImage(ud.image)
                                            : AssetImage('l.jpg')),
                                  ),
                                  FloatingActionButton(
                                    onPressed: () async {
                                      await choseFile(context, db)
                                          .then((val) async => await uploadFile(
                                                  context, db.uid)
                                              .whenComplete(() => load = false))
                                          .then((v) async {
                                        if (uploadedFileURL != null) {
                                          print(' ob nn');
                                          await db.updateimage(
                                              uploadedFileURL: uploadedFileURL,
                                              context: context);
                                        } else {
                                          print('object');
                                        }
                                      });
                                    },
                                    tooltip: 'Pick Image',
                                    child: Icon(Icons.add_a_photo),
                                  ),
                                  /* Visibility(
                                      visible: !edit,
                                      child: FloatingActionButton.extended(
                                        elevation: 10,isExtended: true,
                                        onPressed: () async {
                                           setState(() {
                                                  edit=!edit;
                                                });
                                               
                                           await uploadFile(context,db.uid);
                                           Future.delayed(Duration(milliseconds:5));
                                        
                                         }
                                        ,
                                        // tooltip: 'Upload Image',
                                        label: Text('Update'),
                                        icon: Icon(Icons.file_upload),
                                      )),*/
                                ]),
                            SizedBox(height: 10),
                            /*Padding(
                              padding:
                                  const EdgeInsets.only(left: 45.0, right: 45.0),
                             child: Divider(
                                height: 5,
                                thickness: 3,
                                color: Colors.greenAccent,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 25.0, right: 25.0),
                              child: Divider(
                                height: 5,
                                thickness: 3,
                                color: Colors.greenAccent,
                              ),
                            ),*/
                            SizedBox(height: 10),
                            //listtile for company name
                            ListTile(
                              leading: Icon(Icons.people_outline),
                              title: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Company's Name",
                                    style: TextStyle(fontSize: 11.0),
                                  ),
                                  Text(ud.companyName ?? 'empty'),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(15))),
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          padding: EdgeInsets.only(bottom: bot),
                                          width: double.infinity,
                                          //  height: MediaQuery.of(context).size.height /  3,
                                          //  child: Text('data'),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom),
                                            child: Form(
                                              key: _form,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  //Text("Enter Company's Name"),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 18),
                                                    child: TextFormField(

                                                        //autovalidateMode: true,
                                                        autofocus: true,
                                                        onChanged: (val) {
                                                          cn = val;
                                                        },
                                                        // controller: cncontrol,
                                                        validator: (val) =>
                                                            val.length < 1
                                                                ? 'It is Empty'
                                                                : null,
                                                        maxLines: 1,
                                                        decoration:
                                                            InputDecoration(
                                                                focusColor: Colors
                                                                    .greenAccent,
                                                                prefixIcon:
                                                                    Icon(Icons
                                                                        .people_outline),
                                                                labelText:
                                                                    'Company Name',
                                                                border:
                                                                    UnderlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                  color: Colors
                                                                      .teal,
                                                                )))),
                                                  ),
                                                  ButtonBar(children: <Widget>[
                                                    TextButton(
                                                      child: Text('Cancel'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text('Update'),
                                                      onPressed: () async {
                                                        if (_form.currentState
                                                            .validate()) {
                                                          try {
                                                            await db.reference
                                                                .doc(db.uid)
                                                                .update({
                                                              "Company's Name":
                                                                  cn
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          } catch (e) {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                barrierDismissible:
                                                                    false,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        'Error'),
                                                                    content: Text(
                                                                        'Could not update,please try again'),
                                                                    actions: <
                                                                        Widget>[
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              Text('ok'))
                                                                    ],
                                                                  );
                                                                });
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ]),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                                icon: Icon(Icons.edit),
                              ),
                            ),
                            SizedBox(height: 10),
                            //listtile for name
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Name",
                                    style: TextStyle(fontSize: 11.0),
                                  ),
                                  Text(ud.contactname ?? 'empty'),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(15))),
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          width: double.infinity,
                                          //  child: Text('data'),
                                          child: Form(
                                            key: _form,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                //Text("Enter Company's Name"),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: TextFormField(
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      autofocus: true,
                                                      onChanged: (val) {
                                                        cpn = val;
                                                      },
                                                      // controller: cncontrol,
                                                      validator: (val) =>
                                                          val.length < 1
                                                              ? 'It is Empty'
                                                              : null,
                                                      maxLines: 1,
                                                      decoration:
                                                          InputDecoration(
                                                              focusColor: Colors
                                                                  .greenAccent,
                                                              prefixIcon: Icon(Icons
                                                                  .people_outline),
                                                              labelText: 'Name',
                                                              border:
                                                                  UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color:
                                                                    Colors.teal,
                                                              )))),
                                                ),
                                                ButtonBar(children: <Widget>[
                                                  TextButton(
                                                    child: Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Update'),
                                                    onPressed: () async {
                                                      if (_form.currentState
                                                          .validate()) {
                                                        try {
                                                          await db.reference
                                                              .doc(db.uid)
                                                              .update({
                                                            "Name": cpn
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        } catch (e) {
                                                          showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      'Error'),
                                                                  content: Text(
                                                                      'Could not update,please try again'),
                                                                  actions: <
                                                                      Widget>[
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: Text(
                                                                            'ok'))
                                                                  ],
                                                                );
                                                              });
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ]),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                icon: Icon(Icons.edit),
                              ),
                            ),
                            //listtile for other phone no
                            SizedBox(height: 10),
                            ListTile(
                              leading: Icon(Icons.phone),
                              title: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "other phone no.",
                                    style: TextStyle(fontSize: 11.0),
                                  ),
                                  Text(ud.otherphno ?? 'empty'),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(15))),
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          width: double.infinity,

                                          //  child: Text('data'),
                                          child: Form(
                                            key: _form,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                //Text("Enter Company's Name"),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: TextFormField(
                                                      keyboardType:
                                                          TextInputType.number,
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      autofocus: true,
                                                      onChanged: (val) {
                                                        phno = val;
                                                      },
                                                      // controller: cncontrol,
                                                      validator: (val) {
                                                        final isDigitsOnly =
                                                            int.tryParse(val);
                                                        if (isDigitsOnly !=
                                                            null) {
                                                          if (val.length < 10) {
                                                            return 'Less than 10 digits,please check the number';
                                                          } else if (val
                                                                  .length >
                                                              10) {
                                                            return 'More than 10 digits,please check the number';
                                                          } else {
                                                            return null;
                                                          }
                                                        } else if (isDigitsOnly ==
                                                            null) {
                                                          return 'Only enter digits';
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      maxLines: 1,
                                                      decoration:
                                                          InputDecoration(
                                                              focusColor: Colors
                                                                  .greenAccent,
                                                              prefixIcon: Icon(Icons
                                                                  .people_outline),
                                                              labelText:
                                                                  'Other phone no',
                                                              border:
                                                                  UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color:
                                                                    Colors.teal,
                                                              )))),
                                                ),
                                                ButtonBar(children: <Widget>[
                                                  TextButton(
                                                    child: Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Update'),
                                                    onPressed: () async {
                                                      if (_form.currentState
                                                          .validate()) {
                                                        try {
                                                          await db.reference
                                                              .doc(db.uid)
                                                              .update({
                                                            "other phone no":
                                                                phno
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        } catch (e) {
                                                          showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      'Error'),
                                                                  content: Text(
                                                                      'Could not update,please try again'),
                                                                  actions: <
                                                                      Widget>[
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: Text(
                                                                            'ok'))
                                                                  ],
                                                                );
                                                              });
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ]),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                icon: Icon(Icons.edit),
                              ),
                            ),
                            SizedBox(height: 10),
                            //Listtile for gst
                            ListTile(
                              leading: Icon(Icons.account_box),
                              title: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "GST no.",
                                    style: TextStyle(fontSize: 11.0),
                                  ),
                                  Text(ud.gst),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(15))),
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          width: double.infinity,

                                          //  child: Text('data'),
                                          child: Form(
                                            key: _form,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                //Text("Enter Company's Name"),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: TextFormField(
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      autofocus: true,
                                                      onChanged: (val) {
                                                        gst = val;
                                                      },
                                                      // controller: cncontrol,
                                                      validator: (val) =>
                                                          val.length < 1
                                                              ? 'It is Empty'
                                                              : null,
                                                      maxLines: 1,
                                                      decoration:
                                                          InputDecoration(
                                                              focusColor: Colors
                                                                  .greenAccent,
                                                              prefixIcon: Icon(Icons
                                                                  .people_outline),
                                                              labelText:
                                                                  'GST no',
                                                              border:
                                                                  UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color:
                                                                    Colors.teal,
                                                              )))),
                                                ),
                                                ButtonBar(children: <Widget>[
                                                  TextButton(
                                                    child: Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Update'),
                                                    onPressed: () async {
                                                      if (_form.currentState
                                                          .validate()) {
                                                        try {
                                                          await db.reference
                                                              .doc(db.uid)
                                                              .update(
                                                                  {"GST": gst});
                                                          Navigator.of(context)
                                                              .pop();
                                                        } catch (e) {
                                                          showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      'Error'),
                                                                  content: Text(
                                                                      'Could not update,please try again'),
                                                                  actions: <
                                                                      Widget>[
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: Text(
                                                                            'ok'))
                                                                  ],
                                                                );
                                                              });
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ]),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                icon: Icon(Icons.edit),
                              ),
                            ),
                            SizedBox(height: 10),
                            //Listtile for emmail
                            ListTile(
                              leading: Icon(Icons.email),
                              title: Text(ud.email ?? "empty"),
                              trailing: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(15))),
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          width: double.infinity,
                                          //  child: Text('data'),
                                          child: Form(
                                            key: _form,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                //Text("Enter Company's Name"),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: TextFormField(
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      autofocus: true,
                                                      onChanged: (val) {
                                                        email = val;
                                                      },
                                                      // controller: cncontrol,
                                                      validator: (val) =>
                                                          val.length < 1
                                                              ? 'It is Empty'
                                                              : null,
                                                      maxLines: 1,
                                                      decoration:
                                                          InputDecoration(
                                                              focusColor: Colors
                                                                  .greenAccent,
                                                              prefixIcon: Icon(Icons
                                                                  .people_outline),
                                                              labelText:
                                                                  'Email',
                                                              border:
                                                                  UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color:
                                                                    Colors.teal,
                                                              )))),
                                                ),
                                                ButtonBar(children: <Widget>[
                                                  TextButton(
                                                    child: Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Update'),
                                                    onPressed: () async {
                                                      if (_form.currentState
                                                          .validate()) {
                                                        try {
                                                          await db.reference
                                                              .doc(db.uid)
                                                              .update({
                                                            "email": email
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        } catch (e) {
                                                          showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      'Error'),
                                                                  content: Text(
                                                                      'Could not update,please try again'),
                                                                  actions: <
                                                                      Widget>[
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: Text(
                                                                            'ok'))
                                                                  ],
                                                                );
                                                              });
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ]),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                icon: Icon(Icons.edit),
                              ),
                            ),
                            //list  address
                            SizedBox(height: 10),
                            ListTile(
                              leading: Icon(Icons.home),
                              title: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Address",
                                    style: TextStyle(fontSize: 11.0),
                                  ),
                                  Text(ud.address),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(15))),
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          width: double.infinity,

                                          //  child: Text('data'),
                                          child: Form(
                                            key: _form,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                //Text("Enter Company's Name"),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: TextFormField(
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      autofocus: true,
                                                      onChanged: (val) {
                                                        address = val;
                                                      },
                                                      // controller: cncontrol,
                                                      validator: (val) => val
                                                                  .length <
                                                              10
                                                          ? 'Incomplete Address'
                                                          : null,
                                                      maxLines: 3,
                                                      decoration:
                                                          InputDecoration(
                                                              focusColor: Colors
                                                                  .greenAccent,
                                                              prefixIcon: Icon(Icons
                                                                  .people_outline),
                                                              labelText:
                                                                  'Address',
                                                              border:
                                                                  UnderlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                color:
                                                                    Colors.teal,
                                                              )))),
                                                ),
                                                ButtonBar(children: <Widget>[
                                                  TextButton(
                                                    child: Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Update'),
                                                    onPressed: () async {
                                                      if (_form.currentState
                                                          .validate()) {
                                                        try {
                                                          await db.reference
                                                              .doc(db.uid)
                                                              .update({
                                                            "Address": address
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        } catch (e) {
                                                          showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      'Error'),
                                                                  content: Text(
                                                                      'Could not update,please try again'),
                                                                  actions: <
                                                                      Widget>[
                                                                    TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: Text(
                                                                            'ok'))
                                                                  ],
                                                                );
                                                              });
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ]),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                icon: Icon(Icons.edit),
                              ),
                            ),
                            //Listile for  loc
                            SizedBox(height: 10),
                            ListTile(
                              leading: Icon(Icons.my_location),
                              subtitle: ud.loc != null
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text('Longitude : ' +
                                            ud.loc.longitude.toString()),
                                        SizedBox(height: 5),
                                        Text('Latitude : ' +
                                            ud.loc.latitude.toString()),
                                      ],
                                    )
                                  : Text('empty'),
                              trailing: IconButton(
                                onPressed: () async {
                                  try {
                                    await getLocation(context);

                                    await db.reference.doc(db.uid).update(
                                        {"Geo-location": GeoPoint(lat, lon)});
                                  } catch (e) {
                                    print(e.toString());
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Loction'),
                                            content: Text(
                                                'Current Location not saved'),
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
                                  if (lat != null) {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Loction'),
                                            content:
                                                Text('Current Location saved'),
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
                                tooltip: "get location",
                                icon: Icon(Icons.edit_location),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        );
                      }
                    }),
              ]),
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
