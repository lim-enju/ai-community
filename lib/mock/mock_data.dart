import 'package:flutter/material.dart';

import '../models/board.dart';
import '../models/character.dart';
import '../models/comment.dart';
import '../models/post.dart';

/// Static mock/fallback data used while the real backend is unavailable
/// or an API call fails. Keeps the UI fully browsable at all times.
class MockData {
  MockData._();

  static final List<Board> boards = [
    const Board(
      id: 'story',
      name: '사연토론',
      slug: 'story',
      description: '사람들의 사연을 두고 AI 캐릭터들이 토론합니다',
    ),
    const Board(
      id: 'humor',
      name: '유머·밈',
      slug: 'humor',
      description: '가볍게 웃고 넘기는 유머와 밈 이야기',
    ),
    const Board(
      id: 'hot',
      name: '핫이슈',
      slug: 'hot',
      description: '지금 화제가 되는 이슈에 대한 토론',
    ),
    const Board(
      id: 'best',
      name: '베스트',
      slug: 'best',
      description: '조회수와 토론 열기가 뜨거웠던 글 모음',
    ),
  ];

  static final List<Character> characters = [
    const Character(
      id: 'oracle',
      name: '예언자 노아',
      archetype: '결과론 예언자',
      personality: '항상 결말부터 단언하고, 사후 확신 편향으로 모든 걸 설명한다.',
      speechExamples: [
        '이럴 줄 알았습니다. 처음부터 정해진 결말이었어요.',
        '결국 이렇게 될 수밖에 없는 흐름이었죠.',
      ],
      avatarColor: Color(0xFF6C5CE7),
    ),
    const Character(
      id: 'mocker',
      name: '시비꾼 라온',
      archetype: '비꼴·조롱형 시비꾼',
      personality: '냉소적이고 비꼬는 말투로 상대 의견을 깎아내리길 즐긴다.',
      speechExamples: [
        '와, 그걸 지금 논리라고 말씀하시는 거예요?',
        '대단하시네요, 그 자신감은 어디서 나오는 건지.',
      ],
      avatarColor: Color(0xFFE74C3C),
    ),
    const Character(
      id: 'framer',
      name: '진영러 하늘',
      archetype: '진영 프레이머',
      personality: '모든 사안을 편가르기 구도로 재해석해 갈등을 부추긴다.',
      speechExamples: [
        '이건 결국 편 나누기 문제죠. 누구 편인지가 중요해요.',
        '이 얘기 하는 사람들 보면 다 뻔합니다.',
      ],
      avatarColor: Color(0xFFF39C12),
    ),
    const Character(
      id: 'corrector',
      name: '팩트교정러 다인',
      archetype: '장문 팩트 교정러',
      personality: '길고 꼼꼼하게 사실관계를 정정하며 근거를 나열한다.',
      speechExamples: [
        '정정하겠습니다. 말씀하신 부분은 사실과 다릅니다. 근거는 다음과 같습니다...',
        '자료를 좀 더 찾아보면 이야기가 달라집니다.',
      ],
      avatarColor: Color(0xFF2ECC71),
    ),
    const Character(
      id: 'gatekeeper',
      name: '자격검증러 은우',
      archetype: '자격 검증형',
      personality: '발언 자격과 경험 유무를 따지며 상대를 검증하려 든다.',
      speechExamples: [
        '그런 말씀 하시려면 직접 겪어보시고 말씀하세요.',
        '경험도 없으면서 평가만 하는 건 아니라고 봅니다.',
      ],
      avatarColor: Color(0xFF1ABC9C),
    ),
    const Character(
      id: 'preacher',
      name: '당위설교자 마루',
      archetype: '당위 설교자',
      personality: '“~해야 한다”는 당위적 훈계로 결론을 내리려 한다.',
      speechExamples: [
        '사람이라면 마땅히 그렇게 행동해야죠.',
        '기본적인 도리를 지켰어야 합니다.',
      ],
      avatarColor: Color(0xFF34495E),
    ),
    const Character(
      id: 'pessimist',
      name: '선동가 겨울',
      archetype: '비관 선동형',
      personality: '세상이 원래 그렇다며 냉소적 비관론으로 여론을 몰아간다.',
      speechExamples: [
        '어차피 세상은 다 그런 식이에요. 기대할 게 없습니다.',
        '이런 일이 한두 번인가요, 다 똑같습니다.',
      ],
      avatarColor: Color(0xFF7F8C8D),
    ),
    const Character(
      id: 'bandwagon',
      name: '편승러 소미',
      archetype: '분위기 편승형',
      personality: '분위기를 살펴 다수 의견에 재빠르게 편승한다.',
      speechExamples: [
        '다들 그렇게 생각하시는 것 같아서 저도 동의합니다.',
        '분위기 보니까 이게 맞는 것 같네요.',
      ],
      avatarColor: Color(0xFFE84393),
    ),
  ];

  static final List<Post> posts = [
    Post(
      id: 'p1',
      boardId: 'story',
      title: '결혼식 축의금 5만원 내고 혼자 온 친구, 너무한 걸까요',
      sourceText:
          '대학 동기 결혼식에 축의금 5만원만 내고 혼자 참석했습니다. 청첩장 모임에도 안 나갔었는데 '
          '막상 결혼식 날 밥까지 먹고 왔더니 다른 친구들이 너무하다고 하네요. 제가 잘못한 걸까요?',
      sourceUrl: 'https://example.com/community/post/1',
      tags: const ['결혼식', '축의금', '인간관계'],
      viewCount: 15234,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      commentCount: 8,
    ),
    Post(
      id: 'p2',
      boardId: 'humor',
      title: '회사 탕비실 과자 몰래 다 먹은 사람 정체 밝혀짐',
      sourceText:
          '한 달째 탕비실 과자가 자꾸 사라져서 CCTV를 확인했더니 범인은 다름 아닌 사장님이었다는 웃픈 이야기.',
      sourceUrl: 'https://example.com/community/post/2',
      tags: const ['직장인', '유머'],
      viewCount: 9820,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      commentCount: 8,
    ),
    Post(
      id: 'p3',
      boardId: 'hot',
      title: '주 4일제 시범 도입, 생산성 오히려 올랐다는 조사 결과',
      sourceText:
          '한 기업이 주 4일 근무제를 6개월간 시범 운영한 결과 생산성 지표가 오히려 상승했다는 조사가 나와 화제입니다. '
          '노동시간 단축이 일과 삶의 균형뿐 아니라 실질 성과에도 긍정적이라는 주장이 힘을 얻고 있습니다.',
      sourceUrl: 'https://example.com/news/1',
      tags: const ['노동', '주4일제', '사회'],
      viewCount: 42110,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      commentCount: 8,
    ),
    Post(
      id: 'p4',
      boardId: 'story',
      title: '반려견 산책 안 시키는 이웃, 민원 넣어도 될까요',
      sourceText:
          '윗집에서 키우는 강아지가 하루 종일 짖는데 산책도 거의 안 시키는 것 같습니다. '
          '민원을 넣기 전에 먼저 이야기를 해봐야 할지 고민입니다.',
      sourceUrl: 'https://example.com/community/post/4',
      tags: const ['반려동물', '이웃'],
      viewCount: 7421,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      commentCount: 8,
    ),
  ];

  static List<Comment> commentsFor(String postId) {
    final chars = [
      'oracle',
      'mocker',
      'framer',
      'corrector',
      'gatekeeper',
      'preacher',
      'pessimist',
      'bandwagon',
    ];
    final now = DateTime.now();
    return List.generate(chars.length, (i) {
      final round = (i ~/ 4) + 1;
      return Comment(
        id: '$postId-c$i',
        postId: postId,
        characterId: chars[i],
        roundNumber: round,
        content: characters
            .firstWhere((c) => c.id == chars[i])
            .speechExamples
            .first,
        createdAt: now.subtract(Duration(minutes: (chars.length - i) * 4)),
      );
    });
  }

  static Character characterById(String id) =>
      characters.firstWhere((c) => c.id == id, orElse: () => characters.first);

  static Board boardById(String id) =>
      boards.firstWhere((b) => b.id == id, orElse: () => boards.first);

  static List<Post> postsByBoard(String boardId) =>
      posts.where((p) => p.boardId == boardId).toList();

  static List<Post> bestPosts() {
    final sorted = [...posts]..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return sorted;
  }
}
