# Feature Index

This index connects real user stories, product requirements, Flutter files, mockups, and specs.

| Priority | Feature | Spec | User Stories | Requirements | Flutter target | Status |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Platform Runtime | `specs/features/platform-runtime/platform-runtime.spec.md` | Infra | Runtime config | `lib/services/api_client.dart` | Active |
| 1 | Auth | `specs/features/auth/auth.spec.md` | US01, US02 | R1, R2, RNF7 | `lib/pages/login`, `lib/services/auth_service.dart` | Rewrite first |
| 2 | Academic Profile | `specs/features/academic-profile/academic-profile.spec.md` | US05 | R12, R13 | `lib/pages/setup_carrera` | Rewrite second |
| 3 | Curriculum | `specs/features/curriculum/curriculum.spec.md` | US03, US04 | R4, R5, R10, R11 | `lib/pages/malla` | Rewrite third |
| 4 | Grades | `specs/features/grades/grades.spec.md` | US06, US07 | R6, R9 | `lib/pages/calculadora` | Rewrite fourth |
| 5 | Schedule | `specs/features/schedule/schedule.spec.md` | US09 | R19 | `lib/pages/horario` | Rewrite fifth |
| 6 | Course Detail | `specs/features/course-detail/course-detail.spec.md` | US13, US14 | R20 | `lib/pages/descripcion_cursos` | Rewrite sixth |
| 7 | Alerts | `specs/features/alerts/alerts.spec.md` | US15 | R15, R16, R22, R23 | `lib/pages/home`, `lib/pages/perfil` | Rewrite seventh |
| 8 | Section Management | `specs/features/section-management/section-management.spec.md` | US16, US17, US18 | R14, R17, R18, R21 | services and delegate mockups | Rewrite eighth |

## Workflow

1. Read `KNOWLEDGE.md` and this index before updating a spec.
2. Update or create the feature spec before changing Flutter behavior.
3. Confirm API changes in `docs/specs/api-contracts.md`.
4. Implement within existing `lib/` folders; do not restructure frontend directories unless explicitly approved.
5. Add widget/service tests and link them from the spec using `[@test]`.
6. Review UI behavior against the feature spec and mockups.
7. Runtime/build changes that affect deployed connectivity should live in `specs/features/platform-runtime/platform-runtime.spec.md`.

## Data Rules

- PostgreSQL through the backend is definitive.
- `assets/data/*.json` files are disposable mocks.
- Do not use JSON as final fallback for API-backed features.
- Services own API/data access; widgets must not read assets or call HTTP directly.
- Report missing backend/PostgreSQL data instead of reintroducing mock behavior.
