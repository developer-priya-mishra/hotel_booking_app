import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../component/loading_dialog.dart';
import '../services/firestore_services.dart';

class Booking extends StatefulWidget {
  final bool isBookingEnable;
  final String bookingDocId;
  final String hotelDocId;
  final String hotelName;
  final int availableRooms;
  final int price;
  final String username;
  final String email;
  final String phoneNumber;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int noOfRoomBooked;
  final int noOfPeople;

  const Booking({
    super.key,
    this.isBookingEnable = true,
    this.bookingDocId = "",
    required this.hotelDocId,
    required this.hotelName,
    required this.availableRooms,
    required this.price,
    this.username = "",
    this.email = "",
    this.phoneNumber = "",
    this.checkIn,
    this.checkOut,
    this.noOfRoomBooked = 1,
    this.noOfPeople = 2,
  });

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneNumberController;

  late DateTime checkInDateTime;
  late DateTime checkOutDateTime;

  late int noOfRoomBooked;
  late int noOfPeople;
  int totalPrice = 0;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.username);
    emailController = TextEditingController(text: widget.email.isEmpty ? FirebaseAuth.instance.currentUser!.email : widget.email);
    phoneNumberController = TextEditingController(text: widget.phoneNumber);

    checkInDateTime = widget.checkIn ??
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          12,
        );

    checkOutDateTime = widget.checkOut ??
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day + 1,
          12,
        );

    noOfRoomBooked = widget.noOfRoomBooked;
    noOfPeople = widget.noOfPeople;

    totalPrice = widget.price * (checkOutDateTime.day - checkInDateTime.day) * noOfRoomBooked;
  }

  Future<void> chooseCheckIn() async {
    DateTime? choosedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      currentDate: checkInDateTime,
      helpText: "Choose check in date",
      barrierDismissible: false,
    );

    if (context.mounted) {
      if (choosedDate != null) {
        TimeOfDay? choosedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: checkInDateTime.hour,
            minute: checkInDateTime.minute,
          ),
          helpText: "Choose check in time",
          barrierDismissible: false,
        );

        if (choosedTime != null) {
          DateTime oldCheckInDateTime = checkInDateTime;

          setState(() {
            checkInDateTime = DateTime(
              choosedDate.year,
              choosedDate.month,
              choosedDate.day,
              choosedTime.hour,
              choosedTime.minute,
            );
            totalPrice = widget.price * (checkOutDateTime.day - checkInDateTime.day) * noOfRoomBooked;
          });

          bool isCheckOutChoosen = await chooseCheckOut();

          if (!isCheckOutChoosen) {
            setState(() {
              checkInDateTime = oldCheckInDateTime;
            });
          }
        }
      }
    }
  }

  Future<bool> chooseCheckOut() async {
    DateTime? choosedDate = await showDatePicker(
      context: context,
      firstDate: checkInDateTime.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      currentDate: checkOutDateTime,
      helpText: "Choose check out date",
      barrierDismissible: false,
    );

    if (context.mounted) {
      if (choosedDate != null) {
        TimeOfDay? choosedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: checkOutDateTime.hour,
            minute: checkOutDateTime.minute,
          ),
          helpText: "Choose check out time",
          barrierDismissible: false,
        );

        if (choosedTime != null) {
          setState(() {
            checkOutDateTime = DateTime(
              choosedDate.year,
              choosedDate.month,
              choosedDate.day,
              choosedTime.hour,
              choosedTime.minute,
            );
            totalPrice = widget.price * (checkOutDateTime.day - checkInDateTime.day) * noOfRoomBooked;
          });
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookingDocId.isEmpty
            ? "Book Room"
            : widget.isBookingEnable
                ? "Edit Booked Room"
                : "Booked Room Info"),
        centerTitle: true,
        actions: [
          if (widget.isBookingEnable && widget.bookingDocId.isNotEmpty)
            IconButton(
              onPressed: () async {
                LoadingDialog(context);
                try {
                  await FirebaseServices.deleteBookingInfo(widget.bookingDocId);
                  await FirebaseServices.editHotelInfo(widget.hotelDocId, {
                    "availableRooms": widget.availableRooms + noOfRoomBooked,
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Booking deleted successfully"),
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
            // hotel title
            Row(
              children: [
                const Icon(Icons.apartment_rounded),
                const SizedBox(width: 5.0),
                const Text("Hotel:"),
                const SizedBox(width: 15.0),
                Expanded(
                  child: Text(
                    widget.hotelName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            // full username
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 5.0),
                const Text("Name:"),
                const SizedBox(width: 15.0),
                Expanded(
                  child: TextFormField(
                    readOnly: !widget.isBookingEnable,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter full name';
                      }
                      return null;
                    },
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Peter",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            // email
            Row(
              children: [
                const Icon(Icons.email),
                const SizedBox(width: 5.0),
                const Text("Email:"),
                const SizedBox(width: 15.0),
                Expanded(
                  child: TextFormField(
                    readOnly: !widget.isBookingEnable,
                    validator: (value) {
                      RegExp emailRegExp = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                      );

                      if (value == null || value.trim().isEmpty) {
                        return 'Enter email address';
                      } else if (!value.contains(emailRegExp)) {
                        return 'Enter valid email address';
                      }
                      return null;
                    },
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "peter@gmail.com",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            // contact no
            Row(
              children: [
                const Icon(Icons.phone),
                const SizedBox(width: 5.0),
                const Text("Contact:"),
                const SizedBox(width: 15.0),
                Expanded(
                  child: TextFormField(
                    readOnly: !widget.isBookingEnable,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter phone number';
                      }
                      if (value.trim().length < 10) {
                        return "Enter valid phone number";
                      }
                      return null;
                    },
                    maxLength: 10,
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "+91 9876543210",
                      counterText: "",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            // check in datetime
            Row(
              children: [
                const Icon(Icons.calendar_month),
                const SizedBox(width: 5.0),
                const Text("Check In:"),
                const SizedBox(width: 15.0),
                SizedBox(
                  height: 50.0,
                  child: TextButton(
                    onPressed: () async {
                      if (widget.isBookingEnable) {
                        await chooseCheckIn();
                      }
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 18.0),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                          side: BorderSide(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    child: Text(
                      "${checkInDateTime.day}-${checkInDateTime.month}-${checkInDateTime.year} | ${TimeOfDay(
                        hour: checkInDateTime.hour,
                        minute: checkInDateTime.minute,
                      ).format(context)}",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            // check out datetime
            Row(
              children: [
                const Icon(Icons.calendar_month),
                const SizedBox(width: 5.0),
                const Text("Check out:"),
                const SizedBox(width: 15.0),
                SizedBox(
                  height: 50.0,
                  child: TextButton(
                    onPressed: () async {
                      if (widget.isBookingEnable) {
                        await chooseCheckOut();
                      }
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 18.0),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                          side: BorderSide(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    child: Text(
                      "${checkOutDateTime.day}-${checkOutDateTime.month}-${checkOutDateTime.year} | ${TimeOfDay(
                        hour: checkOutDateTime.hour,
                        minute: checkOutDateTime.minute,
                      ).format(context)}",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15.0),
            // no of rooms
            Row(
              children: [
                const Icon(Icons.bed_rounded),
                const SizedBox(width: 5.0),
                const Text("No of rooms:"),
                const SizedBox(width: 15.0),
                Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                    border: Border.all(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (widget.isBookingEnable) {
                            setState(() {
                              noOfRoomBooked == 1 ? 1 : noOfRoomBooked--;
                              noOfPeople = noOfRoomBooked * 2;
                              totalPrice = widget.price * (checkOutDateTime.day - checkInDateTime.day) * noOfRoomBooked;
                            });
                          }
                        },
                        icon: Icon(
                          Icons.remove,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        '$noOfRoomBooked',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (widget.isBookingEnable) {
                            setState(() {
                              if (widget.bookingDocId.isEmpty) {
                                noOfRoomBooked == widget.availableRooms ? widget.availableRooms : noOfRoomBooked++;
                              } else {
                                noOfRoomBooked == widget.availableRooms + widget.noOfRoomBooked ? widget.availableRooms + widget.noOfRoomBooked : noOfRoomBooked++;
                              }
                              noOfPeople = noOfRoomBooked * 2;
                              totalPrice = widget.price * (checkOutDateTime.day - checkInDateTime.day) * noOfRoomBooked;
                            });
                          }
                        },
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 15.0),
            // no of people
            Row(
              children: [
                const Icon(Icons.people),
                const SizedBox(width: 5.0),
                const Text("No of People:"),
                const SizedBox(width: 15.0),
                Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                    border: Border.all(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (widget.isBookingEnable) {
                            setState(() {
                              noOfPeople == 1 ? 1 : noOfPeople--;
                              noOfRoomBooked = noOfPeople.isEven ? noOfPeople ~/ 2 : (noOfPeople + 1) ~/ 2;
                              totalPrice = widget.price * (checkOutDateTime.day - checkInDateTime.day) * noOfRoomBooked;
                            });
                          }
                        },
                        icon: Icon(
                          Icons.remove,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        '$noOfPeople',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (widget.isBookingEnable) {
                            setState(() {
                              if (widget.bookingDocId.isEmpty) {
                                noOfPeople == widget.availableRooms * 2 ? widget.availableRooms * 2 : noOfPeople++;
                              } else {
                                noOfPeople == (widget.availableRooms + widget.noOfRoomBooked) * 2 ? (widget.availableRooms + widget.noOfRoomBooked) * 2 : noOfPeople++;
                              }

                              noOfRoomBooked = noOfPeople.isEven ? noOfPeople ~/ 2 : (noOfPeople + 1) ~/ 2;
                              totalPrice = widget.price * (checkOutDateTime.day - checkInDateTime.day) * noOfRoomBooked;
                            });
                          }
                        },
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 15.0),
            // total price
            Row(
              children: [
                const Icon(Icons.currency_rupee_rounded),
                const SizedBox(width: 5.0),
                const Text("Total Prices:"),
                const SizedBox(width: 15.0),
                Expanded(
                  child: Text(
                    "Rs $totalPrice",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.isBookingEnable
          ? Container(
              height: 50.0,
              margin: const EdgeInsets.all(15.0),
              width: MediaQuery.of(context).size.width,
              child: TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    LoadingDialog(context);

                    final Map<String, dynamic> bookingInfos = {
                      "hotelDocId": widget.hotelDocId,
                      "hotelName": widget.hotelName,
                      "userId": FirebaseAuth.instance.currentUser!.uid,
                      "name": nameController.text.trim(),
                      "email": emailController.text.trim(),
                      "contact": phoneNumberController.text.trim(),
                      "checkIn": checkInDateTime,
                      "checkOut": checkOutDateTime,
                      "noOfRoom": noOfRoomBooked,
                      "noOfPeople": noOfPeople,
                      "totalPrice": totalPrice,
                    };

                    try {
                      if (widget.bookingDocId.isEmpty) {
                        await FirebaseServices.addBookingInfo(bookingInfos);
                        await FirebaseServices.editHotelInfo(widget.hotelDocId, {"availableRooms": widget.availableRooms - noOfRoomBooked});
                      } else {
                        await FirebaseServices.editBookingInfo(widget.bookingDocId, bookingInfos);
                        await FirebaseServices.editHotelInfo(widget.hotelDocId, {
                          "availableRooms": widget.availableRooms - (noOfRoomBooked - widget.noOfRoomBooked),
                        });
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              widget.bookingDocId.isEmpty ? "Hotel Booking is done successfully" : "Hotel Booking is updated successfully",
                            ),
                          ),
                        );
                      }
                    } catch (error) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.toString()),
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
                child: const Text("Confirm Booking"),
              ),
            )
          : const SizedBox(),
    );
  }
}
