import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotoGrid extends StatelessWidget {
  final List<String> photoUrls;
  final int maxPhotos;
  final Function(int)? onPhotoTap;
  final Function(int)? onPhotoDelete;

  const PhotoGrid({
    super.key,
    required this.photoUrls,
    this.maxPhotos = 6,
    this.onPhotoTap,
    this.onPhotoDelete,
  });

  @override
  Widget build(BuildContext context) {
    final displayPhotos = photoUrls.take(maxPhotos).toList();
    final remainingCount = photoUrls.length - maxPhotos;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: displayPhotos.length + (remainingCount > 0 ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < displayPhotos.length) {
          return _buildPhotoItem(
            context,
            displayPhotos[index],
            index,
            isLast: index == displayPhotos.length - 1 && remainingCount > 0,
            remainingCount: remainingCount,
          );
        } else {
          return _buildRemainingCounter(remainingCount);
        }
      },
    );
  }

  Widget _buildPhotoItem(
      BuildContext context,
      String url,
      int index, {
        bool isLast = false,
        int remainingCount = 0,
      }) {
    return GestureDetector(
      onTap: () => onPhotoTap?.call(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          if (isLast && remainingCount > 0)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                child: Text(
                  '+$remainingCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (onPhotoDelete != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onPhotoDelete?.call(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRemainingCounter(int count) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: Center(
        child: Text(
          '+$count',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}