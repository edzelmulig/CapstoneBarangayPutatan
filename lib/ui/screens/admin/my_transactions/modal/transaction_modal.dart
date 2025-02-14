import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:putatanapk/constant.dart';
import 'package:putatanapk/services/firebase_services.dart';
import 'package:putatanapk/ui/widgets/buttons/custom_button.dart';
import 'package:putatanapk/ui/widgets/images/profile_image.dart';
import 'package:putatanapk/ui/widgets/snackbar/custom_snackbar.dart';

// MODAL BOTTOM FOR ACTION CONFIRMATION
void appointmentProviderModal(
    BuildContext context,
    final dynamic appointment,
    Map<String, dynamic> clientData,
    final String appointmentID,
    ) {
  showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    context: context,
    isDismissible: true,
    backgroundColor: Colors.white,
    elevation: 0,
    builder: (context) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 180, right: 180),
              child: Container(
                width: double.infinity,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: const Color(0xFFE5E7EB),
                ),
              ),
            ),
            // CLIENT PERSONAL DATA
            Padding(
              padding: const EdgeInsets.only(
                left: 30,
                top: 20,
                right: 30,
                bottom: 20,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // CLIENT PROFILE
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ProfileImageWidget(
                      width: 110,
                      height: 100,
                      borderRadius: 12,
                      imageURL: clientData['imageURL'],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // CLIENT NAME
                        SizedBox(
                          child: Text(
                            "${clientData['firstName']} ${clientData['lastName']}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              height: 1.3,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3C3C40),
                            ),
                          ),
                        ),

                        // SIZED BOX: SPACING
                        const SizedBox(height: 12),

                        // CONTACT NUMBER
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.phone_rounded,
                                size: 18,
                                color: Color(0xFF3C3C40),
                              ),
                            ),
                            Text(
                              clientData['phoneNumber'] ?? 'Loading...',
                              style: const TextStyle(
                                height: 1.2,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3C3C40),
                              ),
                            ),
                          ],
                        ),

                        // CONTACT NUMBER
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.email_rounded,
                                size: 18,
                                color: Color(0xFF3C3C40),
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                child: Text(
                                  clientData['email'] ?? 'Loading...',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    height: 1.2,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF3C3C40),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // SERVICE DETAILS
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1EF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: <Widget>[
                    // SERVICE DETAILS
                    Container(
                      padding: const EdgeInsets.all(7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // SERVICE NAME
                          Text(
                            appointment['serviceName'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              height: 1.2,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3C3C40),
                            ),
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            child: Text(
                              "${appointment['appointmentDate']} | ${appointment['appointmentTime']}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                height: 0.9,
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF3C3C40),
                              ),
                            ),
                          ),


                          // REFERENCE NUMBER
                          const SizedBox(height: 10),

                          SizedBox(
                            child: Text(
                              "Ref No. ${appointment['referenceNumber']}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                height: 0.9,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            var response = await Dio().get(
                                "${appointment['receiptImage']}",
                                options:
                                Options(responseType: ResponseType.bytes));

                            if (response.statusCode == 200) {
                              // CONVERT RESPONSE DATA TO Uint8List
                              Uint8List imageData = response.data as Uint8List;


                              if (context.mounted) {
                                showFloatingSnackBar(
                                  context,
                                  "Photo saved to this device",
                                  const Color(0xFF3C3C40),
                                );
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              }
                            } else {
                              print(
                                  "Error: Failed to download image. Status code: ${response.statusCode}");
                            }
                          } catch (e) {
                            debugPrint('Error downloading image: $e');
                          }
                        },
                        child: const Icon(
                          Icons.file_download_outlined,
                          size: 27,
                          color: Color(0xFF3C3C40),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SIZED BOX: SPACING
            const SizedBox(height: 20),

            if (appointment['appointmentStatus'] == 'new') ...[
              // IF NOT CONFIRMED OR DONE
              Column(
                children: <Widget>[
                  // CONFIRM BUTTON
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: CustomButton(
                      buttonLabel: "Confirm",
                      onPressed: () async {
                        try {
                          // UPDATE THE appointmentStatus ON PROVIDER'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointmentID,
                            providerID: FirebaseAuth.instance.currentUser!.uid,
                            fieldsToUpdate: {
                              'appointmentStatus': 'confirmed',
                            },
                          );

                          // UPDATE THE appointmentStatus ON CLIENT'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointment['appointmentID'],
                            providerID: appointment['clientID'],
                            fieldsToUpdate: {
                              'appointmentStatus': 'confirmed',
                            },
                          );


                          // SEND SMS TO CLIENT THAT RESERVATION HAS BEEN APPROVED
                          final String phoneNumber =
                              '639${clientData['phoneNumber'].toString(1)}';


                          // SEND MESSAGE TO THE SERVICE PROVIDER
                          final Map<String, dynamic> requestData = {
                            'recipient': phoneNumber,
                            'sender_id': 'PhilSMS',
                            'type': 'plain',
                            'message': 'DormLander Reservation Update: \n\nDear ${clientData['firstName']} ${clientData['lastName']}, \n\n'
                                'your reservation has been approved.\nKindly refer for your DormLander app for further details. Thank you.',
                          };

                          const String apiUrl = 'https://app.philsms.com/api/v3/sms/send';

                          final http.Response response = await http.post(
                            Uri.parse(apiUrl),
                            headers: {
                              'Authorization': smsAPI,
                              'Content-Type': 'application/json',
                              'Accept': 'application/json'
                            },
                            body: jsonEncode(requestData),
                          );




                          Navigator.of(context).pop();
                          if (context.mounted) {
                            showFloatingSnackBar(
                              context,
                              'Reservation updated successfully.',
                              const Color(0xFF193147),
                            );
                          }
                        } catch (e) {
                          print('Error confirming appointment: $e');
                        }
                      },
                      buttonHeight: 55,
                      buttonColor: const Color(0xFF193147),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontColor: Colors.white,
                      borderRadius: 10,
                    ),
                  ),

                  // SIZED BOX: SPACING
                  const SizedBox(height: 10),

                  // CANCEL BUTTON
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: CustomButton(
                      borderColor: const Color(0xFFBDBDC7),
                      borderWidth: 1.5,
                      buttonLabel: "Cancel",
                      onPressed: () async {
                        try {
                          // UPDATE THE appointmentStatus ON PROVIDER'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointmentID,
                            providerID: FirebaseAuth.instance.currentUser!.uid,
                            fieldsToUpdate: {
                              'appointmentStatus': 'cancelled',
                            },
                          );

                          // UPDATE THE appointmentStatus ON CLIENT'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointment['appointmentID'],
                            providerID: appointment['clientID'],
                            fieldsToUpdate: {
                              'appointmentStatus': 'cancelled',
                            },
                          );

                          Navigator.of(context).pop();
                          if (context.mounted) {
                            showFloatingSnackBar(
                              context,
                              'Reservation cancelled successfully.',
                              const Color(0xFF193147),
                            );
                          }
                        } catch (e) {
                          print('Error cancelling reservation: $e');
                        }
                      },
                      buttonHeight: 55,
                      buttonColor: Colors.transparent,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontColor: const Color(0xFFe91b4f),
                      borderRadius: 10,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ] else if (appointment['appointmentStatus'] == 'confirmed') ...[
              Column(
                children: <Widget>[
                  // CONFIRM BUTTON
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: CustomButton(
                      buttonLabel: "Done",
                      onPressed: () async {
                        try {
                          // UPDATE THE appointmentStatus ON PROVIDER'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointmentID,
                            providerID: FirebaseAuth.instance.currentUser!.uid,
                            fieldsToUpdate: {
                              'appointmentStatus': 'done',
                            },
                          );

                          // UPDATE THE appointmentStatus ON CLIENT'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointment['appointmentID'],
                            providerID: appointment['clientID'],
                            fieldsToUpdate: {
                              'appointmentStatus': 'done',
                            },
                          );

                          Navigator.of(context).pop();
                          if (context.mounted) {
                            showFloatingSnackBar(
                              context,
                              'Reservation done.',
                              const Color(0xFF193147),
                            );
                          }
                        } catch (e) {
                          print('Error updating reservation: $e');
                        }
                      },
                      buttonHeight: 55,
                      buttonColor: const Color(0xFF3680EE),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontColor: Colors.white,
                      borderRadius: 10,
                    ),
                  ),

                  // SIZED BOX: SPACING
                  const SizedBox(height: 10),

                  // CANCEL BUTTON
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: CustomButton(
                      borderColor: const Color(0xFFBDBDC7),
                      borderWidth: 1.5,
                      buttonLabel: "Cancel",
                      onPressed: () async {
                        try {
                          // UPDATE THE appointmentStatus ON PROVIDER'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointmentID,
                            providerID: FirebaseAuth.instance.currentUser!.uid,
                            fieldsToUpdate: {
                              'appointmentStatus': 'cancelled',
                            },
                          );

                          // UPDATE THE appointmentStatus ON CLIENT'S SIDE
                          FirebaseService.updateAppointment(
                            context: context,
                            appointmentID: appointment['appointmentID'],
                            providerID: appointment['clientID'],
                            fieldsToUpdate: {
                              'appointmentStatus': 'cancelled',
                            },
                          );
                          Navigator.of(context).pop();
                          if (context.mounted) {
                            showFloatingSnackBar(
                              context,
                              'Reservation cancelled successfully.',
                              const Color(0xFF193147),
                            );
                          }
                        } catch (e) {
                          print('Error cancelling reservation: $e');
                        }
                      },
                      buttonHeight: 55,
                      buttonColor: Colors.transparent,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontColor: const Color(0xFFe91b4f),
                      borderRadius: 10,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ] else if (appointment['appointmentStatus'] == 'cancelled') ...[
              Column(
                children: <Widget>[
                  // CONFIRM BUTTON
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: CustomButton(
                      buttonLabel: "Cancelled",
                      onPressed: () {},
                      buttonHeight: 55,
                      buttonColor: const Color(0xFF3C3C40),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontColor: Colors.white,
                      borderRadius: 10,
                    ),
                  ),

                  // SIZED BOX: SPACING
                  const SizedBox(height: 20),
                ],
              ),
            ] else if (appointment['appointmentStatus'] == 'done') ...[
              Column(
                children: <Widget>[
                  // CONFIRM BUTTON
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: CustomButton(
                      buttonLabel: "Done",
                      onPressed: () {},
                      buttonHeight: 55,
                      buttonColor: const Color(0xFF3C3C40),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      fontColor: Colors.white,
                      borderRadius: 10,
                    ),
                  ),

                  // SIZED BOX: SPACING
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ],
        ),
      );
    },
  );
}