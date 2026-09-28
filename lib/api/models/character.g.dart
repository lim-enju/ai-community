// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Character _$CharacterFromJson(Map<String, dynamic> json) => Character(
  id: json['id'] as String,
  name: json['name'] as String,
  archetype: CharacterArchetype.fromJson(json['archetype'] as String),
  speechExamples: (json['speechExamples'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  personality: json['personality'] as String,
  argumentPattern: json['argumentPattern'] as String,
  responseLengthGuide: json['responseLengthGuide'] as String,
);

Map<String, dynamic> _$CharacterToJson(Character instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'archetype': _$CharacterArchetypeEnumMap[instance.archetype]!,
  'speechExamples': instance.speechExamples,
  'personality': instance.personality,
  'argumentPattern': instance.argumentPattern,
  'responseLengthGuide': instance.responseLengthGuide,
};

const _$CharacterArchetypeEnumMap = {
  CharacterArchetype.undefined0: '결과론 예언자',
  CharacterArchetype.undefined1: '비꼴·조롱형 시비꾼',
  CharacterArchetype.undefined2: '진영 프레이머',
  CharacterArchetype.undefined3: '장문 팩트 교정러',
  CharacterArchetype.undefined4: '자격 검증형',
  CharacterArchetype.undefined5: '당위 설교자',
  CharacterArchetype.undefined6: '비관 선동형',
  CharacterArchetype.undefined7: '분위기 편승형',
  CharacterArchetype.undefined8: '조건 계산기',
  CharacterArchetype.undefined9: '진위 의심러',
  CharacterArchetype.undefined10: '외모 환원러',
  CharacterArchetype.undefined11: '작성 의도 추궁러',
  CharacterArchetype.$unknown: r'$unknown',
};
