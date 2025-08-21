/**
 * [BoxLang]
 *
 * Copyright [2023] [Ortus Solutions, Corp]
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.myproject.runner;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.myproject.mocks.TestContext;

import ortus.boxlang.runtime.aws.LambdaRunner;

/**
 * Local Lambda Test Runner
 *
 * Run your BoxLang Lambda locally with different event payloads
 * Usage:
 * gradle runLocal
 * gradle runLocal -PeventFile=workbench/sampleEvents/api.json
 */
public class LocalLambdaRunner {

	private static final ObjectMapper objectMapper = new ObjectMapper();

	public static void main( String[] args ) {
		try {
			// Get event file from system property or use default
			String eventFile = System.getProperty( "eventFile", "workbench/sampleEvents/event-local.json" );

			System.out.println( "🚀 BoxLang Lambda Local Runner" );
			System.out.println( "📄 Loading event from: " + eventFile );

			// Load event data
			Map<String, Object>	event		= loadEventFromFile( eventFile );

			// Create Lambda runner
			Path				lambdaPath	= Paths.get( "src", "main", "bx", "Lambda.bx" );
			LambdaRunner		runner		= new LambdaRunner( lambdaPath, true );

			// Create mock context
			TestContext			context		= new TestContext();

			System.out.println( "⚡ Executing Lambda..." );
			long	startTime		= System.currentTimeMillis();

			// Execute the Lambda
			var		response		= runner.handleRequest( event, context );

			long	executionTime	= System.currentTimeMillis() - startTime;

			// Print results
			System.out.println( "✅ Lambda execution completed in " + executionTime + "ms" );
			System.out.println( "📊 Response:" );
			System.out.println( objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString( response ) );

			// Force exit to prevent hanging (BoxLang runtime may have background threads)
			System.exit( 0 );

		} catch ( Exception e ) {
			System.err.println( "❌ Error running Lambda locally:" );
			e.printStackTrace();
			System.exit( 1 );
		}
	}

	/**
	 * Load the event data from a JSON file.
	 *
	 * @param eventFile The path to the event file.
	 *
	 * @return The event data as a Map.
	 *
	 * @throws IOException If an error occurs while reading the file.
	 */
	private static Map<String, Object> loadEventFromFile( String eventFile ) throws IOException {
		Path eventPath = Paths.get( eventFile );

		if ( !Files.exists( eventPath ) ) {
			System.err.println( "❌ Event file not found: " + eventFile );
			System.out.println( "💡 Available sample events:" );
			System.out.println( "   - workbench/sampleEvents/event-local.json (default Lambda event)" );
			System.out.println( "   - workbench/sampleEvents/api.json (API Gateway event)" );
			System.out.println( "   - workbench/sampleEvents/event.json (Legacy API Gateway)" );
			System.exit( 1 );
		}

		String eventJson = Files.readString( eventPath );
		return objectMapper.readValue( eventJson, new TypeReference<Map<String, Object>>() {
		} );
	}
}
