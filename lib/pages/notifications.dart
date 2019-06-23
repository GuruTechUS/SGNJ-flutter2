import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget{
  
  @override
  State<StatefulWidget> createState() {
    return _NotificationsState();
  }

}

class _NotificationsState extends State<Notifications>{

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
        child: notificationsList(context),
    ));
  }

  Widget notificationsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("notifications").snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        } else {
          return renderNotificationsList(snapshot);
        }
      },
    );
  }

  renderNotificationsList(AsyncSnapshot<QuerySnapshot> snapshot){
      return CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text('Notifications')
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Card(
                child: new Container(
                  padding: EdgeInsets.all(10.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          notificationIcon(),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(snapshot.data.documents[index]["message"],
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold
                            )),
                            Text(snapshot.data.documents[index]["message"]),
                          ],
                        )
                      )
                    ],
                  )
                ),
              );
            },
            childCount: snapshot.data.documents.length
            ),
          )
        ],
      );
  }

  

  notificationIcon(){
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Image.asset(
                 "assets/images/notification.png",
                width: 30,
              ));
  }

}