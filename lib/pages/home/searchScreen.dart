
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/utils/firebase_anon_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'eventDetails.dart';

class SearchScreen extends StatefulWidget {

  SearchScreen();

  @override
  State<StatefulWidget> createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  
  String genderValue="Boys & Girls";
  String categoryValue = "All Categories";
  String sportValue = "All Sports";
  String searchSrting = "";
  String userId;
  bool recordExist = false;
  Stream<QuerySnapshot> eventStream = Firestore.instance.collection("events").snapshots();

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  Map<String, dynamic> subscription = new Map<String, dynamic>();
  
  final FirebaseAnonAuth firebaseAnonAuth = new FirebaseAnonAuth();

  _SearchScreenState(){
    firebaseAnonAuth.signInAnon().then((user) {
      this.userId = user.uid;
      fetchUserPreferences();
    });
  }

  fetchUserPreferences() async {
      await fetchSubscriptionData();
  }
  
  @override
  Widget build(BuildContext context) {
    return searchScreenLayout(context);
    
  }

  searchScreenLayout(BuildContext context){
    return StaggeredGridView.count(
      crossAxisCount: 1,
      crossAxisSpacing: 0.0,
      mainAxisSpacing: 0.0,
      //padding: EdgeInsets.all(5.0),
      children: <Widget>[
        Container(
          color: Colors.white54,
          child: searchBar(context),
        ),
          fetchSearchResults(context)
        ],
      staggeredTiles: [
        StaggeredTile.extent(1, 60),
        StaggeredTile.extent(1, MediaQuery.of(context).size.height - 270),
      ],
    );
  }

  searchBar(BuildContext context){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
          genderDropDown(),
          sportsDropDown(),
          categoryDropDown(),
          searchBarField()
        ],
      )
    );
  }

  genderDropDown(){
    return Container(
      decoration: new BoxDecoration(
                  color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                  borderRadius: new BorderRadius.only(
                    topLeft:  const  Radius.circular(25.0),
                    topRight: const  Radius.circular(25.0),
                    bottomLeft: const  Radius.circular(25.0),
                    bottomRight: const  Radius.circular(25.0))
                ),
                padding: EdgeInsets.only(left:10, right: 10),
                margin: EdgeInsets.all(5),
      child: DropdownButton<String>(
        hint: Text("Gender"),
        value: genderValue,
        onChanged: (String newValue) {
          setState(() {
            genderValue = newValue;
          });
          updateStream();
        },
        items: <String>['Boys & Girls', 'Boys', 'Girls']
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          })
          .toList(),
          )
      );   
  }

  categoryDropDown(){
    return Container(
      decoration: new BoxDecoration(
                  color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                  borderRadius: new BorderRadius.only(
                    topLeft:  const  Radius.circular(25.0),
                    topRight: const  Radius.circular(25.0),
                    bottomLeft: const  Radius.circular(25.0),
                    bottomRight: const  Radius.circular(25.0))
                ),
                padding: EdgeInsets.only(left:10, right: 10),
                margin: EdgeInsets.all(5),
      child: DropdownButton<String>(
        hint: Text("Category"),
        value: categoryValue,
        onChanged: (String newValue) {
          setState(() {
            categoryValue = newValue;
          });
          updateStream();
        },
        items: <String>['All Categories','u10', 'u14', 'u18', 'a18']
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          })
          .toList(),
          )
      );   
  }

  sportsDropDown(){
    return Container(
      decoration: new BoxDecoration(
                  color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                  borderRadius: new BorderRadius.only(
                    topLeft:  const  Radius.circular(25.0),
                    topRight: const  Radius.circular(25.0),
                    bottomLeft: const  Radius.circular(25.0),
                    bottomRight: const  Radius.circular(25.0))
                ),
                padding: EdgeInsets.only(left:10, right: 10),
                margin: EdgeInsets.all(5),
      child: DropdownButton<String>(
        hint: Text("Sport"),
        value: sportValue,
        onChanged: (String newValue) {
          setState(() {
            sportValue = newValue;
          });
          updateStream();
        },
        items: <String>['All Sports','Soccer', 'Basket Ball', 'Volleyball', 'Track']
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          })
          .toList(),
          )
      );   
  }

  searchBarField(){
    //final myController = TextEditingController();
    return Container(
      width: 200,
      decoration: new BoxDecoration(
                  color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                  borderRadius: new BorderRadius.only(
                    topLeft:  const  Radius.circular(25.0),
                    topRight: const  Radius.circular(25.0),
                    bottomLeft: const  Radius.circular(25.0),
                    bottomRight: const  Radius.circular(25.0))
                ),
                padding: EdgeInsets.only(left:10, right: 10),
                margin: EdgeInsets.all(5),
      child: Column(
          children: <Widget>[
            Expanded(
              child: TextField(
                onChanged: (data){
                  setState(() {
                    searchSrting = data;
                  });
                  updateStream();
                },
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search team'
                ),
              )
            )
          ],
        )
      ); 
  }

  updateStream() {
    print("==========uid==========");
    print(userId);
    print("==========uid==========");
    CollectionReference collectionRef = Firestore.instance.collection("events");
    bool gender;
    String sport;
    String category;

    if(genderValue == "Boys"){
      gender = true;
    } else if(genderValue == "Girls"){
      gender = false;
    } else {
      gender = null;
    }
    if(sportValue == "Soccer"){
      sport = "soccer";
    } else if(sportValue == "Basket Ball"){
      sport = "basketball";
    } else if(sportValue == "Volleyball"){
      sport = "volleyball";
    } else if(sportValue == "Track"){
      sport = "track";
    }

    if(categoryValue == "u10" || categoryValue == "u14" || categoryValue == "u18" || categoryValue == "a10"){
      category = categoryValue;
    } 

    eventStream = collectionRef.where("gender", isEqualTo: gender)
                                .where("sport", isEqualTo: sport)
                                .where("category", isEqualTo: category)
                                .snapshots();
  }

  fetchSearchResults(BuildContext context){
    return eventList(context);
  }

  Widget eventList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: eventStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        } else {
          return Scaffold(
            body: Center(
              child: eventsList(snapshot),
            )
          );
        }
      },
    );
  }

  eventsList(AsyncSnapshot<QuerySnapshot> snapshot){
      return CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return InkWell(
                onTap: (){ 
                  Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                     EventDetails(userId, snapshot.data.documents[index].documentID, (snapshot.data.documents[index]["gender"] ==true?"Boys":"Girls") + " / "+ snapshot.data.documents[index]["sport"] + " / "+snapshot.data.documents[index]["category"])));
                      
                },
                child: Card(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            displayInfo(snapshot.data.documents[index]),
                            snapshot.data.documents[index]["isTeamSport"] != null &&
                            snapshot.data.documents[index]["isTeamSport"] == true ?
                             displayTeams(snapshot.data.documents[index]["teams"]) : Container(),
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
              ));
            },
            childCount: snapshot.data.documents.length
            ),
          )
        ],
      );
  }

  displayInfo(event){
    return Text(event["gender"] == true ? "Boys":"Girls" + " / "+
              event["sport"] + " / " + event["category"]  
              );
  }

  displayTeams(teams) {
    if(teams != null && teams.length == 2){
      return Text(
        teams[0]["name"]+" vs "+teams[1]["name"],
        style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: "WorkSansSemiBold"
          )
        );
    } else if(teams != null && teams.length == 1){
      return Text(
        teams[0]["name"]+" vs --",
         style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: "WorkSansSemiBold"
          ));
    } else if(teams != null && teams.length >= 2){
      return Text("");
    } else {
      return Text("");
    }                     
  }
  displayLocation(location) {
    if(location != null){
      return Text(
        "Location: " + location,
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
    return Text("Status: " + status);
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
    print("======4======");
    Stream<DocumentSnapshot> subscriptionSnapshot = Firestore.instance.collection("devices").document("preferences").collection(this.userId).document("subscriptions").snapshots();
  
    subscriptionSnapshot.listen((documentData) {
      print("======5======");
      print("check: "+documentData.data.toString());
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
}
