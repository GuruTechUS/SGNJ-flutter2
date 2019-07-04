import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Links extends StatefulWidget{
  
  @override
  State<StatefulWidget> createState() {
    return _LinksState();
  }

}

class _LinksState extends State<Links>{

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  _LinksState(){
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
        child: linkList(context),
    ));
  }

  Widget linkList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("links").snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        } else {
          return renderLinkList(snapshot);
        }
      },
    );
  }

  renderLinkList(AsyncSnapshot<QuerySnapshot> snapshot){
      return CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text('Docs/Links')
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
                          fileIcon(),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(snapshot.data.documents[index]["name"],
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold
                            )),
                          //  displayTeams(snapshot.data.documents[index]["teams"]),
                          ],
                        )
                      ),
                        Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          openButton(snapshot.data.documents[index]["url"]),
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

  openButton(url){
    return Container(
      padding: EdgeInsets.all(10.0),
      child: InkWell(
            onTap: () {
            _launchURL(Uri.encodeFull(url));
            },
            child: Image.asset(
                 "assets/images/link-filled.png",
                width: 30,
              )));
  }

  fileIcon(){
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Image.asset(
                 "assets/images/file.png",
                width: 30,
              ));
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}