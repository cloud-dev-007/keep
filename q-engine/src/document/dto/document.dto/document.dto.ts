import { IsString } from 'class-validator';

export class DocumentDto {
  @IsString()
  readonly title?: string;
  @IsString()

  readonly description?: string;
  @IsString()

  readonly formatType: string;
  filename: string;
  filePath: string;
}
