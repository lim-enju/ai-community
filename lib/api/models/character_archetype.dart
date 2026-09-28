// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum CharacterArchetype {
  /// Incorrect name has been replaced. Original name: `결과론 예언자`.
  @JsonValue('결과론 예언자')
  undefined0('결과론 예언자'),
  /// Incorrect name has been replaced. Original name: `비꼴·조롱형 시비꾼`.
  @JsonValue('비꼴·조롱형 시비꾼')
  undefined1('비꼴·조롱형 시비꾼'),
  /// Incorrect name has been replaced. Original name: `진영 프레이머`.
  @JsonValue('진영 프레이머')
  undefined2('진영 프레이머'),
  /// Incorrect name has been replaced. Original name: `장문 팩트 교정러`.
  @JsonValue('장문 팩트 교정러')
  undefined3('장문 팩트 교정러'),
  /// Incorrect name has been replaced. Original name: `자격 검증형`.
  @JsonValue('자격 검증형')
  undefined4('자격 검증형'),
  /// Incorrect name has been replaced. Original name: `당위 설교자`.
  @JsonValue('당위 설교자')
  undefined5('당위 설교자'),
  /// Incorrect name has been replaced. Original name: `비관 선동형`.
  @JsonValue('비관 선동형')
  undefined6('비관 선동형'),
  /// Incorrect name has been replaced. Original name: `분위기 편승형`.
  @JsonValue('분위기 편승형')
  undefined7('분위기 편승형'),
  /// Incorrect name has been replaced. Original name: `조건 계산기`.
  @JsonValue('조건 계산기')
  undefined8('조건 계산기'),
  /// Incorrect name has been replaced. Original name: `진위 의심러`.
  @JsonValue('진위 의심러')
  undefined9('진위 의심러'),
  /// Incorrect name has been replaced. Original name: `외모 환원러`.
  @JsonValue('외모 환원러')
  undefined10('외모 환원러'),
  /// Incorrect name has been replaced. Original name: `작성 의도 추궁러`.
  @JsonValue('작성 의도 추궁러')
  undefined11('작성 의도 추궁러'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const CharacterArchetype(this.json);

  factory CharacterArchetype.fromJson(String json) => values.firstWhere(
        (e) => e.json == json,
        orElse: () => $unknown,
      );

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  /// Returns all defined enum values excluding the $unknown value.
  static List<CharacterArchetype> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
