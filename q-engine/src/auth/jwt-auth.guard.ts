import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { IS_PUBLIC_KEY } from './public.decorator';
import { JwtPayload } from './auth.service';
import { User } from './user.entity';

/**
 * Global guard: requires a valid Bearer JWT on every route except those
 * marked with @Public(). On success it attaches { id, email } to req.user.
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwt: JwtService,
    private readonly reflector: Reflector,
    @InjectRepository(User) private readonly users: Repository<User>,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const req = context.switchToHttp().getRequest();
    const header: string = req.headers?.authorization ?? '';
    const [scheme, token] = header.split(' ');
    if (scheme !== 'Bearer' || !token) {
      throw new UnauthorizedException('Missing bearer token');
    }

    let payload: JwtPayload;
    try {
      payload = await this.jwt.verifyAsync<JwtPayload>(token);
    } catch {
      throw new UnauthorizedException('Invalid or expired token');
    }

    // The token is validly signed, but the account may no longer exist (e.g.
    // it was deleted). Reject with 401 so the client logs out cleanly instead
    // of failing later with a confusing 500 on the first write.
    const exists = await this.users.existsBy({ id: payload.sub });
    if (!exists) {
      throw new UnauthorizedException('Account no longer exists');
    }

    req.user = { id: payload.sub, email: payload.email };
    return true;
  }
}
