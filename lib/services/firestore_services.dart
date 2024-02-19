import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  // Returns a CollectionReference with the provided path.
  static CollectionReference<Map<String, dynamic>> userCollectionRef() {
    return FirebaseFirestore.instance.collection("users");
  }

  static Future<Map<String, dynamic>?> getCurrentUserFields() async {
    try {
      DocumentReference<Map<String, dynamic>> docRef = userCollectionRef().doc(FirebaseAuth.instance.currentUser!.uid);

      // Doc Snapshot is doc infos like id, metadata, creation datetime, modified datetime, fields
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await docRef.get();

      Map<String, dynamic>? field = docSnapshot.data();

      return field;
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> setCurrentUserField(Map<String, dynamic> field) async {
    try {
      DocumentReference<Map<String, dynamic>> docRef = userCollectionRef().doc(FirebaseAuth.instance.currentUser!.uid);

      await docRef.set(field, SetOptions(merge: true));
    } catch (error) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllAdminDoc() async {
    try {
      List<Map<String, dynamic>> fieldList = [];

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await userCollectionRef().where("role", isEqualTo: "admin").get();

      for (var docSnap in querySnapshot.docs) {
        fieldList.add(docSnap.data());
      }

      return fieldList;
    } catch (error) {
      rethrow;
    }
  }

  // Returns a CollectionReference with the provided path.
  static CollectionReference<Map<String, dynamic>> hotelCollectionRef() {
    return FirebaseFirestore.instance.collection("hotels");
  }

  static Future<void> addHotelInfo(Map<String, dynamic> field) async {
    try {
      await hotelCollectionRef().add(field);
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> editHotelInfo(String id, Map<String, dynamic> field) async {
    try {
      await hotelCollectionRef().doc(id).set(field, SetOptions(merge: true));
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> deleteHotelInfo(String id) async {
    try {
      await hotelCollectionRef().doc(id).delete();
    } catch (error) {
      rethrow;
    }
  }

  // Returns a CollectionReference with the provided path.
  static CollectionReference<Map<String, dynamic>> bookingCollectionRef() {
    return FirebaseFirestore.instance.collection("bookings");
  }

  static Future<void> addBookingInfo(Map<String, dynamic> field) async {
    try {
      await bookingCollectionRef().add(field);
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> editBookingInfo(String id, Map<String, dynamic> field) async {
    try {
      await bookingCollectionRef().doc(id).set(field, SetOptions(merge: true));
    } catch (error) {
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUserBookingDocStream() {
    try {
      return bookingCollectionRef()
          .where(
            "userId",
            isEqualTo: FirebaseAuth.instance.currentUser!.uid,
          )
          .snapshots();
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> deleteBookingInfo(String id) async {
    try {
      await bookingCollectionRef().doc(id).delete();
    } catch (error) {
      rethrow;
    }
  }
}
