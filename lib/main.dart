import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hydro_app/home.dart';
import 'package:hydro_app/main_home.dart';
import 'package:hydro_app/mpesa.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';

Future<void> main() async {
  MpesaFlutterPlugin.setConsumerKey("FSMdLAsjoXK3KclanuePiIAfurO0qRRA");
  MpesaFlutterPlugin.setConsumerSecret(" En0m2VGl8NMXvjBX");

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness:
          Brightness.dark, // navigation bar color
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      // status bar color
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthUser(),
    );
  }
}

class AuthUser extends StatefulWidget {
  const AuthUser({Key? key}) : super(key: key);

  @override
  _AuthUserState createState() => _AuthUserState();
}

class _AuthUserState extends State<AuthUser> {
  Future enableLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    User? _user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;

    if (_user != null) {
      final QuerySnapshot resultQuery = await FirebaseFirestore.instance
          .collection('users')
          .where(
            'id',
            isEqualTo: _user.uid,
          )
          .get();

      final List<DocumentSnapshot> _documentSnapshots = resultQuery.docs;

      if (_documentSnapshots.isEmpty) {
        FirebaseFirestore.instance.collection('users').doc(_user.uid).set({
          'name': _user.displayName,
          'photo': _user.photoURL,
          'id': _user.uid,
          'email': _user.email,
          'joined': FieldValue.serverTimestamp(),
        });
      }
    }
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    enableLocation().then(
      (value) {
        FirebaseAuth.instance.authStateChanges().listen(
          (User? user) async {
            if (user == null) {
              signInWithGoogle().then(
                (value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Home();
                      },
                    ),
                  );
                },
              );
            }
            if (user != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Home();
                  },
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff191c1f),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff191c1f),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Padding(
            padding: EdgeInsets.all(10.0),
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
        ),
      ),
    );
  }
}
