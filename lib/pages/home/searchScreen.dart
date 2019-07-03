
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  
  String genderValue;
  String categoryValue;
  String sportValue;
  String searchSrting = "";

  @override
  Widget build(BuildContext context) {
    return searchScreenLayout2(context);
    
  }

  searchScreenLayout(BuildContext context){
    return StaggeredGridView.count(
      crossAxisCount: 1,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      //padding: EdgeInsets.all(5.0),
      children: <Widget>[
        searchBar(context),
        fetchSearchResults()
        ],
      staggeredTiles: [
        StaggeredTile.extent(1, 60),
        StaggeredTile.extent(1, MediaQuery.of(context).size.height),
      ],
    );
  }

  searchScreenLayout2(BuildContext context){
    return CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: searchBar(context),
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                  return Card();
                }
              )
            )
          ]);
                  
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
          //fetchSearchResults();
        },
        items: <String>['All Genders', 'Boys', 'Girls']
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
          //fetchSearchResults();
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
          //fetchSearchResults();
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
                  //fetchSearchResults();
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

  fetchSearchResults(){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Text("hello")
    );
  }
}
