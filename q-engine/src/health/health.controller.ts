import { Controller, Get } from '@nestjs/common';
import {
  HealthCheck,
  HealthCheckService,
  HttpHealthIndicator,
  TypeOrmHealthIndicator,
} from '@nestjs/terminus';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { LangchainService } from '../langchain/langchain.service';
import { Throttle } from '@nestjs/throttler';
import { Public } from '../auth/public.decorator';

@ApiTags('health')
@Controller('health')
export class HealthController {
  constructor(
    private readonly health: HealthCheckService,
    private readonly db: TypeOrmHealthIndicator,
    private readonly http: HttpHealthIndicator,
    private readonly langchain: LangchainService,
  ) {}

  /**
   * Returns 200 if both the DB and the LLM endpoint are reachable.
   * Used by Docker's healthcheck and by an external uptime monitor.
   */
  @Public()
  @Get()
  @ApiOperation({ summary: 'Liveness/readiness probe — DB + LLM reachability' })
  @HealthCheck()
  // Don't let throttling bounce healthchecks during traffic spikes.
  @Throttle({ default: { limit: 10000, ttl: 60000 } })
  check() {
    // Strip the /v1 suffix if present and probe the OpenAI-compatible
    // /v1/models endpoint, which both LM Studio and Ollama support.
    const llmUrl = this.langchain.baseURL.replace(/\/$/, '');
    const probeUrl = llmUrl.endsWith('/v1')
      ? `${llmUrl}/models`
      : `${llmUrl}/v1/models`;

    // Cloud providers (Groq, OpenAI, ...) require a Bearer token even on /models.
    // Local servers (Ollama, LM Studio) ignore the header. Skip the header for the
    // sentinel value used in dev/local prod so we don't accidentally send junk.
    const key = this.langchain.apiKey;
    const probeOpts: { timeout: number; headers?: Record<string, string> } = {
      timeout: 15000,
    };
    if (key && key !== 'not-needed') {
      probeOpts.headers = { Authorization: `Bearer ${key}` };
    }

    return this.health.check([
      () => this.db.pingCheck('database'),
      () => this.http.pingCheck('llm', probeUrl, probeOpts),
    ]);
  }
}
