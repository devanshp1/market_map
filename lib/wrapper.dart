import 'package:flutter/material.dart';
import 'package:market_map/backend/database.dart';
import 'package:market_map/screens/profile/Profile.dart';
import 'package:market_map/screens/home.dart';
import 'screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<User>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data;
            if (user != null) {
              Dbservice db = Dbservice(uid: user.uid);
              return StreamBuilder<UserData>(
                  stream: db.data,
                  builder: (BuildContext context, snap) {
                    if (!snap.hasData) {
                      return Profile(
                        newuser: true,
                      );
                    } else {
                      return HomePage(uid: user.uid);
                    }
                  });
            } else {
              return LoginPage();
            }
          } else {
            return LoginPage();
          }
        });
  }
}
