import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/utils/firebase_anon_auth.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';

// DateTime parseTime(dynamic date) {
//   return Platform.isIOS ? (date as Timestamp).toDate() : (date as DateTime);
// }

class ScheduleScreen extends StatefulWidget {

  final dynamic sportsItem;
  final dynamic category;
  final bool gender;

  
  ScheduleScreen(this.sportsItem, this.category, this.gender){
    fetchUserToken();
  }

  fetchUserToken() async {
    
  }

  @override
  State<StatefulWidget> createState() {
    return _ScheduleScreenState(sportsItem, category, gender);
  }
}

class _ScheduleScreenState extends State<ScheduleScreen>{

  final dynamic sportsItem;
  final dynamic category;
  final bool gender;
  String userId;
  
  Map<String, dynamic> subscription = new Map<String, dynamic>();

  final FirebaseAnonAuth firebaseAnonAuth = new FirebaseAnonAuth();

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  
  _ScheduleScreenState(this.sportsItem, this.category, this.gender)  {
    print("======0======");
    firebaseAnonAuth.signInAnon().then((user) {
      print("======1======");
      this.userId = user.uid;
      fetchUserToken();
    });
  }

  fetchUserToken() async {
    print("======3======");
      await fetchSubscriptionData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
        child: scheduleList(context),
    ));
  }

  Widget scheduleList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("events")
                                .where("category", isEqualTo: category["name"])
                                .where("gender", isEqualTo: gender)
                                .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        } else {
          //return ListView(children: getExpenseItems(snapshot));
          return eventsList(snapshot);
        }
      },
    );
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents
        .map((doc) => new ListTile(title: new Text(doc["category"]), subtitle: new Text(doc["gender"].toString())))
        .toList();
  }

  eventsList(AsyncSnapshot<QuerySnapshot> snapshot){
      return CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              //background: Image.network("https://i.ibb.co/zNQkbJZ/gameday.png"),
              centerTitle: true,
              title: Text('Schedule')
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
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            displayTeams(snapshot.data.documents[index]["teams"]),
                            displayLocation(snapshot.data.documents[index]["location"]),
                            displayStatus(snapshot.data.documents[index]["status"])
                          ],
                        )
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          displayTimeAndDate(snapshot.data.documents[index]["startTime"]),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          subscribeToEvent(snapshot.data.documents[index].documentID),
                        ],
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

  displayTeams(teams) {
    if(teams != null && teams.length == 2){
      return Text(
        teams[0]["name"]+" vs "+teams[1]["name"],
        style: TextStyle(
            color: Colors.black,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            fontFamily: "WorkSansSemiBold"
          )
        );
    } else if(teams != null && teams.length == 1){
      return Text(teams[0]["name"]+" vs --");
    } else if(teams != null && teams.length >= 2){
      return Text("");
    } else {
      return Text("");
    }
                          
  }
  displayLocation(location) {
    if(location != null){
      return Text(
        location,
        textAlign: TextAlign.left);
    } else {
      return Text("");
    }
  }

  dynamic months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  displayTimeAndDate(startTime){
    DateTime date = DateTime.parse(startTime.toString());
    print(date);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        getTime(date),
        getDate(date),        
    ]);
  }

  getDate(DateTime startTime){
    if(startTime != null){
      return Text(startTime.toUtc().day.toString()+" "+months[startTime.toUtc().month]);
    } else {
      return Text("");
    }
  }

  getTime(DateTime startTime){
    print(startTime);
    if(startTime != null){
      String padding = startTime.toUtc().minute <= 9 ? "0": "";
      String hour = startTime.toUtc().hour.toString();
      String sufix = "AM";
      if(startTime.toUtc().hour >= 12){
        hour = (startTime.toUtc().hour-12).toString();
        sufix = "PM";
      }
      return Text(
        hour
        +":"
        +padding
        +startTime.toUtc().minute.toString()
        +" "
        +sufix,
        style: TextStyle(
          fontSize: 24.0    
        ));
    } else {
      return Text("");
    }
  }
  
  displayStatus(String status){
    return Text(status);
  }

  
  subscribeToEvent(documentID){
    print("======6======");
    subscription.putIfAbsent(documentID, () => false);
    return Container(
      padding: EdgeInsets.all(10.0),
      child: InkWell(
            onTap: () {
              updateData(documentID);
            },
            child: Image.asset(
                 subscription[documentID]?"assets/images/bell-solid.png":"assets/images/bell-regular.png",
                width: 30,
              )));
  }

  updateData(key){
    DocumentReference subscriptionDocumentReference =  Firestore.instance.collection("devices").document("preferences").collection(this.userId).document("subscriptions");
    if(!subscription[key]){
      subscribeToTopic(key);
    } else {
      unSubscribeToTopic(key);
    }
    subscriptionDocumentReference.updateData({key: !subscription[key]});
  }

  subscribeToTopic(key){
    print("subscribed: "+key);
    firebaseMessaging.subscribeToTopic(key);
  }

  unSubscribeToTopic(key){
    print("unsubscribed: "+key);
    firebaseMessaging.unsubscribeFromTopic(key);
  }

  fetchSubscriptionData(){
    print("======4======");
    Stream<DocumentSnapshot> subscriptionSnapshot = Firestore.instance.collection("devices").document("preferences").collection(this.userId).document("subscriptions").snapshots();
  
    subscriptionSnapshot.listen((documentData) {
      print("======5======");
      print("check: "+documentData.data.toString());
      if (!mounted) return;
      setState(() {
        subscription = documentData.data;
      });
    });   
  }
  
}