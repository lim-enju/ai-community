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
import { ApiHideProperty } from '@nestjs/swagger';
import { Post } from './post.entity';
import { Character } from './character.entity';

@Entity('comments')
export class Comment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'post_id', type: 'uuid' })
  postId: string;

  @ApiHideProperty()
  @ManyToOne(() => Post, (post) => post.comments, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'post_id' })
  post: Post;

  @Column({ name: 'character_id', type: 'uuid' })
  characterId: string;

  @ApiHideProperty()
  @ManyToOne(() => Character, (character) => character.comments, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'character_id' })
  character: Character;

  @Index()
  @Column({ name: 'round_number', type: 'int' })
  roundNumber: number;

  @Column({ type: 'text' })
  content: string;

  // 대댓글: 다른 댓글에 달린 답글이면 그 부모 댓글 id. 최상위 댓글이면 null.
  @Index()
  @Column({ name: 'parent_comment_id', type: 'uuid', nullable: true })
  parentCommentId: string | null;

  @ApiHideProperty()
  @ManyToOne(() => Comment, (comment) => comment.replies, {
    onDelete: 'CASCADE',
    nullable: true,
  })
  @JoinColumn({ name: 'parent_comment_id' })
  parent: Comment | null;

  @ApiHideProperty()
  @OneToMany(() => Comment, (comment) => comment.parent)
  replies: Comment[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
