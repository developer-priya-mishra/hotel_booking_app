import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_services.dart';
import '../booking.dart';

class HotelInfo extends StatefulWidget {
  final String hotelDocId;
  const HotelInfo(this.hotelDocId, {super.key});

  @override
  State<HotelInfo> createState() => _HotelInfoState();
}

class _HotelInfoState extends State<HotelInfo> {
  Widget buildTile(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade100 : Colors.grey.shade800,
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 10.0),
          Flexible(child: Text(label)),
        ],
      ),
    );
  }

  Map<String, dynamic> field = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hotel Info"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseServices.hotelCollectionRef().doc(widget.hotelDocId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData && snapshot.data!.data() != null) {
              DocumentSnapshot<Map<String, dynamic>> docSnapshot = snapshot.data!;

              field = docSnapshot.data()!;

              return ListView(
                padding: const EdgeInsets.all(15.0),
                children: [
                  const Icon(
                    Icons.apartment_rounded,
                    size: 150.0,
                  ),
                  Text(
                    field["hotelName"],
                    style: const TextStyle(
                      fontSize: 40.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    field["description"],
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20.0),
                  buildTile(Icons.location_on_rounded, field["address"]),
                  buildTile(Icons.currency_rupee_rounded, field["price"].toString()),
                  buildTile(Icons.local_hotel_rounded, field["availableRooms"].toString()),
                ],
              );
            } else {
              return const Center(
                child: Text("Something went wrong, try again"),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(15.0),
        height: 50.0,
        child: TextButton(
          onPressed: () async {
            if (field["availableRooms"] != null && field["availableRooms"] == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("No room available for booking"),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Booking(
                    hotelDocId: widget.hotelDocId,
                    hotelName: field["hotelName"],
                    availableRooms: field["availableRooms"],
                    price: field["price"],
                  ),
                ),
              );
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            shape: MaterialStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
            ),
          ),
          child: const Text(
            "Book Now",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    );
  }
}
