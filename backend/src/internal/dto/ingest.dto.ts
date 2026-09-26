import { IsArray, IsOptional, IsString, IsUUID } from 'class-validator';

export class IngestDto {
  @IsUUID()
  boardId: string;

  @IsString()
  sourceText: string;

  @IsOptional()
  @IsString()
  sourceUrl?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];
}
