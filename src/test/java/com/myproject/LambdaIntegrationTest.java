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
package com.myproject;

import static com.google.common.truth.Truth.assertThat;

import java.io.IOException;
import java.nio.file.Path;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;

import com.amazonaws.services.lambda.runtime.Context;
import com.myproject.mocks.TestContext;

import ortus.boxlang.runtime.aws.LambdaRunner;
import ortus.boxlang.runtime.scopes.Key;
import ortus.boxlang.runtime.types.IStruct;

@TestInstance( TestInstance.Lifecycle.PER_CLASS )
public class LambdaIntegrationTest {

	private LambdaRunner	runner;
	private Context			context;

	@BeforeEach
	void setUp() throws IOException {
		Path validPath = Path.of( "src", "main", "bx", "Lambda.bx" );
		runner	= new LambdaRunner( validPath, true );
		context	= new TestContext();
	}

	@DisplayName( "Test your Lambda.bx" )
	@Test
	public void testBasicExecution() throws IOException {
		var event = new HashMap<String, Object>();
		// Add some mock data to the event
		event.put( "name", "Ortus Solutions" );
		event.put( "when", Instant.now().toString() );

		// EXECUTE THE LAMBDA
		var		results	= runner.handleRequest( event, context );
		IStruct	body	= ( IStruct ) results.get( "BODY" );

		assertThat( results ).isNotNull();
		assertThat( results.get( "STATUSCODE" ) ).isEqualTo( 200 );
		assertThat(
		    body.getAsString( Key.of( "data" ) )
		)
		    .contains( "Ortus Solutions" );
	}

	@Test
	@DisplayName( "Test API Gateway event simulation" )
	public void testApiGatewayEvent() {
		var	event	= createApiGatewayEvent();

		var	results	= runner.handleRequest( event, context );

		assertThat( results ).isNotNull();
		assertThat( results.get( "STATUSCODE" ) ).isEqualTo( 200 );

		// Verify response structure
		assertThat( results.containsKey( "HEADERS" ) ).isTrue();
		assertThat( results.containsKey( "BODY" ) ).isTrue();
	}

	@Test
	@DisplayName( "Test with empty event" )
	public void testEmptyEvent() {
		var	event	= new HashMap<String, Object>();

		var	results	= runner.handleRequest( event, context );

		assertThat( results ).isNotNull();
		assertThat( results.get( "STATUSCODE" ) ).isEqualTo( 200 );
	}

	@Test
	@DisplayName( "Test with complex nested data" )
	public void testComplexEvent() {
		var	event		= new HashMap<String, Object>();
		var	userData	= Map.of(
		    "id", 123,
		    "profile", Map.of(
		        "name", "John Doe",
		        "preferences", List.of( "java", "boxlang", "aws" )
		    )
		);
		event.put( "user", userData );
		event.put( "action", "profile_update" );

		var results = runner.handleRequest( event, context );

		assertThat( results ).isNotNull();
		assertThat( results.get( "STATUSCODE" ) ).isEqualTo( 200 );
	}

	@Test
	@DisplayName( "Test performance with large payload" )
	public void testLargePayload() {
		var				event		= new HashMap<String, Object>();

		// Create a large string payload
		StringBuilder	largeData	= new StringBuilder();
		for ( int i = 0; i < 1000; i++ ) {
			largeData.append( "This is test data line " ).append( i ).append( ". " );
		}

		event.put( "largeData", largeData.toString() );
		event.put( "timestamp", System.currentTimeMillis() );

		long	startTime		= System.currentTimeMillis();
		var		results			= runner.handleRequest( event, context );
		long	executionTime	= System.currentTimeMillis() - startTime;

		assertThat( results ).isNotNull();
		assertThat( results.get( "STATUSCODE" ) ).isEqualTo( 200 );

		// Performance assertion - should complete within reasonable time
		assertThat( executionTime ).isLessThan( 5000L ); // 5 seconds max

		System.out.println( "Large payload test completed in " + executionTime + "ms" );
	}

	@Test
	@DisplayName( "Test error handling with null values" )
	public void testNullHandling() {
		var event = new HashMap<String, Object>();
		event.put( "data", null );
		event.put( "nullField", null );

		var results = runner.handleRequest( event, context );

		assertThat( results ).isNotNull();
		// Should handle null gracefully without throwing exceptions
		assertThat( results.get( "STATUSCODE" ) ).isEqualTo( 200 );
	}

	/**
	 * Create a mock API Gateway event for testing
	 */
	private Map<String, Object> createApiGatewayEvent() {
		Map<String, Object> event = new HashMap<>();

		event.put( "version", "2.0" );
		event.put( "routeKey", "GET /test" );
		event.put( "rawPath", "/test" );
		event.put( "rawQueryString", "param1=value1" );

		Map<String, String> headers = new HashMap<>();
		headers.put( "accept", "application/json" );
		headers.put( "user-agent", "test-agent" );
		event.put( "headers", headers );

		Map<String, String> queryParams = new HashMap<>();
		queryParams.put( "param1", "value1" );
		event.put( "queryStringParameters", queryParams );

		Map<String, Object> requestContext = new HashMap<>();
		requestContext.put( "accountId", "123456789012" );
		requestContext.put( "apiId", "test123" );
		requestContext.put( "stage", "test" );

		Map<String, Object> http = new HashMap<>();
		http.put( "method", "GET" );
		http.put( "path", "/test" );
		http.put( "protocol", "HTTP/1.1" );
		requestContext.put( "http", http );

		event.put( "requestContext", requestContext );
		event.put( "isBase64Encoded", false );

		return event;
	}
}
