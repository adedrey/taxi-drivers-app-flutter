import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trip_history_model.dart';

class HistoryDesignUIWidget extends StatefulWidget {
  TripHistoryModel? tripHistoryModel;

  HistoryDesignUIWidget({this.tripHistoryModel});

  @override
  _HistoryDesignUIWidgetState createState() => _HistoryDesignUIWidgetState();
}

class _HistoryDesignUIWidgetState extends State<HistoryDesignUIWidget> {
  @override
  String formatDateAndTime(String dateTimeFromDB) {
    DateTime dateTime =
        DateTime.parse(dateTimeFromDB); // convert string type to datetime type
    // Get Month and Date e.g Dec 10, 2022, 1:12 pm
    String formattedDateTime =
        "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)}, ${DateFormat.jm().format(dateTime)}";

    return formattedDateTime;
  }

  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver info - name + Fare Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    "User : " + widget.tripHistoryModel!.userName!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  "₦" + widget.tripHistoryModel!.fareAmount!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            // car_details
            Row(
              children: [
                const Icon(
                  Icons.phone_iphone,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  widget.tripHistoryModel!.userPhone!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // const SizedBox(
                //   width: 12,
                // ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            // Icon + pickup
            Row(
              children: [
                Image.asset(
                  "assets/img/origin.png",
                  height: 24,
                  width: 24,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      widget.tripHistoryModel!.originAddress!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            // Icon + picdestinationkup
            Row(
              children: [
                Image.asset(
                  "assets/img/destination.png",
                  height: 24,
                  width: 24,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      widget.tripHistoryModel!.destinationAddress!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 12,
            ),

            // Date time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(""),
                Text(
                  formatDateAndTime(widget.tripHistoryModel!.time!),
                  style: const TextStyle(
                    color: Colors.grey,
                    // fontSize: 18,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
