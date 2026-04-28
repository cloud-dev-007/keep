import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  UploadedFiles,
  UseInterceptors,
} from '@nestjs/common';
import { diskStorage } from 'multer';
import { extname, basename } from 'path';
import { DocumentService } from './document.service';
import { FilesInterceptor } from '@nestjs/platform-express';
import {
  ApiBody,
  ApiConsumes,
  ApiOperation,
  ApiParam,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';

const ALLOWED_EXTENSIONS = ['.pdf', '.docx', '.doc', '.pptx', '.txt'];
const ALLOWED_MIME_TYPES = new Set([
  'application/pdf',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document', // .docx
  'application/msword', // .doc
  'application/vnd.openxmlformats-officedocument.presentationml.presentation', // .pptx
  'text/plain',
]);

const MAX_UPLOAD_BYTES = parseInt(process.env.MAX_UPLOAD_MB ?? '25', 10) * 1024 * 1024;
const UPLOAD_DIR = process.env.UPLOAD_DIR ?? './uploads';

/** Strip directory components and dangerous characters from a filename. */
function sanitizeBaseName(name: string): string {
  const base = basename(name);
  // Keep alphanumerics, dash, underscore, dot, and space (replaced below).
  return base.replace(/[^a-zA-Z0-9._-]+/g, '_').slice(0, 80);
}

@ApiTags('document')
@Controller('document')
export class DocumentController {
  constructor(private readonly documentService: DocumentService) {}

  @Get()
  @ApiOperation({ summary: 'List uploaded documents (optionally filter by ids)' })
  @ApiQuery({ name: 'ids', required: false, type: [Number] })
  async getAllDocuments(@Query('ids') ids?: Array<number>) {
    return this.documentService.getAllDocuments(ids);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a document and its embeddings' })
  @ApiParam({ name: 'id', type: Number })
  async deleteDocument(@Param('id', ParseIntPipe) id: number) {
    return this.documentService.removeDocument(id);
  }

  @Post('upload/:id')
  @ApiOperation({ summary: 'Re-process and embed an already-uploaded document' })
  @ApiParam({ name: 'id', type: Number })
  async embedDocuments(@Param('id', ParseIntPipe) id: number) {
    return await this.documentService.processAndEmbedDocument(id);
  }

  @Post('upload')
  @ApiOperation({ summary: 'Upload one or more documents (multipart/form-data)' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        files: {
          type: 'array',
          items: { type: 'string', format: 'binary' },
        },
      },
    },
  })
  @UseInterceptors(
    FilesInterceptor('files', 10, {
      storage: diskStorage({
        destination: UPLOAD_DIR,
        filename: (req, file, cb) => {
          const ext = extname(file.originalname).toLowerCase();
          const safeBase = sanitizeBaseName(
            file.originalname.replace(ext, ''),
          );
          const uniqueSuffix = Date.now();
          cb(null, `qD_${uniqueSuffix}_${safeBase}${ext}`);
        },
      }),
      limits: { fileSize: MAX_UPLOAD_BYTES },
      fileFilter: (req, file, cb) => {
        const ext = extname(file.originalname).toLowerCase();
        if (!ALLOWED_EXTENSIONS.includes(ext)) {
          return cb(
            new BadRequestException(
              `Unsupported file extension: ${ext}. Allowed: ${ALLOWED_EXTENSIONS.join(', ')}`,
            ),
            false,
          );
        }
        if (file.mimetype && !ALLOWED_MIME_TYPES.has(file.mimetype)) {
          return cb(
            new BadRequestException(
              `Unsupported MIME type: ${file.mimetype}`,
            ),
            false,
          );
        }
        cb(null, true);
      },
    }),
  )
  async uploadFiles(@UploadedFiles() files: Array<Express.Multer.File>) {
    if (!files || files.length === 0) {
      throw new BadRequestException('No files were uploaded');
    }
    return this.documentService.uploadDocuments(files);
  }
}
