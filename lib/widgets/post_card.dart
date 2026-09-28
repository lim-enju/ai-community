import 'package:flutter/material.dart';

import '../mock/mock_data.dart';
import '../models/post.dart';
import '../screens/post_detail_screen.dart';
import '../theme/app_theme.dart';
import 'tag_chip.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.showBoardLabel = false});

  final Post post;
  final bool showBoardLabel;

  @override
  Widget build(BuildContext context) {
    final board = MockData.boardById(post.boardId);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showBoardLabel)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    board.name,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                post.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              if (post.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: post.tags.map((t) => TagChip(label: t)).toList(),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${post.viewCount}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  const Icon(Icons.forum_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
