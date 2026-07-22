import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// A minimal in-app photo grid used instead of the platform gallery picker.
///
/// The platform picker (as wrapped by `image_picker`) hands back a photo
/// through Android's content resolver, which redacts GPS EXIF data on
/// Android 10+ scoped storage unless the caller holds
/// `ACCESS_MEDIA_LOCATION` and explicitly asks for the unredacted original
/// (`MediaStore.setRequireOriginal`). `photo_manager`'s [AssetEntity.originFile]
/// does that for us, so picking through this grid is what lets a photo's
/// real embedded location survive into the app.
class PhotoAssetPickerPage extends StatefulWidget {
  const PhotoAssetPickerPage({super.key});

  @override
  State<PhotoAssetPickerPage> createState() => _PhotoAssetPickerPageState();
}

class _PhotoAssetPickerPageState extends State<PhotoAssetPickerPage> {
  static const _pageSize = 60;
  static const _loadMoreThreshold = 800.0;

  final _scrollController = ScrollController();
  final _assets = <AssetEntity>[];

  AssetPathEntity? _album;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _init();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final permission = await PhotoManager.requestPermissionExtend(
        requestOption: const PermissionRequestOption(
          androidPermission: AndroidPermission(
            type: RequestType.image,
            mediaLocation: true,
          ),
        ),
      );
      if (permission != PermissionState.authorized &&
          permission != PermissionState.limited) {
        throw StateError('Photo library access was denied.');
      }

      final albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.image,
        // FilterOptionGroup's own default has no `orders`, which leaves
        // sorting up to the platform's natural (often oldest-first) cursor
        // order. Ask for newest-first explicitly, matching how a gallery
        // app is expected to sort photos.
        filterOption: FilterOptionGroup(
          orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
        ),
      );
      if (albums.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
        return;
      }
      _album = albums.first;
      await _loadMore();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    final album = _album;
    if (album == null || _isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    final start = _assets.length;
    final next = await album.getAssetListRange(
      start: start,
      end: start + _pageSize,
    );

    if (!mounted) return;
    setState(() {
      _assets.addAll(next);
      _hasMore = next.length == _pageSize;
      _isLoadingMore = false;
    });
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a photo')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Photo library access is needed to pick a memory photo.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: PhotoManager.openSetting,
                child: const Text('Open settings'),
              ),
            ],
          ),
        ),
      );
    }
    if (_assets.isEmpty) {
      return const Center(child: Text('No photos found.'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _assets.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _assets.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final asset = _assets[index];
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(asset),
          child: _AssetThumbnail(asset: asset),
        );
      },
    );
  }
}

class _AssetThumbnail extends StatelessWidget {
  const _AssetThumbnail({required this.asset});

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize.square(200)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest);
        }
        return Image.memory(snapshot.data!, fit: BoxFit.cover);
      },
    );
  }
}
