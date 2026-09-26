import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../services/community_service.dart';
import '../theme/app_theme.dart';
import '../widgets/async_view.dart';
import '../widgets/comment_thread.dart';
import '../widgets/tag_chip.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId, this.service});

  final String postId;
  final CommunityService? service;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late final CommunityService _service = widget.service ?? CommunityService();
  late final Future<Post> _postFuture;
  late final Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _postFuture = _service.getPost(widget.postId);
    _commentsFuture = _service.getComments(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시글')),
      body: AsyncView<Post>(
        future: _postFuture,
        builder: (context, post) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(post.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('조회수 ${post.viewCount}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('yyyy.MM.dd HH:mm').format(post.createdAt),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              if (post.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: post.tags.map((t) => TagChip(label: t)).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(post.sourceText, style: const TextStyle(fontSize: 15, height: 1.5)),
                ),
              ),
              if (post.sourceUrl != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.link, size: 14, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        post.sourceUrl!,
                        style: const TextStyle(fontSize: 12, color: AppColors.accent),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              const Text('캐릭터 토론', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(height: 24),
              AsyncView<List<Comment>>(
                future: _commentsFuture,
                emptyMessage: '아직 캐릭터 댓글이 없습니다.',
                isEmpty: (data) => data.isEmpty,
                builder: (context, comments) => CommentThread(comments: comments),
              ),
            ],
          );
        },
      ),
    );
  }
}
