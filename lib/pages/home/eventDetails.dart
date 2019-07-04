import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/utils/animated-count.dart';
import 'package:firebase_app/utils/firebase_anon_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'addressCard.dart';
import 'editEvent.dart';
import 'eventUpdate.dart';

class EventDetails extends StatefulWidget{

  final String userId;
  //final AsyncSnapshot<QuerySnapshot> eventSnapshot;
  final String documentId;
  final String title;

  EventDetails(this.userId, this.documentId, this.title);

  @override
  State<StatefulWidget> createState() {
    return _EventDetailsState(this.documentId);
  }

}

class _EventDetailsState extends State<EventDetails>{

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  Map<String, dynamic> subscription = new Map<String, dynamic>();
  
  bool recordExist = false;
  bool isAdminLoggedIn = false;
  String userId;
  final String documentId;

  final _updatesFormKey = GlobalKey<FormState>();
  String statusUpdate = "";
  
  final FirebaseAnonAuth firebaseAnonAuth = new FirebaseAnonAuth();


  _EventDetailsState(this.documentId){
    firebaseAnonAuth.isLoggedIn().then((user){
      if(user != null && user.uid != null){
        setState(() {
          this.userId = user.uid;
          if(user.isAnonymous == false){
            isAdminLoggedIn = true;
          }
        });
        fetchUserPreferences();
      } else {
        firebaseAnonAuth.signInAnon().then((anonUser) {
          if(anonUser != null && anonUser.uid != null){
            setState(() {
              this.userId = anonUser.uid;
            });
            fetchUserPreferences();
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  fetchUserPreferences() async {
    await fetchSubscriptionData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
              isAdminLoggedIn ? IconButton(
                icon: Icon(Icons.edit),
                tooltip: 'Edit',
                onPressed: () {
                  Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                     EditEvent(documentId)
                                     )
                                );
                  
                },
              ) : Container(),
            ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
        ),
        child: eventItemStream(context)
      )
    );
  }

  Widget eventItemStream(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection("events").document(documentId).snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        } else {
          //return ListView(children: getExpenseItems(snapshot));
          return eventPageBody(context, snapshot);
        }
      },
    );
  }
  
  Widget eventPageBody(BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    bool locationEnabled = snapshot.data["location"] != null && snapshot.data["location"] != ""?true:false;
    double updatesCardHeight = 400;
    if(MediaQuery.of(context).size.height - (locationEnabled ? 420 : 340) < 400){
      updatesCardHeight = MediaQuery.of(context).size.height - (locationEnabled ? 420 : 340);
    }
    // int updatesCount = 0;
    // if(snapshot.data["updates"] != null && snapshot.data["updates"].length > 0){
    //   updatesCount = snapshot.data["updates"].length;
    // }
    return StaggeredGridView.count(
      crossAxisCount: 1,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      padding: EdgeInsets.all(5.0),
      children: <Widget>[
        eventMainCard(context, snapshot),
        locationEnabled ? AddressCard(snapshot) : Container(),
        submitNewUpdate(),
        EventUpdateCard(documentId, updatesCardHeight),
      ],
      staggeredTiles: [
        StaggeredTile.extent(1, 230),
        locationEnabled ? StaggeredTile.extent(1, 80):StaggeredTile.extent(1, 0),
        StaggeredTile.extent(1, 80),
        StaggeredTile.extent(1, updatesCardHeight),
      ],
    );
  }

  submitNewUpdate(){
    return Form(
      key: _updatesFormKey,
      child: Card(
            child: new Container(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Any new updates?'
                        ),
                        validator: (value) {
                          statusUpdate = value;
                          if (value.isEmpty) {
                            return 'Enter update details';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      child: IconButton(
                        icon: Icon(Icons.send),
                        tooltip: 'Send',
                        onPressed: () {
                          if (_updatesFormKey.currentState.validate()) {
                            print("===========000=========");
                            print(statusUpdate);
                                
                            if(statusUpdate != null && statusUpdate.trim() != ""){
                              setState(() {
                                print("===========212=========");
                                sendUpdate();
                                statusUpdate = "";
                                _updatesFormKey.currentState.reset();
                              });
                            }
                          }
                        })
                  )
                ]
              ),
            )
            )
      )
    );
  }

  sendUpdate() async {
    await Firestore.instance.collection("events").document(documentId).collection("updates").add({
                                  "content": statusUpdate,
                                  "timestamp": DateTime.now()
                                });
  }

  Widget eventMainCard(BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            displaySubscribeButton(snapshot.data),
            displayScoreCards(snapshot.data),
            displayRound(snapshot.data)
          ],
        )
      )
    );
  }


  Widget displaySubscribeButton(DocumentSnapshot eventData){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: timeAndDate(eventData),
        ),
        subscribeToEvent(widget.documentId)
      ]
    );
  }
  

  subscribeToEvent(documentID){
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
    DocumentReference subscriptionDocumentReference =  Firestore.instance.collection("devices").document("preferences").collection(userId).document("subscriptions");
    if(!subscription[key]){
      subscribeToTopic(key);
    } else {
      unSubscribeToTopic(key);
    }
    if(!recordExist){
      subscriptionDocumentReference.setData({key: !subscription[key]});
    } else {
      subscriptionDocumentReference.updateData({key: !subscription[key]});
    }
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
    Stream<DocumentSnapshot> subscriptionSnapshot = Firestore.instance.collection("devices").document("preferences").collection(userId).document("subscriptions").snapshots();
  
    subscriptionSnapshot.listen((documentData) {
      if (!mounted) return;
      setState(() {
        if(documentData.data == null){
          subscription = {};
        } else {
          subscription = documentData.data;
          recordExist = true;
        }
        
      });
    });   
  }
  
  displayScoreCards(DocumentSnapshot eventData){
    print(eventData);
    return eventData["teams"] != null && eventData["teams"].length >= 2 ? Row(
      children: <Widget>[
        Expanded(
          child: teamBox(eventData["teams"][0]),
        ),
        Container(
          child: vsSymbol()
        ),
        Expanded(
          child: teamBox(eventData["teams"][1]),
        ),
      ],
    ): Container();
    
  }

  teamBox(team){
    int score = team["score"] != null?team["score"]:0;
    String name = team["name"] != null?team["name"]:"";
    return Center(
      child: Column(
        children: <Widget>[
          AnimatedCount(count: score, duration: Duration(seconds: 1), curve: Curves.easeOut),
          Text(
            name,
            style: TextStyle(
              fontSize: 18
            ),
          )
        ],
      )
    );
  }

  vsSymbol(){
    return Text(
      "vs",
      style: TextStyle(
        fontSize: 30
      ),
    );
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

  timeAndDate(DocumentSnapshot eventData){
    DateTime date = DateTime.parse(eventData["startTime"].toString());
    print("==================");
    print(date);
    print("==================");
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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

  displayRound(DocumentSnapshot eventData){
    String round = eventData["round"];
    String status = eventData["status"];
    return Center(
      child: Text(
        round +" - "+ status,
        style: TextStyle(
          fontSize: 20
        ),
        )
    ); 
  }
  
  
}