import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

import '../models/invoice.dart';

class ConsultApi {
  /// Gets transaction id  for current appointment from user appointments list
  // ignore: missing_return
  http.Client _client = http.Client(); //3gb
  Future<String> getTransactionID(String iHLUserID, String appointmentID) async {
    String transactionID;
    final getTransactionid = await _client.get(
      Uri.parse(API.iHLUrl + "/consult/user_transaction_from_ihl_id?ihl_id=$iHLUserID"),
    );
    if (getTransactionid.statusCode == 200) {
      var response = getTransactionid.body;
      List appointmentList = json.decode(response);
      appointmentList.forEach((element) {
        if (element['ihl_appointment_id'] == appointmentID) {
          transactionID = element['transaction_id'];
        }
      });
    }
    return transactionID;
  }

  //gets invoice number for current appointment from user appointment list
  Future<Invoice> getInvoiceNumber(String iHLUserID, String appointmentID) async {
    Invoice invoice;
    String invoiceNumber;
    final getInvoiceResponse = await _client.get(
      Uri.parse(API.iHLUrl + "/consult/user_transaction_from_ihl_id?ihl_id=$iHLUserID"),
    );
    if (getInvoiceResponse.statusCode == 200) {
      var response = getInvoiceResponse.body;
      List appointmentList = json.decode(response);
      appointmentList.forEach((element) async {
        print('${element['ihl_appointment_id']} $appointmentID');
        if (element['ihl_appointment_id'] == appointmentID) {
          invoice = Invoice.fromJson(element);
          log(invoice.toJson().toString());
          invoiceNumber = element['ihl_invoice_numbers'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("invoice", invoiceNumber);
        }
      });
    }
    log('Invoice Number $invoiceNumber');
    return invoice;
  }

  /// Updates Service provided after Call is completed.
  Future<void> updateServiceProvided(String iHLUserID, String appointmentID) async {
    final getTransactionid = await _client.get(
      Uri.parse(API.iHLUrl + "/consult/user_transaction_from_ihl_id?ihl_id=$iHLUserID"),
    );
    if (getTransactionid.statusCode == 200) {
      var response = getTransactionid.body;
      List appointmentList = json.decode(response);
      appointmentList.forEach((element) async {
        if (element['ihl_appointment_id'] == appointmentID) {
          var tranresponce = await _client.post(
              Uri.parse(API.iHLUrl +
                  "/data/serviceProvidedPortal?transaction=${element['transaction_id']}"),
              headers: {
                'Content-Type': 'application/json',
                'ApiToken': '${API.headerr['ApiToken']}',
                'Token': '${API.headerr['Token']}',
              });

          var value = tranresponce.body;
        }
      });
    }
  }
}
