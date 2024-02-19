import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hotel_booking_app/services/firestore_services.dart';

import 'add_edit_hotel_info.dart';
import 'profile.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hotels"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminProfile(),
                  ),
                );
              },
              icon: const Icon(
                Icons.account_circle_rounded,
                size: 35.0,
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseServices.hotelCollectionRef().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              QuerySnapshot<Map<String, dynamic>> querySnap = snapshot.data!;

              List<QueryDocumentSnapshot<Map<String, dynamic>>> docSnapList = querySnap.docs;

              List<String> hotelDocIdList = [];
              List<Map<String, dynamic>> fieldList = [];
              int totalRooms = 0;
              int availableRooms = 0;

              for (var docSnap in docSnapList) {
                hotelDocIdList.add(docSnap.id);
                fieldList.add(docSnap.data());
                totalRooms += int.parse(docSnap.data()["totalRoom"].toString());
                availableRooms += int.parse(docSnap.data()["availableRooms"].toString());
              }

              return Column(
                children: [
                  SizedBox(
                    height: 50.0,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      scrollDirection: Axis.horizontal,
                      children: [
                        RawChip(
                          label: Text("Total Rooms : $totalRooms"),
                        ),
                        const SizedBox(width: 5.0),
                        RawChip(
                          label: Text("Available Rooms : $availableRooms"),
                        ),
                        const SizedBox(width: 5.0),
                        RawChip(
                          label: Text("No. of Booking : ${totalRooms - availableRooms}"),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: fieldList.length,
                      itemBuilder: (context, index) {
                        String hotelDocId = hotelDocIdList[index];
                        Map<String, dynamic> field = fieldList[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditHotelInfo(
                                    hotelDocId: hotelDocId,
                                    hotelName: field["hotelName"],
                                    description: field["description"],
                                    address: field["address"],
                                    price: field["price"].toString(),
                                    totalRoom: field["totalRoom"].toString(),
                                    availableRooms: field["availableRooms"].toString(),
                                  ),
                                ),
                              );
                            },
                            tileColor: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade100 : Colors.grey.shade800,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            ),
                            leading: const Icon(Icons.apartment_rounded),
                            title: Text(field["hotelName"]),
                            subtitle: Text(
                              "Rs ${field["price"]} | ${field["address"]}",
                            ),
                            trailing: const Icon(
                              Icons.edit_rounded,
                              size: 18.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text("No data"),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.all(20.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditHotelInfo(),
              ),
            );
          },
          child: const Icon(
            Icons.add,
            size: 38.0,
          ),
        ),
      ),
    );
  }
}
