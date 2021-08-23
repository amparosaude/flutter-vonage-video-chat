import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:vonage/publisher_view.dart';
import 'package:vonage/subscriber_view.dart';

/// show a video chat view if session is realized
class VonageVideoChatScreen extends StatelessWidget {
  // static String _viewType = 'flutter-vonage-video-chat';
  // int _pluginViewId = -1;

  // VonageVideoChatScreen({ Key key }) : super(key: key);

  // @override
  // Widget build(BuildContext context) {
  //   Map<String, dynamic> creationParams = <String, dynamic> {};
  //   if (defaultTargetPlatform == TargetPlatform.android) {
  //     return PlatformViewLink(
  //       viewType: _viewType,
  //       surfaceFactory: (BuildContext context, PlatformViewController controller) {          
  //         return AndroidViewSurface(
  //           controller: controller,
  //           gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{},
  //           hitTestBehavior: PlatformViewHitTestBehavior.opaque,
  //         );
  //       },
  //       onCreatePlatformView: (PlatformViewCreationParams params) {
  //         return PlatformViewsService.initSurfaceAndroidView(
  //           id: params.id,
  //           viewType: _viewType,
  //           layoutDirection: TextDirection.ltr,
  //           creationParams: creationParams,
  //           creationParamsCodec: StandardMessageCodec(),
  //         )
  //         ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
  //         ..create();
  //       },
  //     );
  //   } else if(defaultTargetPlatform == TargetPlatform.iOS) {
  //     return UiKitView(
  //       viewType: _viewType,
  //       layoutDirection: TextDirection.ltr,
  //       creationParams: creationParams,
  //       creationParamsCodec: const StandardMessageCodec(),
  //       onPlatformViewCreated: (int id) {
  //         _pluginViewId = id;
  //       },
  //     );
  //   }
  //   return Container();
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Stack(
        children: [
          SubscriberView(),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 90,
              height: 120,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PublisherView()),
            ),
          ),
        ],
      ),
    );
  }
}