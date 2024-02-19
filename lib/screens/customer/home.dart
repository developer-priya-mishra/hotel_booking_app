import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_services.dart';
import 'hotel_info.dart';
import 'profile.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
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
                    builder: (context) => const CustomerProfile(),
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

              List<String> docIdList = [];
              List<Map<String, dynamic>> fieldList = [];

              for (var docSnap in docSnapList) {
                docIdList.add(docSnap.id);
                fieldList.add(docSnap.data());
              }

              return ListView.builder(
                itemCount: fieldList.length,
                itemBuilder: (context, index) {
                  String docId = docIdList[index];
                  Map<String, dynamic> field = fieldList[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HotelInfo(docId),
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
                        "Rs ${field["price"]} | Available Rooms: ${field["availableRooms"]} | ${field["address"]}",
                      ),
                    ),
                  );
                },
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
    );
  }
}
