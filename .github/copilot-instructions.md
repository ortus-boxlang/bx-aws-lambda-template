## Quick context

This is a BoxLang AWS Lambda template that wraps a BoxLang runtime inside a Java Lambda runner. Key artifacts are produced by Gradle and packaged into a ZIP suitable for AWS/SAM deployments.

## Big-picture architecture (short)

- BoxLang runtime (boxlang-aws-lambda-<version>.jar) is downloaded into `src/resources/libs` and used at test/runtime.
- BoxLang sources live under `src/main/bx` (notably `Lambda.bx` and `Application.bx`). `Lambda.bx` exposes `run(event, context, response)` by convention.
- Java/Gradle wrapper provides build/test, produces `shadowJar` and `build/distributions/<project>-<version>.zip` which contains:
  - root: `Lambda.bx`, `boxlang.json`
  - `lib/`: runtime jars and shadow jar outputs
- AWS integration: `workbench/template.yml` (SAM) points CodeUri at the zip and Handler at `ortus.boxlang.runtime.aws.LambdaRunner::handleRequest`.

## What an AI agent should know immediately

- Build system: use the Gradle wrapper (`./gradlew`) to ensure correct plugin versions and JVM settings. `./gradlew downloadBoxLang` must run before tests/compilation that rely on the runtime jar.
- Tests: JUnit tests are in `src/test/java/com/myproject` and `compileTestJava` depends on `downloadBoxLang` (see `build.gradle`). Run `./gradlew test`.
- Packaging: `shadowJar` then `buildLambdaZip` / `build` create `build/distributions/*.zip`. `workbench/2-deploy.sh` runs `gradle build -i` (or `mvn package` alternative) then uses `aws cloudformation package/deploy`.
- Runtime config: `src/resources/boxlang.json` controls caching, class generation, logging, timeouts, and trustedCache — change these for dev vs prod (e.g. `trustedCache`, `debugMode`).
- BoxLang modules: add modules to `src/resources/boxlang_modules` or declare them in `box.json`.

## Commands (exact examples)

- Download runtime (safe first step):
  - `./gradlew downloadBoxLang`
- Build (produce deployable ZIP):
  - `./gradlew build`  (uses `shadowJar` and `buildLambdaZip` via `build.gradle`)
- Run tests:
  - `./gradlew test`
- Deploy via workbench script (uses AWS CLI + CloudFormation/SAM):
  - `./workbench/2-deploy.sh`  (or inspect `workbench/template.yml` to adapt)
- Invoke locally via AWS CLI after deploy:
  - `./workbench/3-invoke.sh` (reads stack resources and runs `aws lambda invoke`)

## Project-specific conventions & patterns

- Entrypoint convention: BoxLang lambda handlers expose `run(event, context, response)` (see `src/main/bx/Lambda.bx`). Alternate functions are fine but the runtime expects `run` by example.
- Packaging layout: runtime expects `boxlang.json` and `Lambda.bx` at the ZIP root; Java libs go into `lib/` inside the ZIP. See `build.gradle` → `buildLambdaZip`.
- Tests depend on the downloaded runtime jar in `src/test/resources/libs` — do not remove this folder.
- `box.json` is used to declare BoxLang modules for publishing/install; local modules for packaging belong in `src/resources/boxlang_modules`.
- Application lifecycle hooks live in `src/main/bx/Application.bx` (onApplicationStart/onRequest*), not in the Java layer.

## Integration points & external dependencies

- AWS CLI + CloudFormation/SAM are used by `workbench/*.sh` scripts. The SAM template is `workbench/template.yml` and expects the deployable at `build/distributions/*.zip`.
- The Lambda handler class is `ortus.boxlang.runtime.aws.LambdaRunner::handleRequest` (SAM `Handler` setting).
- The runtime JAR is downloaded from Ortus S3 via `downloadBoxLang` (see `build.gradle` URL). Tests rely on that file.

## Useful file pointers (examples to inspect)

- `src/main/bx/Lambda.bx` — lambda entrypoint and examples of response shape.
- `src/main/bx/Application.bx` — lifecycle hooks (onApplicationStart, onRequest, etc.).
- `build.gradle` — tasks: `downloadBoxLang`, `shadowJar`, `buildLambdaZip`, test wiring.
- `src/resources/boxlang.json` — runtime configuration (debug/trustedCache/logging/timeouts).
- `workbench/*` — `1-create-bucket.sh`, `2-deploy.sh`, `3-invoke.sh` show real deployment/invoke flows.

## Quick checklist for code edits

1. If you add Java dependencies, update `build.gradle` and ensure they end up in `lib/` or shadowJar as needed.
2. If you add BoxLang modules, put them in `src/resources/boxlang_modules` or declare them in `box.json`.
3. Keep `downloadBoxLang` intact unless you have an alternative binary source (Maven). Tests expect that JAR.

---

If any section is unclear or you'd like additional examples (tests, a small local-run guide, or CI snippets), tell me which area and I will iterate.
