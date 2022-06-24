import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../infoHandler/app_info.dart';
import '../main.dart';
import '../widgets/history_design_ui.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({Key? key}) : super(key: key);

  @override
  _TripsHistoryScreenState createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Trips History"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            MyApp.restartApp(context);
          },
        ),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => const Divider(
          thickness: 2,
          height: 2,
          color: Colors.white,
        ),
        itemBuilder: (context, index) {
          print("we are here 1");
          return Card(
            color: Colors.white54,
            child: HistoryDesignUIWidget(
              tripHistoryModel: Provider.of<AppInfo>(
                context,
                listen: false,
              ).allTripHistoryInformationList[index],
            ),
          );
        },
        itemCount: Provider.of<AppInfo>(
          context,
          listen: false,
        ).allTripHistoryInformationList.length,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
