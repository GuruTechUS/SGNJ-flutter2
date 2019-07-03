import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddressCard extends StatefulWidget{

  final AsyncSnapshot<DocumentSnapshot> eventData;

  AddressCard(this.eventData);

  @override
  State<StatefulWidget> createState() {
    return _AddressCardState();
  }

}

class _AddressCardState extends State<AddressCard>{
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  widget.eventData.data["location"],
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              )
            )
          ],
        )
      )
    );
  }
  
}