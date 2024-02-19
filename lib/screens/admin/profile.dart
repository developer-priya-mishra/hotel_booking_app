import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_services.dart';
import '../../services/firestore_services.dart';
import '../booking.dart';
import '../signup.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await AuthServices.signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUp(),
                    ),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        error.toString(),
                      ),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(15.0),
        children: [
          const Icon(
            Icons.account_circle_rounded,
            size: 150.0,
          ),
          const SizedBox(height: 10.0),
          Text(
            "${FirebaseAuth.instance.currentUser!.email}",
            style: const TextStyle(
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          ),
          FutureBuilder(
            future: FirebaseServices.getAllAdminDoc(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  List<Map<String, dynamic>> dataList = snapshot.data!;

                  return Column(
                    children: [
                      const SizedBox(height: 20.0),
                      const Divider(),
                      const SizedBox(height: 20.0),
                      const Text(
                        "List of Admin",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10.0),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dataList.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> item = dataList[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade100 : Colors.grey.shade800,
                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            ),
                            height: 50.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.email),
                                const SizedBox(width: 10.0),
                                Text(item["email"]),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              } else {
                return const SizedBox();
              }
            },
          ),
          const SizedBox(height: 20.0),
          const Divider(),
          const SizedBox(height: 20.0),
          const Text(
            "Hotel Bookings",
            style: TextStyle(
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10.0),
          StreamBuilder(
            stream: FirebaseServices.bookingCollectionRef().snapshots(),
            builder: (context, snapshot1) {
              if (snapshot1.connectionState == ConnectionState.active) {
                if (snapshot1.hasData && snapshot1.data!.docs.isNotEmpty) {
                  QuerySnapshot<Map<String, dynamic>> querySnapshot = snapshot1.data!;

                  List<String> bookingDocIdList = [];
                  List<Map<String, dynamic>> bookingFieldList = [];

                  for (var docSnap in querySnapshot.docs) {
                    bookingDocIdList.add(docSnap.id);
                    bookingFieldList.add(docSnap.data());
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bookingFieldList.length,
                    itemBuilder: (context, index) {
                      String bookDocId = bookingDocIdList[index];
                      Map<String, dynamic> bookingField = bookingFieldList[index];

                      return StreamBuilder(
                          stream: FirebaseServices.hotelCollectionRef().doc(bookingField["hotelDocId"]).snapshots(),
                          builder: (context, snapshot2) {
                            if (snapshot2.connectionState == ConnectionState.active) {
                              if (snapshot2.hasData && snapshot2.data!.data() != null) {
                                DocumentSnapshot<Map<String, dynamic>> docSnapshot = snapshot2.data!;

                                Map<String, dynamic> hotelField = docSnapshot.data()!;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Booking(
                                            isBookingEnable: false,
                                            bookingDocId: bookDocId,
                                            hotelDocId: bookingField["hotelDocId"],
                                            hotelName: hotelField["hotelName"],
                                            availableRooms: hotelField["availableRooms"],
                                            price: hotelField["price"],
                                            username: bookingField["name"],
                                            email: bookingField["email"],
                                            phoneNumber: bookingField["contact"],
                                            checkIn: bookingField["checkIn"].toDate(),
                                            checkOut: bookingField["checkOut"].toDate(),
                                            noOfRoomBooked: bookingField["noOfRoom"],
                                            noOfPeople: bookingField["noOfPeople"],
                                          ),
                                        ),
                                      );
                                    },
                                    tileColor: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade100 : Colors.grey.shade800,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    ),
                                    leading: const Icon(Icons.apartment_rounded),
                                    title: Text(bookingField["hotelName"]),
                                    subtitle: Text(
                                      "Rs ${bookingField["totalPrice"]} | Check in: ${bookingField["checkIn"].toDate().toString().split(" ")[0].split("-").reversed.toList().join("-")}",
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox();
                              }
                            } else {
                              return const SizedBox();
                            }
                          });
                    },
                  );
                } else {
                  return const SizedBox(
                    height: 100.0,
                    child: Center(
                      child: Text("No booking available"),
                    ),
                  );
                }
              } else {
                return const SizedBox();
              }
            },
          )
        ],
      ),
    );
  }
}
