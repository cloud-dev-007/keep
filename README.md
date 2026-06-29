# qCraft — Adaptive Text‑Based Quiz Generation System

Turn lecture notes, slides and PDFs into **adaptive, Bloom‑aligned quizzes**. Upload a
document, and the system extracts its content, generates multiple‑choice / theory /
fill‑in‑the‑blank questions at a chosen cognitive level, grades attempts, and produces
**personalised follow‑up quizzes** that target the topics you got wrong.

> Final‑year project — Design & Implementation of an Adaptive Text‑Based E‑Learning Quiz
> Generation System. Crawford University, Dept. of Computer & Mathematical Sciences.

---

## Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [How it works (the pipeline)](#how-it-works-the-pipeline)
- [Bloom's Taxonomy mapping](#blooms-taxonomy-mapping)
- [Features](#features)
- [Tech stack](#tech-stack)
- [Repository layout](#repository-layout)
- [Running the backend (q-engine)](#running-the-backend-q-engine)
- [Running the mobile app (qcraft-app)](#running-the-mobile-app-qcraft-app)
- [Environment variables](#environment-variables)
- [API overview](#api-overview)
- [Deployment](#deployment)
- [Known constraints](#known-constraints)

---

## Overview

qCraft is a two‑tier application:

- A **Flutter mobile client** (Android & iOS) where users register, upload documents,
  and take generated quizzes.
- A **NestJS / TypeScript backend** ("q‑engine") that performs document extraction,
  embedding, retrieval‑augmented question generation, grading, and adaptive logic.

Question generation uses a **Retrieval‑Augmented Generation (RAG)** pipeline: documents
are chunked and embedded into a vector store, relevant context is retrieved per
document, and a Large Language Model produces questions and answers grounded in that
context. Difficulty is mapped onto **Bloom's Taxonomy** levels.

---

## Architecture

```
┌──────────────────────────┐         HTTPS / JWT          ┌───────────────────────────────┐
│   Flutter app (client)   │  ─────────────────────────▶  │      q-engine (NestJS API)     │
│  • auth / token storage  │                              │  • auth (JWT, per-user data)   │
│  • upload documents      │  ◀─────────────────────────  │  • document extraction + chunk │
│  • take quizzes / scores │                              │  • embeddings (bge-small)      │
└──────────────────────────┘                              │  • RAG question generation     │
                                                           │  • grading + adaptive logic    │
                                                           └───────────────┬───────────────┘
                                                                           │
                                       ┌───────────────────────────────────┼───────────────────────────┐
                                       ▼                                   ▼                           ▼
                              ┌──────────────────┐              ┌────────────────────┐      ┌────────────────────┐
                              │ PostgreSQL +     │              │  Embedding model    │      │  LLM (Groq Cloud)  │
                              │ pgvector         │              │  bge-small-en-v1.5  │      │  llama-3.1-8b      │
                              │ (data + vectors) │              │  (local, CPU)       │      │  (OpenAI-compatible)│
                              └──────────────────┘              └────────────────────┘      └────────────────────┘
```

- **Client tier** — Flutter cross‑platform UI with lightweight reactive state
  (StatefulWidget + ChangeNotifier, Dio HTTP client).
- **Application tier** — NestJS business logic: auth, document processing, embeddings,
  RAG, grading.
- **Data tier** — PostgreSQL with the `pgvector` extension stores both relational data
  (users, documents, quizzes, attempts) and the embedding vectors.
- **LLM** — an OpenAI‑compatible chat endpoint. The deployment uses **Groq Cloud**
  (`llama-3.1-8b-instant`). The `LLM_BASE_URL` is configurable, so a local
  Ollama / LM Studio server can be swapped in without code changes.

---

## How it works (the pipeline)

1. **Extract** — parse the uploaded file (PDF, DOCX, PPTX, TXT) with LangChain document
   loaders.
2. **Chunk** — recursive, token‑aware splitting (`chunkSize 4000`, `overlap 400`).
3. **Embed** — each chunk → a dense vector via `bge-small-en-v1.5` (HuggingFace,
   runs locally on CPU).
4. **Store** — vectors + metadata saved in PostgreSQL/`pgvector`.
5. **Retrieve** — relevant chunks pulled per document (and via cosine similarity for
   answer grounding).
6. **Generate** — context is composed into a Bloom‑aware prompt and sent to the LLM,
   which returns questions (and, for MCQ, the correct answer + distractors).
7. **Parse** — raw LLM output is parsed into structured JSON and persisted.

Uploaded documents are embedded **in the background**, so the upload request returns
immediately; quiz generation becomes available once embedding completes.

---

## Bloom's Taxonomy mapping

A user picks a difficulty score (1–10) which maps onto a cognitive level that shapes the
generated questions:

| Difficulty | Bloom level    |
|-----------:|----------------|
| 1–2        | Remembering    |
| 3–4        | Understanding  |
| 5–6        | Applying       |
| 7–8        | Analyzing      |
| 9–10       | Evaluating     |

After an attempt, weak topics are extracted from the incorrectly answered questions and
used to generate an **adaptive follow‑up quiz** focused on those areas.

---

## Features

- **Accounts & per‑user data** — email + password auth (JWT, bcrypt). Each user only
  sees their own documents and quizzes.
- **Document upload** — PDF, DOCX, PPTX, TXT (background embedding).
- **Quiz generation** — Multiple Choice, True/False, Fill‑in‑the‑Blank, Theory, or Mixed.
- **Grading** — MCQ/True‑False graded locally; Theory/FITB graded by the LLM.
- **Scoring & breakdown** — accuracy, per‑question correctness, weak topics, and a
  short written analysis.
- **Adaptive quizzes** — follow‑up questions target previously weak topics.

---

## Tech stack

| Layer        | Technology |
|--------------|------------|
| Mobile app   | Flutter (Dart), Dio, shared_preferences |
| Backend      | NestJS (TypeScript), TypeORM |
| Database     | PostgreSQL + pgvector |
| Embeddings   | `Xenova/bge-small-en-v1.5` (HuggingFace transformers, 384‑dim, CPU) |
| LLM          | Groq Cloud `llama-3.1-8b-instant` (OpenAI‑compatible; configurable) |
| RAG / LLM glue | LangChain |
| Auth         | JWT (`@nestjs/jwt`) + `bcryptjs` |
| Container    | Docker / Docker Compose |
| Reverse proxy | Apache (TLS) in the reference deployment |

---

## Repository layout

```
.
├── q-engine/            # NestJS backend API
│   ├── src/
│   │   ├── auth/                 # JWT auth, user entity, guard, decorators
│   │   ├── document/            # upload + document CRUD (per-user scoped)
│   │   ├── document-processing/ # loaders, splitter, embeddings, vector store, retriever
│   │   ├── quiz/                # quiz creation, generation, grading, adaptive logic
│   │   ├── langchain/           # LLM client + prompt templates
│   │   ├── health/              # liveness/readiness probe
│   │   └── migrations/          # TypeORM migrations
│   ├── docker-compose*.yml
│   └── Dockerfile
├── qcraft-app/          # Flutter mobile client
│   └── lib/
│       ├── api/                 # ApiClient (Dio), AuthStore, models
│       ├── screens/             # auth, documents, quizzes, take-quiz, result
│       ├── state/               # quiz session
│       └── widgets/             # shared UI
├── DEPLOYMENT.md        # detailed deployment guide
└── references/          # research papers / supporting material
```

---

## Running the backend (q-engine)

**Prerequisites:** Docker + Docker Compose, and an LLM endpoint (a Groq API key, or a
local Ollama / LM Studio server).

```bash
cd q-engine
cp .env.example .env          # then edit it (DB creds, JWT_SECRET, LLM settings)

# bring up Postgres + the API
docker compose --env-file .env up -d --build
```

Local development without Docker:

```bash
cd q-engine
npm install
npm run start:dev             # needs a reachable Postgres + pgvector and an LLM endpoint
```

Migrations run automatically on boot when `DB_MIGRATIONS_RUN=true`.

---

## Running the mobile app (qcraft-app)

**Prerequisites:** Flutter SDK (>= 3.27).

```bash
cd qcraft-app
flutter pub get
flutter run                                   # on a connected device/emulator
# or build a release APK:
flutter build apk
```

The API base URL defaults to the hosted backend and can be overridden at build time:

```bash
flutter build apk --dart-define=API_BASE_URL=https://your-backend.example.com/
```

---

## Environment variables

Backend (`q-engine/.env`):

| Variable | Purpose |
|----------|---------|
| `DB_HOST` / `DB_PORT` / `DB_USER` / `DB_PASSWORD` / `DB_NAME` | PostgreSQL connection |
| `DB_MIGRATIONS_RUN` | run migrations on boot (`true` in deploy) |
| `PORT` | API port (default 3000) |
| `CORS_ORIGINS` | comma‑separated allowed origins (`*` dev only) |
| `JWT_SECRET` | **required** — secret used to sign auth tokens |
| `JWT_EXPIRES_IN` | token lifetime (default `7d`) |
| `LLM_BASE_URL` | OpenAI‑compatible base URL (e.g. `https://api.groq.com/openai/v1`) |
| `LLM_API_KEY` | API key for the LLM provider |
| `LLM_MODEL` | model id (e.g. `llama-3.1-8b-instant`) |
| `LLM_TEMPERATURE` / `LLM_TIMEOUT_MS` / `LLM_MAX_RETRIES` | LLM tuning |
| `MAX_UPLOAD_MB` | upload size limit |
| `THROTTLE_TTL` / `THROTTLE_LIMIT` | rate limiting |

---

## API overview

All routes except those below require a `Bearer` JWT.

| Method | Route | Description |
|-------|-------|-------------|
| `POST` | `/auth/register` | Create an account, returns a JWT *(public)* |
| `POST` | `/auth/login` | Authenticate, returns a JWT *(public)* |
| `GET`  | `/auth/me` | Current user |
| `GET`  | `/health` | DB + LLM readiness probe *(public)* |
| `POST` | `/document/upload` | Upload one or more documents (multipart) |
| `GET`  | `/document` | List the user's documents |
| `DELETE` | `/document/:id` | Delete a document + its embeddings |
| `POST` | `/quiz/create` | Create a quiz definition from documents |
| `POST` | `/quiz/generate/:id` | Generate (or adaptively regenerate) questions |
| `GET`  | `/quiz` | List the user's quizzes |
| `POST` | `/quiz/evaluate` | Submit an attempt; returns score + analysis |

Interactive API docs (Swagger) are served at `/api/docs`.

---

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for the full guide. In summary the reference
deployment runs the API + PostgreSQL via Docker Compose behind an Apache reverse proxy
that terminates TLS, with the embedding model **baked into the image** at build time so
containers don't download it at runtime.

---

## Known constraints

- **LLM rate limits** — on Groq's free tier (~6,000 tokens/minute) a full multi‑question
  MCQ quiz can exceed the per‑minute budget; a paid tier removes this. The context sent
  to the LLM is capped to avoid oversized requests.
- **Large documents on small hosts** — embedding runs on CPU. Very large documents
  (hundreds of pages → hundreds of chunks) are CPU‑heavy on a small VPS; smaller,
  focused documents process fastest and produce sharper quizzes.
- **Background processing** — after upload, allow a few seconds for embedding to finish
  before generating a quiz; the API returns a clear "still being processed" message if
  you try too early.
