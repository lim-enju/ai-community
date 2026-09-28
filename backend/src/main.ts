import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { writeFileSync } from 'fs';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  app.enableCors();

  const config = new DocumentBuilder()
    .setTitle('AI Community API')
    .setDescription('AI 캐릭터 토론 커뮤니티 백엔드 API')
    .setVersion('1.0')
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document); // UI: /api-docs, 스펙 JSON: /api-docs-json

  // OPENAPI_EXPORT=1 이면 스펙만 openapi.json 으로 뽑고 종료 (codegen 스킬용, 서버 안 띄움)
  if (process.env.OPENAPI_EXPORT) {
    writeFileSync('openapi.json', JSON.stringify(document, null, 2));
    await app.close();
    return;
  }

  await app.listen(process.env.PORT ? Number(process.env.PORT) : 3000);
}

bootstrap();
