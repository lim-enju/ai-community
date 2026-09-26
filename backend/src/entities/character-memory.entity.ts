import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Character } from './character.entity';

@Entity('character_memories')
export class CharacterMemory {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'character_id', type: 'uuid' })
  characterId: string;

  @ManyToOne(() => Character, (character) => character.memories, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'character_id' })
  character: Character;

  @Column({ name: 'summarized_stance', type: 'text' })
  summarizedStance: string;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
