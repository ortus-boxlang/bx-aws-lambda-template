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

import com.amazonaws.services.lambda.runtime.ClientContext;
import com.amazonaws.services.lambda.runtime.CognitoIdentity;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;

/**
 * This is a test context for AWS Lambda functions.
 */
public class TestContext implements Context {

	public TestContext() {
	}

	public String getAwsRequestId() {
		return new String( "495b12a8-xmpl-4eca-8168-160484189f99" );
	}

	public String getLogGroupName() {
		return new String( "/aws/lambda/my-function" );
	}

	public String getLogStreamName() {
		return new String( "2020/02/26/[$LATEST]704f8dxmpla04097b9134246b8438f1a" );
	}

	public String getFunctionName() {
		return new String( "my-function" );
	}

	public String getFunctionVersion() {
		return new String( "$LATEST" );
	}

	public String getInvokedFunctionArn() {
		return new String( "arn:aws:lambda:us-east-2:123456789012:function:my-function" );
	}

	public CognitoIdentity getIdentity() {
		return null;
	}

	public ClientContext getClientContext() {
		return null;
	}

	public int getRemainingTimeInMillis() {
		return 300000;
	}

	public int getMemoryLimitInMB() {
		return 512;
	}

	public LambdaLogger getLogger() {
		return new TestLogger();
	}

}
