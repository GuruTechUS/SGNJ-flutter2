import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewer extends StatefulWidget{
  
  final int initialIndex;
  final PageController pageController;
  final List<DocumentSnapshot> imagesList;

  PhotoViewer(this.imagesList, this.initialIndex):
    pageController = PageController(initialPage: initialIndex);
  

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewerState();
  }
}

class _PhotoViewerState extends State<PhotoViewer>{

  int currentIndex;
  
  _PhotoViewerState(){
  }

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black
        ),
        constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: _buildItem,
                itemCount: widget.imagesList.length,
                loadingChild: null,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
                pageController: widget.pageController,
                onPageChanged: onPageChanged,
              )
          ],
        ),
      ),
    );
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    //final GalleryExampleItem item = widget.galleryItems[index];
    return  PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.imagesList[index].data['url']),
            initialScale: PhotoViewComputedScale.contained,
            //minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
            //maxScale: PhotoViewComputedScale.covered * 1.1,
            heroTag: widget.imagesList[index].documentID,
          );
  }
}