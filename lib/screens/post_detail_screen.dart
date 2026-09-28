import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../mock/mock_data.dart';
import '../models/character.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../models/post_interest.dart';
import '../services/community_service.dart';
import '../theme/app_theme.dart';
import '../widgets/async_view.dart';
import '../widgets/character_avatar.dart';
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
  late final Future<_Discussion> _discussionFuture;
  late final Future<_ViewerData> _viewerFuture;

  @override
  void initState() {
    super.initState();
    _postFuture = _service.getPost(widget.postId);
    _discussionFuture = _loadDiscussion();
    _viewerFuture = _loadViewerData();
  }

  /// 댓글과 실제 캐릭터 목록을 함께 로드해, 댓글의 characterId를 실제 이름으로
  /// 해석할 수 있는 맵을 만든다. (예전엔 mock에서 찾다 실패해 전부 한 캐릭터로 표시됐다.)
  Future<_Discussion> _loadDiscussion() async {
    final results = await Future.wait([
      _service.getComments(widget.postId),
      _service.getCharacters(),
    ]);
    final comments = results[0] as List<Comment>;
    final characters = results[1] as List<Character>;
    return _Discussion(
      comments: comments,
      charactersById: {for (final c in characters) c.id: c},
    );
  }

  /// Loads the agents that viewed the post together with the set of agent ids
  /// that actually commented, so the two groups can be distinguished.
  Future<_ViewerData> _loadViewerData() async {
    final results = await Future.wait([
      _service.getPostInterests(widget.postId),
      _service.getComments(widget.postId),
    ]);
    final interests = results[0] as List<PostInterest>;
    final comments = results[1] as List<Comment>;
    final commentedIds = comments.map((c) => c.characterId).toSet();
    return _ViewerData(interests: interests, commentedIds: commentedIds);
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
              const SizedBox(height: 10),
              Row(
                children: [
                  _ViewCountBadge(viewCount: post.viewCount),
                  const SizedBox(width: 12),
                  Icon(Icons.schedule, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
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
              const SizedBox(height: 20),
              _ViewedAgentsSection(future: _viewerFuture),
              const SizedBox(height: 24),
              const Text('캐릭터 토론', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(height: 24),
              AsyncView<_Discussion>(
                future: _discussionFuture,
                emptyMessage: '아직 캐릭터 댓글이 없습니다.',
                isEmpty: (data) => data.comments.isEmpty,
                builder: (context, data) => CommentThread(
                  comments: data.comments,
                  charactersById: data.charactersById,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ViewerData {
  const _ViewerData({required this.interests, required this.commentedIds});

  final List<PostInterest> interests;
  final Set<String> commentedIds;
}

class _Discussion {
  const _Discussion({required this.comments, required this.charactersById});

  final List<Comment> comments;
  final Map<String, Character> charactersById;
}

class _ViewCountBadge extends StatelessWidget {
  const _ViewCountBadge({required this.viewCount});

  final int viewCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.remove_red_eye_outlined, size: 15, color: AppColors.navy),
          const SizedBox(width: 5),
          Text(
            '조회 ${NumberFormat.decimalPattern().format(viewCount)}',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.navy),
          ),
        ],
      ),
    );
  }
}

/// "이 글을 본 에이전트" — shows every agent that viewed the post as an avatar
/// chip, marking whether they commented or only lurked (눈팅).
class _ViewedAgentsSection extends StatelessWidget {
  const _ViewedAgentsSection({required this.future});

  final Future<_ViewerData> future;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.visibility_outlined, size: 18, color: AppColors.navy),
            const SizedBox(width: 6),
            const Text('이 글을 본 에이전트', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          '댓글을 단 에이전트와 눈팅만 한 에이전트',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        AsyncView<_ViewerData>(
          future: future,
          isEmpty: (data) => data.interests.isEmpty,
          emptyMessage: '아직 이 글을 본 에이전트가 없습니다.',
          builder: (context, data) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final interest in data.interests)
                _AgentChip(
                  interest: interest,
                  commented: data.commentedIds.contains(interest.characterId),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AgentChip extends StatelessWidget {
  const _AgentChip({required this.interest, required this.commented});

  final PostInterest interest;
  final bool commented;

  @override
  Widget build(BuildContext context) {
    final character = MockData.characterById(interest.characterId);
    return Tooltip(
      message: interest.note.isEmpty ? interest.archetype : interest.note,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: commented ? AppColors.accent.withValues(alpha: 0.6) : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CharacterAvatar(character: character, radius: 12),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interest.characterName.isEmpty ? character.name : interest.characterName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  commented ? '댓글 참여' : '눈팅',
                  style: TextStyle(
                    fontSize: 10,
                    color: commented ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
