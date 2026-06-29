import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as omap;
import 'package:geolocator/geolocator.dart';

class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  omap.LatLng userLocation = const omap.LatLng(31.4363, 74.1926);

  // --- 1. Real Details ke sath Hospitals ki List ---
  final List<Map<String, dynamic>> hospitals = [
    {
      "name": "Indus Hospital",
      "pos": const omap.LatLng(31.3855, 74.2125),
      "phone": "+92 42 111 111 880",
      "address": "Jubilee Town, Lahore",
      "specialist": "Dr. Ahmed (Skin Specialist)"
    },
    {
      "name": "Saleem Memorial",
      "pos": const omap.LatLng(31.4376, 74.1901),
      "phone": "+92 42 35948910",
      "address": "Mohlanwal Road, Lahore",
      "specialist": "Dr. Sarah (Dermatologist)"
    },
    {
      "name": "Akhtar Saeed Trust",
      "pos": const omap.LatLng(31.4112, 74.1755),
      "phone": "+92 42 35963351",
      "address": "Tulspura, Canal Bank, Lahore",
      "specialist": "Dr. Usman (Oncologist)"
    },
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        userLocation = omap.LatLng(position.latitude, position.longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Skin Specialists"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: userLocation,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.my_app',
          ),
          MarkerLayer(
            markers: [
              // User ka Marker (Blue)
              Marker(
                point: userLocation,
                width: 80,
                height: 80,
                child: const Icon(Icons.my_location, color: Colors.blue, size: 40),
              ),
              // Hospitals ke Markers (Red)
              ...hospitals.map((h) => Marker(
                point: h['pos'],
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () => _showHospitalDetails(h), // Naya Bottom Sheet Call
                  child: const Icon(Icons.local_hospital, color: Colors.red, size: 35),
                ),
              )).toList(),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. Naya Professional Bottom Sheet (Popup ki jagah) ---
  void _showHospitalDetails(Map<String, dynamic> hospital) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Background transparent rakha hai rounded corners ke liye
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF0D1117), // Dark Theme Match
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upar wali handle bar
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            // Hospital Name
            Text(hospital['name'], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Specialist Name
            Row(
              children: [
                const Icon(Icons.medical_services, color: Colors.cyanAccent, size: 20),
                const SizedBox(width: 10),
                Text(hospital['specialist'], style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),

            // Phone Number
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.greenAccent, size: 20),
                const SizedBox(width: 10),
                Text(hospital['phone'], style: const TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),

            // Address
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(hospital['address'], style: const TextStyle(color: Colors.white70, fontSize: 14))),
              ],
            ),

            const SizedBox(height: 30),

            // Booking Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  Navigator.pop(context); // Sheet band karein
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text("Appointment Request Sent to ${hospital['name']}!"),
                    ),
                  );
                },
                child: const Text("BOOK APPOINTMENT", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}