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

- **Configuration System**: All workbench scripts use `workbench/config.local.env` → `config.env` → environment variables for settings like AWS_LAMBDA_BUCKET, STACK_NAME, FUNCTION_NAME, LAMBDA_MEMORY, LAMBDA_TIMEOUT, ENVIRONMENT.
- **Build system**: use the Gradle wrapper (`./gradlew`) to ensure correct plugin versions and JVM settings. BoxLang runtime is now a Maven dependency.
- **Tests**: JUnit tests are in `src/test/java/com/myproject`. Run `./gradlew test`. Local testing via `./gradlew runLocal*` tasks.
- **Packaging**: `shadowJar` then `buildLambdaZip` / `build` create `build/distributions/*.zip`.
- **Deployment**: `workbench/2-deploy.sh` uses configuration variables and passes them as CloudFormation parameters to the parameterized `workbench/template.yml`.
- **Invocation**: `workbench/3-invoke.sh` uses direct function name invocation (no stack lookups), configured via FUNCTION_NAME.
- **Runtime config**: `src/resources/boxlang.json` controls caching, class generation, logging, timeouts, and trustedCache — change these for dev vs prod (e.g. `trustedCache`, `debugMode`).
- **BoxLang modules**: add modules to `src/resources/boxlang_modules` or declare them in `box.json`.

## Commands (exact examples)

- **Configuration setup**: Copy `workbench/config.env` to `workbench/config.local.env` and customize settings
- **Build** (produce deployable ZIP): `./gradlew build` (uses `shadowJar` and `buildLambdaZip` via `build.gradle`)
- **Run tests**: `./gradlew test`
- **Local testing**:
  - `./gradlew runLocal` (basic Lambda execution with default event)
  - `./gradlew runLocalApi` (Lambda with API Gateway event)
  - `./gradlew runLocalLegacy` (Lambda with legacy API Gateway event)
  - `./gradlew startSamServerBackground` (start HTTP server for API testing)
  - `./gradlew stopSamServer` (stop HTTP server)
- **Deployment workflow**:
  - `./workbench/0-check-aws.sh` (troubleshoot AWS credentials)
  - `./workbench/1-create-bucket.sh` (create S3 bucket using config)
  - `./workbench/2-deploy.sh` (deploy with configuration parameters)
  - `./workbench/3-invoke.sh` (invoke deployed function by name)
  - `./workbench/4-cleanup.sh` (clean up resources)

## Project-specific conventions & patterns

- Entrypoint convention: BoxLang lambda handlers expose `run(event, context, response)` (see `src/main/bx/Lambda.bx`). Alternate functions are fine but the runtime expects `run` by example.
- **NEW: Pascal Case URI Routing**: Multi-class Lambda functions using convention-based routing (e.g., `/products` → `Products.bx`, `/home-savings` → `HomeSavings.bx`). Each class should implement `handler(event, context)` function.
- Packaging layout: runtime expects `boxlang.json` and `Lambda.bx` at the ZIP root; Java libs go into `lib/` inside the ZIP. See `build.gradle` → `buildLambdaZip`.
- Tests depend on the Maven dependency `io.boxlang:boxlang-aws-lambda:1.4.0` resolved at build time.
- `box.json` is used to declare BoxLang modules for publishing/install; local modules for packaging belong in `src/resources/boxlang_modules`.
- Application lifecycle hooks live in `src/main/bx/Application.bx` (onApplicationStart/onRequest*), not in the Java layer.

## Integration points & external dependencies

- **Configuration Management**: All scripts use config file hierarchy (`config.local.env` → `config.env` → environment variables) for AWS settings, Lambda parameters, and deployment configuration.
- **AWS CLI + CloudFormation/SAM**: Used by `workbench/*.sh` scripts. The SAM template `workbench/template.yml` is now parameterized and receives configuration values via `--parameter-overrides`.
- **Direct Function Invocation**: `3-invoke.sh` uses function name directly (from FUNCTION_NAME config) instead of CloudFormation stack lookups for simplicity.
- **Event Files**: Production testing uses `workbench/event-live.json` for realistic payloads. Local testing has multiple event files in `workbench/sampleEvents/`.
- **AWS Resource Outputs**: Template now provides FunctionName and FunctionArn outputs for easy integration.
- **Lambda Handler**: Still `ortus.boxlang.runtime.aws.LambdaRunner::handleRequest` (SAM `Handler` setting).
- **Runtime JAR**: Maven dependency `io.boxlang:boxlang-aws-lambda:1.4.0` resolved automatically by Gradle.

## Useful file pointers (examples to inspect)

- `src/main/bx/Lambda.bx` — lambda entrypoint and examples of response shape.
- `src/main/bx/Application.bx` — lifecycle hooks (onApplicationStart, onRequest, etc.).
- **Multi-class Lambda structure**: Create additional `.bx` files in `src/main/bx/` for Pascal case routing (e.g., `Products.bx`, `HomeSavings.bx`).
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
