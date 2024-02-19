import 'package:flutter/material.dart';

import '../../component/loading_dialog.dart';
import '../../services/firestore_services.dart';

class AddEditHotelInfo extends StatefulWidget {
  final String hotelDocId;
  final String hotelName;
  final String description;
  final String address;
  final String totalRoom;
  final String availableRooms;
  final String price;
  const AddEditHotelInfo({
    super.key,
    this.hotelDocId = "",
    this.hotelName = "",
    this.description = "",
    this.address = "",
    this.price = "1000",
    this.totalRoom = "1",
    this.availableRooms = "1",
  });

  @override
  State<AddEditHotelInfo> createState() => _AddEditHotelInfoState();
}

class _AddEditHotelInfoState extends State<AddEditHotelInfo> {
  late final TextEditingController hotelNameController;
  late final TextEditingController descriptionController;
  late final TextEditingController addressController;
  late final TextEditingController priceController;
  late final TextEditingController totalRoomsController;
  late final TextEditingController availableRoomsController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    hotelNameController = TextEditingController(text: widget.hotelName);
    descriptionController = TextEditingController(text: widget.description);
    addressController = TextEditingController(text: widget.address);
    priceController = TextEditingController(text: widget.price);
    totalRoomsController = TextEditingController(text: widget.totalRoom);
    availableRoomsController = TextEditingController(text: widget.availableRooms);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotelDocId.isEmpty ? "Add Hotel Info" : "Edit Hotel Info"),
        centerTitle: true,
        actions: [
          if (widget.hotelDocId.isNotEmpty)
            IconButton(
              onPressed: () async {
                LoadingDialog(context);
                try {
                  await FirebaseServices.deleteHotelInfo(widget.hotelDocId);
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Hotel info deleted successfully"),
                      ),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    Navigator.pop(context);
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
              icon: const Icon(Icons.delete_rounded),
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(15.0),
          children: [
            // name
            TextFormField(
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Enter hotel name";
                }
                return null;
              },
              controller: hotelNameController,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15.0),
            // description
            TextFormField(
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Enter hotel description";
                }
                return null;
              },
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15.0),
            // address
            TextFormField(
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Enter hotel address";
                }
                return null;
              },
              controller: addressController,
              keyboardType: TextInputType.streetAddress,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15.0),
            // price
            TextFormField(
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Enter hotel room price";
                } else if (value.trim() == "0") {
                  return "Hotel room price cannot be zero";
                }
                return null;
              },
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15.0),
            // total room
            TextFormField(
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Enter number of rooms";
                } else if (value.trim() == "0") {
                  return "Number of rooms cannot be zero";
                }
                return null;
              },
              controller: totalRoomsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Total room",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15.0),
            // available room
            TextFormField(
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Enter available number of rooms";
                } else if (totalRoomsController.text.trim().isEmpty) {
                  return "Enter number of rooms";
                } else if (totalRoomsController.text.trim() == "0") {
                  return "Number of rooms cannot be zero";
                } else if (int.parse(value) > int.parse(totalRoomsController.text)) {
                  return "Available rooms cannot be greater than total room";
                }
                return null;
              },
              controller: availableRoomsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Available rooms",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(15.0),
        height: 50.0,
        child: TextButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              LoadingDialog(context);
              try {
                if (widget.hotelDocId.isEmpty) {
                  await FirebaseServices.addHotelInfo({
                    "hotelName": hotelNameController.text.trim(),
                    "description": descriptionController.text.trim(),
                    "address": addressController.text.trim(),
                    "price": int.parse(priceController.text),
                    "totalRoom": int.parse(totalRoomsController.text),
                    "availableRooms": int.parse(availableRoomsController.text),
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Hotel info added successfully"),
                      ),
                    );
                  }
                } else {
                  await FirebaseServices.editHotelInfo(widget.hotelDocId, {
                    "hotelName": hotelNameController.text.trim(),
                    "description": descriptionController.text.trim(),
                    "address": addressController.text.trim(),
                    "price": int.parse(priceController.text),
                    "totalRoom": int.parse(totalRoomsController.text),
                    "availableRooms": int.parse(availableRoomsController.text),
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Hotel info edited successfully"),
                      ),
                    );
                  }
                }
              } catch (error) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        error.toString(),
                      ),
                    ),
                  );
                }
              }
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
            "Submit",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    );
  }
}
