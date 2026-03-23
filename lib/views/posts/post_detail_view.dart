import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/post_model.dart';
import '../../models/place_model.dart';
import '../explore/widgets/explore_post_feed_card.dart';

class PostDetailView extends StatelessWidget {
  const PostDetailView({super.key, required this.post, this.place});

  final PostModel post;
  final PlaceModel? place;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Bài viết',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        child: ExplorePostFeedCard(
          post: post,
          place: place,
          onOpenPlace: null, // Có thể truyền logic mở quán nếu cần
        ),
      ),
    );
  }
}
