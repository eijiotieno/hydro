import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _userID = FirebaseAuth.instance.currentUser;
  final _users = FirebaseFirestore.instance.collection("users");

  String _name = '';
  String _photo = '';
  getUserInfo() async {
    QuerySnapshot resultQuery = await _users
        .where(
          'id',
          isEqualTo: _userID!.uid,
        )
        .get();
    if (resultQuery.docs.isNotEmpty) {
      setState(() {
        _name = resultQuery.docs.single['name'];
        _photo = resultQuery.docs.single['photo'];
      });
    }
  }

  @override
  void initState() {
    getUserInfo();
    getLocation().then(
      (value) {
        getAddressFromLatLng();
      },
    );
    // TODO: implement initState
    super.initState();
  }

  GoogleMapController? googleMapController;
  Position? currentPosition;
  String currentAddress = "";

  Future getLocation() async {
    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      // forceAndroidLocationManager: true,
    );
    setState(() {});
  }

  getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition!.latitude,
        currentPosition!.longitude,
      );

      Placemark place = placemarks[0];

      setState(() {
        currentAddress = place.administrativeArea!;
        // "${place.administrativeArea}";
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Set<Marker> createMarker() {
    return <Marker>{
      Marker(
        markerId: const MarkerId("me"),
        position: LatLng(
          currentPosition!.latitude,
          currentPosition!.longitude,
        ),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: const InfoWindow(
          title: "me",
        ),
      ),
    };
  }

  int currentStep = 0;
  StepperType stepperType = StepperType.vertical;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          title: const Text(
            'Hydro App',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: _photo.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                          _photo.toString(),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent,
                Colors.white,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stepper(
                  type: stepperType,
                  physics: const ScrollPhysics(),
                  currentStep: currentStep,
                  onStepTapped: (step) => tapped(step),
                  onStepContinue: continued,
                  onStepCancel: cancel,
                  steps: [
                    Step(
                      title: const Text(
                        'Place an order',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      content: const Text(
                        "Press 'CONTINUE' to place an order",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      isActive: currentStep >= 0,
                      state: currentStep >= 0
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: const Text(
                        'Quantity',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      content: TextFormField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          labelText: '20 litres @ KSH. 30 ',
                          prefixText: 'Bottles : ',
                        ),
                      ),
                      isActive: currentStep >= 0,
                      state: currentStep >= 1
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: const Text(
                        'Location',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      content: SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: GoogleMap(
                          zoomControlsEnabled: false,
                          mapType: MapType.normal,
                          markers: createMarker(),
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              currentPosition!.latitude,
                              currentPosition!.longitude,
                            ),
                            zoom: 15,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            googleMapController = controller;
                          },
                        ),
                      ),
                      isActive: currentStep >= 0,
                      state: currentStep >= 2
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: const Text(
                        'Contact',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      content: TextFormField(
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          prefixText: '+254 7',
                        ),
                      ),
                      isActive: currentStep >= 0,
                      state: currentStep >= 3
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: const Text(
                        'Details',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      content: Column(
                        children: const [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Name : ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Phone : ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Number of bottles : ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Total price : ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      isActive: currentStep >= 0,
                      state: currentStep >= 4
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  switchStepsType() {
    setState(() => stepperType == StepperType.vertical
        ? stepperType = StepperType.horizontal
        : stepperType = StepperType.vertical);
  }

  tapped(int step) {
    setState(() => currentStep = step);
  }

  continued() {
    currentStep < 5 - 1 ? setState(() => currentStep += 1) : currentStep = 0;
  }

  cancel() {
    currentStep > 0 ? setState(() => currentStep -= 1) : currentStep = 0;
  }
}
