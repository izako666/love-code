import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:love_code/localization.dart';
import 'package:love_code/portable_api/ui/bottom_sheet.dart';
import 'package:love_code/ui/util/lc_app_bar.dart';
import 'package:love_code/ui/util/lc_button.dart';
import 'package:love_code/ui/util/lc_scaffold.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

Future<T?> imagePickerBottomSheet<T>(BuildContext context, {required Function(AssetPathEntity album, AssetEntity image)? onImageTap}) {
  return showIzBottomSheet<T>(
      context: context,
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: ImagePicker(
        onImageTap: onImageTap,
      ));
}

class ImagePicker extends StatefulWidget {
  final Function(AssetPathEntity album, AssetEntity image)? onImageTap;
  const ImagePicker({
    super.key,
    this.onImageTap,
  });

  @override
  State<ImagePicker> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePicker> {
  bool selectingPhotos = true;
  List<AssetPathEntity>? albums;
  AssetPathEntity? currentAlbum;
  List<AssetEntity>? currentPhotos = List.empty(growable: true);
  List<AssetEntity>? albumThumbnails;
  bool loading = true;
  bool loadedThumbnails = false;
  bool loadingMoreImages = false;
  late ScrollController imgScrollController;
  @override
  void initState() {
    imgScrollController = ScrollController(keepScrollOffset: true);
    imgScrollController.addListener(() async {
      if (imgScrollController.position.pixels >= imgScrollController.position.maxScrollExtent && !loadingMoreImages) {
        loadingMoreImages = true;
        setState(() {});
        await loadMoreImages();
        loadingMoreImages = false;
        setState(() {});
      }
    });
    loadData();
    super.initState();
  }

  void loadData() async {
    List<AssetPathEntity> loadedAlbums = await IzPhotoManager.loadAlbums();
    List<AssetEntity> photos = await IzPhotoManager.loadImages(loadedAlbums[0], 0, 24);
    albums = loadedAlbums;
    currentAlbum = albums![0];
    currentPhotos = photos;
    setState(() {});
  }

  Future<void> loadMoreImages() async {
    int albumAssetCount = await currentAlbum!.assetCountAsync;
    int start = currentPhotos!.length;
    int end = (currentPhotos!.length + 24) > albumAssetCount ? albumAssetCount : (currentPhotos!.length + 24);
    if (currentPhotos!.length == albumAssetCount) {
      return;
    }
    List<AssetEntity> photos = await IzPhotoManager.loadImages(currentAlbum!, start, end);
    currentPhotos!.addAll(photos);
  }

  @override
  Widget build(BuildContext context) {
    if (selectingPhotos == false && !loadedThumbnails && albums != null) {
      albumThumbnails = null;

      IzPhotoManager.loadAlbumThumbnails(albums!).then((value) {
        loadedThumbnails = true;
        albumThumbnails = value;
        setState(() {});
      });
    }
    return LcScaffold(
      extendBodyBehindAppBar: true,
      appBar: const LcAppBar(
        title: Text('Select Image'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (albums == null || currentPhotos == null) const Center(child: CircularProgressIndicator()),
          if (albums != null && currentPhotos != null) ...[
            TextButton(
              child: Row(
                children: [
                  Text(currentAlbum!.name,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 18, decoration: TextDecoration.underline)),
                  Icon(selectingPhotos ? Icons.arrow_drop_down_rounded : Icons.arrow_drop_up_rounded, color: Colors.white)
                ],
              ),
              onPressed: () {
                if (selectingPhotos) {
                  loadedThumbnails = false;
                  selectingPhotos = false;
                } else {
                  selectingPhotos = true;
                }
                setState(() {});
              },
            ),
            const Divider(),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.45,
              child: (currentPhotos == null)
                  ? const Center(child: CircularProgressIndicator())
                  : (selectingPhotos)
                      ? GridView.builder(
                          padding: EdgeInsets.zero,
                          controller: imgScrollController,
                          itemCount: loadingMoreImages
                              ? ((currentPhotos!.length % 3) == 0
                                  ? currentPhotos!.length + 3
                                  : currentPhotos!.length + 3 + (currentPhotos!.length % 3))
                              : currentPhotos!.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                          itemBuilder: (ctx, i) {
                            return (i < currentPhotos!.length)
                                ? Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: InkWell(
                                      onTap: () {
                                        if (widget.onImageTap != null) {
                                          widget.onImageTap!(currentAlbum!, currentPhotos![i]);
                                        }
                                      },
                                      child: AssetEntityImage(
                                        currentPhotos![i],
                                        isOriginal: false,
                                        thumbnailSize: const ThumbnailSize.square(250),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stacktrace) {
                                          return const Center(child: Icon(Icons.error, color: Colors.red));
                                        },
                                      ),
                                    ))
                                : (i ==
                                        currentPhotos!.length +
                                            (((currentPhotos!.length % 3) == 0 ? 3 : 3 + (currentPhotos!.length % 3)) - 2))
                                    ? const SizedBox(width: 50, height: 50, child: Center(child: CircularProgressIndicator()))
                                    : Container(width: 50, height: 50, color: Colors.transparent);
                          })
                      : (loadedThumbnails && albumThumbnails != null)
                          ? GridView.builder(
                              shrinkWrap: true,
                              itemCount: albums!.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                              itemBuilder: (ctx, i) {
                                return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: InkWell(
                                      onTap: () {
                                        currentAlbum = albums![i];
                                        selectingPhotos = true;
                                        setState(() {});
                                      },
                                      child: Flexible(
                                        child: Container(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 180,
                                                height: 150,
                                                child: ClipRRect(
                                                  clipBehavior: Clip.hardEdge,
                                                  borderRadius: BorderRadius.circular(16),
                                                  child: AssetEntityImage(
                                                    albumThumbnails![i],
                                                    isOriginal: false,
                                                    fit: BoxFit.cover,
                                                    thumbnailSize: const ThumbnailSize.square(360),
                                                  ),
                                                ),
                                              ),
                                              Text(albums![i].name, style: Theme.of(context).textTheme.titleSmall)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ));
                              },
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
            )
          ]
        ],
      ),
    );
  }
}

class IzPhotoManager {
  static Future<List<AssetPathEntity>> loadAlbums() async {
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    return albums;
  }

  static Future<List<AssetEntity>> loadImages(AssetPathEntity selectedAlbum, int start, int end) async {
    List<AssetEntity> imageList = await selectedAlbum.getAssetListRange(start: start, end: end);
    return imageList;
  }

  static Future<List<AssetEntity>> loadAlbumThumbnails(List<AssetPathEntity> albums) async {
    List<AssetEntity> thumbnails = List.empty(growable: true);
    for (int i = 0; i < albums.length; i++) {
      thumbnails.add((await albums[i].getAssetListRange(start: 0, end: 1))[0]);
    }
    return thumbnails;
  }
}

class ImageCropper extends StatefulWidget {
  const ImageCropper({super.key, required this.image, this.withCircleUi = true});
  final Uint8List image;
  final bool withCircleUi;
  @override
  State<ImageCropper> createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  late CropController controller;
  @override
  void initState() {
    super.initState();
    controller = CropController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 300.w,
          height: 200.w,
          child: Crop(
            withCircleUi: widget.withCircleUi,
            image: widget.image,
            aspectRatio: 1.0,
            progressIndicator: const CircularProgressIndicator(),
            onCropped: (image) {
              Get.back(result: image);
            },
            controller: controller,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LcButton(
              width: 128,
              height: 32,
              text: Localization.send,
              onPressed: () {
                controller.cropCircle();
              },
            ),
            const SizedBox(width: 32),
            LcButton(
              width: 128,
              height: 32,
              text: Localization.cancel,
              onPressed: () {
                Get.back(result: null);
              },
            )
          ],
        ),
      ],
    );
  }
}
