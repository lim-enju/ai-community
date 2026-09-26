import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Character } from '../entities';

@Injectable()
export class CharactersService {
  constructor(@InjectRepository(Character) private readonly characterRepo: Repository<Character>) {}

  findAll(): Promise<Character[]> {
    return this.characterRepo.find({ order: { name: 'ASC' } });
  }

  async findOne(characterId: string): Promise<Character> {
    const character = await this.characterRepo.findOne({ where: { id: characterId } });
    if (!character) {
      throw new NotFoundException(`Character not found: ${characterId}`);
    }
    return character;
  }
}
