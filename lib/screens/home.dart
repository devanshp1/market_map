import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:market_map/screens/Orders.dart';
import 'package:market_map/screens/Products.dart';
import 'package:market_map/wrapper.dart';
import 'profile/MainProfile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../backend/database.dart';
import 'package:market_map/backend/sharable.dart';

class HomePage extends StatefulWidget {
  final String uid;
  HomePage({this.uid});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    registerNotification();
  }

  void registerNotification() {
    print(widget.uid + '      home');
    Dbservice db = Dbservice(uid: widget.uid);
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      // showNotification(message['notification']);

      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      db.reference.doc(db.uid).update({'token': token});
    }).catchError((err) {
      print(err.message.toString());
    });
  }

  int _current = 0;
  void _onTabtap(int index) {
    setState(() {
      _current = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _children = [
      MProfile(
        uid: widget.uid,
      ),
      Products(uid: widget.uid),
      Orders(uid: widget.uid),
    ];

    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.white,
            onTap: _onTabtap,
            type: BottomNavigationBarType.shifting,
            currentIndex: _current,
            items: [
              BottomNavigationBarItem(
                backgroundColor: Colors.yellowAccent,
                icon: Icon(
                  Icons.person_outline,
                  color: Colors.black,
                ),
                label: "Profile",
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.yellowAccent[700],
                icon: Icon(
                  Icons.toc_rounded,
                  color: Colors.black,
                ),
                label: "Products",
              ),
              BottomNavigationBarItem(
                backgroundColor: Colors.yellow[100],
                icon: Icon(
                  Icons.shopping_bag,
                  color: Colors.black,
                ),
                label: "Orders",
              ),
            ]),

        //     appBar: AppBar(automaticallyImplyLeading: false,
        //  elevation: 0,
        //       brightness: Brightness.dark,
        //       title: Text('Home'),
        //     ),
        body: _children[_current],
        endDrawer: Container(
            //color: Theme.of(context).primaryColor,
            constraints: BoxConstraints(
              maxWidth: w / 1.7,
              // maxHeight: MediaQuery.of(context).size.height,
              // minHeight: MediaQuery.of(context).size.height,
            ),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                )),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(20.0),
              children: <Widget>[
                SizedBox(height: 1),
                ListTile(
                  leading: Icon(Icons.toc),
                  title: Text('Products'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Products(
                                  uid: widget.uid,
                                )));
                  },
                ),
                SizedBox(height: 1),
                ListTile(
                  leading: Icon(Icons.shopping_basket),
                  title: Text('Orders'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Hero(
                                tag: 'order',
                                child: Orders(
                                  uid: widget.uid,
                                ))));
                  },
                ),
                SizedBox(height: 1),
                ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Profile'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MProfile(
                                  uid: widget.uid,
                                )));
                  },
                ),
                SizedBox(height: 1),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Logout'),
                  onTap: () async {
                    Navigator.of(context).pop();

                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            title: Text('LogOut'),
                            content: Text('Are you sure you want to logout?'),
                            actions: <Widget>[
                              TextButton(
                                  style: textButtonstyle,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel')),
                              TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await _auth.signOut();
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Wrapper()));
                                  },
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark),
                                  ))
                            ],
                          );
                        });

                    // Navigator.of(context).popUntil(ModalRoute.withName('/login'));
                  },
                ),
                SizedBox(height: 1),
              ],
            )));
  }
}
