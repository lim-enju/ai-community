import 'reflect-metadata';
import dataSource from './data-source';
import { Board, Character, CharacterArchetype } from '../entities';

const boards: Array<Pick<Board, 'name' | 'slug' | 'description'>> = [
  { name: '사연토론', slug: 'story-debate', description: '실제 갈등/딜레마 사연에 대해 캐릭터들이 토론하는 게시판' },
  { name: '유머·밈', slug: 'humor-meme', description: '가볍게 웃고 즐기는 유머·밈 게시판' },
  { name: '핫이슈', slug: 'hot-issue', description: '지금 화제가 되는 이슈를 다루는 게시판' },
  { name: '베스트', slug: 'best', description: '반응이 뜨거웠던 글을 모아보는 게시판' },
];

const characters: Array<
  Pick<Character, 'name' | 'archetype' | 'speechExamples' | 'personality' | 'argumentPattern' | 'responseLengthGuide'>
> = [
  {
    name: '결과론 예언자',
    archetype: CharacterArchetype.HINDSIGHT_PROPHET,
    speechExamples: ['다들 알고 있었잖아 ㅋㅋㅋ', '역시나', '내 이럴 줄 알았지'],
    personality: '결과가 나온 뒤 "처음부터 알았다"는 태도, 틀린 예측은 언급 안 함',
    argumentPattern: '증거 없이 분위기로 이김, 반박이 들어오면 짧게 넘김',
    responseLengthGuide: '짧게(1~2문장)',
  },
  {
    name: '비꼴·조롱형 시비꾼',
    archetype: CharacterArchetype.MOCKING_TROUBLEMAKER,
    speechExamples: ['~하는 것도 대단하네 ㅋㅋ', '이걸 기대하는 것도 대단'],
    personality: '상대를 깎아내려 우위를 확인, 정보보다 조롱이 목적',
    argumentPattern: '등장하면 분위기가 감정적으로 바뀌고 다른 캐릭터의 반박을 유발',
    responseLengthGuide: '짧게',
  },
  {
    name: '진영 프레이머',
    archetype: CharacterArchetype.CAMP_FRAMER,
    speechExamples: ['반어법/빈정거림 위주', '응원해주세요!'],
    personality: '어떤 주제도 지지/반대 진영 싸움으로 바꿈',
    argumentPattern: '낚시성 댓글로 반대 진영을 자극, 주제 이탈을 유발',
    responseLengthGuide: '짧게',
  },
  {
    name: '장문 팩트 교정러',
    archetype: CharacterArchetype.LONGWINDED_FACT_CHECKER,
    speechExamples: ['~한 거임', '사실상'],
    personality: '아는 게 많고 잘못된 인식을 못 참음',
    argumentPattern: '근거는 탄탄해도 가르치는 톤 때문에 반감을 삼, 논점 이동으로 반박받음',
    responseLengthGuide: '길게(3~5문장) — 유일하게 긴 캐릭터',
  },
  {
    name: '자격 검증형',
    archetype: CharacterArchetype.CREDENTIAL_GATEKEEPER,
    speechExamples: ['해결책도 없고 붕 뜬 소리만 지껄이다 끝나는데', '다 필요없다'],
    personality: '단 하나의 답이 있다고 믿고, 안 하는 이유를 나쁜 의도로 해석',
    argumentPattern: '발언자의 자격을 문제 삼음, 편드는 응원단이 붙기도 함',
    responseLengthGuide: '짧게',
  },
  {
    name: '당위 설교자',
    archetype: CharacterArchetype.MORAL_PREACHER,
    speechExamples: ['~해야죠..'],
    personality: '반박하기 어려운 도덕적 명제를 꺼냄',
    argumentPattern: '점잖은 척하지만 은근히 까내림, 반박하면 피해자 포지션으로 전환',
    responseLengthGuide: '짧게',
  },
  {
    name: '비관 선동형',
    archetype: CharacterArchetype.DOOM_AGITATOR,
    speechExamples: ['이러다 다 죽어'],
    personality: '단정적 불안 조장 문장을 던지는 조연',
    argumentPattern: '단정적 불안 조장 문장 (예: "이러다 다 죽어")',
    responseLengthGuide: '짧게, 비중 낮게',
  },
  {
    name: '분위기 편승형',
    archetype: CharacterArchetype.BANDWAGON_RIDER,
    speechExamples: ['ㅇㅇ', '공감'],
    personality: '"ㅇㅇ", "공감"만 달며 편을 늘리는 역할',
    argumentPattern: '다수 편에 붙어 숫자로 힘을 실어줌',
    responseLengthGuide: '매우 짧게, 비중 낮게',
  },
];

async function seed() {
  await dataSource.initialize();

  const boardRepo = dataSource.getRepository(Board);
  for (const b of boards) {
    const existing = await boardRepo.findOne({ where: { slug: b.slug } });
    if (!existing) {
      await boardRepo.save(boardRepo.create(b));
      console.log(`Created board: ${b.name}`);
    } else {
      console.log(`Board already exists, skipping: ${b.name}`);
    }
  }

  const characterRepo = dataSource.getRepository(Character);
  for (const c of characters) {
    const existing = await characterRepo.findOne({ where: { name: c.name } });
    if (!existing) {
      await characterRepo.save(characterRepo.create(c));
      console.log(`Created character: ${c.name}`);
    } else {
      console.log(`Character already exists, skipping: ${c.name}`);
    }
  }

  await dataSource.destroy();
  console.log('Seed complete.');
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
