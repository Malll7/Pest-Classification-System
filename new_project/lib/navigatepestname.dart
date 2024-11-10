import 'package:flutter/material.dart';

import 'control/AphidControl.dart';
import 'control/ArmywormControl.dart';
import 'control/BeetleControl.dart';
import 'control/MiteControl.dart';
import 'control/SawflyControl.dart';
import 'control/StemBorerControl.dart';
import 'control/StemflyControl.dart';
import 'pests/AphidList.dart';
import 'pests/ArmywormList.dart';
import 'pests/BeetleList.dart';
import 'pests/MiteList.dart';
import 'pests/SawflyList.dart';
import 'pests/StemBorerList.dart';
import 'pests/StemflyList.dart';

// ignore: camel_case_types
class navigatepestname {
  final BuildContext context;
  navigatepestname(this.context);
  void handlePestClick(String pestName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an option for $pestName'),
          content: const Text(
              'Would you like to view the list or control measures?'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToPestList(pestName);
                  },
                  child: const Text('View List'),
                ),
                const SizedBox(
                    width: 20), // Add spacing between buttons if needed
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToPestControl(pestName);
                  },
                  child: const Text('View Control'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _navigateToPestList(String pestName) {
    if (pestName == 'aphid') {
      // Navigate to Aphid list screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AphidList()), // Replace with actual list screen
      );
    } else if (pestName == 'armyworm') {
      // Navigate to Armyworm list screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ArmywormList()), // Replace with actual list screen
      );
    } else if (pestName == 'beetle') {
      // Navigate to Armyworm list screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                BeetleList()), // Replace with actual list screen
      );
    } else if (pestName == 'mite') {
      // Navigate to Armyworm list screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MiteList()), // Replace with actual list screen
      );
    } else if (pestName == 'sawfly') {
      // Navigate to Armyworm list screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SawflyList()), // Replace with actual list screen
      );
    } else if (pestName == 'stem borer') {
      // Navigate to Armyworm list screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                StemBorerList()), // Replace with actual list screen
      );
    } else if (pestName == 'stemfly') {
      // Navigate to Armyworm list screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                StemflyList()), // Replace with actual list screen
      );
    }
    // Add additional cases for other pests
  }

  void _navigateToPestControl(String pestName) {
    if (pestName == 'aphid') {
      // Navigate to Aphid control screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AphidControl()),
      );
    } else if (pestName == 'armyworm') {
      // Navigate to Armyworm control screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ArmywormControl()),
      );
    } else if (pestName == 'beetle') {
      // Navigate to Armyworm list screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                BeetleControl()), // Replace with actual list screen
      );
    } else if (pestName == 'mite') {
      // Navigate to Armyworm list screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MiteControl()), // Replace with actual list screen
      );
    } else if (pestName == 'sawfly') {
      // Navigate to Armyworm list screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SawflyControl()), // Replace with actual list screen
      );
    } else if (pestName == 'stem borer') {
      // Navigate to Armyworm list screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                StemBorerControl()), // Replace with actual list screen
      );
    } else if (pestName == 'stemfly') {
      // Navigate to Armyworm list screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                StemflyControl()), // Replace with actual list screen
      );
    }
    // Add additional cases for other pests
  }
}
