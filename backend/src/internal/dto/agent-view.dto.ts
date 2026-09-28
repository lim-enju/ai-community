import { IsOptional, IsString, IsUUID } from 'class-validator';

export class AgentViewDto {
  @IsUUID()
  characterId: string;

  @IsOptional()
  @IsString()
  note?: string;
}
