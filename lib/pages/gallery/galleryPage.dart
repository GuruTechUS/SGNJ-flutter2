import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/pages/gallery/photoView.dart';
import 'package:firebase_app/utils/firebase_anon_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
//import 'package:image_picker/image_picker.dart';

class Gallery extends StatefulWidget{
  
  @override
  State<StatefulWidget> createState() {
    return _GalleryState();
  }

}

class _GalleryState extends State<Gallery>{

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  StreamSubscription<QuerySnapshot> subscription;
  List<DocumentSnapshot> wallpapersList;
  final CollectionReference collectionReference =
      Firestore.instance.collection("gallery");

  final FirebaseAnonAuth firebaseAnonAuth = new FirebaseAnonAuth();

  String userId;
  bool isAdminLoggedIn = false;

  _GalleryState(){
    firebaseAnonAuth.isLoggedIn().then((user){
      if(user != null && user.uid != null){
        setState(() {
          this.userId = user.uid;
          if(user.isAnonymous == false){
            isAdminLoggedIn = true;
          }
        });
      } else {
        firebaseAnonAuth.signInAnon().then((anonUser) {
          if(anonUser != null && anonUser.uid != null){
            setState(() {
              this.userId = anonUser.uid;
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    subscription = collectionReference.snapshots().listen((datasnapshot) {
      setState(() {
        wallpapersList = datasnapshot.documents;
      });
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title:  Center(
            child: Text("          Gallery")
          ),
          actions: <Widget>[
          isAdminLoggedIn ? IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add Photo',
            onPressed: () {
              //addPhoto();
              //_optionsDialogBox();
            },
          ) : Container()
        ],
        ),
        body: wallpapersList != null
            ? new StaggeredGridView.countBuilder(
                padding: const EdgeInsets.all(8.0),
                crossAxisCount: 4,
                itemCount: wallpapersList.length,
                itemBuilder: (context, i) {
                  return new Material(
                    elevation: 8.0,
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(8.0)),
                    child: new InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                     PhotoViewer(wallpapersList, i)));
                      },
                      child: new Hero(
                        tag: wallpapersList[i].documentID,
                        child: new FadeInImage(
                          image: new NetworkImage(wallpapersList[i].data['url']),
                          fit: BoxFit.cover,
                          placeholder: new AssetImage("assets/images/placeholder.png"),
                        ),
                      ),
                    ),
                  );
                },
                staggeredTileBuilder: (i) =>
                    new StaggeredTile.count(2, i.isEven ? 2 : 3),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              )
            : new Center(
                child: new CircularProgressIndicator(),
              ));
  }

  /*
  addPhoto(){
    
  }

  Future<void> _optionsDialogBox() {
    return showDialog(context: context,
      builder: (BuildContext context) {
          return AlertDialog(
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: new Text('Take a picture'),
                    onTap: openCamera,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: new Text('Select from gallery'),
                    onTap: openGallery,
                  ),
                ],
              ),
            ),
          );
        }
      );
  }
  Future openCamera() async {
    var picture = "openCamera";
    //var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    print(picture);
  }

  Future openGallery() async {
    //var picture = "openGallery";
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(picture);
  }

  */
  
}