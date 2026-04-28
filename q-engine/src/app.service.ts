import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'Hello Convenant, Backend is running designed by Demilade!';
  }
}
