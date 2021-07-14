import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:market_map/backend/sharable.dart';
import 'package:market_map/wrapper.dart';
//import 'database.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

bool newuser = false;

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  final _code = GlobalKey<FormState>();
  bool _isLoading = false;
  String err = '';
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  Future loginUser(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          Navigator.of(context).pop();

          UserCredential result = await _auth.signInWithCredential(credential);

          // ignore: deprecated_member_use

          var user = result.user;

          if (user != null) {
            //setState(() {              _isLoading=false;            });
            newuser = result.additionalUserInfo.isNewUser;
            //  if(newuser)
            //              {
            //               Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(newuser: newuser,)));
            //           }
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Wrapper()));
          } else {
            print("Error");
          }

          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (FirebaseException exception) {
          String err = exception.message.toString();
          print(err);

          // setState(() {            _isLoading=false;            err = exception.toString();            print(err);          });
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  title: Text('Error'),
                  content: Text('$err'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('ok'))
                  ],
                );
              });
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          // setState(() {  _isLoading=false;        });
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
//backgroundColor: Colors.teal[400],
                  title: Text("Enter code"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Form(
                        key: _code,
                        child: TextFormField(
                          validator: (val) {
                            if (val.length < 1) {
                              return 'empty';
                            } else if (val.length < 3) {
                              return 'Incorrect code';
                            } else {
                              return null;
                            }
                          },
                          controller: _codeController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            hintText: "Code",
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Confirm"),
                      onPressed: () async {
                        // setState(() { _isLoading=true;                     });
                        // if (_code.currentState.validate()) {
                        final code = _codeController.text.trim();
                        AuthCredential credential =
                            PhoneAuthProvider.credential(
                                verificationId: verificationId, smsCode: code);

                        UserCredential result;
                        // try {
                        result = await _auth.signInWithCredential(credential);
                        //} catch (e) {
                        //print(e);
                        //setState(() {                              _isLoading=false;                            });
                        /* showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:BorderRadius.all(Radius.circular(20))
                                    ),
                                    title: Text('Error'),
                                    content:
                                        Text('Login Failed try again later'),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('ok'))
                                    ],
                                  );
                                });
                         }*/

                        var user = result.user;
                        if (user != null) {
                          newuser = result.additionalUserInfo.isNewUser;

                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Wrapper()));
                        }
                        //}
                        else {
                          print("Error");
                        }
                      },
                    ),
                    TextButton(
                
                        onPressed: () {
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey),
                        )),
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          //setState(() {            _isLoading=false;          });
          verificationId = verificationId;
          print(verificationId);
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  title: Text('Code Timeout'),
                  content: Text('Please try again'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('ok'))
                  ],
                );
              });
          print("Timeout");
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
          duration: Duration(seconds: 3),
          curve: Curves.easeInOutCirc,
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              image: DecorationImage(
                  fit: BoxFit.fill, image: AssetImage("assets/w1.jpg"))),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size(double.infinity, 90),
            child: AppBar(
              automaticallyImplyLeading: false,
              //backgroundColor: ,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(50))),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Market Map',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              elevation: 16,
            ),
          ),
          body: Container(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            //Text('+91', style: TextStyle(fontSize: 18,color: Colors.white)),
                            Expanded(
                              child: TextFormField(style: TextStyle(color: Colors.white),
                                maxLength: 10,
                                autofocus: false,
                                decoration: InputDecoration(
                                  disabledBorder: OutlineInputBorder(
                                    
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                  ),
                                  prefixText: '+91 ',prefixStyle: TextStyle(color: Colors.white),
                                  filled: true,
                                  fillColor: Colors.grey,
                                  focusColor: Colors.black,
                                  hintText: "Phone number",
                                ),
                                keyboardType: TextInputType.number,
                                controller: _phoneController,
                                validator: (val) {
                                  if (val.length < 1) {
                                    return 'empty field';
                                  } else {
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
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formkey.currentState.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              final String phone =
                                  "+91" + _phoneController.text.trim();

                              await loginUser(phone, context);
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          style: elevatedbutton,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Login',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _phoneController.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            primary: Colors.grey,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('cancel'),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                )
              ],
            ),
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
                  backgroundColor: Colors.amberAccent,
                )),
              ),
            ))
      ],
    ));
  }
}
