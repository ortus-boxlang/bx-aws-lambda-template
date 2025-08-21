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
package com.myproject.mocks;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.amazonaws.services.lambda.runtime.LambdaLogger;

/**
 * This is a test logger for AWS Lambda functions.
 */
public class TestLogger implements LambdaLogger {

	private static final Logger logger = LoggerFactory.getLogger( TestLogger.class );

	public void log( String message ) {
		logger.info( message );
	}

	public void log( byte[] message ) {
		logger.info( new String( message ) );
	}
}
