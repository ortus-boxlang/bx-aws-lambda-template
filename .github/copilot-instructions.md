## Quick context

This is a BoxLang AWS Lambda template that wraps a BoxLang runtime inside a Java Lambda runner. Key artifacts are produced by Gradle and packaged into a ZIP suitable for AWS/SAM deployments.

## Big-picture architecture (short)

- BoxLang runtime is a Maven dependency `io.boxlang:boxlang-aws-lambda:1.4.0` included in the shadow JAR.
- BoxLang sources live under `src/main/bx` (notably `Lambda.bx` and `Application.bx`). `Lambda.bx` exposes `run(event, context, response)` by convention.
- Java/Gradle wrapper provides build/test, produces `shadowJar` and `build/distributions/<project>-<version>.zip` which contains:
  - root: `Lambda.bx`, `boxlang.json`
  - `lib/`: runtime jars and shadow jar outputs
- AWS integration: `workbench/template.yml` (SAM) points CodeUri at the zip and Handler at `ortus.boxlang.runtime.aws.LambdaRunner::handleRequest`.

## What an AI agent should know immediately

- Build system: use the Gradle wrapper (`./gradlew`) to ensure correct plugin versions and JVM settings. BoxLang runtime is now a Maven dependency.
- Tests: JUnit tests are in `src/test/java/com/myproject`. Run `./gradlew test`.
- Packaging: `shadowJar` then `buildLambdaZip` / `build` create `build/distributions/*.zip`. `workbench/2-deploy.sh` runs `gradle build -i` (or `mvn package` alternative) then uses `aws cloudformation package/deploy`.
- Runtime config: `src/resources/boxlang.json` controls caching, class generation, logging, timeouts, and trustedCache — change these for dev vs prod (e.g. `trustedCache`, `debugMode`).
- BoxLang modules: add modules to `src/resources/boxlang_modules` or declare them in `box.json`.

## Commands (exact examples)

- Build (produce deployable ZIP):
  - `./gradlew build`  (uses `shadowJar` and `buildLambdaZip` via `build.gradle`)
- Run tests:
  - `./gradlew test`
- Local testing:
  - `./gradlew runLocal` (basic Lambda execution)
  - `./gradlew startSamServerBackground` (start HTTP server for API testing)
  - `./gradlew stopSamServer` (stop HTTP server)
- Deploy via workbench script (uses AWS CLI + CloudFormation/SAM):
  - `./workbench/2-deploy.sh`  (or inspect `workbench/template.yml` to adapt)
- Invoke locally via AWS CLI after deploy:
  - `./workbench/3-invoke.sh` (reads stack resources and runs `aws lambda invoke`)

## Project-specific conventions & patterns

- Entrypoint convention: BoxLang lambda handlers expose `run(event, context, response)` (see `src/main/bx/Lambda.bx`). Alternate functions are fine but the runtime expects `run` by example.
- Packaging layout: runtime expects `boxlang.json` and `Lambda.bx` at the ZIP root; Java libs go into `lib/` inside the ZIP. See `build.gradle` → `buildLambdaZip`.
- Tests depend on the Maven dependency `io.boxlang:boxlang-aws-lambda:1.4.0` resolved at build time.
- `box.json` is used to declare BoxLang modules for publishing/install; local modules for packaging belong in `src/resources/boxlang_modules`.
- Application lifecycle hooks live in `src/main/bx/Application.bx` (onApplicationStart/onRequest*), not in the Java layer.

## Integration points & external dependencies

- AWS CLI + CloudFormation/SAM are used by `workbench/*.sh` scripts. The SAM template is `workbench/template.yml` and expects the deployable at `build/distributions/*.zip`.
- The Lambda handler class is `ortus.boxlang.runtime.aws.LambdaRunner::handleRequest` (SAM `Handler` setting).
- The runtime JAR is now a Maven dependency `io.boxlang:boxlang-aws-lambda:1.4.0` resolved automatically by Gradle.

## Useful file pointers (examples to inspect)

- `src/main/bx/Lambda.bx` — lambda entrypoint and examples of response shape.
- `src/main/bx/Application.bx` — lifecycle hooks (onApplicationStart, onRequest, etc.).
- `build.gradle` — tasks: `shadowJar`, `buildLambdaZip`, test wiring; Maven dependency declaration.
- `src/resources/boxlang.json` — runtime configuration (debug/trustedCache/logging/timeouts).
- `workbench/*` — `1-create-bucket.sh`, `2-deploy.sh`, `3-invoke.sh` show real deployment/invoke flows.

## Quick checklist for code edits

1. If you add Java dependencies, update `build.gradle` and ensure they end up in `lib/` or shadowJar as needed.
2. If you add BoxLang modules, put them in `src/resources/boxlang_modules` or declare them in `box.json`.
3. The BoxLang runtime is now a Maven dependency - no manual JAR download needed.

## Code formatting standards

- **Spacing around symbols**: Always add spaces around parentheses `( )`, brackets `[ ]`, braces `{ }`, and operators for readability
- **Examples**:
  - ✅ `function run( event, context, response )`
  - ❌ `function run(event,context,response)`
  - ✅ `var results = [ 1, 2, 3 ]`
  - ❌ `var results = [1,2,3]`
  - ✅ `if ( condition ) { doSomething(); }`
  - ❌ `if(condition){doSomething();}`
- Apply this spacing standard to all BoxLang, Java, and configuration code in the project

---

If any section is unclear or you'd like additional examples (tests, a small local-run guide, or CI snippets), tell me which area and I will iterate.
