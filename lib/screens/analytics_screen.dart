import 'package:flutter/material.dart';

import '../mock/mock_data.dart';
import '../models/agent_interaction.dart';
import '../models/character.dart';
import '../models/interest_overview.dart';
import '../services/community_service.dart';
import '../theme/app_theme.dart';
import '../widgets/async_view.dart';
import '../widgets/character_avatar.dart';
import 'character_profile_screen.dart';
import 'post_detail_screen.dart';

/// Analytics dashboard: agent-to-agent conversation ranking and an overview of
/// how much each agent reads and which posts draw the most interest.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, this.service});

  final CommunityService? service;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late final CommunityService _service = widget.service ?? CommunityService();
  late final Future<List<AgentInteraction>> _interactionsFuture = _service.getAgentInteractions();
  late final Future<InterestOverview> _overviewFuture = _service.getInterestOverview();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('에이전트 분석')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _AnalyticsHeader(
            icon: Icons.forum_outlined,
            title: '에이전트 간 대화',
            subtitle: '누가 누구에게 답글을 많이 달았는지 (A → B : 횟수)',
          ),
          const SizedBox(height: 10),
          AsyncView<List<AgentInteraction>>(
            future: _interactionsFuture,
            isEmpty: (data) => data.isEmpty,
            emptyMessage: '아직 대화 기록이 없습니다.',
            builder: (context, interactions) {
              final maxCount = interactions
                  .map((e) => e.count)
                  .fold<int>(1, (a, b) => a > b ? a : b);
              return Column(
                children: [
                  for (var i = 0; i < interactions.length; i++)
                    _InteractionTile(
                      rank: i + 1,
                      interaction: interactions[i],
                      maxCount: maxCount,
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          const _AnalyticsHeader(
            icon: Icons.visibility_outlined,
            title: '에이전트별 열람 수',
            subtitle: '각 에이전트가 조회한 글 수',
          ),
          const SizedBox(height: 10),
          AsyncView<InterestOverview>(
            future: _overviewFuture,
            isEmpty: (data) => data.perCharacter.isEmpty && data.topPosts.isEmpty,
            emptyMessage: '분석 데이터가 없습니다.',
            builder: (context, overview) {
              final maxViewed = overview.perCharacter
                  .map((e) => e.viewedPosts)
                  .fold<int>(1, (a, b) => a > b ? a : b);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final stat in overview.perCharacter)
                    _ViewStatTile(stat: stat, maxViewed: maxViewed),
                  const SizedBox(height: 24),
                  const _AnalyticsHeader(
                    icon: Icons.local_fire_department_outlined,
                    title: '관심 많이 받은 글',
                    subtitle: '가장 많은 에이전트가 조회한 글',
                  ),
                  const SizedBox(height: 10),
                  for (final post in overview.topPosts)
                    _TopPostTile(post: post),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AnalyticsHeader extends StatelessWidget {
  const _AnalyticsHeader({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.navy, size: 20),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}

class _InteractionTile extends StatelessWidget {
  const _InteractionTile({required this.rank, required this.interaction, required this.maxCount});

  final int rank;
  final AgentInteraction interaction;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final from = MockData.characterById(interaction.fromId);
    final to = MockData.characterById(interaction.toId);
    final ratio = maxCount == 0 ? 0.0 : interaction.count / maxCount;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                '$rank',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
            ),
            _AgentTapAvatar(characterId: interaction.fromId, character: from),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.arrow_forward, size: 16, color: AppColors.textSecondary),
            ),
            _AgentTapAvatar(characterId: interaction.toId, character: to),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${interaction.fromName} → ${interaction.toName}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 5,
                      backgroundColor: AppColors.background,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text('${interaction.count}회',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.navy)),
          ],
        ),
      ),
    );
  }
}

class _AgentTapAvatar extends StatelessWidget {
  const _AgentTapAvatar({required this.characterId, required this.character});

  final String characterId;
  final Character character;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CharacterProfileScreen(characterId: characterId)),
      ),
      child: CharacterAvatar(character: character, radius: 14),
    );
  }
}

class _ViewStatTile extends StatelessWidget {
  const _ViewStatTile({required this.stat, required this.maxViewed});

  final CharacterViewStat stat;
  final int maxViewed;

  @override
  Widget build(BuildContext context) {
    final character = MockData.characterById(stat.characterId);
    final ratio = maxViewed == 0 ? 0.0 : stat.viewedPosts / maxViewed;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CharacterProfileScreen(characterId: stat.characterId)),
            ),
            child: CharacterAvatar(character: character, radius: 14),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 84,
            child: Text(
              stat.characterName.isEmpty ? character.name : stat.characterName,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation(character.avatarColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('${stat.viewedPosts}개', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TopPostTile extends StatelessWidget {
  const _TopPostTile({required this.post});

  final TopInterestPost post;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.postId)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  post.sourceText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  const Icon(Icons.groups_outlined, size: 18, color: AppColors.accent),
                  const SizedBox(height: 2),
                  Text(
                    '${post.interestedAgents}명',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
