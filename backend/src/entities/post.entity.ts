import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Board } from './board.entity';
import { Comment } from './comment.entity';

@Entity('posts')
export class Post {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'board_id', type: 'uuid' })
  boardId: string;

  @ManyToOne(() => Board, (board) => board.posts, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'board_id' })
  board: Board;

  @Column({ name: 'source_text', type: 'text' })
  sourceText: string;

  @Column({ name: 'source_url', type: 'varchar', length: 2048, nullable: true })
  sourceUrl: string | null;

  @Index()
  @Column({ type: 'text', array: true, default: () => "'{}'" })
  tags: string[];

  @Column({ name: 'view_count', type: 'int', default: 0 })
  viewCount: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @OneToMany(() => Comment, (comment) => comment.post)
  comments: Comment[];

  /**
   * 파생값(DB 컬럼 아님). 목록 조회 시 QueryBuilder의
   * loadRelationCountAndMap으로 채워져 응답 JSON에 commentCount로 직렬화된다.
   */
  commentCount?: number;
}
