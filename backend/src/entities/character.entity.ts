import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { Comment } from './comment.entity';
import { CharacterMemory } from './character-memory.entity';

export enum CharacterArchetype {
  HINDSIGHT_PROPHET = '결과론 예언자',
  MOCKING_TROUBLEMAKER = '비꼴·조롱형 시비꾼',
  CAMP_FRAMER = '진영 프레이머',
  LONGWINDED_FACT_CHECKER = '장문 팩트 교정러',
  CREDENTIAL_GATEKEEPER = '자격 검증형',
  MORAL_PREACHER = '당위 설교자',
  DOOM_AGITATOR = '비관 선동형',
  BANDWAGON_RIDER = '분위기 편승형',
}

@Entity('characters')
export class Character {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 100 })
  name: string;

  @Column({ type: 'enum', enum: CharacterArchetype })
  archetype: CharacterArchetype;

  @Column({ name: 'speech_examples', type: 'text', array: true, default: () => "'{}'" })
  speechExamples: string[];

  @Column({ type: 'text' })
  personality: string;

  @Column({ name: 'argument_pattern', type: 'text' })
  argumentPattern: string;

  @Column({ name: 'response_length_guide', type: 'text' })
  responseLengthGuide: string;

  @OneToMany(() => Comment, (comment) => comment.character)
  comments: Comment[];

  @OneToMany(() => CharacterMemory, (memory) => memory.character)
  memories: CharacterMemory[];
}
