import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vaastav/progress.dart';

Widget cachedNetworkImage(String previewImage) {
  return CachedNetworkImage(
    imageUrl: previewImage,
    fit: BoxFit.cover,
    placeholder: (context, url) => Padding(
      child: circularProgress(),
      padding: EdgeInsets.all(20.0),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}
