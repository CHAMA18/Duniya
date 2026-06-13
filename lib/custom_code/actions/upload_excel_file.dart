// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

Future<dynamic> uploadExcelFile(Future<dynamic> Function() showSnackbar) async {
  // Add your function code here!
  try {
    // Open the file picker to allow the user to select an Excel
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result == null) {
      // User canceled the picker
      return null;
    }

    // Read the selected Excel file
    var bytes = result.files.first.bytes!;
    var excel = Excel.decodeBytes(bytes);

    // Get the first sheet in the Excel file
    var sheet = excel.tables.keys.first;
    var rows = excel.tables[sheet]?.rows;

    List<Map<String, dynamic>> jsonData = [];

    for (var i = 1; i < rows!.length; i++) {
      Map<String, dynamic> rowMap = {};
      for (var j = 0; j < rows[i].length; j++) {
        // Get the header value for this column
        var header = rows[0][j]!.value.toString();

        // Get the cell value for this column
        var cellValue = (j == 1)
            ? double.parse(rows[i][j]!.value)
            : rows[i][j]!.value.toString();

        // Add the cell value to the row map using the header as the key
        rowMap[header] = cellValue;
      }
      jsonData.add(rowMap);
    }

    Map<String, dynamic> excelMap = {"data": jsonData};

    return excelMap;
  } catch (e) {
    showSnackbar();
    return null;
  }
}
