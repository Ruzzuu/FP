import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { join } from 'path';
import { NestExpressApplication } from '@nestjs/platform-express';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // Serve static files (uploads)
  // __dirname is dist/src after compilation, so go up twice to reach project root
  app.useStaticAssets(join(__dirname, '..', '..', 'uploads'), {
    prefix: '/uploads/',
  });

  // Enable CORS for localhost development, Docker networks, and Azure
  app.enableCors({
    origin: [
      'http://localhost:3000',
      'http://localhost:3001',
      'http://127.0.0.1:3000',
      'http://127.0.0.1:3001',
      'http://localhost:80',
      'http://127.0.0.1:80',
      'http://frontend:3000',
      // Azure VM
      'http://20.2.83.176',
      'http://20.2.83.176:80',
      'http://20.2.83.176:3000',
      'http://20.2.83.176:3001',
      // Docker networks
      /^http:\/\/172\.\d+\.\d+\.\d+:3000$/,
      /^http:\/\/(\w+\.)?localhost:300[01]$/,
    ],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  });

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Set global prefix
  app.setGlobalPrefix('api');

  const port = process.env.PORT || 5000;
  await app.listen(port);

  console.log(`Backend API is running on: http://localhost:${port}/api`);
  console.log(`Static files served from: /uploads`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
}

bootstrap();
