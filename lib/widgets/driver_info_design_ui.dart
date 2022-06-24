import 'package:flutter/material.dart';

class DriverInfoDesignUIWidget extends StatefulWidget {
  String? textinfo;
  IconData? iconData;

  DriverInfoDesignUIWidget({
    this.textinfo,
    this.iconData,
  });

  @override
  _DriverInfoDesignUIWidgetState createState() =>
      _DriverInfoDesignUIWidgetState();
}

class _DriverInfoDesignUIWidgetState extends State<DriverInfoDesignUIWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white54,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: ListTile(
        leading: Icon(
          widget.iconData,
          color: Colors.black,
        ),
        title: Text(
          widget.textinfo!,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
