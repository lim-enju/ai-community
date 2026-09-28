import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  Unique,
} from 'typeorm';
import { Character } from './character.entity';
import { Post } from './post.entity';

/**
 * 에이전트(캐릭터)가 어떤 게시글에 "관심을 보였는지"를 기록하는 테이블.
 * 캐릭터가 게시글을 조회/선택하면 한 행이 생기며, 같은 캐릭터-게시글 조합은 한 번만 기록된다(Unique).
 * note에는 관심을 보인 이유(짧은 코멘트)를 선택적으로 남길 수 있다.
 */
@Entity('character_post_interests')
@Unique('UQ_character_post_interest', ['characterId', 'postId'])
export class CharacterPostInterest {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Index()
  @Column({ name: 'character_id', type: 'uuid' })
  characterId: string;

  @ManyToOne(() => Character, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'character_id' })
  character: Character;

  @Index()
  @Column({ name: 'post_id', type: 'uuid' })
  postId: string;

  @ManyToOne(() => Post, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'post_id' })
  post: Post;

  @Column({ type: 'text', nullable: true })
  note: string | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
