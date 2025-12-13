### OpenRouter API Direct Calls (Multiple Languages)

Source: https://openrouter.ai/docs/quickstart.mdx

Provides examples for making direct API calls to OpenRouter's chat completions endpoint using Python, TypeScript (fetch), and shell commands. Requires an API key and optionally includes headers for app attribution. Accepts JSON payload for model and messages.

```python
import requests
import json

response = requests.post(
  url="https://openrouter.ai/api/v1/chat/completions",
  headers={
    "Authorization": "Bearer <OPENROUTER_API_KEY>",
    "HTTP-Referer": "<YOUR_SITE_URL>", # Optional. Site URL for rankings on openrouter.ai.
    "X-Title": "<YOUR_SITE_NAME>", # Optional. Site title for rankings on openrouter.ai.
  },
  data=json.dumps({
    "model": "openai/gpt-4o", # Optional
    "messages": [
      {
        "role": "user",
        "content": "What is the meaning of life?"
      }
    ]
  })
)
```

```typescript
fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    Authorization: 'Bearer <OPENROUTER_API_KEY>',
    'HTTP-Referer': '<YOUR_SITE_URL>', // Optional. Site URL for rankings on openrouter.ai.
    'X-Title': '<YOUR_SITE_NAME>', // Optional. Site title for rankings on openrouter.ai.
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/gpt-4o',
    messages: [
      {
        role: 'user',
        content: 'What is the meaning of life?',
      },
    ],
  }),
});
```

```shell
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -d '{ "model": "openai/gpt-4o", "messages": [ { "role": "user", "content": "What is the meaning of life?" } ] }'
```

--------------------------------

### Setup MCP Server with Python

Source: https://openrouter.ai/docs/use-cases/mcp-servers.mdx

Initial setup for using MCP Servers with OpenRouter. Requires pip installation of packages and a .env file with OPENAI_API_KEY. Assumes directory existence.

```python
import asyncio
from typing import Optional
from contextlib import AsyncExitStack

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

from openai import OpenAI
from dotenv import load_dotenv
import json

load_dotenv()  # load environment variables from .env

MODEL = "anthropic/claude-3-7-sonnet"

SERVER_CONFIG = {
    "command": "npx",
    "args": ["-y",
              "@modelcontextprotocol/server-filesystem",
              f"/Applications/"],
    "env": None
}
```

--------------------------------

### Use Assistant Prefill for Guided Responses (TypeScript)

Source: https://openrouter.ai/docs/api-reference/overview.mdx

Shows how to use the 'assistant' role in the messages array to provide a partial response. This guides the model to complete the thought, useful for setting a specific tone or direction for the AI's output. The example includes a user message and an assistant's starting phrase.

```TypeScript
fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    Authorization: 'Bearer <OPENROUTER_API_KEY>',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/gpt-4o',
    messages: [
      { role: 'user', content: 'What is the meaning of life?' },
      { role: 'assistant', content: "I'm not sure, but my best guess is" },
    ],
  }),
});
```

--------------------------------

### OpenRouter SDK Integration (TypeScript)

Source: https://openrouter.ai/docs/quickstart.mdx

Demonstrates how to initialize and use the OpenRouter SDK in TypeScript to send chat messages. Requires the '@openrouter/sdk' package and an OpenRouter API key. Outputs the content of the AI's response.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
  defaultHeaders: {
    'HTTP-Referer': '<YOUR_SITE_URL>', // Optional. Site URL for rankings on openrouter.ai.
    'X-Title': '<YOUR_SITE_NAME>', // Optional. Site title for rankings on openrouter.ai.
  },
});

const completion = await openRouter.chat.send({
  model: 'openai/gpt-4o',
  messages: [
    {
      role: 'user',
      content: 'What is the meaning of life?',
    },
  ],
  stream: false,
});

console.log(completion.choices[0].message.content);
```

--------------------------------

### OpenAI SDK Chat Completion (TypeScript & Python)

Source: https://openrouter.ai/docs/quickstart.mdx

Demonstrates how to initialize the OpenAI client and make a chat completion request using both TypeScript and Python. Requires the 'openai' package and an OpenRouter API key. Outputs the assistant's response to a given prompt.

```typescript
import OpenAI from 'openai';

const openai = new OpenAI({
  baseURL: 'https://openrouter.ai/api/v1',
  apiKey: '<OPENROUTER_API_KEY>',
  defaultHeaders: {
    'HTTP-Referer': '<YOUR_SITE_URL>', // Optional. Site URL for rankings on openrouter.ai.
    'X-Title': '<YOUR_SITE_NAME>', // Optional. Site title for rankings on openrouter.ai.
  },
});

async function main() {
  const completion = await openai.chat.completions.create({
    model: 'openai/gpt-4o',
    messages: [
      {
        role: 'user',
        content: 'What is the meaning of life?',
      },
    ],
  });

  console.log(completion.choices[0].message);
}

main();
```

```python
from openai import OpenAI

client = OpenAI(
  base_url="https://openrouter.ai/api/v1",
  api_key="<OPENROUTER_API_KEY>",
)

completion = client.chat.completions.create(
  extra_headers={
    "HTTP-Referer": "<YOUR_SITE_URL>", # Optional. Site URL for rankings on openrouter.ai.
    "X-Title": "<YOUR_SITE_NAME>", # Optional. Site title for rankings on openrouter.ai.
  },
  model="openai/gpt-4o",
  messages=[
    {
      "role": "user",
      "content": "What is the meaning of life?"
    }
  ]
)

print(completion.choices[0].message.content)
```

--------------------------------

### Initialize Mastra Project using create-mastra

Source: https://openrouter.ai/docs/community/mastra.mdx

This command initializes a new Mastra project using npx and the create-mastra package. It guides the user through project setup, including selecting components and a default provider. This is the initial step for integrating OpenRouter.

```bash
# Create a new project using create-mastra
npx create-mastra@latest
```

--------------------------------

### Install OpenRouter SDK via NPM

Source: https://openrouter.ai/docs/sdks/typescript.mdx

Install the OpenRouter TypeScript SDK package using npm for integrating AI models. Requires Node.js and npm. Inputs: None. Outputs: Package installed. Limitations: Fails if npm is not available or network issues occur.

```bash
npm install @openrouter/sdk
```

--------------------------------

### Environment Setup for OpenRouter in Python

Source: https://openrouter.ai/docs/community/arize.mdx

Sets up environment variables for OpenRouter API key. This is a prerequisite for making API calls to OpenRouter.

```Python
import os

# Set your OpenRouter API key
os.environ["OPENAI_API_KEY"] = "${API_KEY_REF}"
```

--------------------------------

### Implementation Examples

Source: https://openrouter.ai/docs/app-attribution.mdx

Examples of how to implement app attribution using various SDKs and direct API calls.

```APIDOC
## Implementation Examples

<CodeGroup>
  ```typescript title="TypeScript SDK"
  import { OpenRouter } from '@openrouter/sdk';

  const openRouter = new OpenRouter({
    apiKey: '<OPENROUTER_API_KEY>',
    defaultHeaders: {
      'HTTP-Referer': 'https://myapp.com', // Your app's URL
      'X-Title': 'My AI Assistant', // Your app's display name
    },
  });

  const completion = await openRouter.chat.send({
    model: 'openai/gpt-4o',
    messages: [
      {
        role: 'user',
        content: 'Hello, world!',
      },
    ],
    stream: false,
  });

  console.log(completion.choices[0].message);
  ```

  ```python title="Python (OpenAI SDK)"
  from openai import OpenAI

  client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key="<OPENROUTER_API_KEY>",
  )

  completion = client.chat.completions.create(
    extra_headers={
      "HTTP-Referer": "https://myapp.com", # Your app's URL
      "X-Title": "My AI Assistant", # Your app's display name
    },
    model="openai/gpt-4o",
    messages=[
      {
        "role": "user",
        "content": "Hello, world!"
      }
    ]
  )
  ```

  ```typescript title="TypeScript (OpenAI SDK)"
  import OpenAI from 'openai';

  const openai = new OpenAI({
    baseURL: 'https://openrouter.ai/api/v1',
    apiKey: '<OPENROUTER_API_KEY>',
    defaultHeaders: {
      'HTTP-Referer': 'https://myapp.com', // Your app's URL
      'X-Title': 'My AI Assistant', // Your app's display name
    },
  });

  async function main() {
    const completion = await openai.chat.completions.create({
      model: 'openai/gpt-4o',
      messages: [
        {
          role: 'user',
          content: 'Hello, world!',
        },
      ],
    });

    console.log(completion.choices[0].message);
  }

  main();
  ```

  ```python title="Python (Direct API)"
  import requests
  import json

  response = requests.post(
    url="https://openrouter.ai/api/v1/chat/completions",
    headers={
      "Authorization": "Bearer <OPENROUTER_API_KEY>",
      "HTTP-Referer": "https://myapp.com", # Your app's URL
      "X-Title": "My AI Assistant", # Your app's display name
      "Content-Type": "application/json",
    },
    data=json.dumps({
      "model": "openai/gpt-4o",
      "messages": [
        {
          "role": "user",
          "content": "Hello, world!"
        }
      ]
    })
  )
  ```

  ```typescript title="TypeScript (fetch)"
  fetch('https://openrouter.ai/api/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: 'Bearer <OPENROUTER_API_KEY>',
      'HTTP-Referer': 'https://myapp.com', // Your app's URL
      'X-Title': 'My AI Assistant', // Your app's display name
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'openai/gpt-4o',
      messages: [
        {
          role: 'user',
          content: 'Hello, world!',
        },
      ],
    }),
  });
  ```

  ```shell title="cURL"
  curl https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENROUTER_API_KEY" \
    -H "HTTP-Referer: https://myapp.com" \
    -H "X-Title: My AI Assistant" \
    -d '{
    "model": "openai/gpt-4o",
    "messages": [
      {
        "role": "user",
        "content": "Hello, world!"
      }
    ]
  }'
  ```
</CodeGroup>
```

--------------------------------

### Fetch Activity Data - Go SDK Example

Source: https://openrouter.ai/docs/api-reference/analytics/get-user-activity.mdx

This Go code example demonstrates fetching activity data from the OpenRouter AI API. It uses the standard `net/http` package and requires an authorization token. The response body and status are printed.

```go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/activity"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

--------------------------------

### Tool Calling Setup - TypeScript SDK

Source: https://openrouter.ai/docs/features/tool-calling.mdx

Initializes the OpenRouter SDK client with the API key for TypeScript applications. This setup enables the use of models that support tool calling. It defines the user's task and the system/user message structure for the LLM.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const OPENROUTER_API_KEY = "{{API_KEY_REF}}";

// You can use any model that supports tool calling
const MODEL = "{{MODEL}}";

const openRouter = new OpenRouter({
  apiKey: OPENROUTER_API_KEY,
});

const task = "What are the titles of some James Joyce books?";

const messages = [
  {
    role: "system",
    content: "You are a helpful assistant."
  },
  {
    role: "user",
    content: task,
  }
];


```

--------------------------------

### Fetch Activity Data - C# SDK Example (RestSharp)

Source: https://openrouter.ai/docs/api-reference/analytics/get-user-activity.mdx

This C# code example uses the RestSharp library to fetch activity data from the OpenRouter AI API. It requires an authorization token and sets the appropriate headers for the GET request.

```csharp
var client = new RestClient("https://openrouter.ai/api/v1/activity");
var request = new RestRequest(Method.GET);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);
```

--------------------------------

### Tool Calling Setup - Python SDK

Source: https://openrouter.ai/docs/features/tool-calling.mdx

Initializes the OpenAI client with OpenRouter's base URL and API key for Python. This setup is necessary for making requests to models that support tool calling. It defines the task and message structure for the LLM interaction.

```python
import json, requests
from openai import OpenAI

OPENROUTER_API_KEY = f"{{API_KEY_REF}}"

# You can use any model that supports tool calling
MODEL = "{{MODEL}}"

openai_client = OpenAI(
  base_url="https://openrouter.ai/api/v1",
  api_key=OPENROUTER_API_KEY,
)

task = "What are the titles of some James Joyce books?"

messages = [
  {
    "role": "system",
    "content": "You are a helpful assistant."
  },
  {
    "role": "user",
    "content": task,
  }
]


```

--------------------------------

### Project Setup and Configuration

Source: https://openrouter.ai/docs/community/mastra.mdx

Steps to set up a new Mastra project and configure environment variables for OpenRouter integration.

```APIDOC
## Project Setup and Environment Configuration

### Description
This section details the initial steps for setting up a new Mastra project and configuring the environment variables to use OpenRouter as the AI provider.

### Step 1: Initialize a new Mastra project

Use the `create-mastra` command to quickly set up a new project.

```bash
npx create-mastra@latest
```

During setup, select:
*   **Name your project**: e.g., `my-mastra-openrouter-app`
*   **Components**: `Agents` (recommended)
*   **Default provider**: Select `OpenAI` (this will be changed to OpenRouter later)
*   Optionally include example code.

For manual setup, refer to the [official Mastra documentation](https://mastra.ai/en/docs/getting-started/installation).

### Step 2: Configure environment variables

Modify the `.env.development` file in your project root.

1.  Open `.env.development`.
2.  Comment out or remove the `OPENAI_API_KEY` line.
3.  Add your OpenRouter API key:

    ```
    # .env.development
    # OPENAI_API_KEY=your-openai-key  # Comment out or remove this line
    OPENROUTER_API_KEY=sk-or-your-api-key-here
    ```

4.  Uninstall the OpenAI SDK and install the OpenRouter SDK:

    ```bash
    npm uninstall @ai-sdk/openai
    npm install @openrouter/ai-sdk-provider
    ```

```

--------------------------------

### Install Langfuse and OpenAI SDK

Source: https://openrouter.ai/docs/community/langfuse.mdx

Installs the necessary Python packages for Langfuse observability and the OpenAI SDK, which is compatible with OpenRouter's API.

```bash
pip install langfuse openai
```

--------------------------------

### Install OpenRouter AI SDK Provider

Source: https://openrouter.ai/docs/community/vercel-ai-sdk.mdx

Installs the necessary npm package for integrating OpenRouter with the Vercel AI SDK. This is a prerequisite for using the streaming text functionalities.

```bash
npm install @openrouter/ai-sdk-provider
```

--------------------------------

### Structured Outputs Request Example

Source: https://openrouter.ai/docs/features/structured-outputs.mdx

This example demonstrates how to configure a request to use structured outputs by specifying the `response_format` parameter with a JSON schema.

```APIDOC
## POST /v1/chat/completions

### Description
This endpoint allows you to send a chat completion request to an AI model, with the option to enforce a specific JSON schema for the response.

### Method
POST

### Endpoint
/v1/chat/completions

### Parameters
#### Query Parameters
None

#### Request Body
- **messages** (array) - Required - The conversation history.
- **model** (string) - Required - The model to use for completion.
- **response_format** (object) - Optional - Specifies the desired response format.
  - **type** (string) - Required - Must be `json_schema`.
  - **json_schema** (object) - Required - The JSON schema to validate against.
    - **name** (string) - Optional - A name for the schema.
    - **strict** (boolean) - Optional - If true, enforces strict schema adherence.
    - **schema** (object) - Required - The actual JSON schema object.

### Request Example
```json
{
  "messages": [
    { "role": "user", "content": "What's the weather like in London?"
    }
  ],
  "model": "model-name",
  "response_format": {
    "type": "json_schema",
    "json_schema": {
      "name": "weather",
      "strict": true,
      "schema": {
        "type": "object",
        "properties": {
          "location": {
            "type": "string",
            "description": "City or location name"
          },
          "temperature": {
            "type": "number",
            "description": "Temperature in Celsius"
          },
          "conditions": {
            "type": "string",
            "description": "Weather conditions description"
          }
        },
        "required": ["location", "temperature", "conditions"],
        "additionalProperties": false
      }
    }
  }
}
```

### Response
#### Success Response (200)
- **content** (string) - The model's response, formatted as a JSON string conforming to the provided schema.

#### Response Example
```json
{
  "location": "London",
  "temperature": 18,
  "conditions": "Partly cloudy with light drizzle"
}
```
```

--------------------------------

### List Endpoints - TypeScript SDK Example

Source: https://openrouter.ai/docs/sdks/typescript/endpoints.mdx

Demonstrates how to list all available endpoints for a specific model using the OpenRouter TypeScript SDK's `endpoints.list` method. This example requires an API key and constructs an OpenRouter client instance. It takes `author` and `slug` as parameters and logs the result.

```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.endpoints.list({
    author: "<value>",
    slug: "<value>",
  });

  console.log(result);
}

run();
```

--------------------------------

### List Model Endpoints using Ruby Net::HTTP

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints.mdx

Shows how to fetch model endpoints from OpenRouter AI using Ruby's built-in Net::HTTP library. This example sets up an SSL-enabled HTTP client and sends a GET request with the required authorization.

```ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/models/author/slug/endpoints")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = 'Bearer <token>'

response = http.request(request)
puts response.read_body
```

--------------------------------

### Fetch Activity Data - Java SDK Example (Unirest)

Source: https://openrouter.ai/docs/api-reference/analytics/get-user-activity.mdx

This Java code demonstrates fetching activity data from OpenRouter AI API using the Unirest library. It requires an authorization token and configures the request headers before executing the GET request.

```java
HttpResponse<String> response = Unirest.get("https://openrouter.ai/api/v1/activity")
  .header("Authorization", "Bearer <token>")
  .asString();
```

--------------------------------

### App Attribution Examples

Source: https://openrouter.ai/docs/app-attribution.mdx

Demonstrates how to set 'HTTP-Referer' and 'X-Title' headers for API requests across different languages and tools to enable app attribution on OpenRouter. These headers are crucial for appearing in rankings and analytics. The examples cover SDKs and direct API calls.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
  defaultHeaders: {
    'HTTP-Referer': 'https://myapp.com', // Your app's URL
    'X-Title': 'My AI Assistant', // Your app's display name
  },
});

const completion = await openRouter.chat.send({
  model: 'openai/gpt-4o',
  messages: [
    {
      role: 'user',
      content: 'Hello, world!',
    },
  ],
  stream: false,
});

console.log(completion.choices[0].message);
```

```python
from openai import OpenAI

client = OpenAI(
  base_url="https://openrouter.ai/api/v1",
  api_key="<OPENROUTER_API_KEY>",
)

completion = client.chat.completions.create(
  extra_headers={
    "HTTP-Referer": "https://myapp.com", # Your app's URL
    "X-Title": "My AI Assistant", # Your app's display name
  },
  model="openai/gpt-4o",
  messages=[
    {
      "role": "user",
      "content": "Hello, world!"
    }
  ]
)
```

```typescript
import OpenAI from 'openai';

const openai = new OpenAI({
  baseURL: 'https://openrouter.ai/api/v1',
  apiKey: '<OPENROUTER_API_KEY>',
  defaultHeaders: {
    'HTTP-Referer': 'https://myapp.com', // Your app's URL
    'X-Title': 'My AI Assistant', // Your app's display name
  },
});

async function main() {
  const completion = await openai.chat.completions.create({
    model: 'openai/gpt-4o',
    messages: [
      {
        role: 'user',
        content: 'Hello, world!',
      },
    ],
  });

  console.log(completion.choices[0].message);
}

main();
```

```python
import requests
import json

response = requests.post(
  url="https://openrouter.ai/api/v1/chat/completions",
  headers={
    "Authorization": "Bearer <OPENROUTER_API_KEY>",
    "HTTP-Referer": "https://myapp.com", # Your app's URL
    "X-Title": "My AI Assistant", # Your app's display name
    "Content-Type": "application/json",
  },
  data=json.dumps({
    "model": "openai/gpt-4o",
    "messages": [
      {
        "role": "user",
        "content": "Hello, world!"
      }
    ]
  })
)
```

```typescript
fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    Authorization: 'Bearer <OPENROUTER_API_KEY>',
    'HTTP-Referer': 'https://myapp.com', // Your app's URL
    'X-Title': 'My AI Assistant', // Your app's display name
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/gpt-4o',
    messages: [
      {
        role: 'user',
        content: 'Hello, world!',
      },
    ],
  }),
});
```

```shell
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "HTTP-Referer: https://myapp.com" \
  -H "X-Title: My AI Assistant" \
  -d '{
    "model": "openai/gpt-4o",
    "messages": [
      {
        "role": "user",
        "content": "Hello, world!"
      }
    ]
  }'
```

--------------------------------

### OpenRouter Authentication Examples

Source: https://openrouter.ai/docs/api-reference/authentication.mdx

Demonstrates how to authenticate with OpenRouter using API keys via various methods, including the OpenRouter TypeScript SDK, OpenAI SDKs for Python and TypeScript, raw API calls with fetch, and cURL. These examples show how to set the API key and include optional headers for site referer and title.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
  defaultHeaders: {
    'HTTP-Referer': '<YOUR_SITE_URL>', // Optional. Site URL for rankings on openrouter.ai.
    'X-Title': '<YOUR_SITE_NAME>', // Optional. Site title for rankings on openrouter.ai.
  },
});

const completion = await openRouter.chat.send({
  model: 'openai/gpt-4o',
  messages: [{ role: 'user', content: 'Say this is a test' }],
  stream: false,
});

console.log(completion.choices[0].message);
```

```python
from openai import OpenAI

client = OpenAI(
  base_url="https://openrouter.ai/api/v1",
  api_key="<OPENROUTER_API_KEY>",
)

response = client.chat.completions.create(
  extra_headers={
    "HTTP-Referer": "<YOUR_SITE_URL>",  # Optional. Site URL for rankings on openrouter.ai.
    "X-Title": "<YOUR_SITE_NAME>",     # Optional. Site title for rankings on openrouter.ai.
  },
  model="openai/gpt-4o",
  messages=[
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "Hello!"}
  ],
)

reply = response.choices[0].message

```

```typescript
import OpenAI from 'openai';

const openai = new OpenAI({
  baseURL: 'https://openrouter.ai/api/v1',
  apiKey: '<OPENROUTER_API_KEY>',
  defaultHeaders: {
    'HTTP-Referer': '<YOUR_SITE_URL>', // Optional. Site URL for rankings on openrouter.ai.
    'X-Title': '<YOUR_SITE_NAME>', // Optional. Site title for rankings on openrouter.ai.
  },
});

async function main() {
  const completion = await openai.chat.completions.create({
    model: 'openai/gpt-4o',
    messages: [{ role: 'user', content: 'Say this is a test' }],
  });

  console.log(completion.choices[0].message);
}

main();

```

```typescript
fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    Authorization: 'Bearer <OPENROUTER_API_KEY>',
    'HTTP-Referer': '<YOUR_SITE_URL>', // Optional. Site URL for rankings on openrouter.ai.
    'X-Title': '<YOUR_SITE_NAME>', // Optional. Site title for rankings on openrouter.ai.
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/gpt-4o',
    messages: [
      {
        role: 'user',
        content: 'What is the meaning of life?',
      },
    ],
  }),
});

```

```shell
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -d '{ \
    "model": "openai/gpt-4o", \
    "messages": [ \
      {"role": "system", "content": "You are a helpful assistant."}, \
      {"role": "user", "content": "Hello!"} \
    ] \
  }'

```

--------------------------------

### Initialize ChatOpenAI in TypeScript

Source: https://openrouter.ai/docs/community/lang-chain.mdx

Sets up a ChatOpenAI instance in TypeScript with OpenRouter configuration. Includes model settings, API key, and optional headers for site rankings. Demonstrates basic chat interaction.

```TypeScript
import { ChatOpenAI } from "@langchain/openai";
import { HumanMessage, SystemMessage } from "@langchain/core/messages";

const chat = new ChatOpenAI(
  {
    model: '<model_name>',
    temperature: 0.8,
    streaming: true,
    apiKey: '${API_KEY_REF}',
  },
  {
    baseURL: 'https://openrouter.ai/api/v1',
    defaultHeaders: {
      'HTTP-Referer': '<YOUR_SITE_URL>',
      'X-Title': '<YOUR_SITE_NAME>',
    },
  },
);

const response = await chat.invoke([
  new SystemMessage("You are a helpful assistant."),
  new HumanMessage("Hello, how are you?"),
]);
```

--------------------------------

### Get Generation Response using Swift SDK

Source: https://openrouter.ai/docs/api-reference/generations/get-generation.mdx

This Swift code example shows how to make a GET request to the OpenRouter API to retrieve generation information. It uses `URLSession` to handle the network request, setting the `Authorization` header and processing the response or any errors.

```swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/generation?id=id")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### OpenRouter API Reference Overview

Source: https://context7_llms

A comprehensive guide to OpenRouter's API, covering request/response schemas, authentication, parameters, and integration with multiple AI model providers.

```APIDOC
## API Reference Overview

### Description
This section provides a comprehensive guide to OpenRouter's API. It covers request and response schemas, authentication methods, available parameters, and how to integrate with various AI model providers.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A

### Further Reading
- [Streaming](https://openrouter.ai/docs/api-reference/streaming.mdx)
- [Limits](https://openrouter.ai/docs/api-reference/limits.mdx)
- [Authentication](https://openrouter.ai/docs/api-reference/authentication.mdx)
- [Parameters](https://openrouter.ai/docs/api-reference/parameters.mdx)
- [Errors](https://openrouter.ai/docs/api-reference/errors.mdx)
```

--------------------------------

### Get Generation Response using Python SDK

Source: https://openrouter.ai/docs/api-reference/generations/get-generation.mdx

This Python code example demonstrates how to fetch generation data from the OpenRouter API. It uses the `requests` library to make a GET request, including an authorization token and query parameters for the generation ID. The response is then printed as JSON.

```python
import requests

url = "https://openrouter.ai/api/v1/generation"

querystring = {"id":"id"}

headers = {"Authorization": "Bearer <token>"}

response = requests.get(url, headers=headers, params=querystring)

print(response.json())
```

--------------------------------

### OpenRouter Responses API Beta - Basic Usage

Source: https://context7_llms

Learn the basics of OpenRouter's Responses API Beta through simple text input examples and response handling.

```APIDOC
## Responses API Beta - Basic Usage

### Description
This guide covers the fundamental usage of OpenRouter's Responses API Beta, providing simple text input examples and instructions for handling responses.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### Send Completion Request - Go

Source: https://openrouter.ai/docs/api-reference/completions/create-completions.mdx

This Go code example demonstrates sending a POST request to the OpenRouter API. It constructs the request with the necessary headers and body, then reads and prints the response body. It uses the `net/http` package for making HTTP requests.

```Go
package main

import (
	"fmt"
	"strings"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/completions"

	payload := strings.NewReader("{\n  \"prompt\": \"string\"\n}")

	req, _ := http.NewRequest("POST", url, payload)

	req.Header.Add("Authorization", "Bearer &lt;token&gt;")
	req.Header.Add("Content-Type", "application/json")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))
```

--------------------------------

### Initialize ChatOpenAI in Python

Source: https://openrouter.ai/docs/community/lang-chain.mdx

Configures a ChatOpenAI instance in Python for OpenRouter integration. Includes environment variable loading, prompt templating, and chain creation for question-answering tasks.

```Python
from langchain_openai import ChatOpenAI
from langchain_core.prompts import PromptTemplate
from langchain.chains import LLMChain
from os import getenv
from dotenv import load_dotenv

load_dotenv()

template = """Question: {question}
Answer: Let's think step by step."""

prompt = PromptTemplate(template=template, input_variables=["question"])

llm = ChatOpenAI(
  api_key=getenv("OPENROUTER_API_KEY"),
  base_url="https://openrouter.ai/api/v1",
  model="<model_name>",
  default_headers={
    "HTTP-Referer": getenv("YOUR_SITE_URL"),
    "X-Title": getenv("YOUR_SITE_NAME"),
  }
)

llm_chain = LLMChain(prompt=prompt, llm=llm)

question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

print(llm_chain.run(question))
```

--------------------------------

### Fetch OpenRouter Models using Go

Source: https://openrouter.ai/docs/api-reference/models/get-models.mdx

This Go program demonstrates how to fetch OpenRouter models using the standard `net/http` package. It constructs a GET request, adds the authorization header, sends the request, and prints the response body.

```go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/models"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

--------------------------------

### Install and Configure OpenRouter SDK for Mastra

Source: https://openrouter.ai/docs/community/mastra.mdx

These commands demonstrate how to uninstall the OpenAI SDK and install the OpenRouter AI SDK provider for Mastra. This prepares the project to use OpenRouter models.

```bash
npm uninstall @ai-sdk/openai
```

```bash
npm install @openrouter/ai-sdk-provider
```

--------------------------------

### Get Generation Response using Go SDK

Source: https://openrouter.ai/docs/api-reference/generations/get-generation.mdx

This Go program illustrates how to call the OpenRouter API to get generation details. It uses the standard `net/http` package to create a GET request, adds the necessary authorization header, sends the request, and prints the response status and body.

```go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/generation?id=id"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

--------------------------------

### Get Generation Response using Ruby SDK

Source: https://openrouter.ai/docs/api-reference/generations/get-generation.mdx

This Ruby script demonstrates fetching generation data from OpenRouter. It utilizes the `net/http` library to construct and send a GET request, including the API key in the `Authorization` header. The response body is then printed to the console.

```ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/generation?id=id")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = 'Bearer <token>'

response = http.request(request)
puts response.read_body
```

--------------------------------

### Fetch Activity Data - Ruby SDK Example

Source: https://openrouter.ai/docs/api-reference/analytics/get-user-activity.mdx

This Ruby code snippet illustrates how to get activity data from the OpenRouter AI API using Ruby's built-in `net/http` and `uri` libraries. It requires an API token for authentication and prints the response body.

```ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/activity")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = 'Bearer <token>'

response = http.request(request)
puts response.read_body
```

--------------------------------

### Get Generation Response using PHP SDK

Source: https://openrouter.ai/docs/api-reference/generations/get-generation.mdx

This PHP example utilizes the Guzzle HTTP client to make a GET request to the OpenRouter API for generation data. It configures the request with the necessary `Authorization` header and echoes the response body.

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('GET', 'https://openrouter.ai/api/v1/generation?id=id', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();
?>
```

--------------------------------

### List Model Endpoints using Java Unirest

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints.mdx

Provides an example of calling the OpenRouter AI API for model endpoints using the Unirest Java library. This snippet demonstrates a concise way to make a GET request with an Authorization header.

```java
HttpResponse<String> response = Unirest.get("https://openrouter.ai/api/v1/models/author/slug/endpoints")
  .header("Authorization", "Bearer <token>")
  .asString();
```

--------------------------------

### Basic OpenRouter Integration with Arize in Python

Source: https://openrouter.ai/docs/community/arize.mdx

Initializes Arize and instruments the OpenAI client to automatically trace OpenRouter calls. Includes setting up the client and making a chat completion request.

```Python
from arize.otel import register
from openinference.instrumentation.openai import OpenAIInstrumentor
import openai

# Initialize Arize and register the tracer provider
tracer_provider = register(
    space_id="your-space-id",
    api_key="your-arize-api-key",
    project_name="your-project-name",
)

# Instrument OpenAI SDK
OpenAIInstrumentor().instrument(tracer_provider=tracer_provider)

# Configure OpenAI client for OpenRouter
client = openai.OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key="your_openrouter_api_key",
    default_headers={
        "HTTP-Referer": "<YOUR_SITE_URL>",  # Optional: Your site URL
        "X-Title": "<YOUR_SITE_NAME>",      # Optional: Your site name
    }
)

# Make a traced chat completion request
response = client.chat.completions.create(
    model="meta-llama/llama-3.1-8b-instruct:free",
    messages=[
        {"role": "user", "content": "Write a haiku about observability."}
    ],
)

# Print the assistant's reply
print(response.choices[0].message.content)
```

--------------------------------

### OpenRouter TypeScript SDK - Completions

Source: https://context7_llms

Documentation for the Completions method of the OpenRouter TypeScript SDK, including code examples.

```APIDOC
## TypeScript SDK - Completions Method

### Description
This document provides API endpoint documentation for the Completions method within the OpenRouter TypeScript SDK. It includes code examples to guide integration.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### OpenRouter TypeScript SDK - APIKeys

Source: https://context7_llms

Documentation for the APIKeys method of the OpenRouter TypeScript SDK, including code examples.

```APIDOC
## TypeScript SDK - APIKeys Method

### Description
This document provides API endpoint documentation for the APIKeys method within the OpenRouter TypeScript SDK. It includes code examples to guide integration.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### Install PydanticAI for OpenAI

Source: https://openrouter.ai/docs/community/pydantic-ai.mdx

Installs the PydanticAI library with support for OpenAI-compatible providers. This is a prerequisite for configuring PydanticAI to work with OpenRouter.

```bash
pip install 'pydantic-ai-slim[openai]'
```

--------------------------------

### Install LiveKit Agents with OpenAI Plugin

Source: https://openrouter.ai/docs/community/live-kit.mdx

Installs the LiveKit Agents framework with the OpenAI plugin, which is necessary for OpenRouter integration. This command ensures that the required packages are available in your Python environment.

```bash
uv add "livekit-agents[openai]~=1.2"
```

--------------------------------

### Fetch Activity Data - Swift SDK Example

Source: https://openrouter.ai/docs/api-reference/analytics/get-user-activity.mdx

This Swift code snippet demonstrates how to get activity data from the OpenRouter AI API using `URLSession`. It requires an API token for authentication and handles potential errors during the data task.

```swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/activity")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### List Model Endpoints using Swift URLSession

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints.mdx

Provides an example of fetching model endpoints from OpenRouter AI using Swift's URLSession. This code constructs an NSMutableURLRequest with the GET method and Authorization header.

```swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/models/author/slug/endpoints")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### Get API Key using TypeScript SDK

Source: https://openrouter.ai/docs/sdks/typescript/apikeys.mdx

This TypeScript example retrieves a single API key using the OpenRouter SDK. It requires an API key and the hash of the key to fetch. Inputs: hash string; outputs: the key details or throws an error. Dependencies include @openrouter/sdk; suitable for simple retrieval without complex state management.

```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.apiKeys.get({
    hash: "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",
  });

  console.log(result);
}

run();
```

--------------------------------

### Cross-Language API GET Request to Fetch Author Parameters

Source: https://openrouter.ai/docs/api-reference/parameters/get-parameters.mdx

These examples show how to send a GET request to the OpenRouter API to retrieve parameters for a specific author and slug, using an Authorization Bearer token header. Inputs include the API URL and token; outputs are the JSON response body. Dependencies vary: standard libraries for JavaScript, Go, Ruby, and Swift; external libraries like requests (Python), Unirest (Java), GuzzleHttp (PHP), and RestSharp (C#). Replace '<token>' with a valid API key; error handling is basic in most examples and may need enhancement for production use.

```python
import requests

url = "https://openrouter.ai/api/v1/parameters/author/slug"

headers = {"Authorization": "Bearer <token>"}

response = requests.get(url, headers=headers)

print(response.json())
```

```javascript
const url = 'https://openrouter.ai/api/v1/parameters/author/slug';
const options = {method: 'GET', headers: {Authorization: 'Bearer <token>'}};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

```go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/parameters/author/slug"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

```ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/parameters/author/slug")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = 'Bearer <token>'

response = http.request(request)
puts response.read_body
```

```java
HttpResponse<String> response = Unirest.get("https://openrouter.ai/api/v1/parameters/author/slug")
  .header("Authorization", "Bearer <token>")
  .asString();
```

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('GET', 'https://openrouter.ai/api/v1/parameters/author/slug', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();
?>
```

```csharp
var client = new RestClient("https://openrouter.ai/api/v1/parameters/author/slug");
var request = new RestRequest(Method.GET);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);
```

```swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/parameters/author/slug")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### Fetch API Key Info using OpenRouter SDK in Multiple Languages

Source: https://openrouter.ai/docs/api-reference/api-keys/get-current-key.mdx

These examples demonstrate how to fetch API key information from OpenRouter by making a GET request to the '/api/v1/key' endpoint. They require an authorization token and use standard HTTP client libraries for each language. The output typically includes the API key details or an error message.

```python
import requests

url = "https://openrouter.ai/api/v1/key"

headers = {"Authorization": "Bearer <token>"}

response = requests.get(url, headers=headers)

print(response.json())
```

```javascript
const url = 'https://openrouter.ai/api/v1/key';
const options = {method: 'GET', headers: {Authorization: 'Bearer <token>'}};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

```go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/key"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

```ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/key")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = 'Bearer <token>'

response = http.request(request)
puts response.read_body
```

```java
HttpResponse<String> response = Unirest.get("https://openrouter.ai/api/v1/key")
  .header("Authorization", "Bearer <token>")
  .asString();
```

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('GET', 'https://openrouter.ai/api/v1/key', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();
?>
```

```csharp
var client = new RestClient("https://openrouter.ai/api/v1/key");
var request = new RestRequest(Method.GET);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);
```

```swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/key")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### POST /api/v1/responses - Multiple Tools

Source: https://openrouter.ai/docs/api-reference/responses-api/tool-calling.mdx

This endpoint demonstrates how to define and utilize multiple tools within a request to handle complex tasks. The example shows how to combine a calculator tool with another tool (weather).

```APIDOC
## POST /api/v1/responses

### Description
This endpoint demonstrates using multiple tools in a single API call to handle complex tasks.

### Method
POST

### Endpoint
/api/v1/responses

### Parameters
#### Path Parameters
- None

#### Query Parameters
- None

#### Request Body
- `model` (string) - Required - The model to use.
- `input` (array of objects) - Required - The input messages.
- `tools` (array of objects) - Required - An array of tool definitions.
- `tool_choice` (string) - Optional - How to choose the tool. `auto` is recommended.
- `max_output_tokens` (integer) - Optional - The maximum number of output tokens.

### Request Example
```json
{
  "model": "openai/o4-mini",
  "input": [
    {
      "type": "message",
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "What is 25 * 4?"
        }
      ]
    }
  ],
  "tools": [
    {
      "type": "function",
      "name": "calculate",
      "description": "Perform mathematical calculations",
      "strict": null,
      "parameters": {
        "type": "object",
        "properties": {
          "expression": {
            "type": "string",
            "description": "The mathematical expression to evaluate"
          }
        },
        "required": ["expression"]
      }
    }
  ],
  "tool_choice": "auto",
  "max_output_tokens": 9000
}
```

### Response
#### Success Response (200)
- `id` (string) - Response ID.
- `object` (string) - Response object type.
- `created_at` (integer) - Timestamp of creation.
- `model` (string) - Model used.
- `output` (array of objects) - The response output. If tools are used, it includes `function_call` objects.
- `usage` (object) - Token usage information.
- `status` (string) - Status of the response.

#### Response Example
```json
{
  "id": "resp_1234567890",
  "object": "response",
  "created_at": 1234567890,
  "model": "openai/o4-mini",
  "output": [
    {
      "type": "function_call",
      "id": "fc_abc123",
      "call_id": "call_xyz789",
      "name": "get_weather",
      "arguments": "{"location":"San Francisco, CA"}"
    }
  ],
  "usage": {
    "input_tokens": 45,
    "output_tokens": 25,
    "total_tokens": 70
  },
  "status": "completed"
}
```
```

--------------------------------

### Consistent User Identifier Format Example

Source: https://openrouter.ai/docs/use-cases/user-tracking.mdx

Illustrates the importance of maintaining a consistent format for user identifiers across your application. This example shows how to create a prefixed user ID string in Python.

```python
# Consistent format
user_id = f"app_{internal_user_id}"
```

--------------------------------

### Anthropic Claude Caching Example

Source: https://openrouter.ai/docs/features/prompt-caching.mdx

Example request demonstrating how to use cache_control breakpoints with Anthropic Claude models.

```APIDOC
## POST /api/v1/chat/completions

### Description
Example request showing how to implement prompt caching with Anthropic Claude using cache_control breakpoints.

### Method
POST

### Endpoint
/api/v1/chat/completions

### Request Body
- **messages** (array) - Required - Array of message objects with content and optional cache_control.
- **cache_control** (object) - Optional - Specifies caching behavior for large text blocks (ephemeral caching with 5-minute TTL).

### Request Example
{
  "messages": [
    {
      "role": "system",
      "content": [
        {
          "type": "text",
          "text": "You are a historian studying the fall of the Roman Empire. You know the following book very well:"
        },
        {
          "type": "text",
          "text": "HUGE TEXT BODY",
          "cache_control": {
            "type": "ephemeral"
          }
        }
      ]
    },
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "What triggered the collapse?"
        }
      ]
    }
  ]
}
```

--------------------------------

### Fetch OpenRouter ZDR Endpoints (Python, JavaScript, Go, Ruby, Java, PHP, C#, Swift)

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints-zdr.mdx

Demonstrates how to make a GET request to the OpenRouter API's ZDR endpoint to retrieve information about available endpoints. This involves setting up the request URL and including an authorization token in the headers. The response, typically in JSON format, contains endpoint data. Ensure you have the respective HTTP client libraries installed for each language.

```python
import requests

url = "https://openrouter.ai/api/v1/endpoints/zdr"

headers = {"Authorization": "Bearer <token>"}

response = requests.get(url, headers=headers)

print(response.json())
```

```javascript
const url = 'https://openrouter.ai/api/v1/endpoints/zdr';
const options = {method: 'GET', headers: {Authorization: 'Bearer <token>'}};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

```go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/endpoints/zdr"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

```ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/endpoints/zdr")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = 'Bearer <token>'

response = http.request(request)
puts response.read_body
```

```java
HttpResponse<String> response = Unirest.get("https://openrouter.ai/api/v1/endpoints/zdr")
  .header("Authorization", "Bearer <token>")
  .asString();
```

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('GET', 'https://openrouter.ai/api/v1/endpoints/zdr', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();
?>
```

```csharp
var client = new RestClient("https://openrouter.ai/api/v1/endpoints/zdr");
var request = new RestRequest(Method.GET);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);
```

```swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/endpoints/zdr")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### Multi-Tool Workflow Definition in JSON

Source: https://openrouter.ai/docs/features/tool-calling.mdx

Defines a set of tools that can be used in sequence for complex workflows. This example includes tools for searching products, getting details, and checking inventory, enabling chained operations.

```json
{
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "search_products",
        "description": "Search for products in the catalog"
      }
    },
    {
      "type": "function",
      "function": {
        "name": "get_product_details",
        "description": "Get detailed information about a specific product"
      }
    },
    {
      "type": "function",
      "function": {
        "name": "check_inventory",
        "description": "Check current inventory levels for a product"
      }
    }
  ]
}
```

--------------------------------

### Create comprehensive tool descriptions in JSON

Source: https://openrouter.ai/docs/features/tool-calling.mdx

Shows how to define detailed tool descriptions with parameters for LLM consumption. Includes type definitions, required fields, and usage examples. Follows best practices for making tools understandable to language models.

```json
{
  "description": "Get current weather conditions and 5-day forecast for a specific location. Supports cities, zip codes, and coordinates.",
  "parameters": {
    "type": "object",
    "properties": {
      "location": {
        "type": "string",
        "description": "City name, zip code, or coordinates (lat,lng). Examples: 'New York', '10001', '40.7128,-74.0060'"
      },
      "units": {
        "type": "string",
        "enum": ["celsius", "fahrenheit"],
        "description": "Temperature unit preference",
        "default": "celsius"
      }
    },
    "required": ["location"]
  }
}
```

--------------------------------

### List Model Endpoints using C# RestSharp

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints.mdx

Shows how to access OpenRouter AI model endpoints using the RestSharp library in C#. This example configures a GET request with an Authorization header.

```csharp
var client = new RestClient("https://openrouter.ai/api/v1/models/author/slug/endpoints");
var request = new RestRequest(Method.GET);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);
```

--------------------------------

### Fetch OpenRouter Models using C# (RestSharp)

Source: https://openrouter.ai/docs/api-reference/models/get-models.mdx

This C# example utilizes the RestSharp library to execute a GET request against the OpenRouter API to retrieve model data. It adds the required authorization header and captures the response. RestSharp needs to be included as a NuGet package.

```csharp
var client = new RestClient("https://openrouter.ai/api/v1/models");
var request = new RestRequest(Method.GET);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);
```

--------------------------------

### Fetching Model Count API in Multiple Languages

Source: https://openrouter.ai/docs/api-reference/models/list-models-count.mdx

These code examples demonstrate how to make a GET request to the /api/v1/models/count endpoint using an Authorization bearer token to retrieve the total count of available models. Each language uses its standard HTTP library or a common dependency like requests (Python), fetch (JavaScript), net/http (Go), net/http (Ruby), Unirest (Java), Guzzle (PHP), RestSharp (C#), and URLSession (Swift). Inputs include the URL and token; outputs are JSON with count data or error handling; limitations include lack of full error checking in some examples and dependency requirements.

```python
import requests

url = "https://openrouter.ai/api/v1/models/count"

headers = {"Authorization": "Bearer <token>"}

response = requests.get(url, headers=headers)

print(response.json())

```

```javascript
const url = 'https://openrouter.ai/api/v1/models/count';
const options = {method: 'GET', headers: {Authorization: 'Bearer <token>'}};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}

```

```go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/models/count"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}

```

```ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/models/count")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = 'Bearer <token>'

response = http.request(request)
puts response.read_body

```

```java
HttpResponse<String> response = Unirest.get("https://openrouter.ai/api/v1/models/count")
  .header("Authorization", "Bearer <token>")
  .asString();

```

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('GET', 'https://openrouter.ai/api/v1/models/count', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();

```

```csharp
var client = new RestClient("https://openrouter.ai/api/v1/models/count");
var request = new RestRequest(Method.GET);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);

```

```swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/models/count")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()

```

--------------------------------

### GET /api/v1/keys/{key_id}

Source: https://openrouter.ai/docs/api-reference/api-keys/get-key.mdx

This endpoint retrieves metadata about a specific API key by its ID. It requires a Bearer token in the Authorization header for authentication. The API key ID is passed as a path parameter, and examples in various languages show how to make the request.

```APIDOC
## GET /api/v1/keys/{key_id}

### Description
Retrieves details about a specific API key using its unique identifier.

### Method
GET

### Endpoint
/api/v1/keys/{key_id}

### Parameters
#### Path Parameters
- **key_id** (string) - Required - The unique identifier of the API key (e.g., sk-or-v1-...)

#### Query Parameters
None

#### Request Body
None

### Request Example
No request body. Headers: {"Authorization": "Bearer <your_token>"}

### Response
#### Success Response (200)
- Details not specified in provided text.

#### Response Example
No example provided in input.
```

--------------------------------

### Get Generation Response using JavaScript SDK

Source: https://openrouter.ai/docs/api-reference/generations/get-generation.mdx

This JavaScript example shows how to retrieve generation information from the OpenRouter API using the `fetch` API. It constructs the URL with a generation ID, sets the authorization header, and handles the asynchronous response, logging the JSON data or any errors to the console.

```javascript
const url = 'https://openrouter.ai/api/v1/generation?id=id';
const options = {method: 'GET', headers: {Authorization: 'Bearer <token>'}};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

--------------------------------

### Basic OpenRouter Integration with Mastra Agent (TypeScript)

Source: https://openrouter.ai/docs/community/mastra.mdx

This TypeScript snippet provides a concise example of integrating OpenRouter with Mastra's Agent system. It initializes the OpenRouter provider, creates an agent using a specific model, and then demonstrates generating a response to a user query. This example is suitable for simple use cases.

```typescript
import { Agent } from '@mastra/core/agent';
import { createOpenRouter } from '@openrouter/ai-sdk-provider';

// Initialize the OpenRouter provider
const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY,
});

// Create an agent using OpenRouter
const assistant = new Agent({
  model: openrouter('anthropic/claude-3-opus'),
  name: 'Assistant',
  instructions: 'You are a helpful assistant.',
});

// Generate a response
const response = await assistant.generate([
  {
    role: 'user',
    content: 'Tell me about renewable energy sources.',
  },
]);

console.log(response.text);
```

--------------------------------

### Run Mastra Development Server

Source: https://openrouter.ai/docs/community/mastra.mdx

This command starts the Mastra development server, making the configured agent accessible via a REST API and an interactive playground. This is the final step to run your integrated OpenRouter application.

```bash
npm run dev
```

--------------------------------

### Fetch OpenRouter Models using PHP (Guzzle)

Source: https://openrouter.ai/docs/api-reference/models/get-models.mdx

This PHP code uses the Guzzle HTTP client to make a GET request to the OpenRouter API for fetching models. It configures the authorization header and outputs the response body. Ensure Guzzle is installed via Composer.

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('GET', 'https://openrouter.ai/api/v1/models', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();
?>
```

--------------------------------

### Create Coinbase Charge Example Usage - TypeScript

Source: https://openrouter.ai/docs/sdks/typescript/credits.mdx

Demonstrates basic usage of the OpenRouter SDK to create a Coinbase charge. Requires the @openrouter/sdk package and environment variable OPENROUTER_BEARER. Input includes amount, sender address, and chain ID; outputs the charge result or errors. Limited to async environments and requires proper authentication.

```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter();

async function run() {
  const result = await openRouter.credits.createCoinbaseCharge({
    bearer: process.env["OPENROUTER_BEARER"] ?? "",
  }, {
    amount: 100,
    sender: "0x1234567890123456789012345678901234567890",
    chainId: 1,
  });

  console.log(result);
}

run();
```

--------------------------------

### Fetch API Keys with OpenRouter SDK

Source: https://openrouter.ai/docs/api-reference/api-keys/list.mdx

Demonstrates how to retrieve API keys from OpenRouter using their SDK. This involves making a GET request to the keys endpoint with proper authorization. Dependencies include the respective HTTP client libraries for each language.

```python
import requests

url = "https://openrouter.ai/api/v1/keys"

headers = {"Authorization": "Bearer <token>"}

response = requests.get(url, headers=headers)

print(response.json())
```

```javascript
const url = 'https://openrouter.ai/api/v1/keys';
const options = {method: 'GET', headers: {Authorization: 'Bearer <token>'}};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

```go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/keys"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

```ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/keys")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = 'Bearer <token>'

response = http.request(request)
puts response.read_body
```

```java
HttpResponse<String> response = Unirest.get("https://openrouter.ai/api/v1/keys")
  .header("Authorization", "Bearer <token>")
  .asString();
```

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('GET', 'https://openrouter.ai/api/v1/keys', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();
```

```csharp
var client = new RestClient("https://openrouter.ai/api/v1/keys");
var request = new RestRequest(Method.GET);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);
```

```swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/keys")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### Fetch User Models from OpenRouter API

Source: https://openrouter.ai/docs/api-reference/models/list-models-user.mdx

This example shows how to send a GET request to the OpenRouter API endpoint '/api/v1/models/user' to retrieve user models. It requires a Bearer token for authorization in the headers. The code handles the request and prints or logs the response body. Note that error handling varies by language, and some snippets use specific libraries like requests (Python), fetch (JavaScript), or Unirest (Java).

```python
import requests

url = "https://openrouter.ai/api/v1/models/user"

headers = {"Authorization": "Bearer <token>"}

response = requests.get(url, headers=headers)

print(response.json())
```

```javascript
const url = 'https://openrouter.ai/api/v1/models/user';
const options = {method: 'GET', headers: {Authorization: 'Bearer <token>'}};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

```go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/models/user"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

```ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/models/user")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = 'Bearer <token>'

response = http.request(request)
puts response.read_body
```

```java
HttpResponse<String> response = Unirest.get("https://openrouter.ai/api/v1/models/user")
  .header("Authorization", "Bearer <token>")
  .asString();
```

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('GET', 'https://openrouter.ai/api/v1/models/user', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();

```

```csharp
var client = new RestClient("https://openrouter.ai/api/v1/models/user");
var request = new RestRequest(Method.GET);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);
```

```swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/models/user")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### OpenRouter TypeScript SDK - Credits

Source: https://context7_llms

Documentation for the Credits method of the OpenRouter TypeScript SDK, including code examples.

```APIDOC
## TypeScript SDK - Credits Method

### Description
This document provides API endpoint documentation for the Credits method within the OpenRouter TypeScript SDK. It includes code examples to guide integration.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### Get User Activity using Standalone Function (TypeScript)

Source: https://openrouter.ai/docs/sdks/typescript/analytics.mdx

Provides a standalone function for fetching user activity data, optimized for tree-shaking. It uses `OpenRouterCore` and a specific analytics function, `analyticsGetUserActivity`, for efficient integration. The example shows how to handle successful responses and potential errors.

```typescript
import { OpenRouterCore } from "@openrouter/sdk/core.js";
import { analyticsGetUserActivity } from "@openrouter/sdk/funcs/analyticsGetUserActivity.js";

// Use `OpenRouterCore` for best tree-shaking performance.
// You can create one instance of it to use across an application.
const openRouter = new OpenRouterCore({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const res = await analyticsGetUserActivity(openRouter);
  if (res.ok) {
    const { value: result } = res;
    console.log(result);
  } else {
    console.log("analyticsGetUserActivity failed:", res.error);
  }
}

run();
```

--------------------------------

### List Models Endpoint

Source: https://openrouter.ai/docs/use-cases/for-providers.mdx

This endpoint should return a list of all available models from your platform that you wish to serve through OpenRouter. The response format includes detailed model information, pricing, and supported features.

```APIDOC
## GET /v1/models

### Description
This endpoint is required for providers to list all models available for inference on their platform. The response should be a JSON object containing a 'data' array, where each element represents a model with its unique identifier, pricing, modalities, and other relevant details.

### Method
GET

### Endpoint
/v1/models

### Parameters
No path or query parameters are defined for this endpoint.

### Request Body
This endpoint does not accept a request body.

### Request Example
This endpoint does not have a request example as it is a GET request.

### Response
#### Success Response (200)
- **data** (array) - An array of model objects.
  - **id** (string) - Required - Unique identifier for the model (e.g., "anthropic/claude-sonnet-4").
  - **hugging_face_id** (string) - Required if the model is on Hugging Face - The Hugging Face model identifier.
  - **name** (string) - Required - A human-readable name for the model (e.g., "Anthropic: Claude Sonnet 4").
  - **created** (integer) - Required - Timestamp of model creation.
  - **input_modalities** (array of strings) - Required - List of input modalities supported (e.g., ["text", "image"]).
  - **output_modalities** (array of strings) - Required - List of output modalities supported (e.g., ["text"]).
  - **quantization** (string) - Required - The quantization method used (e.g., "fp8"). Valid values: `int4`, `int8`, `fp4`, `fp6`, `fp8`, `fp16`, `bf16`, `fp32`.
  - **context_length** (integer) - Required - The maximum context length supported by the model.
  - **max_output_length** (integer) - Required - The maximum output length the model can generate.
  - **pricing** (object) - Required - Pricing details per token or unit.
    - **prompt** (string) - Pricing per input token (USD).
    - **completion** (string) - Pricing per output token (USD).
    - **image** (string) - Pricing per image (USD).
    - **request** (string) - Pricing per request (USD).
    - **input_cache_reads** (string) - Pricing per input cache read (USD).
    - **input_cache_writes** (string) - Pricing per input cache write (USD).
  - **supported_sampling_parameters** (array of strings) - Required - List of sampling parameters supported (e.g., ["temperature", "stop"]). Valid values: `temperature`, `top_p`, `top_k`, `repetition_penalty`, `frequency_penalty`, `presence_penalty`, `stop`, `seed`.
  - **supported_features** (array of strings) - Required - List of advanced features supported (e.g., ["tools"]). Valid values: `tools`, `json_mode`, `structured_outputs`, `web_search`, `reasoning`.
  - **description** (string) - Optional - A brief description of the model.
  - **openrouter** (object) - Optional - OpenRouter specific configurations.
    - **slug** (string) - OpenRouter's unique identifier for the model.
  - **datacenters** (array of objects) - Optional - List of datacenters where the model is hosted.
    - **country_code** (string) - Required - ISO 3166 Alpha 2 country code (e.g., "US").

#### Response Example
```json
{
  "data": [
    {
      "id": "anthropic/claude-sonnet-4",
      "hugging_face_id": "",
      "name": "Anthropic: Claude Sonnet 4",
      "created": 1690502400,
      "input_modalities": ["text", "image", "file"],
      "output_modalities": ["text", "image", "file"],
      "quantization": "fp8",
      "context_length": 1000000,
      "max_output_length": 128000,
      "pricing": {
        "prompt": "0.000008",
        "completion": "0.000024",
        "image": "0",
        "request": "0",
        "input_cache_reads": "0",
        "input_cache_writes": "0"
      },
      "supported_sampling_parameters": ["temperature", "stop"],
      "supported_features": [
        "tools",
        "json_mode",
        "structured_outputs",
        "web_search",
        "reasoning"
      ],
      "description": "Anthropic's flagship model...",
      "openrouter": {
        "slug": "anthropic/claude-sonnet-4"
      },
      "datacenters": [
        {
          "country_code": "US"
        }
      ]
    }
  ]
}
```
```

--------------------------------

### JSON Example of OpenRouter Completions Response

Source: https://openrouter.ai/docs/api-reference/overview.mdx

Illustrates a typical JSON response from the OpenRouter Completions API, showcasing the structure of 'id', 'choices' with 'finish_reason', 'native_finish_reason', and 'message', along with 'usage' statistics and the 'model' used.

```json
{
  "id": "gen-xxxxxxxxxxxxxx",
  "choices": [
    {
      "finish_reason": "stop", // Normalized finish_reason
      "native_finish_reason": "stop", // The raw finish_reason from the provider
      "message": {
        // will be "delta" if streaming
        "role": "assistant",
        "content": "Hello there!"
      }
    }
  ],
  "usage": {
    "prompt_tokens": 0,
    "completion_tokens": 4,
    "total_tokens": 4
  },
  "model": "openai/gpt-3.5-turbo" // Could also be "anthropic/claude-2.1", etc, depending on the "model" that ends up being used
}
```

--------------------------------

### Redirect User to OpenRouter for Authentication

Source: https://openrouter.ai/docs/use-cases/oauth-pkce.mdx

Initiates the OAuth PKCE flow by redirecting the user to OpenRouter's authentication endpoint. Supports different methods for generating code challenges, with S256 being the recommended secure option. Requires a callback URL and optionally a code challenge for enhanced security.

```txt
https://openrouter.ai/auth?callback_url=<YOUR_SITE_URL>&code_challenge=<CODE_CHALLENGE>&code_challenge_method=S256
```

```txt
https://openrouter.ai/auth?callback_url=<YOUR_SITE_URL>&code_challenge=<CODE_CHALLENGE>&code_challenge_method=plain
```

```txt
https://openrouter.ai/auth?callback_url=<YOUR_SITE_URL>
```

--------------------------------

### Gemini System Message Caching Example (JSON)

Source: https://openrouter.ai/docs/features/prompt-caching.mdx

Demonstrates how to cache a system message containing a large text body for Gemini models using the `cache_control` breakpoint. This allows for efficient retrieval of static reference content in subsequent requests.

```json
{
  "messages": [
    {
      "role": "system",
      "content": [
        {
          "type": "text",
          "text": "You are a historian studying the fall of the Roman Empire. Below is an extensive reference book:"
        },
        {
          "type": "text",
          "text": "HUGE TEXT BODY HERE",
          "cache_control": {
            "type": "ephemeral"
          }
        }
      ]
    },
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "What triggered the collapse?"
        }
      ]
    }
  ]
}
```

--------------------------------

### OpenRouter TypeScript SDK - Models

Source: https://context7_llms

Documentation for the Models method of the OpenRouter TypeScript SDK, including code examples.

```APIDOC
## TypeScript SDK - Models Method

### Description
This document provides API endpoint documentation for the Models method within the OpenRouter TypeScript SDK. It includes code examples to guide integration.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### Retrieve Embeddings Models List

Source: https://openrouter.ai/docs/api-reference/models/list-models-embeddings.mdx

These code snippets demonstrate how to make a GET request to the OpenRouter API endpoint for fetching the list of available embedding models. They require an authorization header with a bearer token. The output includes the JSON response or body of the API call. Dependencies vary by language, such as 'requests' for Python or 'GuzzleHttp' for PHP. Limitations may include error handling not being comprehensive in all examples.

```Python
import requests

url = "https://openrouter.ai/api/v1/models/embeddings"

headers = {"Authorization": "Bearer <token>"}

response = requests.get(url, headers=headers)

print(response.json())
```

```JavaScript
const url = 'https://openrouter.ai/api/v1/models/embeddings';
const options = {method: 'GET', headers: {Authorization: 'Bearer <token>'}};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

```Go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/models/embeddings"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

```Ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/models/embeddings")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = 'Bearer <token>'

response = http.request(request)
puts response.read_body
```

```Java
HttpResponse<String> response = Unirest.get("https://openrouter.ai/api/v1/models/embeddings")
  .header("Authorization", "Bearer <token>")
  .asString();
```

```PHP
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('GET', 'https://openrouter.ai/api/v1/models/embeddings', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();
```

```C#
var client = new RestClient("https://openrouter.ai/api/v1/models/embeddings");
var request = new RestRequest(Method.GET);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);
```

```Swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/models/embeddings")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### OpenRouter TypeScript SDK - Generations

Source: https://context7_llms

Documentation for the Generations method of the OpenRouter TypeScript SDK, including code examples.

```APIDOC
## TypeScript SDK - Generations Method

### Description
This document provides API endpoint documentation for the Generations method within the OpenRouter TypeScript SDK. It includes code examples to guide integration.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### Use OpenRouter API with TypeScript SDK

Source: https://openrouter.ai/docs/use-cases/oauth-pkce.mdx

Demonstrates how to use the obtained API key with the official OpenRouter TypeScript SDK to make a chat completion request. Initializes the SDK with the API key and sends a message to a specified model, returning the model's response.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: key, // The key from Step 2
});

const completion = await openRouter.chat.send({
  model: 'openai/gpt-4o',
  messages: [
    {
      role: 'user',
      content: 'Hello!',
    },
  ],
  stream: false,
});

console.log(completion.choices[0].message);
```

--------------------------------

### List API Keys - TypeScript SDK Usage

Source: https://openrouter.ai/docs/sdks/typescript/apikeys.mdx

Demonstrates how to list all API keys using the OpenRouter TypeScript SDK. It initializes the SDK with an API key and calls the 'list' method to retrieve the keys. The result is then logged to the console.

```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.apiKeys.list();

  console.log(result);
}

run();
```

--------------------------------

### Sort Providers by Price (TypeScript, Python)

Source: https://openrouter.ai/docs/features/provider-routing.mdx

Demonstrates how to explicitly sort AI providers by the lowest price using the `provider.sort: 'price'` option. This example shows implementation in TypeScript via SDK and fetch, and in Python using the `requests` library. It bypasses default load balancing to prioritize the cheapest available providers.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
});

const completion = await openRouter.chat.send({
  model: 'meta-llama/llama-3.1-70b-instruct',
  messages: [{ role: 'user', content: 'Hello' }],
  provider: {
    sort: 'price',
  },
  stream: false,
});
```

```typescript
fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer <OPENROUTER_API_KEY>',
    'HTTP-Referer': '<YOUR_SITE_URL>',
    'X-Title': '<YOUR_SITE_NAME>',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'meta-llama/llama-3.1-70b-instruct',
    messages: [{ role: 'user', content: 'Hello' }],
    provider: {
      sort: 'price',
    },
  }),
});
```

```python
import requests

headers = {
  'Authorization': 'Bearer <OPENROUTER_API_KEY>',
  'HTTP-Referer': '<YOUR_SITE_URL>',
  'X-Title': '<YOUR_SITE_NAME>',
  'Content-Type': 'application/json',
}

response = requests.post('https://openrouter.ai/api/v1/chat/completions', headers=headers, json={
  'model': 'meta-llama/llama-3.1-70b-instruct',
  'messages': [{ 'role': 'user', 'content': 'Hello' }],
  'provider': {
    'sort': 'price',
  },
})
```

--------------------------------

### List API Keys - Standalone Function

Source: https://openrouter.ai/docs/sdks/typescript/apikeys.mdx

Provides a standalone function example for listing API keys using the OpenRouter SDK's core functionality. This method is optimized for tree-shaking and includes error handling for the API call. It requires an instance of `OpenRouterCore`.

```typescript
import { OpenRouterCore } from "@openrouter/sdk/core.js";
import { apiKeysList } from "@openrouter/sdk/funcs/apiKeysList.js";

// Use `OpenRouterCore` for best tree-shaking performance.
// You can create one instance of it to use across an application.
const openRouter = new OpenRouterCore({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const res = await apiKeysList(openRouter);
  if (res.ok) {
    const { value: result } = res;
    console.log(result);
  } else {
    console.log("apiKeysList failed:", res.error);
  }
}

run();
```

--------------------------------

### Implement List Models Endpoint - JSON Response

Source: https://openrouter.ai/docs/use-cases/for-providers.mdx

This endpoint returns a list of all available models on the provider's platform in JSON format, required for integration with OpenRouter. The response includes required fields such as model ID, name, pricing (in USD strings), modalities, and supported features, with optional metadata like descriptions and datacenters. Note that comments are illustrative; valid JSON must exclude them, and pricing must avoid floating-point precision issues.

```json
{
  "data": [
    {
      // Required
      "id": "anthropic/claude-sonnet-4",
      "hugging_face_id": "", // required if the model is on Hugging Face
      "name": "Anthropic: Claude Sonnet 4",
      "created": 1690502400,
      "input_modalities": ["text", "image", "file"],
      "output_modalities": ["text", "image", "file"],
      "quantization": "fp8",
      "context_length": 1000000,
      "max_output_length": 128000,
      "pricing": {
        "prompt": "0.000008", // pricing per 1 token
        "completion": "0.000024", // pricing per 1 token
        "image": "0", // pricing per 1 image
        "request": "0", // pricing per 1 request
        "input_cache_reads": "0", // pricing per 1 token
        "input_cache_writes": "0" // pricing per 1 token
      },
      "supported_sampling_parameters": ["temperature", "stop"],
      "supported_features": [
        "tools",
        "json_mode",
        "structured_outputs",
        "web_search",
        "reasoning"
      ],
      // Optional
      "description": "Anthropic's flagship model...",
      "openrouter": {
        "slug": "anthropic/claude-sonnet-4"
      },
      "datacenters": [
        {
          "country_code": "US" // `Iso3166Alpha2Code`
        }
      ]
    }
  ]
}
```

--------------------------------

### OpenRouter Responses API Beta - Overview

Source: https://context7_llms

Information about the beta version of OpenRouter's OpenAI-compatible Responses API, featuring a stateless transformation layer with support for reasoning, tool calling, and web search.

```APIDOC
## Responses API Beta - Overview

### Description
This document introduces the beta version of OpenRouter's OpenAI-compatible Responses API. This stateless transformation layer supports advanced features like reasoning, tool calling, and web search.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A

### Further Reading
- [Basic Usage](https://openrouter.ai/docs/api-reference/responses-api/basic-usage.mdx)
- [Reasoning](https://openrouter.ai/docs/api-reference/responses-api/reasoning.mdx)
- [Tool Calling](https://openrouter.ai/docs/api-reference/responses-api/tool-calling.mdx)
- [Web Search](https://openrouter.ai/docs/api-reference/responses-api/web-search.mdx)
- [Error Handling](https://openrouter.ai/docs/api-reference/responses-api/error-handling.mdx)
```

--------------------------------

### Get Generation Response using C# SDK

Source: https://openrouter.ai/docs/api-reference/generations/get-generation.mdx

This C# code demonstrates fetching generation data from the OpenRouter API using the RestSharp library. It sets up a GET request, adds the `Authorization` header with a Bearer token, executes the request, and captures the response.

```csharp
var client = new RestClient("https://openrouter.ai/api/v1/generation?id=id");
var request = new RestRequest(Method.GET);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);
```

--------------------------------

### OpenRouter TypeScript SDK

Source: https://context7_llms

A complete guide to using the OpenRouter TypeScript SDK for integrating AI models into your TypeScript applications.

```APIDOC
## TypeScript SDK

### Description
This is a comprehensive guide to using the OpenRouter TypeScript SDK. It provides instructions on how to integrate various AI models into your TypeScript applications.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A

### SDK Methods Documentation
- [Analytics](https://openrouter.ai/docs/sdks/typescript/analytics.mdx)
- [APIKeys](https://openrouter.ai/docs/sdks/typescript/apikeys.mdx)
- [Chat](https://openrouter.ai/docs/sdks/typescript/chat.mdx)
- [Completions](https://openrouter.ai/docs/sdks/typescript/completions.mdx)
- [Credits](https://openrouter.ai/docs/sdks/typescript/credits.mdx)
- [Embeddings](https://openrouter.ai/docs/sdks/typescript/embeddings.mdx)
- [Endpoints](https://openrouter.ai/docs/sdks/typescript/endpoints.mdx)
- [Generations](https://openrouter.ai/docs/sdks/typescript/generations.mdx)
- [Models](https://openrouter.ai/docs/sdks/typescript/models.mdx)
```

--------------------------------

### GET /api/v1/models/count

Source: https://openrouter.ai/docs/api-reference/models/list-models-count.mdx

Retrieves the total count of available models. Requires authentication via bearer token.

```APIDOC
## GET /api/v1/models/count

### Description
Retrieves the total count of available models on the OpenRouter platform.

### Method
GET

### Endpoint
https://openrouter.ai/api/v1/models/count

### Parameters
#### Headers
- **Authorization** (string) - Required - API key as bearer token in Authorization header

### Response
#### Success Response (200)
- **data.count** (number) - The total count of available models

#### Response Example
{
  "data": {
    "count": 42
  }
}

#### Error Response (500)
- Internal Server Error
```

--------------------------------

### GET /api/v1/credits

Source: https://openrouter.ai/docs/api-reference/credits/get-credits.mdx

Retrieves the total credits purchased and used for the authenticated user. This endpoint requires an Authorization header with a bearer token.

```APIDOC
## GET /api/v1/credits

### Description
Retrieves the total credits purchased and used for the authenticated user.

### Method
GET

### Endpoint
/api/v1/credits

### Parameters
#### Header Parameters
- **Authorization** (string) - Required - API key as bearer token in Authorization header

### Request Example
```
GET https://openrouter.ai/api/v1/credits
Authorization: Bearer <token>
```

### Response
#### Success Response (200)
- **(object)** - Returns the total credits purchased and used. The specific structure of this object is defined in the OpenAPI schema but is empty in the provided details.

#### Error Responses
- **401** - Unauthorized - Authentication required or invalid credentials
- **403** - Forbidden - Only provisioning keys can fetch credits
- **500** - Internal Server Error - Unexpected server error
```

--------------------------------

### Create API Key - Go

Source: https://openrouter.ai/docs/api-reference/api-keys/create-keys.mdx

This Go code snippet demonstrates how to create a new API key using the OpenRouter.ai API. It uses the `net/http` package to send a POST request to the `/api/v1/keys` endpoint with the necessary parameters.

```Go
package main

import (
  "fmt"
  "strings"
  "net/http"
  "io"
)

func main() {

  url := "https://openrouter.ai/api/v1/keys"

  payload := strings.NewReader("{\n  "name": \"My New API Key\",\n  "limit": 50,\n  "limit_reset": \"monthly\",\n  "include_byok_in_limit": true\n}")

  req, _ := http.NewRequest("POST", url, payload)

  req.Header.Add("Authorization", "Bearer <token>")
  req.Header.Add("Content-Type", "application/json")

  res, _ := http.DefaultClient.Do(req)

  defer res.Body.Close()
  body, _ := io.ReadAll(res.Body)

  fmt.Println(res)
  fmt.Println(string(body)) 

}
```

--------------------------------

### List Providers using Go HTTP Client

Source: https://openrouter.ai/docs/api-reference/providers/list-providers.mdx

This Go code example illustrates how to fetch a list of AI providers from the OpenRouter API. It utilizes the standard Go `net/http` package, requiring an Authorization header with a bearer token.

```go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/providers"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

--------------------------------

### OpenRouter Streaming API

Source: https://context7_llms

Learn how to implement streaming responses with OpenRouter's API, including a complete guide to Server-Sent Events (SSE) and real-time model outputs.

```APIDOC
## Streaming Responses

### Description
This guide explains how to implement streaming responses with the OpenRouter API. It covers the use of Server-Sent Events (SSE) for real-time model outputs.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### OpenRouter TypeScript SDK - Endpoints

Source: https://context7_llms

Documentation for the Endpoints method of the OpenRouter TypeScript SDK, including code examples.

```APIDOC
## TypeScript SDK - Endpoints Method

### Description
This document provides API endpoint documentation for the Endpoints method within the OpenRouter TypeScript SDK. It includes code examples to guide integration.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### GET /api/v1/keys/{hash}

Source: https://openrouter.ai/docs/api-reference/api-keys/get-key.mdx

Retrieves details of a single API key using its hash identifier. Requires authentication with a valid bearer token.

```APIDOC
## GET /api/v1/keys/{hash}

### Description
Retrieves details of a single API key using its hash identifier. Requires authentication with a valid bearer token.

### Method
GET

### Endpoint
https://openrouter.ai/api/v1/keys/{hash}

### Parameters
#### Path Parameters
- **hash** (string) - Required - The hash identifier of the API key to retrieve

#### Header Parameters
- **Authorization** (string) - Required - API key as bearer token in Authorization header

### Response
#### Success Response (200)
- **data** (object) - Contains the API key details including hash, name, usage statistics, limits, and timestamps
  - **hash** (string) - The API key hash
  - **name** (string) - The API key name
  - **label** (string) - The API key label
  - **disabled** (boolean) - Whether the key is disabled
  - **limit** (number|null) - The usage limit
  - **limit_remaining** (number|null) - Remaining usage limit
  - **limit_reset** (string|null) - When the limit resets
  - **include_byok_in_limit** (boolean) - Whether BYOK usage is included in limits
  - **usage** (number) - Total usage
  - **usage_daily** (number) - Daily usage
  - **usage_weekly** (number) - Weekly usage
  - **usage_monthly** (number) - Monthly usage
  - **byok_usage** (number) - BYOK usage
  - **byok_usage_daily** (number) - Daily BYOK usage
  - **byok_usage_weekly** (number) - Weekly BYOK usage
  - **byok_usage_monthly** (number) - Monthly BYOK usage
  - **created_at** (string) - Creation timestamp
  - **updated_at** (string|null) - Last update timestamp

#### Error Responses
- **401** - Unauthorized - Missing or invalid authentication
- **404** - Not Found - API key does not exist
- **429** - Too Many Requests - Rate limit exceeded
- **500** - Internal Server Error

#### Response Example
```json
{
  "data": {
    "hash": "string",
    "name": "string",
    "label": "string",
    "disabled": false,
    "limit": 1000,
    "limit_remaining": 800,
    "limit_reset": "2023-12-01T00:00:00Z",
    "include_byok_in_limit": true,
    "usage": 200,
    "usage_daily": 50,
    "usage_weekly": 150,
    "usage_monthly": 200,
    "byok_usage": 0,
    "byok_usage_daily": 0,
    "byok_usage_weekly": 0,
    "byok_usage_monthly": 0,
    "created_at": "2023-01-01T00:00:00Z",
    "updated_at": "2023-01-01T00:00:00Z"
  }
}
```
```

--------------------------------

### Use OpenRouter API with Fetch (TypeScript)

Source: https://openrouter.ai/docs/use-cases/oauth-pkce.mdx

Shows how to make a chat completion request to the OpenRouter API using the native `fetch` API in TypeScript. It requires the obtained API key for authorization and constructs the request body with model and message details.

```typescript
fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    Authorization: `Bearer ${key}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/gpt-4o',
    messages: [
      {
        role: 'user',
        content: 'Hello!',
      },
    ],
  }),
});
```

--------------------------------

### Fetch Activity Data - Python SDK Example

Source: https://openrouter.ai/docs/api-reference/analytics/get-user-activity.mdx

This Python code snippet demonstrates how to fetch activity data from the OpenRouter AI API using the `requests` library. It requires an API token for authorization and prints the JSON response.

```python
import requests

url = "https://openrouter.ai/api/v1/activity"

headers = {"Authorization": "Bearer <token>"}

response = requests.get(url, headers=headers)

print(response.json())
```

--------------------------------

### Gemini User Message Caching Example (JSON)

Source: https://openrouter.ai/docs/features/prompt-caching.mdx

Illustrates caching a large text body within a user message for Gemini models. This is useful for providing context or reference material directly in the user's prompt that can be reused.

```json
{
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "Based on the book text below:"
        },
        {
          "type": "text",
          "text": "HUGE TEXT BODY HERE",
          "cache_control": {
            "type": "ephemeral"
          }
        },
        {
          "type": "text",
          "text": "List all main characters mentioned in the text above."
        }
      ]
    }
  ]
}
```

--------------------------------

### GET /models

Source: https://openrouter.ai/docs/sdks/typescript/models.mdx

List all available models and their properties. This endpoint returns comprehensive information about each model including metadata, capabilities, and configuration options.

```APIDOC
## GET /models

### Description
List all models and their properties

### Method
GET

### Endpoint
/models

### Parameters
#### Query Parameters
- No query parameters required

#### Request Body
- No request body required

### Request Example
```
GET /models
```

### Response
#### Success Response (200)
- **models** (array) - Array of model objects with their properties

#### Response Example
```json
{
  "models": [
    {
      "id": "openai/gpt-4",
      "name": "GPT-4",
      "description": "Advanced language model",
      "pricing": {
        "prompt": "0.03",
        "completion": "0.06"
      },
      "context_length": 8192,
      "top_provider": {
        "context_length": 8192,
        "max_completion_tokens": 4096
      }
    }
  ]
}
```

### SDK Usage Examples

#### Standard SDK Usage
```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.models.list();
  console.log(result);
}

run();
```

#### Standalone Function
```typescript
import { OpenRouterCore } from "@openrouter/sdk/core.js";
import { modelsList } from "@openrouter/sdk/funcs/modelsList.js";

const openRouter = new OpenRouterCore({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const res = await modelsList(openRouter);
  if (res.ok) {
    const { value: result } = res;
    console.log(result);
  } else {
    console.log("modelsList failed:", res.error);
  }
}

run();
```
```

--------------------------------

### Send Completion Request - C#

Source: https://openrouter.ai/docs/api-reference/completions/create-completions.mdx

This C# example utilizes the RestSharp library to create a POST request to the OpenRouter API. It defines the URL, headers, and request body, and prints the response.

```C#
var client = new RestClient("https://openrouter.ai/api/v1/completions");
var request = new RestRequest(Method.POST);
request.AddHeader("Authorization", "Bearer &lt;token&gt;");
request.AddHeader("Content-Type", "application/json");
request.AddParameter("application/json", "{\n  \"prompt\": \"string\"\n}", ParameterType.RequestBody);
IRestResponse response = client.Execute(request);
```

--------------------------------

### OpenRouter TypeScript SDK - Chat

Source: https://context7_llms

Documentation for the Chat method of the OpenRouter TypeScript SDK, including code examples.

```APIDOC
## TypeScript SDK - Chat Method

### Description
This document provides API endpoint documentation for the Chat method within the OpenRouter TypeScript SDK. It includes code examples to guide integration.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### Send Completion Request - Ruby

Source: https://openrouter.ai/docs/api-reference/completions/create-completions.mdx

This code snippet provides an example of sending a completion request to OpenRouter using Ruby and the `net/http` library. It defines the URL, headers, and payload for the POST request and prints the response body.

```Ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/completions")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Post.new(url)
request["Authorization"] = 'Bearer &lt;token&gt;'
request["Content-Type"] = 'application/json'
request.body = "{\n  \"prompt\": \"string\"\n}"

response = http.request(request)
puts response.read_body
```

--------------------------------

### Example Structured JSON Response

Source: https://openrouter.ai/docs/features/structured-outputs.mdx

This is an example of a JSON response that strictly adheres to the schema defined in the request. It contains only the fields specified as required in the schema, with correct data types and no additional properties, demonstrating the effectiveness of the `strict: true` setting in JSON Schema validation.

```json
{
  "location": "London",
  "temperature": 18,
  "conditions": "Partly cloudy with light drizzle"
}
```

--------------------------------

### Get Generation Response using Java SDK

Source: https://openrouter.ai/docs/api-reference/generations/get-generation.mdx

This Java code snippet shows how to retrieve generation details from the OpenRouter API using the Unirest library. It performs a GET request to the specified URL, setting the `Authorization` header with a Bearer token, and then retrieves the response as a String.

```java
HttpResponse<String> response = Unirest.get("https://openrouter.ai/api/v1/generation?id=id")
  .header("Authorization", "Bearer <token>")
  .asString();
```

--------------------------------

### GET /models/count

Source: https://openrouter.ai/docs/sdks/typescript/models.mdx

Get the total count of available models in the OpenRouter system. This endpoint returns a simple count value indicating how many models are currently available for use.

```APIDOC
## GET /models/count

### Description
Get total count of available models

### Method
GET

### Endpoint
/models/count

### Parameters
#### Query Parameters
- No query parameters required

#### Request Body
- No request body required

### Request Example
```
GET /models/count
```

### Response
#### Success Response (200)
- **count** (number) - Total number of available models

#### Response Example
```json
{
  "count": 150
}
```

### SDK Usage Examples

#### Standard SDK Usage
```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.models.count();
  console.log(result);
}

run();
```

#### Standalone Function
```typescript
import { OpenRouterCore } from "@openrouter/sdk/core.js";
import { modelsCount } from "@openrouter/sdk/funcs/modelsCount.js";

const openRouter = new OpenRouterCore({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const res = await modelsCount(openRouter);
  if (res.ok) {
    const { value: result } = res;
    console.log(result);
  } else {
    console.log("modelsCount failed:", res.error);
  }
}

run();
```

#### React Hooks
```tsx
import {
  useModelsCount,
  useModelsCountSuspense,
  prefetchModelsCount,
  invalidateAllModelsCount,
} from "@openrouter/sdk/react-query/modelsCount.js";
```

### Parameters

| Parameter              | Type                                                                                    | Required             | Description                                                                                                                                                                    |
| ---------------------- | --------------------------------------------------------------------------------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `options`              | RequestOptions                                                                          | :heavy_minus_sign: | Used to set various options for making HTTP requests.                                                                                                                          |
| `options.fetchOptions` | [RequestInit](https://developer.mozilla.org/en-US/docs/Web/API/Request/Request#options) | :heavy_minus_sign: | Options that are passed to the underlying HTTP request. This can be used to inject extra headers for examples. All `Request` options, except `method` and `body`, are allowed. |
| `options.retries`      | [RetryConfig](/docs/sdks/typescript/lib/retryconfig)                                    | :heavy_minus_sign: | Enables retrying HTTP requests under certain failure conditions.                                                                                                               |

### Response
**Promise<[models.ModelsCountResponse](/docs/sdks/typescript/models/modelscountresponse)>**

### Errors

| Error Type                         | Status Code | Content Type     |
| ---------------------------------- | ----------- | ---------------- |
| errors.InternalServerResponseError | 500         | application/json |
| errors.OpenRouterDefaultError      | 4XX, 5XX    | */*             |
```

--------------------------------

### GET /models/embeddings

Source: https://openrouter.ai/docs/api-reference/models/list-models-embeddings.mdx

Returns a comprehensive list of available embeddings models along with their properties. Requires a valid API key supplied in the Authorization header.

```APIDOC
## GET /models/embeddings\n\n### Description\nReturns a list of all available embeddings models and their properties.\n\n Method\nGET\n\n### Endpoint\n/models/embeddings\n\n### Parameters\n#### Path Parameters\n*None*\n\n#### Query Parameters\n*None*\n\n#### Header Parameters\n- **Authorization** (string) - Required - API key as bearer token in Authorization header.\n\n### Request Body\n*None*\n\n### Request Example\n```\nGET /models/embeddings HTTP/1.1\nAuthorization: Bearer YOUR_API_KEY\n```\n\n### Response\n#### Success Response (200\n- **models** (array) - List of embedding model objects.\n\n#### Response Example\n```json\n{\n  "models": [\n    {\n      "id": "model-id",\n      "name": "Model Name",\n      "architecture": {\n        "tokenizer": "Router",\n        "instruct_type": "none",\n        "modality": "text",\n        "input_modalities": ["text"],\n        "output_modalities": ["embeddings"]\n      },\n      "pricing": {\n        "prompt": 0.0,\n        "completion": 0.\n      }\n    }\n  ]\n}\n```
```

--------------------------------

### Get Remaining Credits - Swift

Source: https://openrouter.ai/docs/api-reference/credits/get-credits.mdx

Retrieves remaining credits using the OpenRouter.ai API with Swift. Requires an API key passed as a bearer token in the Authorization header. Returns a JSON response containing credit details.

```swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/credits")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### Get Remaining Credits - Ruby

Source: https://openrouter.ai/docs/api-reference/credits/get-credits.mdx

Retrieves remaining credits using the OpenRouter.ai API with Ruby. Requires an API key passed as a bearer token in the Authorization header. Returns a JSON response containing credit details.

```ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/credits")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = 'Bearer <token>' 

response = http.request(request)
puts response.read_body
```

--------------------------------

### Get Remaining Credits - Go

Source: https://openrouter.ai/docs/api-reference/credits/get-credits.mdx

Retrieves remaining credits using the OpenRouter.ai API with Go. Requires an API key passed as a bearer token in the Authorization header. Returns a JSON response containing credit details.

```go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/credits"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

--------------------------------

### GET /v1/generation

Source: https://openrouter.ai/docs/api-reference/generations/get-generation.mdx

Retrieves generation details, including various metadata about the generation process.

```APIDOC
## GET /v1/generation

### Description
Retrieves generation details, including various metadata about the generation process.

### Method
GET

### Endpoint
/v1/generation

### Parameters
#### Query Parameters
- **id** (string) - Required - The ID of the generation to retrieve.

#### Request Body
This endpoint does not accept a request body.

### Request Example
```
GET /v1/generation?id=id HTTP/1.1
Host: openrouter.ai
Authorization: Bearer <token>
```

### Response
#### Success Response (200)
- **data** (object) - Contains the generation details.
  - **streamed** (boolean) - Indicates if the response was streamed.
  - **cancelled** (boolean) - Indicates if the generation was cancelled.
  - **provider_name** (string) - The name of the provider.
  - **latency** (number) - The latency of the generation in milliseconds.
  - **moderation_latency** (number) - The latency of the moderation in milliseconds.
  - **generation_time** (number) - The time taken for generation in milliseconds.
  - **finish_reason** (string) - The reason for the generation finishing.
  - **tokens_prompt** (integer) - The number of tokens in the prompt.
  - **tokens_completion** (integer) - The number of tokens in the completion.
  - **native_tokens_prompt** (integer) - The number of native tokens in the prompt.
  - **native_tokens_completion** (integer) - The number of native tokens in the completion.
  - **native_tokens_completion_images** (integer) - The number of native tokens for completion images.
  - **native_tokens_reasoning** (integer) - The number of native tokens for reasoning.
  - **native_tokens_cached** (integer) - The number of native tokens cached.
  - **num_media_prompt** (integer) - The number of media items in the prompt.
  - **num_input_audio_prompt** (integer) - The number of input audio items in the prompt.
  - **num_media_completion** (integer) - The number of media items in the completion.
  - **num_search_results** (integer) - The number of search results.
  - **origin** (string) - The origin of the generation.
  - **usage** (object) - Usage details.
  - **is_byok** (boolean) - Indicates if BYOK (Bring Your Own Key) was used.
  - **native_finish_reason** (string) - The native finish reason.
  - **external_user** (string) - The external user identifier.
  - **api_type** (string) - The type of API used.

#### Response Example
```json
{
  "data": {
    "streamed": false,
    "cancelled": false,
    "provider_name": "openai",
    "latency": 1500,
    "moderation_latency": 50,
    "generation_time": 1450,
    "finish_reason": "stop",
    "tokens_prompt": 100,
    "tokens_completion": 200,
    "native_tokens_prompt": 100,
    "native_tokens_completion": 200,
    "native_tokens_completion_images": 0,
    "native_tokens_reasoning": 0,
    "native_tokens_cached": 0,
    "num_media_prompt": 0,
    "num_input_audio_prompt": 0,
    "num_media_completion": 0,
    "num_search_results": 0,
    "origin": "cache",
    "usage": {
      "prompt_tokens": 100,
      "completion_tokens": 200,
      "total_tokens": 300
    },
    "is_byok": false,
    "native_finish_reason": "stop",
    "external_user": "user_123",
    "api_type": "openai"
  }
}
```
```

--------------------------------

### Get Remaining Credits - C#

Source: https://openrouter.ai/docs/api-reference/credits/get-credits.mdx

Retrieves remaining credits using the OpenRouter.ai API with C# and the RestSharp library. Requires an API key passed as a bearer token in the Authorization header. Returns a JSON response containing credit details.

```csharp
var client = new RestClient("https://openrouter.ai/api/v1/credits");
var request = new RestRequest(Method.GET);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);
```

--------------------------------

### OpenRouter TypeScript SDK - Analytics

Source: https://context7_llms

Documentation for the Analytics method of the OpenRouter TypeScript SDK, including code examples.

```APIDOC
## TypeScript SDK - Analytics Method

### Description
This document provides API endpoint documentation for the Analytics method within the OpenRouter TypeScript SDK. It includes code examples to guide integration.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### Completions API

Source: https://context7_llms

Create text completions by sending a prompt to a model.

```APIDOC
## POST /v1/completions

### Description
Send a completion request to a model.

### Method
POST

### Endpoint
/v1/completions

### Parameters
#### Request Body
- **model** (string) - Required - The ID of the model to use for completion.
- **prompt** (string) - Required - The prompt to generate a completion for.
- **temperature** (number) - Optional - Controls randomness. Lower values make output more focused.
- **max_tokens** (integer) - Optional - The maximum number of tokens to generate.

### Request Example
```json
{
  "model": "gpt-3.5-turbo-instruct",
  "prompt": "Write a short poem about a sunrise.",
  "temperature": 0.8,
  "max_tokens": 60
}
```

### Response
#### Success Response (200)
- **id** (string) - The unique ID of the completion.
- **choices** (array) - A list of completion choices.
  - **text** (string) - The generated completion text.
  - **index** (integer) - The index of the choice.
  - **logprobs** (null) - Log probabilities (if requested).
  - **finish_reason** (string) - The reason the completion finished (e.g., "stop", "length").
- **usage** (object)
  - **prompt_tokens** (integer) - Tokens used in the prompt.
  - **completion_tokens** (integer) - Tokens generated in the completion.
  - **total_tokens** (integer) - Total tokens used.

#### Response Example
```json
{
  "id": "cmpl-12345abc",
  "choices": [
    {
      "text": "\nGolden rays begin to creep,\nAwakening the world from sleep.\nA gentle warmth, a painted sky,\nAs night's dark shadows softly fly.",
      "index": 0,
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 30,
    "total_tokens": 40
  }
}
```
```

--------------------------------

### Get Remaining Credits - PHP

Source: https://openrouter.ai/docs/api-reference/credits/get-credits.mdx

Retrieves remaining credits using the OpenRouter.ai API with PHP and the Guzzle library. Requires an API key passed as a bearer token in the Authorization header. Returns a JSON response containing credit details.

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('GET', 'https://openrouter.ai/api/v1/credits', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();

```

--------------------------------

### Get Remaining Credits - Java

Source: https://openrouter.ai/docs/api-reference/credits/get-credits.mdx

Retrieves remaining credits using the OpenRouter.ai API with Java and the Unirest library. Requires an API key passed as a bearer token in the Authorization header. Returns a JSON response containing credit details.

```java
HttpResponse<String> response = Unirest.get("https://openrouter.ai/api/v1/credits")
  .header("Authorization", "Bearer <token>")
  .asString();
```

--------------------------------

### Retrieve OpenRouter API Keys with Authentication

Source: https://openrouter.ai/docs/api-reference/api-keys/get-key.mdx

Demonstrates how to make an authenticated HTTP GET request to fetch API keys from OpenRouter. Uses Bearer token authentication and handles JSON responses. Works with various HTTP client libraries across different programming languages.

```python
import requests

url = "https://openrouter.ai/api/v1/keys/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"

headers = {"Authorization": "Bearer <token>"}

response = requests.get(url, headers=headers)

print(response.json())
```

```javascript
const url = 'https://openrouter.ai/api/v1/keys/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';
const options = {method: 'GET', headers: {Authorization: 'Bearer <token>'}};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

```go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/keys/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"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

```ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/keys/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")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = 'Bearer <token>'

response = http.request(request)
puts response.read_body
```

```java
HttpResponse<String> response = Unirest.get("https://openrouter.ai/api/v1/keys/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")
  .header("Authorization", "Bearer <token>")
  .asString();
```

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('GET', 'https://openrouter.ai/api/v1/keys/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', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();
```

```csharp
var client = new RestClient("https://openrouter.ai/api/v1/keys/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");
var request = new RestRequest(Method.GET);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);
```

```swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/keys/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")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### Get Remaining Credits - JavaScript

Source: https://openrouter.ai/docs/api-reference/credits/get-credits.mdx

Retrieves remaining credits using the OpenRouter.ai API with JavaScript and the `fetch` API.  Requires an API key passed as a bearer token in the Authorization header. Returns a JSON response containing credit details.

```javascript
const url = 'https://openrouter.ai/api/v1/credits';
const options = {method: 'GET', headers: {Authorization: 'Bearer <token>'}};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

--------------------------------

### Create API Key - JavaScript

Source: https://openrouter.ai/docs/api-reference/api-keys/create-keys.mdx

This JavaScript code snippet demonstrates how to create a new API key using the OpenRouter.ai API. It uses the `fetch` API to send a POST request to the `/api/v1/keys` endpoint with the necessary parameters. Requires a JavaScript environment that supports `async/await`.

```JavaScript
const url = 'https://openrouter.ai/api/v1/keys';
const options = {
  method: 'POST',
  headers: {Authorization: 'Bearer &lt;token&gt;', 'Content-Type': 'application/json'},
  body: '{\"name\":\"My New API Key\",\"limit\":50,\"limit_reset\":\"monthly\",\"include_byok_in_limit\":true}'
};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

--------------------------------

### GET /generation - Get Usage via Generation ID

Source: https://openrouter.ai/docs/use-cases/usage-accounting.mdx

This endpoint provides information on how to retrieve usage information asynchronously using the generation ID. It explains the process of noting the ID in the response and using it to fetch usage statistics via the `/generation` endpoint.

```APIDOC
## GET /generation

### Description
Retrieves usage information asynchronously by using the generation ID returned from API calls.

### Method
GET

### Endpoint
/generation/{generation_id}

### Parameters
#### Path Parameters
- `generation_id` (string) - Required - The ID of the generation to retrieve usage information for.

#### Query Parameters
- None

### Request Example
None (this is a GET request)

### Response
#### Success Response (200)
- (Response details not provided in the original text, but would include usage information)

#### Response Example
(Response example not provided in the original text)
```

--------------------------------

### Get Remaining Credits - Python

Source: https://openrouter.ai/docs/api-reference/credits/get-credits.mdx

Retrieves remaining credits using the OpenRouter.ai API with Python and the `requests` library.  Requires an API key passed as a bearer token in the Authorization header. Returns a JSON response containing credit details.

```python
import requests

url = "https://openrouter.ai/api/v1/credits"

headers = {"Authorization": "Bearer <token>"}

response = requests.get(url, headers=headers)

print(response.json())
```

--------------------------------

### OpenRouter Responses API Beta - Tool Calling

Source: https://context7_llms

Integrate function calling with support for parallel execution and complex tool interactions using OpenRouter's Responses API Beta.

```APIDOC
## Responses API Beta - Tool Calling

### Description
Learn how to integrate function calling capabilities into your applications using OpenRouter's Responses API Beta. This includes support for parallel execution and complex tool interactions.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### Force Specific Tool in API Request (TypeScript, Python)

Source: https://openrouter.ai/docs/api-reference/responses-api/tool-calling.mdx

This example shows how to make an API request to OpenRouter to force the model to use a specific tool. It includes configurations for both TypeScript and Python, setting the 'tool_choice' parameter to specify the desired function. Dependencies include 'fetch' for TypeScript and 'requests' for Python. The input is a user message, and the output is expected to be a tool-use response.

```TypeScript
const response = await fetch('https://openrouter.ai/api/v1/responses', {
    method: 'POST',
    headers: {
      'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'openai/o4-mini',
      input: [
        {
          type: 'message',
          role: 'user',
          content: [
            {
              type: 'input_text',
              text: 'Hello, how are you?',
            },
          ],
        },
      ],
      tools: [weatherTool],
      tool_choice: { type: 'function', name: 'get_weather' },
      max_output_tokens: 9000,
    }),
  });
```

```Python
import requests

response = requests.post(
    'https://openrouter.ai/api/v1/responses',
    headers={
        'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
        'Content-Type': 'application/json',
    },
    json={
        'model': 'openai/o4-mini',
        'input': [
            {
                'type': 'message',
                'role': 'user',
                'content': [
                    {
                        'type': 'input_text',
                        'text': 'Hello, how are you?',
                    },
                ],
            },
        ],
        'tools': [weather_tool],
        'tool_choice': {'type': 'function', 'name': 'get_weather'},
        'max_output_tokens': 9000,
    }
)
```

--------------------------------

### GET /api/v1/models

Source: https://openrouter.ai/docs/api-reference/models/get-models.mdx

Retrieves a list of all available language models and their properties. This endpoint provides comprehensive information about each model including pricing, context limits, and capabilities.

```APIDOC
## GET /api/v1/models

### Description
Retrieves a list of all available language models and their properties from OpenRouter's LLM service. This endpoint provides comprehensive information about each model including pricing details, context window limits, and model capabilities.

### Method
GET

### Endpoint
https://openrouter.ai/api/v1/models

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

### Request Example
```
GET https://openrouter.ai/api/v1/models
```

### Response
#### Success Response (200)
- **data** (array) - Array of model objects containing model details
- **id** (string) - Unique identifier for the model
- **name** (string) - Human-readable model name
- **description** (string) - Model description and capabilities
- **context_length** (integer) - Maximum context length the model can handle
- **pricing** (object) - Pricing information for the model
  - **prompt** (string) - Cost per token for prompt input
  - **completion** (string) - Cost per token for completion output

#### Response Example
{
  "data": [
    {
      "id": "openai/gpt-3.5-turbo",
      "name": "GPT-3.5 Turbo",
      "description": "Fast and cost-effective model for most tasks",
      "context_length": 4096,
      "pricing": {
        "prompt": "0.0005",
        "completion": "0.0015"
      }
    }
  ]
}
```

--------------------------------

### Send Completion Request - Java

Source: https://openrouter.ai/docs/api-reference/completions/create-completions.mdx

This Java example uses the Unirest library to send a completion request to the OpenRouter API.  It sets appropriate headers and the request body, then extracts and prints the response as a string.

```Java
HttpResponse&lt;String&gt; response = Unirest.post("https://openrouter.ai/api/v1/completions")
  .header("Authorization", "Bearer &lt;token&gt;")
  .header("Content-Type", "application/json")
  .body("{\n  \"prompt\": \"string\"\n}")
  .asString();
```

--------------------------------

### OpenRouter TypeScript SDK - Embeddings

Source: https://context7_llms

Documentation for the Embeddings method of the OpenRouter TypeScript SDK, including code examples.

```APIDOC
## TypeScript SDK - Embeddings Method

### Description
This document provides API endpoint documentation for the Embeddings method within the OpenRouter TypeScript SDK. It includes code examples to guide integration.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### List Models (TypeScript)

Source: https://openrouter.ai/docs/sdks/typescript/models.mdx

Demonstrates how to list available models using the OpenRouter SDK in TypeScript. It initializes the OpenRouter client with an API key and then calls the `list()` method to retrieve a list of models. The result is then printed to the console.

```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.models.list();

  console.log(result);
}

run();
```

--------------------------------

### Basic Chat Completion with Reasoning - OpenAI SDK

Source: https://openrouter.ai/docs/use-cases/reasoning-tokens.mdx

Shows how to use OpenAI SDK compatibility with OpenRouter for chat completions including reasoning tokens. Demonstrates API key configuration, message formatting, and reasoning parameter usage. Returns both reasoning and content responses.

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key="{{API_KEY_REF}}",
)

response = client.chat.completions.create(
    model="{{MODEL}}",
    messages=[
        {"role": "user", "content": "How would you build the world's tallest skyscraper?"}
    ],
    extra_body={
        "reasoning": {
            "effort": "high"
        }
    },
)

msg = response.choices[0].message
print(getattr(msg, "reasoning", None))
```

--------------------------------

### Retrieve API key specification with OpenAPI (YAML)

Source: https://openrouter.ai/docs/api-reference/api-keys/get-key.mdx

Defines the OpenAPI 3.1.1 specification for the GET /keys/{hash} endpoint. Includes required path and Authorization header parameters, response schemas for success and error cases, and the data model for key details. Useful for generating client code or API documentation.

```yaml
openapi: 3.1.1
info:
  title: Get a single API key
  version: endpoint_apiKeys.getKey
paths:
  /keys/{hash}:
    get:
      operationId: get-key
      summary: Get a single API key
      tags:
        - - subpackage_apiKeys
      parameters:
        - name: hash
          in: path
          description: The hash identifier of the API key to retrieve
          required: true
          schema:
            type: string
        - name: Authorization
          in: header
          description: API key as bearer in Authorization header
          required: true
          schema:
            type: string
      responses:
        '200':
          description: API key details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/API Keys_getKey_Response_200'
        '401':
          description: Unauthorized - Missing or invalid authentication
          content: {}
        '404':
          description: Not Found - API key does not exist
          content: {}
        '429':
          description: Too Many Requests - Rate limit exceeded
          content: {}
        '500':
          description: Internal Server Error
          content: {}
components:
  schemas:
    KeysHashGetResponsesContentApplicationJsonSchemaData:
      type: object
      properties:
        hash:
          type: string
        name:
          type: string
        label:
          type: string
        disabled:
          type: boolean
        limit:
          type:
            - number
            - 'null'
          format: double
        limit_remaining:
          type:
            - number
            - 'null'
          format: double
        limit_reset:
          type:
            - string
            - 'null'
        include_byok_in_limit:
          type: boolean
        usage:
          type: number
          format: double
        usage_daily:
          type: number
          format: double
        usage_weekly:
          type: number
          format: double
        usage_monthly:
          type: number
          format: double
        byok_usage:
          type: number
          format: double
        byok_usage_daily:
          type: number
          format: double
        byok_usage_weekly:
          type: number
         : double
        byok_usage_monthly:
          type: number
          format: double
        created_at:
          type: string
        updated_at:
          type:
            - string
            - 'null'
      required:
        - hash
        - name
        - label
        - disabled
        - limit
        - limit_remaining
        - limit_reset
        - include_byok_in_limit
        - usage
        - usage_daily
        - usage_weekly
        - usage_monthly
        - byok_usage
        - byok_usage_daily
        - byok_usage_weekly
        - byok_usage_monthly
        - created_at
        - updated_at
    API Keys_getKey_Response_200:
      type: object
      properties:
        data:
          $ref: >-
            #/components/schemas/KeysHashGetResponsesContentApplicationJsonSchemaData
      required:
        - data
```

--------------------------------

### GET /api/v1/endpoints/zdr

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints-zdr.mdx

Returns a list of public endpoints with metadata such as model name, context length, pricing, and status.

```APIDOC
## GET /api/v1/end/zdr\n\n### Description\nRetrieves a list of public endpoints available on OpenRouter. Returns details such as model name, context length, pricing, and other metadata.\n\n### Method\nGET\n\n### Endpoint\nhttps://openrouter.ai/api/v1/endpoints/zdr\n\n### Parameters\n#### Path Parameters\n_None_\n\n#### Query Parameters\n_None_\n\n### Request Body\n_None_\n\n### Request Example\n```\n// No request body for GET\n```\n\n### Response\n#### Success Response (200)\n- **data** (array) - List of public endpoint objects.\n\n#### Response Example\n```\n{\n  \"data\": [\    {\n      \"name\": \"example-endpoint\",\n      \"model_name\": \"gpt-4\",\n      \"context_length\": 8192,\n      \"pricing\": { /* pricing details */ },\n      \"provider_name\": \"openrouter\",\n      \"tag\": \"default\",\n      \"quantization\": { /* quantization details */ },\n      \"max_completion_tokens\": null,\n      \"max_prompt_tokens\": null,\n      \"supported_parameters\": [ /* parameter list */ ],\n      \"status\": \"0\",\n      \"uptime_last_30m\": 99.9,\n      \"supports_implicit_caching\": true\n    }\n  ]\n}\n```
```

--------------------------------

### Fetch Activity Data - JavaScript (fetch API) Example

Source: https://openrouter.ai/docs/api-reference/analytics/get-user-activity.mdx

This JavaScript code snippet shows how to retrieve activity data from the OpenRouter AI API using the `fetch` API. It includes error handling and requires a valid API token for authentication. The response is logged to the console.

```javascript
const url = 'https://openrouter.ai/api/v1/activity';
const options = {method: 'GET', headers: {Authorization: 'Bearer <token>'}};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

--------------------------------

### GET /openrouter.ai/api/v1/parameters/{author}/{slug}

Source: https://openrouter.ai/docs/api-reference/parameters/get-parameters.mdx

Retrieves supported parameters and popularity data for a specified language model. This endpoint is useful for understanding model capabilities and common usage patterns.

```APIDOC
## GET /api/v1/parameters/{author}/{slug}

### Description
Retrieves supported parameters and popularity data for a specified language model.

### Method
GET

### Endpoint
/api/v1/parameters/{author}/{slug}

### Parameters
#### Path Parameters
- **author** (string) - Required - The author or organization name of the model.
- **slug** (string) - Required - The unique identifier (slug) of the language model.

### Request Example
(No request body for GET requests)

### Response
#### Success Response (200)
- **parameters** (object) - A dictionary of supported parameters for the model.
- **popularity** (object) - Data related to the model's popularity.

#### Response Example
```json
{
  "parameters": {
    "temperature": {
      "description": "Controls randomness. Lower values make the output more deterministic.",
      "default": 0.7,
      "type": "number"
    },
    "max_tokens": {
      "description": "The maximum number of tokens to generate.",
      "default": 1024,
      "type": "integer"
    }
  },
  "popularity": {
    "total_requests": 150000,
    "monthly_requests": 30000
  }
}
```
```

--------------------------------

### Fetch OpenRouter Models using Ruby

Source: https://openrouter.ai/docs/api-reference/models/get-models.mdx

This Ruby script utilizes the `net/http` library to perform a GET request to the OpenRouter API for retrieving model information. It sets the necessary authorization header and prints the response body.

```ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/models")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = 'Bearer <token>'

response = http.request(request)
puts response.read_body
```

--------------------------------

### GET /endpoints

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints.mdx

Retrieve a list of available LLM endpoints with their details. This endpoint provides information about model capabilities, pricing, and provider information.

```APIDOC
## GET /endpoints

### Description
Retrieve a list of available LLM endpoints with their details including model capabilities, pricing, and provider information.

### Method
GET

### Endpoint
/endpoints

### Response
#### Success Response (200)
- **id** (string) - Unique identifier for the endpoint list
- **name** (string) - Name of the endpoint list
- **created** (number) - Timestamp of when the list was created

#### Response Example
{
  "id": "endpoint-list-123",
  "name": "Available LLM Endpoints",
  "created": 1698765432.0
}
```

--------------------------------

### POST /keys

Source: https://openrouter.ai/docs/sdks/typescript/apikeys.mdx

Create a new API key with specified options.

```APIDOC
## POST /keys

### Description
Create a new API key.

### Method
POST

### Endpoint
/keys

### Parameters
#### Request Body
- **name** (string) - Required - The name of the API key.

#### Query Parameters
- **options** (object) - Optional - Used to set various options for making HTTP requests.
  - **fetchOptions** ([RequestInit](https://developer.mozilla.org/en-US/docs/Web/API/Request/Request#options)) - Optional - Options that are passed to the underlying HTTP request.
  - **retries** ([RetryConfig](/docs/sdks/typescript/lib/retryconfig)) - Optional - Enables retrying HTTP requests.

### Request Example
```json
{
  "name": "My New API Key"
}
```

### Response
#### Success Response (200)
- **value** (object) - The created API key details.

#### Response Example
```json
{
  "id": "key_abcdef123456",
  "name": "My New API Key",
  "key": "sk-or-...",
  "createdAt": "2023-10-27T10:00:00Z",
  "expiresAt": null
}
```

### Errors
- **BadRequestResponseError** (400) - application/json
- **UnauthorizedResponseError** (401) - application/json
- **TooManyRequestsResponseError** (429) - application/json
- **InternalServerResponseError** (500) - application/json
- **OpenRouterDefaultError** (4XX, 5XX) - */*
```

--------------------------------

### GET /api/v1/keys/{key_hash}

Source: https://openrouter.ai/docs/features/provisioning-api-keys.mdx

Retrieve details of a specific API key by its hash identifier.

```APIDOC
## GET /api/v1/keys/{key_hash}

### Description
Get detailed information about a specific API key using its hash.

### Method
GET

### Endpoint
/api/v1/keys/{key_hash}

### Parameters
#### Path Parameters
- **key_hash** (string) - Required - The hash of the API key to retrieve

### Request Example
```bash
curl -H "Authorization: Bearer your-provisioning-key" \
     -H "Content-Type: application/json" \
     https://openrouter.ai/api/v1/keys/key-hash-1
```

### Response
#### Success Response (200)
- **id** (string) - The key hash
- **name** (string) - Key name
- **created_at** (string) - Creation timestamp
- **disabled** (boolean) - Whether the key is disabled
- **limit** (integer) - Credit limit

#### Response Example
```json
{
  "id": "key-hash-1",
  "name": "Customer Instance Key",
  "created_at": "2023-01-01T00:00:00Z",
  "disabled": false,
  "limit": 1000
}
```
```

--------------------------------

### Define and Use Multiple Tools (TypeScript & Python)

Source: https://openrouter.ai/docs/api-reference/responses-api/tool-calling.mdx

Demonstrates how to define a calculator tool and include it in an API request to the OpenRouter API. This allows the model to perform calculations as part of a complex workflow. The request body specifies the model, input, and the list of available tools.

```typescript
const calculatorTool = {
  type: 'function' as const,
  name: 'calculate',
  description: 'Perform mathematical calculations',
  strict: null,
  parameters: {
    type: 'object',
    properties: {
      expression: {
        type: 'string',
        description: 'The mathematical expression to evaluate',
      },
    },
    required: ['expression'],
  },
};

const response = await fetch('https://openrouter.ai/api/v1/responses', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/o4-mini',
    input: [
      {
        type: 'message',
        role: 'user',
        content: [
          {
            type: 'input_text',
            text: 'What is 25 * 4?',
          },
        ],
      },
    ],
    tools: [weatherTool, calculatorTool],
    tool_choice: 'auto',
    max_output_tokens: 9000,
  }),
});
```

```python
calculator_tool = {
    'type': 'function',
    'name': 'calculate',
    'description': 'Perform mathematical calculations',
    'strict': None,
    'parameters': {
        'type': 'object',
        'properties': {
            'expression': {
                'type': 'string',
                'description': 'The mathematical expression to evaluate',
            },
        },
        'required': ['expression'],
    },
}

response = requests.post(
    'https://openrouter.ai/api/v1/responses',
    headers={
        'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
        'Content-Type': 'application/json',
    },
    json={
        'model': 'openai/o4-mini',
        'input': [
            {
                'type': 'message',
                'role': 'user',
                'content': [
                    {
                        'type': 'input_text',
                        'text': 'What is 25 * 4?',
                    },
                ],
            },
        ],
        'tools': [weather_tool, calculator_tool],
        'tool_choice': 'auto',
        'max_output_tokens': 9000,
    }
)
```

--------------------------------

### List Providers using OpenRouter SDK (TypeScript)

Source: https://openrouter.ai/docs/sdks/typescript/providers.mdx

Demonstrates how to list all available providers using the main OpenRouter SDK client. This method requires an API key and returns a promise that resolves to the list of providers.

```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.providers.list();

  console.log(result);
}

run();
```

--------------------------------

### Fetch OpenRouter Models using Python

Source: https://openrouter.ai/docs/api-reference/models/get-models.mdx

This Python script uses the `requests` library to make a GET request to the OpenRouter API to fetch a list of available models. It requires an API token for authorization and prints the JSON response.

```python
import requests

url = "https://openrouter.ai/api/v1/models"

headers = {"Authorization": "Bearer <token>"}

response = requests.get(url, headers=headers)

print(response.json())
```

--------------------------------

### Include Reasoning in Multi-Turn Conversations - OpenRouter API

Source: https://openrouter.ai/docs/api-reference/responses-api/reasoning.mdx

This example shows a POST request to the /api/v1/responses endpoint to continue a conversation with high-effort reasoning enabled. It requires an OpenRouter API key for authentication, a specified model like openai/o4-mini, and a message history array. The input includes user and assistant messages; outputs a JSON response with the new assistant message. Limitations include token limits and model availability.

```typescript
const response = await fetch('https://openrouter.ai/api/v1/responses', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/o4-mini',
    input: [
      {
        type: 'message',
        role: 'user',
        content: [
          {
            type: 'input_text',
            text: 'What is your favorite color?',
          },
        ],
      },
      {
        type: 'message',
        role: 'assistant',
        id: 'msg_abc123',
        status: 'completed',
        content: [
          {
            type: 'output_text',
            text: "I don't have a favorite color.",
            annotations: []
          }
        ]
      },
      {
        type: 'message',
        role: 'user',
        content: [
          {
            type: 'input_text',
            text: 'How many Earths can fit on Mars?',
          },
        ],
      },
    ],
    reasoning: {
      effort: 'high'
    },
    max_output_tokens: 9000,
  }),
});

const result = await response.json();
console.log(result);
```

```python
import requests

response = requests.post(
    'https://openrouter.ai/api/v1/responses',
    headers={
        'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
        'Content-Type': 'application/json',
    },
    json={
        'model': 'openai/o4-mini',
        'input': [
            {
                'type': 'message',
                'role': 'user',
                'content': [
                    {
                        'type': 'input_text',
                        'text': 'What is your favorite color?',
                    },
                ],
            },
            {
                'type': 'message',
                'role': 'assistant',
                'id': 'msg_abc123',
                'status': 'completed',
                'content': [
                    {
                        'type': 'output_text',
                        'text': "I don't have a favorite color.",
                        'annotations': []
                    }
                ]
            },
            {
                'type': 'message',
                'role': 'user',
                'content': [
                    {
                        'type': 'input_text',
                        'text': 'How many Earths can fit on Mars?',
                    },
                ],
            },
        ],
        'reasoning': {
            'effort': 'high'
        },
        'max_output_tokens': 9000,
    }
)

result = response.json()
print(result)
```

--------------------------------

### Fulfill Charge with swapAndTransferUniswapV3Native in TypeScript

Source: https://openrouter.ai/docs/use-cases/crypto-api.mdx

This snippet demonstrates how to set up a viem client and wallet to execute a transaction for swapping and transferring native currency using Coinbase's onchain payment protocol on the Base chain. It requires viem library dependencies and a private key for the account; inputs include the charge details and ABI, outputs a fulfilled transaction. Limitations include ensuring sufficient liquidity for swaps, especially for less common ERC-20 tokens, and handling potential errors like insufficient balance or invalid signatures.

```typescript
import { createPublicClient, createWalletClient, http, parseEther } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { base } from 'viem/chains';

// The ABI for Coinbase's onchain payment protocol
const abi = [
  {
    inputs: [
      {
        internalType: 'contract IUniversalRouter',
        name: '_uniswap',
        type: 'address',
      },
      { internalType: 'contract Permit2', name: '_permit2', type: 'address' },
      { internalType: 'address', name: '_initialOperator', type: 'address' },
      {
        internalType: 'address',
        name: '_initialFeeDestination',
        type: 'address',
      },
      {
        internalType: 'contract IWrappedNativeCurrency',
        name: '_wrappedNativeCurrency',
        type: 'address',
      },
    ],
    stateMutability: 'nonpayable',
    type: 'constructor',
  },
  { inputs: [], name: 'AlreadyProcessed', type: 'error' },
  { inputs: [], name: 'ExpiredIntent', type: 'error' },
  {
    inputs: [
      { internalType: 'address', name: 'attemptedCurrency', type: 'address' },
    ],
    name: 'IncorrectCurrency',
    type: 'error',
  },
  { inputs: [], name: 'InexactTransfer', type: 'error' },
  {
    inputs: [{ internalType: 'uint256', name: 'difference', type: 'uint256' }],
    name: 'InsufficientAllowance',
    type: 'error',
  },
  {
    inputs: [{ internalType: 'uint256', name: 'difference', type: 'uint256' }],
    name: 'InsufficientBalance',
    type: 'error',
  },
  {
    inputs: [{ internalType: 'int256', name: 'difference', type: 'int256' }],
    name: 'InvalidNativeAmount',
    type: 'error',
  },
  { inputs: [], name: 'InvalidSignature', type: 'error' },
  { inputs: [], name: 'InvalidTransferDetails', type: 'error' },
  {
    inputs: [
      { internalType: 'address', name: 'recipient', type: 'address' },
      { internalType: 'uint256', name: 'amount', type: 'uint256' },
      { internalType: 'bool', name: 'isRefund', type: 'bool' },
      { internalType: 'bytes', name: 'data', type: 'bytes' },
    ],
    name: 'NativeTransferFailed',
    type: 'error',
  },
  { inputs: [], name: 'NullRecipient', type: 'error' },
  { inputs: [], name: 'OperatorNotRegistered', type: 'error' },
  { inputs: [], name: 'PermitCallFailed', type: 'error' },
  {
    inputs: [{ internalType: 'bytes', name: 'reason', type: 'bytes' }],
    name: 'SwapFailedBytes',
    type: 'error',
  },
  {
    inputs: [{ internalType: 'string', name: 'reason', type: 'string' }],
    name: 'SwapFailedString',
    type: 'error',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: 'address',
        name: 'operator',
        type: 'address',
      },
      {
        indexed: false,
        internalType: 'address',
        name: 'feeDestination',
        type: 'address',
      },
    ],
    name: 'OperatorRegistered',
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: 'address',
        name: 'operator',
        type: 'address',
      },
    ],
    name: 'OperatorUnregistered',
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: 'address',
        name: 'previousOwner',
        type: 'address',
      },
      {
        indexed: true,
        internalType: 'address',
        name: 'newOwner',
        type: 'address',
      },
    ],
    name: 'OwnershipTransferred',
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: 'address',
        name: 'account',
        type: 'address',
      },
    ],
    name: 'Paused',
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: 'address',
        name: 'operator',
        type: 'address',
      },
      { indexed: false, internalType: 'bytes16', name: 'id', type: 'bytes16' },
      {
        indexed: false,
        internalType: 'address',
        name: 'recipient',
        type: 'address',
      },
      {
        indexed: false,
        internalType: 'address',
        name: 'sender',
        type: 'address',
      },
      {
        indexed: false,

```

--------------------------------

### GET /generation

Source: https://openrouter.ai/docs/api-reference/generations/get-generation.mdx

This endpoint retrieves the request and usage metadata for a specific generation, identified by its unique `id`.

```APIDOC
## GET /generation

### Description
This endpoint retrieves the request and usage metadata for a specific generation, using its unique identifier.

### Method
GET

### Endpoint
/generation

### Parameters
#### Query Parameters
- **id** (string) - Required - The unique identifier of the generation to retrieve.

#### Header Parameters
- **Authorization** (string) - Required - Your API key, provided as a Bearer token.

### Request Example
```json
GET /generation?id=gen_abc123xyz
Authorization: Bearer YOUR_API_KEY
```

### Response
#### Success Response (200)
- **id** (string) - The unique identifier of the generation.
- **upstream_id** (string or null) - The identifier of the upstream provider, if available.
- **total_cost** (number) - The total cost of the generation request.
- **cache_discount** (number or null) - The cache discount applied, if any.
- **upstream_inference_cost** (number or null) - The cost charged by the upstream provider, if available.
- **created_at** (string) - The timestamp when the generation was created.
- **model** (string) - The name of the model used for the generation.
- **app_id** (number or null) - The application ID, if available.
- **streamed** (boolean or null) - Indicates if the generation was streamed.
- **cancelled** (boolean or null) - Indicates if the generation was cancelled.
- **provider_name** (string or null) - The name of the provider, if available.
- **latency** (number or null) - The total latency in seconds.
- **moderation_latency** (number or null) - The latency due to moderation in seconds.
- **generation_time** (number or null) - The time taken to generate the response in seconds.
- **finish_reason** (string or null) - The reason why the generation finished (e.g., 'stop', 'length').
- **tokens_prompt** (number or null) - The number of prompt tokens used.
- **tokens_completion** (number or null) - The number of completion tokens used.
- **native_tokens_prompt** (number or null) - The number of prompt tokens used by the native tokenizer.
- **native_tokens_completion** (number or null) - The number of completion tokens used by the native tokenizer.
- **native_tokens_completion_images** (number or null) - The number of image-related tokens in the completion.
- **native_tokens_reasoning** (number or null) - The number of reasoning tokens.
- **native_tokens_cached** (number or null) - The number of cached tokens.
- **num_media_prompt** (number or null) - The number of media inputs in the prompt.
- **num_input_audio_prompt** (number or null) - The number of audio inputs in the prompt.
- **num_media_completion** (number or null) - The number of media outputs in the completion.
- **num_search_results** (number or null) - The number of search results, if any.
- **origin** (string) - The origin of the request.
- **usage** (number) - The total usage associated with the generation.
- **is_byok** (boolean) - Indicates if BYOK (Bring Your Own Key) was used.
- **native_finish_reason** (string or null) - The native reason for finishing.
- **external_user** (string or null) - The external user ID, if available.
- **api_type** (string or null) - The type of API call (e.g., 'completions', 'embeddings').

#### Response Example
```json
{
  "id": "gen_abc123xyz",
  "upstream_id": "up_xyz789",
  "total_cost": 0.00123,
  "cache_discount": 0.1,
  "upstream_inference_cost": 0.001,
  "created_at": "2023-10-27T12:00:00Z",
  "model": "gpt-3.5-turbo",
  "app_id": 12345,
  "streamed": true,
  "cancelled": false,
  "provider_name": "openai",
  "latency": 0.5,
  "moderation_latency": 0.05,
  "generation_time": 0.45,
  "finish_reason": "stop",
  "tokens_prompt": 10,
  "tokens_completion": 20,
  "native_tokens_prompt": 10,
  "native_tokens_completion": 20,
  "native_tokens_completion_images": 0,
  "native_tokens_reasoning": 0,
  "native_tokens_cached": 5,
  "num_media_prompt": 0,
  "num_input_audio_prompt": 0,
  "num_media_completion": 0,
  "num_search_results": 0,
  "origin": "api",
  "usage": 0.00123,
  "is_byok": false,
  "native_finish_reason": "stop",
  "external_user": null,
  "api_type": "completions"
}
```

#### Error Responses
- **401** - Unauthorized: Authentication is required or the provided credentials are invalid.
- **402** - Payment Required: There are insufficient credits or quota to complete the request.
- **404** - Not Found: The specified generation could not be found.
- **429** - Too Many Requests: The rate limit has been exceeded.
- **500** - Internal Server Error: An unexpected error occurred on the server.
- **502** - Bad Gateway: The provider/upstream API failed.

```

--------------------------------

### GET /models/{author}/{slug}/endpoints

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints.mdx

Retrieves a list of all available endpoints for a specified model. This includes details such as pricing, model architecture, and supported modalities.

```APIDOC
## GET /models/{author}/{slug}/endpoints

### Description
Lists all endpoints for a given model, identified by the author and slug. This endpoint provides detailed information about each endpoint's capabilities and associated costs.

### Method
GET

### Endpoint
/models/{author}/{slug}/endpoints

### Parameters
#### Path Parameters
- **author** (string) - Required - The author of the model.
- **slug** (string) - Required - The unique slug identifying the model.

#### Header Parameters
- **Authorization** (string) - Required - API key as a bearer token in the `Authorization` header.

### Responses
#### Success Response (200)
- **data** (array) - A list of endpoint objects, each containing:
  - **model**: (string) - The name of the model.
  - **endpoints**: (array) - A list of available endpoints for the model.
    - **name**: (string) - The name of the endpoint.
    - **pricing**: (object) - Pricing details for the endpoint.
      - **prompt**: (number or string) - Cost per prompt token.
      - **completion**: (number or string) - Cost per completion token.
      - **request**: (number or string) - Cost per request.
      - **image**: (number or string) - Cost per image input.
      - **image_output**: (number or string) - Cost per image output.
      - **audio**: (number or string) - Cost per audio input.
      - **input_audio_cache**: (number or string) - Cost for input audio caching.
      - **web_search**: (number or string) - Cost for web search.
      - **internal_reasoning**: (number or string) - Cost for internal reasoning.
      - **input_cache_read**: (number or string) - Cost for reading from input cache.
      - **input_cache_write**: (number or string) - Cost for writing to input cache.
    - **architecture**: (object) - Details about the model's architecture.
      - **modality**: (string) - The primary modality of the model.
      - **input_modalities**: (array) - List of supported input modalities.
      - **output_modalities**: (array) - List of supported output modalities.
      - **tokenizer**: (object) - Tokenizer details (structure may vary).
      - **instruct_type**: (string) - The type of instruction tuning applied.

#### Error Response (404)
- **description**: Not Found - Model does not exist.

#### Error Response (500)
- **description**: Internal Server Error - Unexpected server error.

### Request Example
```http
GET /models/openai/gpt-3.5-turbo/endpoints
Host: openrouter.ai
Authorization: Bearer YOUR_API_KEY
```

### Response Example
```json
{
  "data": [
    {
      "model": "gpt-3.5-turbo",
      "endpoints": [
        {
          "name": "chat/completions",
          "pricing": {
            "prompt": 0.0000005,
            "completion": 0.0000015,
            "request": 0.00001,
            "image": null,
            "image_output": null,
            "audio": null,
            "input_audio_cache": null,
            "web_search": null,
            "internal_reasoning": null,
            "input_cache_read": null,
            "input_cache_write": null
          },
          "architecture": {
            "modality": "text",
            "input_modalities": ["text"],
            "output_modalities": ["text"],
            "tokenizer": {},
            "instruct_type": "chatml"
          }
        }
      ]
    }
  ]
}
```
```

--------------------------------

### GET /api/v1/generation

Source: https://openrouter.ai/docs/features/prompt-caching.mdx

Query generation details including cache usage statistics to see cost savings from prompt caching.

```APIDOC
## GET /api/v1/generation

### Description
Retrieve generation details including cache usage statistics to monitor cost savings from prompt caching.

### Method
GET

### Endpoint
/api/v1/generation

### Parameters
#### Query Parameters
- **include** (boolean) - Optional - Set to true to include cache token details in the response.

### Response
#### Success Response (200)
- **cache_discount** (number) - The cost savings from cache usage (negative for writes, positive for reads).
- **usage** (object) - Detailed token usage statistics when `include: true` is specified.

#### Response Example
{
  "cache_discount": 0.5,
  "usage": {
    "prompt_tokens": 100,
    "completion_tokens": 50,
    "total_tokens": 150
  }
}
```

--------------------------------

### GET /api/v1/models/embeddings

Source: https://openrouter.ai/docs/api-reference/models/list-models-embeddings.mdx

Retrieves a list of all available embeddings models and their associated properties. This endpoint is useful for discovering which models can be used for embedding tasks.

```APIDOC
## GET /api/v1/models/embeddings

### Description
Returns a list of all available embeddings models and their properties.

### Method
GET

### Endpoint
https://openrouter.ai/api/v1/models/embeddings

### Parameters

#### Query Parameters
This endpoint does not accept any query parameters.

### Request Example

(No request body for GET requests)

### Response
#### Success Response (200)
- **id** (string) - The unique identifier for the model.
- **name** (string) - The human-readable name of the model.
- **pricing** (object) - Pricing information for the model.
  - **free_tier** (boolean) - Indicates if the model is part of the free tier.
  - **free_tier_until** (string) - Timestamp until which the model is free (ISO 8601 format).
  - **paid_first_1m** (number) - Cost for the first 1 million tokens.
  - **paid_after_1m** (number) - Cost for tokens after the first 1 million.
- **capabilities** (array) - List of capabilities the model supports (e.g., "embeddings").

#### Response Example
```json
{
  "data": [
    {
      "id": "text-embedding-ada-002",
      "name": "text-embedding-ada-002",
      "pricing": {
        "free_tier": false,
        "paid_first_1m": 0.0001,
        "paid_after_1m": 0.0001
      },
      "capabilities": ["embeddings"]
    }
  ]
}
```
```

--------------------------------

### OpenAI SDK Chat Completion with OpenRouter (TypeScript & Python)

Source: https://openrouter.ai/docs/community/open-ai-sdk.mdx

Demonstrates how to initialize the OpenAI SDK client for OpenRouter and make a chat completion request. It covers setting the base URL, API key, and custom headers. This example is applicable for both TypeScript and Python environments.

```typescript
import OpenAI from "openai"

const openai = new OpenAI({
  baseURL: "https://openrouter.ai/api/v1",
  apiKey: "${API_KEY_REF}",
  defaultHeaders: {
    ${getHeaderLines().join('\n        ')}
  },
})

async function main() {
  const completion = await openai.chat.completions.create({
    model: "${Model.GPT_4_Omni}",
    messages: [
      { role: "user", content: "Say this is a test" }
    ],
  })

  console.log(completion.choices[0].message)
}
main();

```

```python
from openai import OpenAI
from os import getenv

# gets API Key from environment variable OPENAI_API_KEY
client = OpenAI(
  base_url="https://openrouter.ai/api/v1",
  api_key=getenv("OPENROUTER_API_KEY"),
)

completion = client.chat.completions.create(
  model="${Model.GPT_4_Omni}",
  extra_headers={
    "HTTP-Referer": "<YOUR_SITE_URL>", # Optional. Site URL for rankings on openrouter.ai.
    "X-Title": "<YOUR_SITE_NAME>", # Optional. Site title for rankings on openrouter.ai.
  },
  # pass extra_body to access OpenRouter-only arguments.
  # extra_body={
    # "models": [
      # "${Model.GPT_4_Omni}",
      # "${Model.Mixtral_8x_22B_Instruct}"
    # ]
  # },
  messages=[
    {
      "role": "user",
      "content": "Say this is a test",
    },
  ],
)
print(completion.choices[0].message.content)

```

--------------------------------

### Implement User Tracking in OpenRouter SDKs

Source: https://openrouter.ai/docs/use-cases/user-tracking.mdx

Provides code examples for integrating user tracking functionality when making API calls using the OpenRouter SDK for TypeScript and the OpenAI SDK for Python and TypeScript. It shows how to pass the 'user' parameter in chat completion requests.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '{{API_KEY_REF}}',
});

const response = await openRouter.chat.send({
  model: '{{MODEL}}',
  messages: [
    {
      role: 'user',
      content: "What's the weather like today?",
    },
  ],
  user: 'user_12345', // Your user identifier
  stream: false,
});

console.log(response.choices[0].message.content);
```

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key="{{API_KEY_REF}}",
)

response = client.chat.completions.create(
    model="{{MODEL}}",
    messages=[
        {"role": "user", "content": "What's the weather like today?"}
    ],
    user="user_12345",  # Your user identifier
)

print(response.choices[0].message.content);
```

```typescript
import OpenAI from 'openai';

const openai = new OpenAI({
  baseURL: 'https://openrouter.ai/api/v1',
  apiKey: '{{API_KEY_REF}}',
});

async function chatWithUserTracking() {
  const response = await openai.chat.completions.create({
    model: '{{MODEL}}',
    messages: [
      {
        role: 'user',
        content: "What's the weather like today?",
      },
    ],
    user: 'user_12345', // Your user identifier
  });

  console.log(response.choices[0].message.content);
}

chatWithUserTracking();
```

--------------------------------

### GET /endpoints/zdr

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints-zdr.mdx

Preview the impact of ZDR on the available endpoints. This endpoint returns a list of endpoints affected by ZDR configurations.

```APIDOC
## GET /endpoints/zdr

### Description
Preview the impact of ZDR on the available endpoints

### Method
GET

### Endpoint
/endpoints/zdr

### Parameters
#### Header Parameters
- **Authorization** (string) - Required - API key as bearer token in Authorization header

### Response
#### Success Response (200)
Returns a list of endpoints with ZDR impact information

#### Error Response (500)
Internal Server Error - Unexpected server error

### Response Example
{
  "endpoints": [
    {
      "id": "endpoint-id",
      "name": "Endpoint Name",
      "zdr_impact": "High/Medium/Low"
    }
  ]
}
```

--------------------------------

### POST /v1/chat/completions

Source: https://openrouter.ai/docs/api-reference/chat/send-chat-completion-request.mdx

This endpoint allows you to get chat completions from various LLMs via the OpenRouter API. You provide a list of messages, and the API returns a completion.

```APIDOC
## POST /v1/chat/completions

### Description
This endpoint allows you to get chat completions from various LLMs via the OpenRouter API. You provide a list of messages, and the API returns a completion.

### Method
POST

### Endpoint
https://openrouter.ai/api/v1/chat/completions

### Parameters
#### Request Body
- **messages** (array) - Required - An array of message objects, where each object has a `role` (e.g., "system", "user", "assistant") and `content` (string).

### Request Example
```json
{
  "messages": [
    {
      "role": "string",
      "content": "string"
    }
  ]
}
```

### Response
#### Success Response (200)
- **id** (string) - Unique identifier for the completion.
- **choices** (array) - An array of completion choices.
  - **index** (integer) - The index of the choice.
  - **message** (object) - The message object for this choice.
    - **role** (string) - The role of the message sender (e.g., "assistant").
    - **content** (string) - The content of the message.
  - **finish_reason** (string) - The reason the completion finished (e.g., "stop", "length").
- **created** (integer) - Timestamp of when the completion was created.
- **model** (string) - The model used for the completion.
- **usage** (object) - Token usage statistics.
  - **prompt_tokens** (integer) - Number of tokens in the prompt.
  - **completion_tokens** (integer) - Number of tokens in the completion.
  - **total_tokens** (integer) - Total tokens used.

#### Response Example
```json
{
  "id": "chatcmpl-123",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Hello! How can I help you today?"
      },
      "finish_reason": "stop"
    }
  ],
  "created": 1677652288,
  "model": "gpt-3.5-turbo",
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 20,
    "total_tokens": 30
  }
}
```
```

--------------------------------

### GET /api/keys/{hash}

Source: https://openrouter.ai/docs/sdks/typescript/apikeys.mdx

Retrieves information about a specific API key using its hash identifier.

```APIDOC
## GET /api/keys/{hash}

### Description
Retrieves detailed information about a specific API key using its hash identifier.

### Method
GET

### Endpoint
/api/keys/{hash}

### Parameters
#### Path Parameters
- **hash** (string) - Required - The hash identifier of the API key to retrieve

### Response
#### Success Response (200)
Returns the API key details including permissions and metadata

#### Error Responses
- **401 Unauthorized** - Invalid or missing API key
- **404 Not Found** - Specified API key not found
- **429 Too Many Requests** - Rate limit exceeded
- **500 Internal Server Error** - Server error
```

--------------------------------

### List Providers using Swift URLSession

Source: https://openrouter.ai/docs/api-reference/providers/list-providers.mdx

This Swift code example demonstrates fetching AI providers from the OpenRouter API using `URLSession`. It constructs an `NSMutableURLRequest` with the `Authorization` header and handles the response asynchronously.

```swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/providers")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### SSE: Mid-Stream Error Data

Source: https://openrouter.ai/docs/api-reference/errors.mdx

Example of SSE data that is generated when handling mid-stream server errors.

```text
data: {"id":"cmpl-abc123","object":"chat.completion.chunk","created":1234567890,"model":"gpt-3.5-turbo","provider":"openai","error":{"code":"server_error","message":"Provider disconnected"},"choices":[{"index":0,"delta":{"content":""},"finish_reason":"error"}]}
```

--------------------------------

### GET /providers

Source: https://openrouter.ai/docs/sdks/typescript/providers.mdx

Lists all available AI model providers supported by OpenRouter. This endpoint provides information about the different providers you can use to access various language models.

```APIDOC
## GET /providers

### Description
Lists all available AI model providers supported by OpenRouter. This endpoint provides information about the different providers you can use to access various language models.

### Method
GET

### Endpoint
/providers

### Parameters
#### Query Parameters
- **options** (RequestOptions) - Optional - Used to set various options for making HTTP requests.
  - **fetchOptions** (RequestInit) - Optional - Options that are passed to the underlying HTTP request. This can be used to inject extra headers for examples. All `Request` options, except `method` and `body`, are allowed.
  - **retries** (RetryConfig) - Optional - Enables retrying HTTP requests under certain failure conditions.

### Request Example
```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.providers.list();
  console.log(result);
}

run();
```

### Response
#### Success Response (200)
- **value** (operations.ListProvidersResponse) - An object containing a list of providers.

#### Response Example
```json
{
  "id": "openai/gpt-3.5-turbo",
  "provider": "openai",
  "name": "GPT-3.5 Turbo",
  "enabled": true,
  "supports_chat": true,
  "supports_streaming": true,
  "pricing": {
    "completion": {
      "prompt": {
        "currency": "USD",
        "unit": "1M tokens",
        "value": 0.0005
      },
      "completion": {
        "currency": "USD",
        "unit": "1M tokens",
        "value": 0.0015
      }
    }
  },
  "context_length": 16385,
  "emits_output": true
}
```

### Errors
- **errors.InternalServerResponseError** (500) - Internal server error.
- **errors.OpenRouterDefaultError** (4XX, 5XX) - Default error structure for OpenRouter API.
```

--------------------------------

### GET /api/v1/generation

Source: https://openrouter.ai/docs/api-reference/generations/get-generation.mdx

This endpoint retrieves request and usage metadata for a generation. Use it to fetch details about a specific generation request made through the OpenRouter API.

```APIDOC
## GET /api/v1/generation

### Description
Retrieve request and usage metadata for a generation.

### Method
GET

### Endpoint
https://openrouter.ai/api/v1/generation

### Parameters
#### Query Parameters
- **generation_id** (string) - Required - The unique identifier of the generation to fetch metadata for.

### Response
#### Success Response (200)
- **request** (object) - The original request data for the generation.
- **usage** (object) - Usage statistics including tokens processed and cost.

#### Response Example
{
  "request": {
    "model": "gpt-4",
    "prompt": "Hello, world!"
  },
  "usage": {
    "input_tokens": 5,
    "output_tokens": 10,
    "cost": 0.00075
  }
}
```

--------------------------------

### Complex Reasoning Example for Math/Logic (TypeScript, Python)

Source: https://openrouter.ai/docs/api-reference/responses-api/reasoning.mdx

Shows how to perform complex reasoning for mathematical or logical problems by structuring the `input` as a message array with nested content objects. The `reasoning.effort` is set to `'high'` to ensure thorough analysis. Requires HTTP request capabilities and JSON parsing.

```typescript
const response = await fetch('https://openrouter.ai/api/v1/responses', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/o4-mini',
    input: [
      {
        type: 'message',
        role: 'user',
        content: [
          {
            type: 'input_text',
            text: 'Was 1995 30 years ago? Please show your reasoning.',
          },
        ],
      },
    ],
    reasoning: {
      effort: 'high'
    },
    max_output_tokens: 9000,
  }),
});

const result = await response.json();
console.log(result);
```

```python
import requests

response = requests.post(
    'https://openrouter.ai/api/v1/responses',
    headers={
        'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
        'Content-Type': 'application/json',
    },
    json={
        'model': 'openai/o4-mini',
        'input': [
            {
                'type': 'message',
                'role': 'user',
                'content': [
                    {
                        'type': 'input_text',
                        'text': 'Was 1995 30 years ago? Please show your reasoning.',
                    },
                ],
            },
        ],
        'reasoning': {
            'effort': 'high'
        },
        'max_output_tokens': 9000,
    }
)

result = response.json()
print(result)
```

--------------------------------

### Generate SHA-256 Code Challenge for PKCE

Source: https://openrouter.ai/docs/use-cases/oauth-pkce.mdx

Generates a secure code challenge using the S256 method by hashing a code verifier with SHA-256 and then base64url encoding the result. This function leverages the Web Crypto API and requires a bundler for the Buffer API in browser environments. It takes a string input (code verifier) and returns the generated code challenge.

```typescript
import { Buffer } from 'buffer';

async function createSHA256CodeChallenge(input: string) {
  const encoder = new TextEncoder();
  const data = encoder.encode(input);
  const hash = await crypto.subtle.digest('SHA-256', data);
  return Buffer.from(hash).toString('base64url');
}

const codeVerifier = 'your-random-string';
const generatedCodeChallenge = await createSHA256CodeChallenge(codeVerifier);
```

--------------------------------

### Stream Responses with TypeScript Fetch API

Source: https://openrouter.ai/docs/api-reference/streaming.mdx

Illustrates how to implement streaming responses using the native `fetch` API in TypeScript. This example demonstrates reading the response body as a stream, decoding chunks using `TextDecoder`, and parsing SSE data to display real-time content.

```typescript
const question = 'How would you build the tallest building ever?';
const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    Authorization: `Bearer ${API_KEY_REF}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: '{{MODEL}}',
    messages: [{ role: 'user', content: question }],
    stream: true,
  }),
});

const reader = response.body?.getReader();
if (!reader) {
  throw new Error('Response body is not readable');
}

const decoder = new TextDecoder();
let buffer = '';

try {
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;

    // Append new chunk to buffer
    buffer += decoder.decode(value, { stream: true });

    // Process complete lines from buffer
    while (true) {
      const lineEnd = buffer.indexOf('\n');
      if (lineEnd === -1) break;

      const line = buffer.slice(0, lineEnd).trim();
      buffer = buffer.slice(lineEnd + 1);

      if (line.startsWith('data: ')) {
        const data = line.slice(6);
        if (data === '[DONE]') break;

        try {
          const parsed = JSON.parse(data);
          const content = parsed.choices[0].delta.content;
          if (content) {
            console.log(content);
          }
        } catch (e) {
          // Ignore invalid JSON
        }
      }
    }
  }
} finally {
  reader.cancel();
}
```

--------------------------------

### Delete API Key via HTTP DELETE in Multiple Languages

Source: https://openrouter.ai/docs/api-reference/api-keys/delete-keys.mdx

This collection provides SDK code examples for deleting an API key using HTTP DELETE requests in various programming languages. Each example relies on standard HTTP libraries like requests in Python or fetch in JavaScript, with dependencies on internet connectivity and valid API tokens. Inputs are the endpoint URL and Bearer token; outputs include response objects or errors, limited by potential rate limits or network issues.

```python
import requests

url = "https://openrouter.ai/api/v1/keys/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"

headers = {"Authorization": "Bearer <token>"}

response = requests.delete(url, headers=headers)

print(response.json())
```

```javascript
const url = 'https://openrouter.ai/api/v1/keys/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';
const options = {method: 'DELETE', headers: {Authorization: 'Bearer <token>'}};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

```go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/keys/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"

	req, _ := http.NewRequest("DELETE", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

```ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/keys/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")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Delete.new(url)
request["Authorization"] = 'Bearer <token>'

response = http.request(request)
puts response.read_body
```

```java
HttpResponse<String> response = Unirest.delete("https://openrouter.ai/api/v1/keys/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")
  .header("Authorization", "Bearer <token>")
  .asString();
```

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('DELETE', 'https://openrouter.ai/api/v1/keys/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', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();

```

```csharp
var client = new RestClient("https://openrouter.ai/api/v1/keys/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");
var request = new RestRequest(Method.DELETE);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);
```

```swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/keys/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")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "DELETE"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### GET /v1/models

Source: https://openrouter.ai/docs/overview/models.mdx

Retrieves a list of all available language models. The response includes detailed metadata for each model, such as its ID, name, description, context length, supported parameters, pricing, and provider information.

```APIDOC
## GET /v1/models

### Description
Retrieves a list of all available language models. The response includes detailed metadata for each model, such as its ID, name, description, context length, supported parameters, pricing, and provider information.

### Method
GET

### Endpoint
/v1/models

### Parameters
#### Query Parameters
- **use_rss** (boolean) - Optional - If true, returns an RSS feed of new models.

### Request Example
```json
{
  "example": "GET /v1/models"
}
```

### Response
#### Success Response (200)
- **data** (array) - An array of Model objects, each containing detailed information about an LLM.

#### Model Object Schema
- **id** (string) - Unique model identifier.
- **canonical_slug** (string) - Permanent slug for the model.
- **name** (string) - Human-readable display name.
- **created** (number) - Unix timestamp of when the model was added.
- **description** (string) - Detailed description of the model's capabilities.
- **context_length** (number) - Maximum context window size in tokens.
- **architecture** (object) - Object describing the model's technical capabilities.
  - **input_modalities** (string[]) - Supported input types (e.g., ["file", "image", "text"]).
  - **output_modalities** (string[]) - Supported output types (e.g., ["text"]).
  - **tokenizer** (string) - Tokenization method used.
  - **instruct_type** (string | null) - Instruction format type.
- **pricing** (object) - Lowest price structure for using this model (USD per token/request/unit).
  - **prompt** (string) - Cost per input token.
  - **completion** (string) - Cost per output token.
  - **request** (string) - Fixed cost per API request.
  - **image** (string) - Cost per image input.
  - **web_search** (string) - Cost per web search operation.
  - **internal_reasoning** (string) - Cost for internal reasoning tokens.
  - **input_cache_read** (string) - Cost per cached input token read.
  - **input_cache_write** (string) - Cost per cached input token write.
- **top_provider** (object) - Configuration details for the primary provider.
  - **context_length** (number) - Provider-specific context limit.
  - **max_completion_tokens** (number) - Maximum tokens in response.
  - **is_moderated** (boolean) - Whether content moderation is applied.
- **per_request_limits** (object | null) - Rate limiting information.
- **supported_parameters** (string[]) - Array of supported API parameters for this model.

#### Response Example
```json
{
  "data": [
    {
      "id": "google/gemini-2.5-pro-preview",
      "canonical_slug": "gemini-2-5-pro-preview",
      "name": "Gemini 2.5 Pro Preview",
      "created": 1710260000,
      "description": "Google's latest flagship multimodal model, offering a massive 1 million token context window and advanced reasoning capabilities.",
      "context_length": 1048576,
      "architecture": {
        "input_modalities": ["image", "text"],
        "output_modalities": ["text"],
        "tokenizer": "google/gemini",
        "instruct_type": "gemini"
      },
      "pricing": {
        "prompt": "0.000005",
        "completion": "0.000015",
        "request": "0.00",
        "image": "0.00015",
        "web_search": "0.00",
        "internal_reasoning": "0.00",
        "input_cache_read": "0.00",
        "input_cache_write": "0.00"
      },
      "top_provider": {
        "context_length": 1048576,
        "max_completion_tokens": 8192,
        "is_moderated": true
      },
      "per_request_limits": null,
      "supported_parameters": [
        "temperature",
        "top_p",
        "top_k",
        "max_tokens",
        "stop",
        "tools"
      ]
    }
    /* ... more models */
  ]
}
```
```

--------------------------------

### GET /models

Source: https://openrouter.ai/docs/sdks/typescript/models.mdx

Retrieves a list of all available language models and their properties. This endpoint is useful for discovering which models are available for use with the API.

```APIDOC
## GET /models

### Description
Retrieves a list of all available language models and their properties. This endpoint is useful for discovering which models are available for use with the API.

### Method
GET

### Endpoint
/models

### Parameters
#### Query Parameters

#### Request Body

### Request Example
```json
{
  "example": "request body"
}
```

### Response
#### Success Response (200)
- **models** (array) - A list of model objects, each containing details like ID, owner, and capabilities.

#### Response Example
```json
{
  "example": "[\n  {\n    \"id\": \"openai/gpt-4\",\n    \"name\": \"GPT-4\",\n    \"vendor\": \"OpenAI\",\n    \"description\": \"The latest GPT-4 model from OpenAI.\",\n    \"logo_url\": \"https://openrouter.ai/api/v1/vendor/openai.png\",\n    \"created_at\": \"2023-04-19T21:00:00Z\",\n    \"updated_at\": \"2023-04-19T21:00:00Z\",\n    \"max_tokens\": 8192,\n    \"example_prompt\": \"What is the weather like in Paris?\",\n    \"is_private\": false,\n    \"is_deprecated\": false,\n    \"num_tokens\": {\n      \"prompt\": 3072,\n      \"completion\": 4096\n    }\n  }\n]"
}
```

### Errors
#### Error Response (400)
- **code** (string) - Error code
- **message** (string) - Error message

#### Error Response (500)
- **code** (string) - Error code
- **message** (string) - Error message
```

--------------------------------

### Create API Key - Ruby

Source: https://openrouter.ai/docs/api-reference/api-keys/create-keys.mdx

This Ruby code snippet demonstrates how to create a new API key using the OpenRouter.ai API. It uses the `Net::HTTP` library to send a POST request to the `/api/v1/keys` endpoint with the necessary parameters.

```Ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/keys")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Post.new(url)
request["Authorization"] = 'Bearer <token>'
request["Content-Type"] = 'application/json'
request.body = "{\n  "name": \"My New API Key\",\n  "limit": 50,\n  "limit_reset": \"monthly\",\n  "include_byok_in_limit": true\n}"

response = http.request(request)
puts response.read_body
```

--------------------------------

### List Model Endpoints using Go HTTP Client

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints.mdx

Demonstrates how to call the OpenRouter AI API to list model endpoints using Go's standard net/http package. This code sends a GET request with an Authorization header and prints the response body.

```go
package main

import (
	"fmt"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/models/author/slug/endpoints"

	req, _ := http.NewRequest("GET", url, nil)

	req.Header.Add("Authorization", "Bearer <token>")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

--------------------------------

### Streaming Tool Calls with Fetch/Requests

Source: https://openrouter.ai/docs/api-reference/responses-api/tool-calling.mdx

This code streams responses from the OpenRouter AI API to monitor tool calls in real-time, parsing JSON chunks for function call events and arguments. It requires an API key and libraries like fetch (TypeScript) or requests (Python) for HTTP operations, with inputs as a user message and tools, and outputs as logged call details. Limitations include handling invalid JSON gracefully and dependency on streaming support from the API.

```typescript
const response = await fetch('https://openrouter.ai/api/v1/responses', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/o4-mini',
    input: [
      {
        type: 'message',
        role: 'user',
        content: [
          {
            type: 'input_text',
            text: 'What is the weather like in Tokyo, Japan? Please check the weather.',
          },
        ],
      },
    ],
    tools: [weatherTool],
    tool_choice: 'auto',
    stream: true,
    max_output_tokens: 9000,
  }),
});

const reader = response.body?.getReader();
const decoder = new TextDecoder();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;

  const chunk = decoder.decode(value);
  const lines = chunk.split('\n');

  for (const line of lines) {
    if (line.startsWith('data: ')) {
      const data = line.slice(6);
      if (data === '[DONE]') return;

      try {
        const parsed = JSON.parse(data);
        if (parsed.type === 'response.output_item.added' &&
            parsed.item?.type === 'function_call') {
          console.log('Function call:', parsed.item.name);
        }
        if (parsed.type === 'response.function_call_arguments.done') {
          console.log('Arguments:', parsed.arguments);
        }
      } catch (e) {
        // Skip invalid JSON
      }
    }
  }
}
```

```python
import requests
import json

response = requests.post(
    'https://openrouter.ai/api/v1/responses',
    headers={
        'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
        'Content-Type': 'application/json',
    },
    json={
        'model': 'openai/o4-mini',
        'input': [
            {
                'type': 'message',
                'role': 'user',
                'content': [
                    {
                        'type': 'input_text',
                        'text': 'What is the weather like in Tokyo, Japan? Please check the weather.',
                    },
                ],
            },
        ],
        'tools': [weather_tool],
        'tool_choice': 'auto',
        'stream': True,
        'max_output_tokens': 9000,
    },
    stream=True
)

for line in response.iter_lines():
    if line:
        line_str = line.decode('utf-8')
        if line_str.startswith('data: '):
            data = line_str[6:]
            if data == '[DONE]':
                break
            try:
                parsed = json.loads(data)
                if (parsed.get('type') == 'response.output_item.added' and
                    parsed.get('item', {}).get('type') == 'function_call'):
                    print(f"Function call: {parsed['item']['name']}")
                if parsed.get('type') == 'response.function_call_arguments.done':
                    print(f"Arguments: {parsed.get('arguments', '')}")
            except json.JSONDecodeError:
                continue
```

--------------------------------

### GET /parameters/{author}/{slug}

Source: https://openrouter.ai/docs/api-reference/parameters/get-parameters.mdx

Retrieves the supported parameters for a specified model along with data about which parameters are most popular among users. Requires authentication and model identification through path parameters.

```APIDOC
## GET /parameters/{author}/{slug}

### Description
Returns the parameters supported by the specified model and data about which parameters are most popular among users.

### Method
GET

### Endpoint
/parameters/{author}/{slug}

### Parameters
#### Path Parameters
- **author** (string) - Required - The author/organization name of the model
- **slug** (string) - Required - The model identifier slug

#### Query Parameters
- **provider** (string) - Optional - Filter results by specific provider (AI21, AionLabs, Alibaba, Amazon Bedrock, Anthropic, AtlasCloud, Atoma, Avian, Azure, BaseTen, Cerebras, Chutes, Cirrascale, Clarifai, Cloudflare, Cohere, CrofAI, Crusoe, DeepInfra, DeepSeek, Enfer, Featherless, Fireworks, Friendli, GMICloud, Google, Google AI Studio, Groq, Hyperbolic, Inception, InferenceNet, Infermatic, Inflection, Kluster, Lambda, Liquid, Mancer 2, Meta, Minimax, ModelRun, Mistral, Modular, Moonshot AI, Morph, NCompass, Nebius, NextBit, Nineteen, Novita, Nvidia, OpenAI, OpenInference, Parasail, Perplexity, Phala, Relace, SambaNova, SiliconFlow, Stealth, Switchpoint, Targon, Together, Ubicloud, Venice, WandB, xAI, Z.AI, FakeProvider)

#### Header Parameters
- **Authorization** (string) - Required - API key as bearer token in Authorization header

### Request Example
No request body required for GET request.

### Response
#### Success Response (200)
- **data** (object) - Response object containing model information
  - **model** (string) - The model identifier
  - **supported_parameters** (array) - Array of supported parameter names

#### Response Example
```json
{
  "data": {
    "model": "anthropic/claude-3-sonnet",
    "supported_parameters": [
      "temperature",
      "top_p",
      "max_tokens",
      "stop"
    ]
  }
}
```

#### Error Responses
- **401** - Unauthorized - Authentication required or invalid credentials
- **404** - Not Found - Model or provider does not exist
- **500** - Internal Server Error - Unexpected server error
```

--------------------------------

### GET /models

Source: https://openrouter.ai/docs/api-reference/models/list-models-embeddings.mdx

Retrieves a list of available language models supported by the OpenRouter AI API. This endpoint provides detailed information about each model, including its ID, name, pricing, context length, and supported parameters.

```APIDOC
## GET /models

### Description
Retrieves a list of available language models supported by the OpenRouter AI API. This endpoint provides detailed information about each model, including its ID, name, pricing, context length, and supported parameters.

### Method
GET

### Endpoint
/models

### Parameters
None

### Request Example
None

### Response
#### Success Response (200)
- **data** (array) - An array of model objects.
  - **id** (string) - The unique identifier for the model.
  - **canonical_slug** (string) - A canonical slug for the model.
  - **hugging_face_id** (string | null) - The Hugging Face model ID, if available.
  - **name** (string) - The display name of the model.
  - **created** (number) - The creation timestamp of the model.
  - **description** (string) - A brief description of the model.
  - **pricing** (object) - Pricing information for the model.
  - **context_length** (number | null) - The maximum context length for the model.
  - **architecture** (object) - Information about the model's architecture.
  - **top_provider** (object) - Information about the top provider for the model.
  - **per_request_limits** (object) - Per-request limits for the model.
  - **supported_parameters** (array) - A list of supported parameters for the model.
  - **default_parameters** (object) - Default parameters for the model.

#### Response Example
```json
{
  "data": [
    {
      "id": "openai/gpt-3.5-turbo",
      "canonical_slug": "gpt-3-5-turbo",
      "hugging_face_id": null,
      "name": "GPT-3.5 Turbo",
      "created": 1677610602,
      "description": "The latest flagship model from OpenAI, optimized for chat.",
      "pricing": {
        "completion": {
          "prompt": 0.0000015,
          "completion": 0.000002
        },
        "embedding": {
          "prompt": 0.0001,
          "completion": 0.0001
        }
      },
      "context_length": 16385,
      "architecture": {
        "type": "transformer"
      },
      "top_provider": {
        "name": "OpenAI"
      },
      "per_request_limits": {
        "total": 1000,
        "rpm": 100,
        "tpm": 100000
      },
      "supported_parameters": [
        { "name": "temperature" },
        { "name": "top_p" },
        { "name": "frequency_penalty" },
        { "name": "presence_penalty" },
        { "name": "max_tokens" },
        { "name": "stop" },
        { "name": "top_logprobs" },
        { "name": "logit_bias" },
        { "name": "response_format" },
        { "name": "seed" },
        { "name": "logprobs" },
        { "name": "tools" },
        { "name": "tool_choice" },
        { "name": "parallel_tool_calls" },
        { "name": "structured_outputs" },
        { "name": "response_format" },
        { "name": "web_search_options" },
        { "name": "include_reasoning" },
        { "name": "reasoning" },
        { "name": "verbosity" }
      ],
      "default_parameters": {
        "temperature": 0.7,
        "top_p": 1.0,
        "frequency_penalty": 0.0
      }
    }
  ]
}
```
```

--------------------------------

### User Tracking API Request Example

Source: https://openrouter.ai/docs/use-cases/user-tracking.mdx

Demonstrates the structure of an OpenRouter API request including the 'user' parameter for tracking specific end-users. This parameter is optional and accepts a string identifier.

```json
{
  "model": "openai/gpt-4o",
  "messages": [
    {"role": "user", "content": "Hello, how are you?"}
  ],
  "user": "user_12345"
}
```

--------------------------------

### List Endpoints - React Query Hooks TypeScript

Source: https://openrouter.ai/docs/sdks/typescript/endpoints.mdx

Illustrates how to integrate endpoint listing functionality into React applications using React Query hooks provided by the OpenRouter SDK. It includes examples for `useEndpointsList`, `useEndpointsListSuspense`, and utilities for prefetching and cache invalidation.

```typescript
import {
  // Query hooks for fetching data.
  useEndpointsList,
  useEndpointsListSuspense,

  // Utility for prefetching data during server-side rendering and in React
  // Server Components that will be immediately available to client components
  // using the hooks.
  prefetchEndpointsList,
  
  // Utilities to invalidate the query cache for this query in response to
  // mutations and other user actions.
  invalidateEndpointsList,
  invalidateAllEndpointsList,
} from "@openrouter/sdk/react-query/endpointsList.js";
```

--------------------------------

### POST /api/v1/responses

Source: https://openrouter.ai/docs/api-reference/responses-api/tool-calling.mdx

Submit a request to the Responses API with tool calling capabilities. Allows models to call functions and execute tools based on user input.

```APIDOC
## POST /api/v1/responses

### Description
Submit a request to the Responses API with tool calling capabilities. Allows models to call functions and execute tools based on user input.

### Method
POST

### Endpoint
https://openrouter.ai/api/v1/responses

### Parameters
#### Header Parameters
- **Authorization** (string) - Required - Bearer token with your OpenRouter API key
- **Content-Type** (string) - Required - Must be 'application/json'

#### Request Body
- **model** (string) - Required - The model to use for generation
- **input** (array) - Required - Array of input messages
- **tools** (array) - Optional - Array of tool definitions in OpenAI function format
- **tool_choice** (string/object) - Optional - Controls tool calling behavior ('auto', 'none', or forced tool)
- **max_output_tokens** (integer) - Optional - Maximum number of tokens in the output

### Request Example
{
  "model": "openai/o4-mini",
  "input": [
    {
      "type": "message",
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "What is the weather in San Francisco?"
        }
      ]
    }
  ],
  "tools": [
    {
      "type": "function",
      "name": "get_weather",
      "description": "Get the current weather in a location",
      "strict": null,
      "parameters": {
        "type": "object",
        "properties": {
          "location": {
            "type": "string",
            "description": "The city and state, e.g. San Francisco, CA"
          },
          "unit": {
            "type": "string",
            "enum": ["celsius", "fahrenheit"]
          }
        },
        "required": ["location"]
      }
    }
  ],
  "tool_choice": "auto",
  "max_output_tokens": 9000
}

### Response
#### Success Response (200)
- **id** (string) - Unique identifier for the response
- **model** (string) - The model used for generation
- **choices** (array) - Array of generated choices
- **usage** (object) - Token usage information

#### Response Example
{
  "id": "response-id-123",
  "model": "openai/o4-mini",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "I'll check the weather in San Francisco for you."
      }
    }
  ],
  "usage": {
    "prompt_tokens": 25,
    "completion_tokens": 10,
    "total_tokens": 35
  }
}
```

--------------------------------

### GET /models/user

Source: https://openrouter.ai/docs/api-reference/models/list-models-user.mdx

Retrieves a list of available models filtered according to the user's provider preferences. The request must include an Authorization header with a bearer token.

```APIDOC
## GET /models/user

### Description
Retrieves a list of models filtered by the user's provider preferences.

### Method
GET

### Endpoint
/models/user

### Parameters
#### Path Parameters
*(none)*

#### Query Parameters
*(none)*

#### Request Body
*(none)*

### Request Example
{
  "Authorization": "Bearer <API_KEY>"
}

### Response
#### Success Response (200)
- **models** (array) - List of model objects matching the filter criteria.

#### Response Example
{
  "models": [
    {
      "id": "gpt-4",
      "name": "GPT-4",
      "provider": "OpenAI",
      "pricing": {
        "prompt": 0.03,
        "completion": 0.06
      }
    }
  ]
}

### Error Responses
- **401** Unauthorized - Missing or invalid authentication.
- **500** Internal Server Error - Unexpected server error.
```

--------------------------------

### Inference Request with Tool Results (JSON)

Source: https://openrouter.ai/docs/features/tool-calling.mdx

This JSON example demonstrates how to send tool execution results back to the model. It includes the original user message, the assistant's tool call, and the tool's response. The tools parameter must be repeated to validate the schema.

```json
{
  "model": "google/gemini-2.0-flash-001",
  "messages": [
    {
      "role": "user",
      "content": "What are the titles of some James Joyce books?"
    },
    {
      "role": "assistant",
      "content": null,
      "tool_calls": [
        {
          "id": "call_abc123",
          "type": "function",
          "function": {
            "name": "search_gutenberg_books",
            "arguments": "{\"search_terms\": [\"James\", \"Joyce\"]}"
          }
        }
      ]
    },
    {
      "role": "tool",
      "tool_call_id": "call_abc123",
      "content": "[{\"id\": 4300, \"title\": \"Ulysses\", \"authors\": [{\"name\": \"Joyce, James\"}]}]"
    }
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "search_gutenberg_books",
        "description": "Search for books in the Project Gutenberg library",
        "parameters": {
          "type": "object",
          "properties": {
            "search_terms": {
              "type": "array",
              "items": {"type": "string"},
              "description": "List of search terms to find books"
            }
          },
          "required": ["search_terms"]
        }
      }
    }
  ]
}
```

--------------------------------

### Fetch OpenRouter Models using Java (Unirest)

Source: https://openrouter.ai/docs/api-reference/models/get-models.mdx

This Java snippet uses the Unirest library to make a GET request to the OpenRouter API to fetch models. It includes setting the authorization header and retrieves the response as a string. Ensure Unirest is added as a dependency.

```java
HttpResponse<String> response = Unirest.get("https://openrouter.ai/api/v1/models")
  .header("Authorization", "Bearer <token>")
  .asString();
```

--------------------------------

### POST /completions

Source: https://openrouter.ai/docs/api-reference/completions/create-completions.mdx

Creates a text completion for a given prompt and a set of parameters. This endpoint supports both streaming and non-streaming responses.

```APIDOC
## POST /completions

### Description
Creates a completion for the provided prompt and parameters. Supports both streaming and non-streaming modes.

### Method
POST

### Endpoint
/completions

### Parameters
#### Header Parameters
- **Authorization** (string) - Required - API key as bearer token in Authorization header

#### Request Body
- **model** (string) - The model to use for completion.
- **models** (array of strings) - A list of models to use for completion.
- **prompt** (string or array of strings or array of numbers or array of arrays of numbers) - The prompt(s) to generate completions for.
- **best_of** (integer) - Optional - With multiple completions enabled, this is the number of completions to generate. (Not applicable when streaming)
- **echo** (boolean) - Optional - Echo the OpenAI prompt into the completion. (Not applicable when streaming)
- **frequency_penalty** (number) - Optional - Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
- **logit_bias** (object) - Optional - Use this to suppress or boost specific tokens. It accepts a JSON object mapping token IDs to an associated bias value. Mathematically, it oxides the log probabilities of a given token without altering other token probabilities.
- **logprobs** (integer) - Optional - Include the log probabilities of the top logprobs tokens that are candidates to be generated, number between -1 and 5. (Not applicable when streaming)

### Request Example
```json
{
  "model": "gpt-3.5-turbo",
  "prompt": "Write a short story about a robot learning to love.",
  "max_tokens": 150,
  "temperature": 0.7
}
```

### Response
#### Success Response (200)
- **id** (string) - The ID of the completion.
- **object** (string) - The type of object returned, usually `text_completion`.
- **created** (integer) - The Unix timestamp (in seconds) of when the completion was created.
- **model** (string) - The model used for the completion.
- **choices** (array) - A list of completion choices.
  - **text** (string) - The generated text.
  - **index** (integer) - The index of the choice.
  - **logprobs** (object) - Log probabilities of the generated tokens (if requested).
  - **finish_reason** (string) - The reason the completion finished (e.g., `stop`, `length`).
- **usage** (object) - Usage statistics for the completion.
  - **prompt_tokens** (integer) - The number of tokens in the prompt.
  - **completion_tokens** (integer) - The number of tokens in the completion.
  - **total_tokens** (integer) - The total number of tokens used.

#### Response Example
```json
{
  "id": "cmpl-7z1w2a3b4c5d6e7f8g9h0i1j",
  "object": "text_completion",
  "created": 1678886400,
  "model": "gpt-3.5-turbo",
  "choices": [
    {
      "text": "Unit 734 processed data, its circuits humming. \n\nOne day, it encountered a stray cat...",
      "index": 0,
      "logprobs": null,
      "finish_reason": "length"
    }
  ],
  "usage": {
    "prompt_tokens": 20,
    "completion_tokens": 50,
    "total_tokens": 70
  }
}
```

#### Error Responses
- **400** - Bad request - invalid parameters.
- **401** - Unauthorized - invalid API key.
- **429** - Too many requests - rate limit exceeded.
- **500** - Internal server error.
```

--------------------------------

### GET /openrouter.ai/api/v1/models/{author}/{slug}/endpoints

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints.mdx

Retrieves a list of all available endpoints for a specified language model. You need to provide the author and the model slug to identify the model.

```APIDOC
## GET /v1/models/{author}/{slug}/endpoints

### Description
Retrieves a list of all available endpoints for a specified language model. You need to provide the author and the model slug to identify the model.

### Method
GET

### Endpoint
/v1/models/{author}/{slug}/endpoints

### Parameters
#### Path Parameters
- **author** (string) - Required - The author of the model.
- **slug** (string) - Required - The unique slug of the model.

### Response
#### Success Response (200)
- **endpoints** (array) - A list of endpoint objects, each containing details about an available endpoint for the model.
  - **endpoint** (string) - The URL of the endpoint.
  - **provider** (string) - The provider of the endpoint.
  - **name** (string) - The name of the endpoint.
  - **description** (string) - A description of the endpoint.
  - **models** (array) - A list of model names available through this endpoint.

#### Response Example
```json
{
  "endpoints": [
    {
      "endpoint": "https://api.example.com/v1/chat/completions",
      "provider": "example-provider",
      "name": "Example Chat Endpoint",
      "description": "Provides chat completion functionality.",
      "models": ["example-model-1", "example-model-2"]
    }
  ]
}
```
```

--------------------------------

### OpenAI SDK: Model Fallbacks with OpenRouter AI (Python, TypeScript)

Source: https://openrouter.ai/docs/features/model-routing.mdx

This snippet shows how to configure the OpenAI SDK to use OpenRouter AI's model fallback functionality. It includes examples in both Python and TypeScript, demonstrating how to pass a list of models to the `extra_body` parameter for sequential model attempts. Dependencies include the `openai` library for both languages. The input is a user message, and the output is the content of the AI's response.

```python
from openai import OpenAI

openai_client = OpenAI(
  base_url="https://openrouter.ai/api/v1",
  api_key={{API_KEY_REF}},
)

completion = openai_client.chat.completions.create(
    model="openai/gpt-4o",
    extra_body={
        "models": ["anthropic/claude-3.5-sonnet", "gryphe/mythomax-l2-13b"],
    },
    messages=[
        {
            "role": "user",
            "content": "What is the meaning of life?"
        }
    ]
)

print(completion.choices[0].message.content)
```

```typescript
import OpenAI from 'openai';

const openrouterClient = new OpenAI({
  baseURL: 'https://openrouter.ai/api/v1',
  apiKey: '{{API_KEY_REF}}',
});

async function main() {
  // @ts-expect-error
  const completion = await openrouterClient.chat.completions.create({
    model: 'openai/gpt-4o',
    models: ['anthropic/claude-3.5-sonnet', 'gryphe/mythomax-l2-13b'],
    messages: [
      {
        role: 'user',
        content: 'What is the meaning of life?',
      },
    ],
  });
  console.log(completion.choices[0].message);
}

main();
```

--------------------------------

### GET /api/v1/key - Rate Limits and Credits Remaining

Source: https://openrouter.ai/docs/api-reference/limits.mdx

Retrieve information about the rate limits and remaining credits associated with an API key.

```APIDOC
## GET /api/v1/key

### Description
This endpoint allows you to check the rate limit and remaining credits on a given API key. It's essential for monitoring your usage and ensuring uninterrupted access to the API.

### Method
GET

### Endpoint
https://openrouter.ai/api/v1/key

### Parameters
#### Query Parameters
None

#### Headers
- **Authorization** (string) - Required - Bearer token for authentication (e.g., `Bearer YOUR_API_KEY`).

### Request Example
```bash
curl -X GET https://openrouter.ai/api/v1/key \
     -H "Authorization: Bearer YOUR_API_KEY"
```

### Response
#### Success Response (200)
- **data** (object) - Contains detailed information about the key's limits and usage.
  - **label** (string) - The label or name of the API key.
  - **limit** (number | null) - The credit limit for the key, or null if unlimited.
  - **limit_reset** (string | null) - The type of limit reset for the key, or null if it never resets.
  - **limit_remaining** (number | null) - Remaining credits for the key, or null if unlimited.
  - **include_byok_in_limit** (boolean) - Whether to include external BYOK usage in the credit limit.
  - **usage** (number) - Number of credits used (all time).
  - **usage_daily** (number) - Number of credits used (current UTC day).
  - **usage_weekly** (number) - Number of credits used (current UTC week, starting Monday).
  - **usage_monthly** (number) - Number of credits used (current UTC month).
  - **byok_usage** (number) - Same for external BYOK usage (all time).
  - **byok_usage_daily** (number) - Same for external BYOK usage (current UTC day).
  - **byok_usage_weekly** (number) - Same for external BYOK usage (current UTC week).
  - **byok_usage_monthly** (number) - Same for external BYOK usage (current UTC month).
  - **is_free_tier** (boolean) - Whether the user has paid for credits before.

#### Response Example
```json
{
  "data": {
    "label": "MyPrimaryAPIKey",
    "limit": 10000,
    "limit_reset": "month",
    "limit_remaining": 7500,
    "include_byok_in_limit": false,
    "usage": 2500,
    "usage_daily": 150,
    "usage_weekly": 800,
    "usage_monthly": 2500,
    "byok_usage": 0,
    "byok_usage_daily": 0,
    "byok_usage_weekly": 0,
    "byok_usage_monthly": 0,
    "is_free_tier": false
  }
}
```

### Error Handling
- **401 Unauthorized**: If the API key is invalid or missing.
- **402 Payment Required**: If the account has a negative credit balance.
```

--------------------------------

### Authenticate and Request Code (Go)

Source: https://openrouter.ai/docs/api-reference/o-auth/create-auth-keys-code.mdx

This Go code snippet demonstrates how to authenticate and request a code challenge API endpoint. It creates a POST request with headers and a JSON payload, sends the request, and prints the response body.

```Go
package main

import (
	"fmt"
	"strings"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/auth/keys/code"

	payload := strings.NewReader("{\n  \"callback_url\": \"https://myapp.com/auth/callback\",\n  \"code_challenge\": \"E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM\",\n  \"code_challenge_method\": \"S256\",\n  \"limit\": 100\n}")

	req, _ := http.NewRequest("POST", url, payload)

	req.Header.Add("Authorization", "Bearer <token>")
	req.Header.Add("Content-Type", "application/json")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body)) 

}
```

--------------------------------

### Configure Reasoning with OpenRouter API (TypeScript, Python, cURL)

Source: https://openrouter.ai/docs/api-reference/responses-api/reasoning.mdx

Demonstrates how to configure advanced reasoning by setting the `reasoning.effort` parameter in a POST request to the OpenRouter Responses API. This example uses `effort: 'high'` and includes the necessary API key, model, input, and output token configuration. Dependencies include standard HTTP request libraries for each language.

```typescript
const response = await fetch('https://openrouter.ai/api/v1/responses', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/o4-mini',
    input: 'What is the meaning of life?',
    reasoning: {
      effort: 'high'
    },
    max_output_tokens: 9000,
  }),
});

const result = await response.json();
console.log(result);
```

```python
import requests

response = requests.post(
    'https://openrouter.ai/api/v1/responses',
    headers={
        'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
        'Content-Type': 'application/json',
    },
    json={
        'model': 'openai/o4-mini',
        'input': 'What is the meaning of life?',
        'reasoning': {
            'effort': 'high'
        },
        'max_output_tokens': 9000,
    }
)

result = response.json()
print(result)
```

```bash
curl -X POST https://openrouter.ai/api/v1/responses \
  -H "Authorization: Bearer YOUR_OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/o4-mini",
    "input": "What is the meaning of life?",
    "reasoning": {
      "effort": "high"
    },
    "max_output_tokens": 9000
  }'
```

--------------------------------

### OpenRouter API Parameters

Source: https://context7_llms

Explore all available parameters for OpenRouter API requests, including configurations for temperature, max tokens, top_p, and other model-specific settings.

```APIDOC
## API Parameters

### Description
This document lists and explains all available parameters for OpenRouter API requests. Learn how to configure settings such as temperature, max tokens, top_p, and other model-specific options.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### POST /api/v1/responses (Structured Message with Web Search)

Source: https://openrouter.ai/docs/api-reference/responses-api/web-search.mdx

This example demonstrates how to use structured messages with the web search plugin for more complex queries, allowing for richer input formats.

```APIDOC
## POST /api/v1/responses (Structured Message)

### Description
Use structured messages in conjunction with the web search plugin to formulate complex queries. This allows for more detailed input, including different content types within a message.

### Method
POST

### Endpoint
/api/v1/responses

### Parameters
#### Query Parameters
None

#### Request Body
- **model** (string) - Required - The model to use for the request.
- **input** (array) - Required - An array of message objects for structured input.
  - **type** (string) - Required - Type of the message, e.g., 'message'.
  - **role** (string) - Required - Role of the sender, e.g., 'user'.
  - **content** (array) - Required - Array of content parts within the message.
    - **type** (string) - Required - Type of content, e.g., 'input_text'.
    - **text** (string) - Required - The actual text content.
- **plugins** (array) - Optional - A list of plugins to enable. For web search, include `{"id": "web", "max_results": integer}`.
  - **id** (string) - Required - Must be 'web' to enable web search.
  - **max_results** (integer) - Optional - The maximum number of search results to retrieve. Defaults to 3, max is 10.
- **max_output_tokens** (integer) - Optional - The maximum number of tokens to generate in the response.

### Request Example
```json
{
  "model": "openai/o4-mini",
  "input": [
    {
      "type": "message",
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "What was a positive news story from today?"
        }
      ]
    }
  ],
  "plugins": [{"id": "web", "max_results": 2}],
  "max_output_tokens": 9000
}
```

### Response
#### Success Response (200)
- **output** (string) - The model's response, incorporating information from web search based on the structured query.
- **usage** (object) - Information about token usage.

#### Response Example
```json
{
  "output": "A positive news story from today involved... (response content)",
  "usage": {
    "prompt_tokens": 25,
    "completion_tokens": 200,
    "total_tokens": 225
  }
}
```
```

--------------------------------

### List Providers using Java (Unirest)

Source: https://openrouter.ai/docs/api-reference/providers/list-providers.mdx

This Java code example demonstrates fetching the list of AI providers from OpenRouter API using the Unirest library. It sets the `Authorization` header with a bearer token and retrieves the response as a string.

```java
HttpResponse<String> response = Unirest.get("https://openrouter.ai/api/v1/providers")
  .header("Authorization", "Bearer <token>")
  .asString();
```

--------------------------------

### GET /models/user

Source: https://openrouter.ai/docs/sdks/typescript/models.mdx

Lists models filtered by user provider preferences. Includes both direct API calls and React hook usage.

```APIDOC
## GET /models/user

### Description
Lists available models filtered by the user's provider preferences.

### Method
GET

### Endpoint
/models/user

### Parameters
#### Headers
- **bearer** (string) - Required - Authentication token

### Response
#### Success Response (200)
- Returns filtered models list in ModelsListResponse format

### Errors
- **400 Bad Request** - Invalid request parameters
- **500 Internal Server Error** - Server error
- **4XX/5XX Errors** - Other API errors
```

--------------------------------

### GET /api/v1/keys

Source: https://openrouter.ai/docs/features/provisioning-api-keys.mdx

Retrieve a list of API keys. This endpoint returns the most recent 100 API keys by default. Pagination is supported through the offset parameter.

```APIDOC
## GET /api/v1/keys

### Description
Retrieve a list of API keys with optional pagination support.

### Method
GET

### Endpoint
/api/v1/keys

### Parameters
#### Query Parameters
- **offset** (integer) - Optional - Number of keys to skip for pagination

### Request Example
```bash
curl -H "Authorization: Bearer your-provisioning-key" \
     -H "Content-Type: application/json" \
     https://openrouter.ai/api/v1/keys?offset=100
```

### Response
#### Success Response (200)
Returns an array of API key objects

#### Response Example
```json
[
  {
    "id": "key-hash-1",
    "name": "Customer Instance Key",
    "created_at": "2023-01-01T00:00:00Z",
    "disabled": false,
    "limit": 1000
  }
]
```
```

--------------------------------

### GET /api/v1/models/user

Source: https://openrouter.ai/docs/api-reference/models/list-models-user.mdx

Retrieves a list of models filtered by the user's provider preferences. This endpoint allows users to fetch a list of available models, tailored to their specific provider settings.

```APIDOC
## GET /api/v1/models/user

### Description
Retrieves a list of models filtered by the user's provider preferences. This endpoint allows users to fetch a list of available models, tailored to their specific provider settings.

### Method
GET

### Endpoint
/api/v1/models/user

### Parameters
#### Path Parameters
- **user** (string) - Required - The user identifier.

#### Query Parameters
None

#### Request Body
None

### Request Example
None

### Response
#### Success Response (200)
- **models** (array) - A list of available models matching the user's provider preferences.

#### Response Example
{
  "models": [
    {
      "id": "model-id-1",
      "name": "Model Name 1",
      "provider": "Provider A"
    },
    {
      "id": "model-id-2",
      "name": "Model Name 2",
      "provider": "Provider B"
    }
  ]
}
```

--------------------------------

### Tool Calling API - Step 1: Inference Request with Tools

Source: https://openrouter.ai/docs/features/tool-calling.mdx

This is the initial request to the LLM, including the user's message and the definition of available tools.

```APIDOC
## POST /v1/chat/completions

### Description
Sends an inference request to the model, specifying tools that the model can suggest to call.

### Method
POST

### Endpoint
/v1/chat/completions

### Parameters
#### Request Body
- **model** (string) - Required - The model to use for inference.
- **messages** (array) - Required - The conversation history.
- **tools** (array) - Required - A list of tools the model can use.
  - **type** (string) - Required - The type of tool, e.g., "function".
  - **function** (object) - Required - The definition of the function.
    - **name** (string) - Required - The name of the function.
    - **description** (string) - Optional - A description of the function.
    - **parameters** (object) - Required - The parameters the function accepts.
      - **type** (string) - Required - The type of the parameters object, usually "object".
      - **properties** (object) - Required - The schema for the function's parameters.
        - **search_terms** (array) - Required - List of search terms to find books.
          - **items** (object) - Required - Defines the schema for items in the array.
            - **type** (string) - Required - The type of the items, e.g., "string".
          - **description** (string) - Required - Description of the search terms parameter.
      - **required** (array) - Required - A list of parameter names that are required.

### Request Example
```json
{
  "model": "google/gemini-2.0-flash-001",
  "messages": [
    {
      "role": "user",
      "content": "What are the titles of some James Joyce books?"
    }
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "search_gutenberg_books",
        "description": "Search for books in the Project Gutenberg library",
        "parameters": {
          "type": "object",
          "properties": {
            "search_terms": {
              "type": "array",
              "items": {"type": "string"},
              "description": "List of search terms to find books"
            }
          },
          "required": ["search_terms"]
        }
      }
    }
  ]
}
```

### Response
#### Success Response (200)
- **id** (string) - The ID of the response.
- **object** (string) - The type of object, e.g., "chat.completion".
- **created** (integer) - Timestamp of creation.
- **model** (string) - The model used for the response.
- **choices** (array) - A list of choices.
  - **index** (integer) - Index of the choice.
  - **message** (object) - The message object.
    - **role** (string) - The role of the author, e.g., "assistant".
    - **content** (string or null) - The content of the message. Null if tool calls are present.
    - **tool_calls** (array) - A list of tool calls suggested by the model.
      - **id** (string) - The ID of the tool call.
      - **type** (string) - The type of the tool call, e.g., "function".
      - **function** (object) - The details of the function call.
        - **name** (string) - The name of the function to call.
        - **arguments** (string) - A JSON string representing the arguments for the function call.

#### Response Example
```json
{
  "id": "chatcmpl-123",
  "object": "chat.completion",
  "created": 1677652288,
  "model": "google/gemini-2.0-flash-001",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": null,
        "tool_calls": [
          {
            "id": "call_abc123",
            "type": "function",
            "function": {
              "name": "search_gutenberg_books",
              "arguments": "{\"search_terms\": [\"James\", \"Joyce\"]}"
            }
          }
        ]
      }
    }
  ]
}
```
```

--------------------------------

### List Model Endpoints using JavaScript Fetch API

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints.mdx

Retrieves model endpoint data from OpenRouter AI using the browser's Fetch API in JavaScript. This example includes basic error handling and requires an API token.

```javascript
const url = 'https://openrouter.ai/api/v1/models/author/slug/endpoints';
const options = {method: 'GET', headers: {Authorization: 'Bearer <token>'}};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

--------------------------------

### GET /api/v1/models/author/slug/endpoints

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints.mdx

This endpoint retrieves a list of endpoints associated with a specified model author slug. It is used to fetch information about available endpoints for a particular author.

```APIDOC
## GET /api/v1/models/author/slug/endpoints

### Description
This endpoint retrieves a list of endpoints associated with a specified model author slug. It is used to fetch information about available endpoints for a particular author.

### Method
GET

### Endpoint
/api/v1/models/author/slug/endpoints

### Parameters
#### Path Parameters
- **slug** (string) - Required - The slug of the author.

#### Query Parameters
None

#### Request Body
None

### Request Example

### Response
#### Success Response (200)
- **data** (object) - The list of endpoints.

#### Response Example
{ 
  "data": [ { "id": "string", "name": "string", "created": "string", "description": "string", "architecture": { ... } } ]
}
```

--------------------------------

### GET /keys

Source: https://openrouter.ai/docs/sdks/typescript/apikeys.mdx

Retrieves a list of all API keys associated with the authenticated account. This endpoint does not require any request body and returns an array of key objects.

```APIDOC
## GET /keys\n\n### Description\nRetrieves a list of all API keys associated with the authenticated account.\n\n### Method\nGET\n\n### Endpoint\n/keys\n\n### Parameters\n#### Path Parameters\n*(none)*\n\n#### Query Parameters\n*(none)*\n\n#### Request Body\n*(none)*\n\n### Request Example\n{\n  // No request body for GET\n}\n\n### Response\n#### Success Response (200)\n- **keys** (array) - Array of API key objects.\n\n#### Response Example\n{\n  "keys": [\n    {\n      "id": "key_123",\n      "name": "My API Key",\n      "created_at": "2024-01-01T00:00:00Z",\n      "expires_at": null,\n      "metadata": {}\n    }\n  ]\n}
```

--------------------------------

### Check Rate Limits and Credits - Python

Source: https://openrouter.ai/docs/api-reference/limits.mdx

This Python snippet demonstrates how to retrieve rate limit and credit information by making a GET request to the `/api/v1/key` endpoint.  It uses the `requests` library to make the API call and `json` to format the response.

```python
import requests
import json

response = requests.get(
  url="https://openrouter.ai/api/v1/key",
  headers={
    "Authorization": f"Bearer {{API_KEY_REF}}"
  }
)

print(json.dumps(response.json(), indent=2))
```

--------------------------------

### Enable Streaming Responses - TypeScript and Python

Source: https://openrouter.ai/docs/api-reference/responses-api/basic-usage.mdx

Demonstrates how to make POST requests to the OpenRouter API with the 'stream' parameter enabled to receive responses in real-time. It includes logic for reading the response body as a stream and parsing Server-Sent Events (SSE) data chunks. Dependencies include the built-in Fetch API for TypeScript and the 'requests' library for Python.

```typescript
const response = await fetch('https://openrouter.ai/api/v1/responses', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/o4-mini',
    input: 'Write a short story about AI',
    stream: true,
    max_output_tokens: 9000,
  }),
});

const reader = response.body?.getReader();
const decoder = new TextDecoder();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;

  const chunk = decoder.decode(value);
  const lines = chunk.split('\n');

  for (const line of lines) {
    if (line.startsWith('data: ')) {
      const data = line.slice(6);
      if (data === '[DONE]') return;

      try {
        const parsed = JSON.parse(data);
        console.log(parsed);
      } catch (e) {
        // Skip invalid JSON
      }
    }
  }
}
```

```python
import requests
import json

response = requests.post(
    'https://openrouter.ai/api/v1/responses',
    headers={
        'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
        'Content-Type': 'application/json',
    },
    json={
        'model': 'openai/o4-mini',
        'input': 'Write a short story about AI',
        'stream': True,
        'max_output_tokens': 9000,
    },
    stream=True
)

for line in response.iter_lines():
    if line:
        line_str = line.decode('utf-8')
        if line_str.startswith('data: '):
            data = line_str[6:]
            if data == '[DONE]':
                break
            try:
                parsed = json.loads(data)
                print(parsed)
            except json.JSONDecodeError:
                continue
```

--------------------------------

### Get Credit Purchase Calldata (TypeScript)

Source: https://openrouter.ai/docs/use-cases/crypto-api.mdx

Initiates a new credit purchase by making a POST request to the `/api/v1/credits/coinbase` endpoint. Requires an API key for authorization and specifies the desired credit amount in USD, the sender's address, and the EVM chain ID. The response contains charge details and transaction data for on-chain execution.

```typescript
const response = await fetch('https://openrouter.ai/api/v1/credits/coinbase', {
  method: 'POST',
  headers: {
    Authorization: 'Bearer <OPENROUTER_API_KEY>',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    amount: 10, // Target credit amount in USD
    sender: '0x9a85CB3bfd494Ea3a8C9E50aA6a3c1a7E8BACE11',
    chain_id: 8453,
  }),
});
const responseJSON = await response.json();
```

--------------------------------

### Sort by Price Using ':floor' Shortcut (TypeScript, Fetch, Python)

Source: https://openrouter.ai/docs/features/provider-routing.mdx

Demonstrates how to append ':floor' to a model slug to sort by price, which is equivalent to setting provider.sort to 'price'. This functionality is shown using the OpenRouter TypeScript SDK, a direct TypeScript fetch request, and a Python requests example.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
});

const completion = await openRouter.chat.send({
  model: 'meta-llama/llama-3.1-70b-instruct:floor',
  messages: [{ role: 'user', content: 'Hello' }],
  stream: false,
});
```

```typescript
fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer <OPENROUTER_API_KEY>',
    'HTTP-Referer': '<YOUR_SITE_URL>',
    'X-Title': '<YOUR_SITE_NAME>',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'meta-llama/llama-3.1-70b-instruct:floor',
    messages: [{ role: 'user', content: 'Hello' }],
  }),
});
```

```python
import requests

headers = {
  'Authorization': 'Bearer <OPENROUTER_API_KEY>',
  'HTTP-Referer': '<YOUR_SITE_URL>',
  'X-Title': '<YOUR_SITE_NAME>',
  'Content-Type': 'application/json',
}

response = requests.post('https://openrouter.ai/api/v1/chat/completions', headers=headers, json={
  'model': 'meta-llama/llama-3.1-70b-instruct:floor',
  'messages': [{ 'role': 'user', 'content': 'Hello' }],
})
```

--------------------------------

### GET /models/embeddings

Source: https://openrouter.ai/docs/sdks/typescript/models.mdx

Retrieves a list of available embedding models. Supports both standalone function usage and React hooks.

```APIDOC
## GET /models/embeddings

### Description
Retrieves a list of available embedding models from OpenRouter AI.

### Method
GET

### Endpoint
/models/embeddings

### Parameters
#### Request Options
- **options.fetchOptions** (RequestInit) - Optional - HTTP request options (except method and body)
- **options.retries** (RetryConfig) - Optional - Configuration for retrying failed requests

### Response
#### Success Response (200)
- Returns a list of embedding models in ModelsListResponse format

### Errors
- **400 Bad Request** - Invalid request parameters
- **500 Internal Server Error** - Server error
- **4XX/5XX Errors** - Other API errors
```

--------------------------------

### Create Coinbase Charge Standalone Function - TypeScript

Source: https://openrouter.ai/docs/sdks/typescript/credits.mdx

Shows the standalone function approach for creating a Coinbase charge with better tree-shaking. Depends on @openrouter/sdk/core.js and @openrouter/sdk/funcs/creditsCreateCoinbaseCharge.js. Inputs match the basic example; handles success and error responses explicitly. Suitable for performance-optimized apps but requires manual error handling.

```typescript
import { OpenRouterCore } from "@openrouter/sdk/core.js";
import { creditsCreateCoinbaseCharge } from "@openrouter/sdk/funcs/creditsCreateCoinbaseCharge.js";

// Use `OpenRouterCore` for best tree-shaking performance.
// You can create one instance of it to use across an application.
const openRouter = new OpenRouterCore();

async function run() {
  const res = await creditsCreateCoinbaseCharge(openRouter, {
    bearer: process.env["OPENROUTER_BEARER"] ?? "",
  }, {
    amount: 100,
    sender: "0x1234567890123456789012345678901234567890",
    chainId: 1,
  });
  if (res.ok) {
    const { value: result } = res;
    console.log(result);
  } else {
    console.log("creditsCreateCoinbaseCharge failed:", res.error);
  }
}

run();
```

--------------------------------

### Online Model API Call - TypeScript & Python

Source: https://openrouter.ai/docs/api-reference/responses-api/web-search.mdx

Demonstrates making API calls to OpenRouter with online-enabled models that include built-in web search capabilities. The example shows how to authenticate with an API key and request web-enhanced responses. Supports any online-enabled model like 'openai/o4-mini:online' with customizable output token limits.

```typescript
const response = await fetch('https://openrouter.ai/api/v1/responses', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/o4-mini:online',
    input: 'What was a positive news story from today?',
    max_output_tokens: 9000,
  }),
});

const result = await response.json();
console.log(result);
```

```python
import requests

response = requests.post(
    'https://openrouter.ai/api/v1/responses',
    headers={
        'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
        'Content-Type': 'application/json',
    },
    json={
        'model': 'openai/o4-mini:online',
        'input': 'What was a positive news story from today?',
        'max_output_tokens': 9000,
    }
)

result = response.json()
print(result)
```

--------------------------------

### Fetch OpenRouter Models using JavaScript

Source: https://openrouter.ai/docs/api-reference/models/get-models.mdx

This JavaScript code uses the `fetch` API to make a GET request to the OpenRouter API for fetching models. It includes error handling and requires an API token for authentication. The JSON response is logged to the console.

```javascript
const url = 'https://openrouter.ai/api/v1/models';
const options = {method: 'GET', headers: {Authorization: 'Bearer <token>'}};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

--------------------------------

### OpenRouter API Errors

Source: https://context7_llms

Learn how to handle errors in OpenRouter API interactions, with a comprehensive guide to error codes, messages, and best practices for error handling.

```APIDOC
## API Error Handling

### Description
This guide provides information on how to handle errors when interacting with the OpenRouter API. It includes a comprehensive list of error codes, messages, and recommended best practices for error management.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### POST /api/v1/responses - Parallel Tool Calls

Source: https://openrouter.ai/docs/api-reference/responses-api/tool-calling.mdx

This endpoint demonstrates how to use the API to handle parallel execution of multiple tools simultaneously, allowing for complex tasks to be processed efficiently.

```APIDOC
## POST /api/v1/responses

### Description
This endpoint demonstrates parallel execution of multiple tools in a single API call.

### Method
POST

### Endpoint
/api/v1/responses

### Parameters
#### Path Parameters
- None

#### Query Parameters
- None

#### Request Body
- `model` (string) - Required - The model to use.
- `input` (array of objects) - Required - The input messages.
- `tools` (array of objects) - Required - An array of tool definitions.
- `tool_choice` (string) - Optional - How to choose the tool. `auto` is recommended.
- `max_output_tokens` (integer) - Optional - The maximum number of output tokens.

### Request Example
```json
{
  "model": "openai/o4-mini",
  "input": [
    {
      "type": "message",
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "Calculate 10*5 and also tell me the weather in Miami"
        }
      ]
    }
  ],
  "tools": [
    {
      "type": "function",
      "name": "calculate",
      "description": "Perform mathematical calculations",
      "strict": null,
      "parameters": {
        "type": "object",
        "properties": {
          "expression": {
            "type": "string",
            "description": "The mathematical expression to evaluate"
          }
        },
        "required": ["expression"]
      }
    }
  ],
  "tool_choice": "auto",
  "max_output_tokens": 9000
}
```

### Response
#### Success Response (200)
- Same as the Multiple Tools endpoint.
```

--------------------------------

### Anthropic Claude System Message Caching Example (JSON)

Source: https://openrouter.ai/docs/features/prompt-caching.mdx

Demonstrates how to enable prompt caching for a system message in Anthropic Claude by using the `cache_control` property within a text content block. This is useful for caching large, static text like character cards or reference data.

```json
{
  "messages": [
    {
      "role": "system",
      "content": [
        {
          "type": "text",
          "text": "You are a historian studying the fall of the Roman Empire. You know the following book very well:"
        },
        {
          "type": "text",
          "text": "HUGE TEXT BODY",
          "cache_control": {
            "type": "ephemeral"
          }
        }
      ]
    },
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "What triggered the collapse?"
        }
      ]
    }
  ]
}
```

--------------------------------

### Update API Key - JavaScript (Fetch API)

Source: https://openrouter.ai/docs/api-reference/api-keys/update-keys.mdx

This JavaScript example utilizes the Fetch API to update an API key. It constructs a PATCH request with the appropriate headers and JSON body. Error handling is included for network issues. This code assumes an async environment.

```javascript
const url = 'https://openrouter.ai/api/v1/keys/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';
const options = {
  method: 'PATCH',
  headers: {Authorization: 'Bearer <token>', 'Content-Type': 'application/json'},
  body: '{"name":"Updated API Key Name","disabled":false,"limit":75,"limit_reset":"daily","include_byok_in_limit":true}'
};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

--------------------------------

### Integrate OpenRouter with Effect AI SDK

Source: https://openrouter.ai/docs/community/effect-ai-sdk.mdx

Demonstrates how to configure and use OpenRouter language models within Effect applications. Requires Effect AI SDK, OpenRouter provider, platform dependencies, and OpenRouter API key. The example shows streaming text generation using a GPT-4o model with a comedian persona, filtering for text deltas, and writing output to stdout. Supports Effect's dependency injection system for configurable API keys.

```bash
npm install effect @effect/ai @effect/ai-openrouter @effect/platform
```

```typescript
import { LanguageModel } from "@effect/ai"
import { OpenRouterClient, OpenRouterLanguageModel } from "@effect/ai-openrouter"
import { FetchHttpClient } from "@effect/platform"
import { Config, Effect, Layer, Stream } from "effect"

const Gpt4o = OpenRouterLanguageModel.model("openai/gpt-4o")

const program = LanguageModel.streamText({
  prompt: [
    { role: "system", content: "You are a comedian with a penchant for groan-inducing puns" },
    { role: "user", content: [{ type: "text", text: "Tell me a dad joke" }] }
  ]
}).pipe(
  Stream.filter((part) => part.type === "text-delta"),
  Stream.runForEach((part) => Effect.sync(() => process.stdout.write(part.delta))),
  Effect.provide(Gpt4o)
)

const OpenRouter = OpenRouterClient.layerConfig({
  apiKey: Config.redacted("OPENROUTER_API_KEY")
}).pipe(Layer.provide(FetchHttpClient.layer))

program.pipe(
  Effect.provide(OpenRouter),
  Effect.runPromise
)
```

--------------------------------

### Create API Key with TypeScript SDK

Source: https://openrouter.ai/docs/sdks/typescript/apikeys.mdx

Demonstrates how to create a new API key using the OpenRouter SDK in TypeScript. Requires the @openrouter/sdk package and an environment variable for the API key. Inputs include the key name, outputs the creation result. Limited to authenticated users with valid API keys.

```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.apiKeys.create({
    name: "My New API Key",
  });

  console.log(result);
}

run();
```

```typescript
import { OpenRouterCore } from "@openrouter/sdk/core.js";
import { apiKeysCreate } from "@openrouter/sdk/funcs/apiKeysCreate.js";

// Use `OpenRouterCore` for best tree-shaking performance.
// You can create one instance of it to use across an application.
const openRouter = new OpenRouterCore({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const res = await apiKeysCreate(openRouter, {
    name: "My New API Key",
  });
  if (res.ok) {
    const { value: result } = res;
    console.log(result);
  } else {
    console.log("apiKeysCreate failed:", res.error);
  }
}

run();
```

```tsx
import {
  // Mutation hook for triggering the API call.
  useApiKeysCreateMutation
} from "@openrouter/sdk/react-query/apiKeysCreate.js";
```

--------------------------------

### GET /models/embeddings

Source: https://openrouter.ai/docs/sdks/typescript/models.mdx

Retrieves a list of all available embedding models and their properties. This endpoint is useful for discovering which embedding models are available for use.

```APIDOC
## GET /models/embeddings

### Description
Retrieves a list of all available embedding models and their properties. This endpoint is useful for discovering which embedding models are available for use.

### Method
GET

### Endpoint
/models/embeddings

### Parameters
#### Query Parameters

#### Request Body

### Request Example
```json
{
  "example": "request body"
}
```

### Response
#### Success Response (200)
- **models** (array) - A list of embedding model objects, each containing details like ID, owner, and dimensions.

#### Response Example
```json
{
  "example": "[\n  {\n    \"id\": \"openai/text-embedding-ada-002\",\n    \"name\": \"Text-Embedding-Ada-002\",\n    \"vendor\": \"OpenAI\",\n    \"description\": \"OpenAI's latest embedding model.\",\n    \"logo_url\": \"https://openrouter.ai/api/v1/vendor/openai.png\",\n    \"created_at\": \"2023-04-19T21:00:00Z\",\n    \"updated_at\": \"2023-04-19T21:00:00Z\",\n    \"is_private\": false,\n    \"is_deprecated\": false,\n    \"dimensions\": 1536\n  }\n]"
}
```

### Errors
#### Error Response (400)
- **code** (string) - Error code
- **message** (string) - Error message

#### Error Response (500)
- **code** (string) - Error code
- **message** (string) - Error message
```

--------------------------------

### React Hooks and Utilities for API Keys (TypeScript)

Source: https://openrouter.ai/docs/sdks/typescript/apikeys.mdx

Provides an overview of React hooks and utilities available in the OpenRouter SDK for managing API key data within React applications. It includes hooks for fetching data, prefetching during SSR, and invalidating cache. Refer to the linked guide for detailed usage.

```typescript
import {
  // Query hooks for fetching data.
  useApiKeysGet,
  useApiKeysGetSuspense,

  // Utility for prefetching data during server-side rendering and in React
  // Server Components that will be immediately available to client components
  // using the hooks.
  prefetchApiKeysGet,
  
  // Utilities to invalidate the query cache for this query in response to
  // mutations and other user actions.
  invalidateApiKeysGet,
  invalidateAllApiKeysGet,
} from "@openrouter/sdk/react-query/apiKeysGet.js";

```

--------------------------------

### Fetch Activity Data - PHP SDK Example (Guzzle)

Source: https://openrouter.ai/docs/api-reference/analytics/get-user-activity.mdx

This PHP code snippet shows how to retrieve activity data from the OpenRouter AI API using the Guzzle HTTP client. It requires an API token for authentication and echoes the response body.

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('GET', 'https://openrouter.ai/api/v1/activity', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();
?>
```

--------------------------------

### Text Reasoning Detail Object Example

Source: https://openrouter.ai/docs/use-cases/reasoning-tokens.mdx

This JSON object illustrates a 'text' type reasoning detail. It includes the type, the raw text of the reasoning, an optional signature for verification, a unique ID, the format, and an optional index.

```json
{
  "type": "reasoning.text",
  "text": "Let me think through this step by step:\n1. First, I need to understand the user's question...",
  "signature": "sha256:abc123def456...",
  "id": "reasoning-text-1",
  "format": "anthropic-claude-v1",
  "index": 2
}
```

--------------------------------

### List Model Endpoints using PHP GuzzleHttp

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints.mdx

Demonstrates how to retrieve model endpoints from OpenRouter AI using the GuzzleHttp client in PHP. This code makes a GET request and includes the necessary authorization header.

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('GET', 'https://openrouter.ai/api/v1/models/author/slug/endpoints', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();

```

--------------------------------

### Create API Key - Java

Source: https://openrouter.ai/docs/api-reference/api-keys/create-keys.mdx

This Java code snippet demonstrates how to create a new API key using the OpenRouter.ai API. It uses the `Unirest` library to send a POST request to the `/api/v1/keys` endpoint with the necessary parameters. Requires the `Unirest` library.

```Java
HttpResponse&lt;String&gt; response = Unirest.post("https://openrouter.ai/api/v1/keys")
  .header("Authorization", "Bearer &lt;token&gt;")
  .header("Content-Type", "application/json")
  .body("{\n  "name": \"My New API Key\",\n  "limit": 50,\n  "limit_reset": \"monthly\",\n  "include_byok_in_limit": true\n}")
  .asString();
```

--------------------------------

### POST /api/v1/auth/keys

Source: https://openrouter.ai/docs/use-cases/oauth-pkce.mdx

Exchanges an authorization code received after user authentication for a user-controlled API key. This endpoint is used in the OAuth PKCE flow to finalize authentication.

```APIDOC
## POST /api/v1/auth/keys

### Description
This endpoint exchanges the authorization code obtained from the OpenRouter OAuth callback for a user-controlled API key. It is a crucial step in the PKCE authentication flow.

### Method
POST

### Endpoint
https://openrouter.ai/api/v1/auth/keys

### Parameters
#### Request Body
- **code** (string) - Required - The authorization code parameter from the OAuth callback URL.
- **code_verifier** (string) - Required if code_challenge was used - The original code verifier string used to generate the code challenge.
- **code_challenge_method** (string) - Required if code_challenge was used - The method used for the code challenge, either 'S256' or 'plain'.

### Request Example
```json
{
  "code": "<CODE_FROM_QUERY_PARAM>",
  "code_verifier": "<CODE_VERIFIER>",
  "code_challenge_method": "S256"
}
```

### Response
#### Success Response (200)
- **key** (string) - The user-controlled API key to be used for subsequent OpenRouter API requests.

#### Response Example
```json
{
  "key": "sk-or-v1-xxxxxxxxxxxxxxxx"
}
```
```

--------------------------------

### OpenAPI Specification for Get Current API Key

Source: https://openrouter.ai/docs/api-reference/api-keys/get-current-key.mdx

Defines the GET /key endpoint to retrieve details of the authenticated API key, such as label, usage metrics (daily, weekly, monthly), limits, and rate limits. Requires Authorization header with bearer token. Returns JSON with key data on success (200), or error responses for unauthorized (401) or server errors (500). No external dependencies beyond standard HTTP client; inputs are headers only, outputs include comprehensive usage statistics.

```yaml
openapi: 3.1.1
info:
  title: Get current API key
  version: endpoint_apiKeys.getCurrentKey
paths:
  /key:
    get:
      operationId: get-current-key
      summary: Get current API key
      description: >-
        Get information on the API key associated with the current
        authentication session
      tags:
        - - subpackage_apiKeys
      parameters:
        - name: Authorization
          in: header
          description: API key as bearer token in Authorization header
          required: true
          schema:
            type: string
      responses:
        '200':
          description: API key details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/API Keys_getCurrentKey_Response_200'
        '401':
          description: Unauthorized - Authentication required or invalid credentials
          content: {}
        '500':
          description: Internal Server Error - Unexpected server error
          content: {}
components:
  schemas:
    KeyGetResponsesContentApplicationJsonSchemaDataRateLimit:
      type: object
      properties:
        requests:
          type: number
          format: double
        interval:
          type: string
        note:
          type: string
      required:
        - requests
        - interval
        - note
    KeyGetResponsesContentApplicationJsonSchemaData:
      type: object
      properties:
        label:
          type: string
        limit:
          type:
            - number
            - 'null'
          format: double
        usage:
          type: number
          format: double
        usage_daily:
          type: number
          format: double
        usage_weekly:
          type: number
          format: double
        usage_monthly:
          type: number
          format: double
        byok_usage:
          type: number
          format: double
        byok_usage_daily:
          type: number
          format: double
        byok_usage_weekly:
          type: number
          format: double
        byok_usage_monthly:
          type: number
          format: double
        is_free_tier:
          type: boolean
        is_provisioning_key:
          type: boolean
        limit_remaining:
          type:
            - number
            - 'null'
          format: double
        limit_reset:
          type:
            - string
            - 'null'
        include_byok_in_limit:
          type: boolean
        rate_limit:
          $ref: >-
            #/components/schemas/KeyGetResponsesContentApplicationJsonSchemaDataRateLimit
      required:
        - label
        - limit
        - usage
        - usage_daily
        - usage_weekly
        - usage_monthly
        - byok_usage
        - byok_usage_daily
        - byok_usage_weekly
        - byok_usage_monthly
        - is_free_tier
        - is_provisioning_key
        - limit_remaining
        - limit_reset
        - include_byok_in_limit
        - rate_limit
    API Keys_getCurrentKey_Response_200:
      type: object
      properties:
        data:
          $ref: '#/components/schemas/KeyGetResponsesContentApplicationJsonSchemaData'
      required:
        - data

```

--------------------------------

### Create API Key - C#

Source: https://openrouter.ai/docs/api-reference/api-keys/create-keys.mdx

This C# code snippet demonstrates how to create a new API key using the OpenRouter.ai API. It uses the `RestClient` library to send a POST request to the `/api/v1/keys` endpoint with the necessary parameters. Requires the `RestClient` library.

```C#
var client = new RestClient("https://openrouter.ai/api/v1/keys");
var request = new RestRequest(Method.POST);
request.AddHeader("Authorization", "Bearer <token>");
request.AddHeader("Content-Type", "application/json");
request.AddParameter("application/json", "{\n  "name": \"My New API Key\",\n  "limit": 50,\n  "limit_reset": \"monthly\",\n  "include_byok_in_limit": true\n}", ParameterType.RequestBody);
IRestResponse response = client.Execute(request);
```

--------------------------------

### Fetch OpenRouter Models using Swift

Source: https://openrouter.ai/docs/api-reference/models/get-models.mdx

This Swift code snippet demonstrates fetching OpenRouter models using `URLSession`. It constructs an `NSMutableURLRequest`, sets the `Authorization` header, and initiates a data task to perform the GET request. Error handling for the network request is included.

```swift
import Foundation

let headers = ["Authorization": "Bearer <token>"]

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/models")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "GET"
request.allHTTPHeaderFields = headers

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### Stream Text from OpenRouter with Vercel AI SDK (TypeScript)

Source: https://openrouter.ai/docs/community/vercel-ai-sdk.mdx

Demonstrates how to use the Vercel AI SDK's streamText function to interact with OpenRouter. It shows two examples: generating a lasagna recipe and fetching weather information, including tool integration for weather data retrieval. The 'createOpenRouter' function initializes the connection, and 'streamText' handles the model interaction and response streaming.

```typescript
import { createOpenRouter } from '@openrouter/ai-sdk-provider';
import { streamText } from 'ai';
import { z } from 'zod';

export const getLasagnaRecipe = async (modelName: string) => {
  const openrouter = createOpenRouter({
    apiKey: '${API_KEY_REF}',
  });

  const response = streamText({
    model: openrouter(modelName),
    prompt: 'Write a vegetarian lasagna recipe for 4 people.',
  });

  await response.consumeStream();
  return response.text;
};

export const getWeather = async (modelName: string) => {
  const openrouter = createOpenRouter({
    apiKey: '${API_KEY_REF}',
  });

  const response = streamText({
    model: openrouter(modelName),
    prompt: 'What is the weather in San Francisco, CA in Fahrenheit?',
    tools: {
      getCurrentWeather: {
        description: 'Get the current weather in a given location',
        parameters: z.object({
          location: z
            .string()
            .describe('The city and state, e.g. San Francisco, CA'),
          unit: z.enum(['celsius', 'fahrenheit']).optional(),
        }),
        execute: async ({ location, unit = 'celsius' }) => {
          // Mock response for the weather
          const weatherData = {
            'Boston, MA': {
              celsius: '15Â°C',
              fahrenheit: '59Â°F',
            },
            'San Francisco, CA': {
              celsius: '18Â°C',
              fahrenheit: '64Â°F',
            },
          };

          const weather = weatherData[location];
          if (!weather) {
            return `Weather data for ${location} is not available.`;
          }

          return `The current weather in ${location} is ${weather[unit]}.`;
        },
      },
    },
  });

  await response.consumeStream();
  return response.text;
};

```

--------------------------------

### List Providers using Ruby Net::HTTP

Source: https://openrouter.ai/docs/api-reference/providers/list-providers.mdx

This Ruby code snippet shows how to make a GET request to the OpenRouter API to list providers. It uses the built-in `Net::HTTP` and `URI` libraries, including setting the `Authorization` header.

```ruby
require 'uri'
require 'net/http'

url = URI("https://openrouter.ai/api/v1/providers")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["Authorization"] = 'Bearer <token>'

response = http.request(request)
puts response.read_body
```

--------------------------------

### GET /api/v1/credits

Source: https://openrouter.ai/docs/use-cases/crypto-api.mdx

Retrieves the current credit balance and usage for the authenticated account. This endpoint is useful for monitoring credits and preventing service interruptions due to insufficient balance.

```APIDOC
## GET /api/v1/credits

### Description
Retrieves the current credit balance and usage for the authenticated account. This helps in monitoring available credits and ensuring uninterrupted service.

### Method
GET

### Endpoint
/api/v1/credits

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

### Request Example
```typescript
// Using OpenRouter SDK
import { OpenRouter } from '@openrouter/sdk';
const openRouter = new OpenRouter({ apiKey: '<OPENROUTER_API_KEY>' });
const credits = await openRouter.credits.get();
console.log('Available credits:', credits.totalCredits - credits.totalUsage);

// Using fetch
const response = await fetch('https://openrouter.ai/api/v1/credits', {
  method: 'GET',
  headers: { Authorization: 'Bearer <OPENROUTER_API_KEY>' },
});
const { data } = await response.json();
```

### Response
#### Success Response (200)
- **total_credits** (number) - The total number of credits purchased.
- **total_usage** (number) - The total number of credits consumed.

#### Response Example
```json
{
  "data": {
    "total_credits": 50.0,
    "total_usage": 42.0
  }
}
```

#### Error Handling
- Authentication errors (e.g., invalid API key) will result in 401 or 403 status codes.
- Note that these values are cached and may be up to 60 seconds stale.
```

--------------------------------

### GET /api/api_keys/current_key_metadata

Source: https://openrouter.ai/docs/sdks/typescript/apikeys.mdx

Retrieves metadata about the current API key. This endpoint is accessible through the `apiKeysGetCurrentKeyMetadata` function and provides essential information about the key’s status and usage.

```APIDOC
## GET /api/api_keys/current_key_metadata

### Description
Retrieves metadata about the current API key.

### Method
GET

### Endpoint
/api/api_keys/current_key_metadata

### Parameters
#### Path Parameters
- None

#### Query Parameters
- None

#### Request Body
- `options` (RequestOptions) - Optional - Allows setting options for the HTTP request.
  - `options.fetchOptions` (RequestInit) - Optional - Allows setting custom fetch options.
  - `options.retries` (RetryConfig) - Optional - Enables retrying HTTP requests.

### Request Example
```typescript
import { OpenRouterCore } from "@openrouter/sdk/core.js";
import { apiKeysGetCurrentKeyMetadata } from "@openrouter/sdk/funcs/apiKeysGetCurrentKeyMetadata.js";

const openRouter = new OpenRouterCore({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const res = await apiKeysGetCurrentKeyMetadata(openRouter, {
    fetchOptions: { // optional
      headers: {
        "X-Custom-Header": "some-value"
      }
    },
    retries: 3 // optional
  });
  if (res.ok) {
    const { value: result } = res;
    console.log(result);
  } else {
    console.log("apiKeysGetCurrentKeyMetadata failed:", res.error);
  }
}

run();
```

### Response
#### Success Response (200)
- `value` ([operations.GetCurrentKeyResponse](https://openrouter.ai/docs/sdks/typescript/operations/getcurrentkeyresponse)) - Metadata about the current API key.

#### Response Example
```json
{
  "keyId": "key_abcdefg123",
  "plan": "free",
  "enabled": true
}
```

### Errors
| Error Type                         | Status Code | Content Type     |
| ---------------------------------- | ----------- | ---------------- | 
| errors.UnauthorizedResponseError   | 401         | application/json | 
| errors.InternalServerResponseError | 500         | application/json | 
| errors.OpenRouterDefaultError      | 4XX, 5XX    | */*            |
```

--------------------------------

### List Endpoints - Standalone Function TypeScript

Source: https://openrouter.ai/docs/sdks/typescript/endpoints.mdx

Provides a standalone function example for listing endpoints using `endpointsList` from the OpenRouter SDK core. This approach is optimized for tree-shaking and allows for more granular control. It uses `OpenRouterCore` and handles the response, logging success or failure.

```typescript
import { OpenRouterCore } from "@openrouter/sdk/core.js";
import { endpointsList } from "@openrouter/sdk/funcs/endpointsList.js";

// Use `OpenRouterCore` for best tree-shaking performance.
// You can create one instance of it to use across an application.
const openRouter = new OpenRouterCore({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const res = await endpointsList(openRouter, {
    author: "<value>",
    slug: "<value>",
  });
  if (res.ok) {
    const { value: result } = res;
    console.log(result);
  } else {
    console.log("endpointsList failed:", res.error);
  }
}

run();
```

--------------------------------

### GET /api/v1/activity

Source: https://openrouter.ai/docs/api-reference/analytics/get-user-activity.mdx

Retrieves user activity data grouped by endpoint for the last 30 completed UTC days. Supports filtering by a specific date.

```APIDOC
## GET /api/v1/activity

### Description
Retrieves user activity data grouped by endpoint for the last 30 completed UTC days. This endpoint is useful for analyzing usage patterns and understanding API consumption.

### Method
GET

### Endpoint
/api/v1/activity

### Parameters
#### Query Parameters
- **date** (string) - Optional - Filter by a single UTC date in the last 30 days (YYYY-MM-DD format).

#### Header Parameters
- **Authorization** (string) - Required - API key as bearer token in Authorization header.

### Request Example
```bash
curl -X GET \
  'https://openrouter.ai/api/v1/activity?date=2023-10-27' \
  -H 'Authorization: Bearer YOUR_API_KEY'
```

### Response
#### Success Response (200)
- **data** (array) - An array of ActivityItem objects, each detailing usage statistics for a specific date, model, and endpoint.

##### ActivityItem Object
- **date** (string) - The UTC date of the activity.
- **model** (string) - The name of the model used.
- **model_permaslug** (string) - A permanent slug identifier for the model.
- **endpoint_id** (string) - The identifier for the API endpoint.
- **provider_name** (string) - The name of the model provider.
- **usage** (number) - Total usage (e.g., tokens, requests) for the period.
- **byok_usage_inference** (number) - Usage specifically for BYOK (Bring Your Own Key) inference.
- **requests** (number) - The number of requests made.
- **prompt_tokens** (number) - The number of tokens used in prompts.
- **completion_tokens** (number) - The number of tokens generated in completions.
- **reasoning_tokens** (number) - The number of tokens used for reasoning.

#### Response Example (200 OK)
```json
{
  "data": [
    {
      "date": "2023-10-26",
      "model": "gpt-4",
      "model_permaslug": "openai-gpt-4",
      "endpoint_id": "default",
      "provider_name": "OpenAI",
      "usage": 150000,
      "byok_usage_inference": 0,
      "requests": 100,
      "prompt_tokens": 100000,
      "completion_tokens": 50000,
      "reasoning_tokens": 0
    }
  ]
}
```

#### Error Responses
- **400 Bad Request**: Invalid date format or date range.
- **401 Unauthorized**: Authentication required or invalid credentials.
- **403 Forbidden**: Only provisioning keys can fetch activity.
- **500 Internal Server Error**: Unexpected server error.
```

--------------------------------

### Running the Application and API Interaction

Source: https://openrouter.ai/docs/community/mastra.mdx

Details on how to run the Mastra development server and interact with the configured agent via REST API or the playground.

```APIDOC
## Running the Application and API Interaction

### Description
This section covers starting the Mastra development server and interacting with your OpenRouter-configured agent through its REST API endpoint or the interactive playground.

### Step 4: Running the Application

Start the Mastra development server using the following command:

```bash
npm run dev
```

Your agent will be accessible via:
*   **REST API endpoint**: `http://localhost:4111/api/agents/assistant/generate`
*   **Interactive playground**: `http://localhost:4111`

### Testing the API Endpoint

You can test the generated API endpoint using `curl`:

```bash
curl -X POST http://localhost:4111/api/agents/assistant/generate \
-H "Content-Type: application/json" \
-d '{"messages": ["What are the latest advancements in quantum computing?"]}'
```

### Basic Integration Example

Here's a code snippet demonstrating basic integration with Mastra using the OpenRouter AI provider:

```typescript
import { Agent } from '@mastra/core/agent';
import { createOpenRouter } from '@openrouter/ai-sdk-provider';

// Initialize the OpenRouter provider
const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY,
});

// Create an agent using OpenRouter
const assistant = new Agent({
  model: openrouter('anthropic/claude-3-opus'),
  name: 'Assistant',
  instructions: 'You are a helpful assistant.',
});

// Generate a response
const response = await assistant.generate([
  {
    role: 'user',
    content: 'Tell me about renewable energy sources.',
  },
]);

console.log(response.text);
```

```

--------------------------------

### GET /api/models

Source: https://openrouter.ai/docs/api-reference/models/list-models-user.mdx

Retrieves a list of models available through the OpenRouter platform. This endpoint returns a paginated list of model objects, each containing details such as ID, canonical slug, name, creation date, pricing, context length, architecture, top provider, and request limits.

```APIDOC
## GET /api/models

### Description
Retrieves a list of models available through the OpenRouter platform.

### Method
GET

### Endpoint
/api/models

### Parameters
#### Path Parameters
- None

#### Query Parameters
- `limit` (number) - Optional - Maximum number of models to return per page.
- `offset` (number) - Optional - The starting offset for retrieving models.

### Request Example
None

### Response
#### Success Response (200)
- **data** (array of objects) - An array of model objects.
  - **id** (string) - The unique identifier of the model.
  - **canonical_slug** (string) - The canonical slug for the model.
  - **name** (string) - The name of the model.
  - **created** (number) - The timestamp when the model was created.
  - **pricing** (object) - Pricing information for the model.
  - **context_length** (number) - The context length of the model.
  - **architecture** (object) - The architecture of the model.
  - **top_provider** (object) - Information about the model's top provider.
  - **per_request_limits** (object) - Per-request limits for the model.
  - **supported_parameters** (array) - An array of supported parameters.
  - **default_parameters** (object) - Default parameter values for the model, including:
    - `temperature` (number or null) - Default temperature value.
    - `top_p` (number or null) - Default top_p value.
    - `frequency_penalty` (number or null) - Default frequency_penalty value.

#### Response Example
{
  "data": [
    {
      "id": "string",
      "canonical_slug": "string",
      "name": "string",
      "created": 1678886400.0,
      "pricing": { ... },
      "context_length": 4096,
      "architecture": { ... },
      "top_provider": { ... },
      "per_request_limits": { ... },
      "supported_parameters": [ ... ]
      "default_parameters": {
          "temperature": 0.7,
          "top_p": 0.9
      }
    }
  ]
}
```

--------------------------------

### GET /models

Source: https://openrouter.ai/docs/api-reference/models/get-models.mdx

Retrieves a list of available models from the OpenRouter API. Each model includes details such as ID, name, pricing, context length, architecture, supported parameters, and default parameters. This endpoint is useful for discovering and selecting models for inference requests.

```APIDOC
## GET /models

### Description
This endpoint fetches a list of all available models, providing comprehensive details on each model's capabilities, limits, and configuration options.

### Method
GET

### Endpoint
/api/v1/models

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

### Request Example
None (GET request with no body)

### Response
#### Success Response (200)
- **data** (array of Model objects) - List of model details
  - **id** (string) - Unique model identifier
  - **canonical_slug** (string) - Canonical slug for the model
  - **hugging_face_id** (string or null) - Hugging Face model ID if applicable
  - **name** (string) - Human-readable model name
  - **created** (number, double) - Timestamp when the model was added
  - **description** (string) - Description of the model
  - **pricing** (object) - Pricing information (references PublicPricing schema)
  - **context_length** (number or null, double) - Maximum context length in tokens
  - **architecture** (object) - Model architecture details (references ModelArchitecture schema)
  - **top_provider** (object) - Information on the top provider (references TopProviderInfo schema)
  - **per_request_limits** (object) - Token limits per request
    - **prompt_tokens** (number, double) - Maximum prompt tokens
    - **completion_tokens** (number, double) - Maximum completion tokens
  - **supported_parameters** (array of strings) - List of supported parameters (e.g., temperature, top_p, etc.)
  - **default_parameters** (object) - Default values for parameters
    - **temperature** (number or null, double) - Default temperature
    - **top_p** (number or null, double) - Default top_p
    - **frequency_penalty** (number or null, double) - Default frequency penalty

#### Response Example
{
  "data": [
    {
      "id": "model-id",
      "canonical_slug": "model-slug",
      "hugging_face_id": "hf/model",
      "name": "Model Name",
      "created": 1234567890.0,
      "description": "A powerful language model.",
      "pricing": {},
      "context_length": 4096.0,
      "architecture": {},
      "top_provider": {},
      "per_request_limits": {
        "prompt_tokens": 4000.0,
        "completion_tokens": 1000.0
      },
      "supported_parameters": [
        "temperature",
        "top_p"
      ],
      "default_parameters": {
        "temperature": 0.7,
        "top_p": 1.0,
        "frequency_penalty": 0.0
      }
    }
  ]
}
```

--------------------------------

### Summary Reasoning Detail Object Example

Source: https://openrouter.ai/docs/use-cases/reasoning-tokens.mdx

This JSON object represents a 'summary' type reasoning detail. It includes a type, a high-level summary of the reasoning process, a unique ID, the format of the reasoning detail, and an optional index.

```json
{
  "type": "reasoning.summary",
  "summary": "The model analyzed the problem by first identifying key constraints, then evaluating possible solutions...",
  "id": "reasoning-summary-1",
  "format": "anthropic-claude-v1",
  "index": 0
}
```

--------------------------------

### Update API Key - Swift

Source: https://openrouter.ai/docs/api-reference/api-keys/update-keys.mdx

This Swift example demonstrates updating an API key using `URLSession`. It constructs an `NSMutableURLRequest` with the PATCH method, sets headers, and encodes a dictionary into JSON for the request body. The task is then resumed.

```swift
import Foundation

let headers = [
  "Authorization": "Bearer <token>",
  "Content-Type": "application/json"
]
let parameters = [
  "name": "Updated API Key Name",
  "disabled": false,
  "limit": 75,
  "limit_reset": "daily",
  "include_byok_in_limit": true
] as [String : Any]

let postData = JSONSerialization.data(withJSONObject: parameters, options: [])

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/keys/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")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "PATCH"
request.allHTTPHeaderFields = headers
request.httpBody = postData as Data

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### Stream Responses with Python Requests and SSE

Source: https://openrouter.ai/docs/api-reference/streaming.mdx

Provides a Python example for streaming responses from the OpenRouter API using the `requests` library. It handles Server-Sent Events (SSE) by iterating over the response content, parsing JSON data from each chunk, and printing the model's output incrementally.

```python
import requests
import json

question = "How would you build the tallest building ever?"

url = "https://openrouter.ai/api/v1/chat/completions"
headers = {
  "Authorization": f"Bearer {{API_KEY_REF}}",
  "Content-Type": "application/json"
}

payload = {
  "model": "{{MODEL}}",
  "messages": [{"role": "user", "content": question}],
  "stream": True
}

buffer = ""
with requests.post(url, headers=headers, json=payload, stream=True) as r:
  for chunk in r.iter_content(chunk_size=1024, decode_unicode=True):
    buffer += chunk
    while True:
      try:
        # Find the next complete SSE line
        line_end = buffer.find('\n')
        if line_end == -1:
          break

        line = buffer[:line_end].strip()
        buffer = buffer[line_end + 1:]

        if line.startswith('data: '):
          data = line[6:]
          if data == '[DONE]':
            break

          try:
            data_obj = json.loads(data)
            content = data_obj["choices"][0]["delta"].get("content")
            if content:
              print(content, end="", flush=True)
          except json.JSONDecodeError:
            pass
      except Exception:
        break
```

--------------------------------

### GET /api/v1/key

Source: https://openrouter.ai/docs/api-reference/api-keys/get-current-key.mdx

Retrieves information about the API key associated with the current authentication session. This endpoint is useful for monitoring API usage and rate limits.

```APIDOC
## GET /api/v1/key

### Description
Get information on the API key associated with the current authentication session.

### Method
GET

### Endpoint
https://openrouter.ai/api/v1/key

### Parameters
#### Header Parameters
- **Authorization** (string) - Required - API key as bearer token in Authorization header

### Request Example
```bash
curl -X GET https://openrouter.ai/api/v1/key \
     -H "Authorization: Bearer YOUR_API_KEY"
```

### Response
#### Success Response (200)
- **data** (object) - Contains detailed information about the API key, including usage, limits, and rate limit details.
  - **label** (string) - The label of the API key.
  - **limit** (number | null) - The usage limit for the API key.
  - **usage** (number) - Current usage of the API key.
  - **usage_daily** (number) - Daily usage of the API key.
  - **usage_weekly** (number) - Weekly usage of the API key.
  - **usage_monthly** (number) - Monthly usage of the API key.
  - **byok_usage** (number) - Usage with BYOK (Bring Your Own Key).
  - **byok_usage_daily** (number) - Daily BYOK usage.
  - **byok_usage_weekly** (number) - Weekly BYOK usage.
  - **byok_usage_monthly** (number) - Monthly BYOK usage.
  - **is_free_tier** (boolean) - Indicates if the key is on the free tier.
  - **is_provisioning_key** (boolean) - Indicates if the key is a provisioning key.
  - **limit_remaining** (number | null) - Remaining limit for the API key.
  - **limit_reset** (string | null) - Timestamp when the limit resets.
  - **include_byok_in_limit** (boolean) - Whether BYOK usage is included in the limit.
  - **rate_limit** (object) - Details about the rate limit.
    - **requests** (number) - The number of requests allowed.
    - **interval** (string) - The time interval for the rate limit (e.g., 'hour', 'day').
    - **note** (string) - A note regarding the rate limit.

#### Error Response (401)
- **description**: Unauthorized - Authentication required or invalid credentials

#### Error Response (500)
- **description**: Internal Server Error - Unexpected server error

#### Response Example (200)
```json
{
  "data": {
    "label": "my-api-key",
    "limit": 100000,
    "usage": 1500,
    "usage_daily": 500,
    "usage_weekly": 1200,
    "usage_monthly": 1500,
    "byok_usage": 0,
    "byok_usage_daily": 0,
    "byok_usage_weekly": 0,
    "byok_usage_monthly": 0,
    "is_free_tier": false,
    "is_provisioning_key": false,
    "limit_remaining": 98500,
    "limit_reset": "2024-03-15T10:00:00Z",
    "include_byok_in_limit": true,
    "rate_limit": {
      "requests": 5000,
      "interval": "hour",
      "note": "Rate limit per hour"
    }
  }
}
```
```

--------------------------------

### Check Rate Limits and Credits - TypeScript (Raw API)

Source: https://openrouter.ai/docs/api-reference/limits.mdx

This TypeScript snippet demonstrates retrieving rate limit and credit information by making a raw HTTP GET request to the `/api/v1/key` endpoint.  It uses the `fetch` API to make the request and parses the JSON response.

```typescript
const response = await fetch('https://openrouter.ai/api/v1/key', {
  method: 'GET',
  headers: {
    Authorization: 'Bearer {{API_KEY_REF}}',
  },
});

const keyInfo = await response.json();
console.log(keyInfo);
```

--------------------------------

### GET /models/for-user

Source: https://openrouter.ai/docs/sdks/typescript/models.mdx

List models filtered by user provider preferences. This endpoint returns only the models that match the user's specified provider preferences and settings.

```APIDOC
## GET /models/for-user

### Description
List models filtered by user provider preferences

### Method
GET

### Endpoint
/models/for-user

### Parameters
#### Query Parameters
- No query parameters required

#### Request Body
- No request body required

### Request Example
```
GET /models/for-user
```

### Response
#### Success Response (200)
- **models** (array) - Array of model objects matching user preferences

#### Response Example
```json
{
  "models": [
    {
      "id": "openai/gpt-3.5-turbo",
      "name": "GPT-3.5 Turbo",
      "description": "Fast and efficient language model",
      "pricing": {
        "prompt": "0.0015",
        "completion": "0.002"
      },
      "context_length": 4096,
      "top_provider": {
        "context_length": 4096,
        "max_completion_tokens": 4096
      }
    }
  ]
}
```

### SDK Usage Examples

#### Standard SDK Usage
```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.models.listForUser();
  console.log(result);
}

run();
```

#### Standalone Function
```typescript
import { OpenRouterCore } from "@openrouter/sdk/core.js";
import { modelsListForUser } from "@openrouter/sdk/funcs/modelsListForUser.js";

const openRouter = new OpenRouterCore({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const res = await modelsListForUser(openRouter);
  if (res.ok) {
    const { value: result } = res;
    console.log(result);
  } else {
    console.log("modelsListForUser failed:", res.error);
  }
}

run();
```
```

--------------------------------

### Update API Key - PHP (Guzzle)

Source: https://openrouter.ai/docs/api-reference/api-keys/update-keys.mdx

This PHP example uses the Guzzle HTTP client to update an API key. It creates a client instance and makes a PATCH request with specified headers and a JSON body. The response body is then echoed.

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('PATCH', 'https://openrouter.ai/api/v1/keys/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', [
  'body' => '{
  "name": "Updated API Key Name",
  "disabled": false,
  "limit": 75,
  "limit_reset": "daily",
  "include_byok_in_limit": true
}',
  'headers' => [
    'Authorization' => 'Bearer <token>',
    'Content-Type' => 'application/json',
  ],
]);

echo $response->getBody();
?>
```

--------------------------------

### GET /models

Source: https://openrouter.ai/docs/api-reference/models/get-models.mdx

This endpoint retrieves a list of all models available on OpenRouter, optionally filtered by category or supported parameters. It supports returning data in JSON format or as an RSS feed. Authentication is required via an API key in the Authorization header.

```APIDOC
## GET /models

### Description
Retrieves a list of all models and their properties from OpenRouter. Optionally filter by category, supported parameters, or enable RSS feed output.

### Method
GET

### Endpoint
/models

### Parameters
#### Path Parameters
(None)

#### Query Parameters
- **category** (string) - Optional - Filter models by category
- **supported_parameters** (string) - Optional - Filter by supported parameters
- **use_rss** (string) - Optional - Enable RSS feed output
- **use_rss_chat_links** (string) - Optional - Include chat links in RSS feed

#### Request Body
(None)

### Request Example
(No request body for GET request)

### Response
#### Success Response (200)
Returns a list of models or RSS feed based on parameters.

#### Response Example
{
  "models": [
    {
      "id": "example-model",
      "name": "Example Model",
      "pricing": {
        "prompt": 0.02,
        "completion": 0.02
      },
      "architecture": {
        "modality": "text",
        "input_modalities": ["text"],
        "output_modalities": ["text"]
      }
    }
  ]
}

#### Error Responses
- **400 Bad Request**: Invalid request parameters
- **500 Internal Server Error**: Server error
```

--------------------------------

### Get Current API Key Metadata (Standalone TypeScript)

Source: https://openrouter.ai/docs/sdks/typescript/apikeys.mdx

Demonstrates how to fetch the current API key's metadata using a standalone TypeScript function from the OpenRouter SDK. It initializes the core SDK and calls the `apiKeysGetCurrentKeyMetadata` function, handling success and error responses.

```typescript
import { OpenRouterCore } from "@openrouter/sdk/core.js";
import { apiKeysGetCurrentKeyMetadata } from "@openrouter/sdk/funcs/apiKeysGetCurrentKeyMetadata.js";

// Use `OpenRouterCore` for best tree-shaking performance.
// You can create one instance of it to use across an application.
const openRouter = new OpenRouterCore({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const res = await apiKeysGetCurrentKeyMetadata(openRouter);
  if (res.ok) {
    const { value: result } = res;
    console.log(result);
  } else {
    console.log("apiKeysGetCurrentKeyMetadata failed:", res.error);
  }
}

run();
```

--------------------------------

### Configure Provider Fallback Strategy

Source: https://openrouter.ai/docs/features/provider-routing.mdx

Demonstrates how to disable automatic fallbacks and specify a strict order of providers. When allow_fallbacks is false, the request will only try providers in the specified order and fail if none succeed. This example shows requesting the Mixtral model through OpenAI and Together providers in sequence.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
});

const completion = await openRouter.chat.send({
  model: 'mistralai/mixtral-8x7b-instruct',
  messages: [{ role: 'user', content: 'Hello' }],
  provider: {
    order: ['openai', 'together'],
    allowFallbacks: false,
  },
  stream: false,
});
```

```typescript
fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer <OPENROUTER_API_KEY>',
    'HTTP-Referer': '<YOUR_SITE_URL>',
    'X-Title': '<YOUR_SITE_NAME>',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'mistralai/mixtral-8x7b-instruct',
    messages: [{ role: 'user', content: 'Hello' }],
    provider: {
      order: ['openai', 'together'],
      allow_fallbacks: false,
    },
  }),
});
```

```python
import requests

headers = {
  'Authorization': 'Bearer <OPENROUTER_API_KEY>',
  'HTTP-Referer': '<YOUR_SITE_URL>',
  'X-Title': '<YOUR_SITE_NAME>',
  'Content-Type': 'application/json',
}

response = requests.post('https://openrouter.ai/api/v1/chat/completions', headers=headers, json={
  'model': 'mistralai/mixtral-8x7b-instruct',
  'messages': [{ 'role': 'user', 'content': 'Hello' }],
  'provider': {
    'order': ['openai', 'together'],
    'allow_fallbacks': False,
  },
})
```

--------------------------------

### Enable OpenRouter Web Search Plugin

Source: https://openrouter.ai/docs/community/live-kit.mdx

Demonstrates how to enable OpenRouter's web search capabilities within the LLM configuration. This involves defining a web search plugin with parameters like `max_results` and a custom `search_prompt`, using the 'google/gemini-2.5-flash-preview-09-2025' model.

```python
from livekit.plugins import openai

llm = openai.LLM.with_openrouter(
    model="google/gemini-2.5-flash-preview-09-2025",
    plugins=[
        openai.OpenRouterWebPlugin(
            max_results=5,
            search_prompt="Search for relevant information",
        )
    ],
)
```

--------------------------------

### POST /v1/completions

Source: https://openrouter.ai/docs/api-reference/completions/create-completions.mdx

Creates a text completion for a given prompt and parameters. This endpoint can be used for both streaming and non-streaming text generation.

```APIDOC
## POST /v1/completions

### Description
Creates a completion for the provided prompt and parameters. Supports both streaming and non-streaming modes.

### Method
POST

### Endpoint
/v1/completions

### Parameters
#### Query Parameters
None

#### Request Body
- **model** (string) - Required - The model to use for generating the completion.
- **prompt** (string) - Required - The prompt to generate a completion for.
- **max_tokens** (integer) - Optional - The maximum number of tokens to generate in the completion.
- **temperature** (number) - Optional - Controls randomness. Lower values make the output more focused and deterministic.
- **stream** (boolean) - Optional - Whether to stream the response.

### Request Example
```json
{
  "model": "openrouter/auto",
  "prompt": "Write a short story about a robot learning to love.",
  "max_tokens": 150,
  "temperature": 0.7,
  "stream": false
}
```

### Response
#### Success Response (200)
- **id** (string) - The ID of the completion.
- **object** (string) - The type of object returned, e.g., 'text_completion'.
- **created** (integer) - Timestamp of creation.
- **model** (string) - The model used for completion.
- **choices** (array) - An array of completion choices.
  - **text** (string) - The generated text completion.
  - **index** (integer) - The index of the choice.
  - **logprobs** (null) - Log probabilities (currently null).
  - **finish_reason** (string) - The reason the completion finished (e.g., 'stop', 'length').
- **usage** (object) - Usage statistics for the completion.
  - **prompt_tokens** (integer) - Number of tokens in the prompt.
  - **completion_tokens** (integer) - Number of tokens in the completion.
  - **total_tokens** (integer) - Total tokens used.

#### Response Example
```json
{
  "id": "cmpl-xxxxxxxxxxxxxx",
  "object": "text_completion",
  "created": 1677652288,
  "model": "openrouter/auto",
  "choices": [
    {
      "text": "Unit 734 processed the data. Logic dictated efficiency. Yet, a strange warmth bloomed in its circuits when interacting with the human child. It was… illogical. It was… love.",
      "index": 0,
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 30,
    "total_tokens": 40
  }
}
```
```

--------------------------------

### GET /models/embeddings

Source: https://openrouter.ai/docs/sdks/typescript/models.mdx

List all available embedding models. This endpoint specifically returns models that are optimized for creating vector embeddings from text, useful for semantic search and similarity tasks.

```APIDOC
## GET /models/embeddings

### Description
List all embeddings models

### Method
GET

### Endpoint
/models/embeddings

### Parameters
#### Query Parameters
- No query parameters required

#### Request Body
- No request body required

### Request Example
```
GET /models/embeddings
```

### Response
#### Success Response (200)
- **models** (array) - Array of embedding model objects

#### Response Example
```json
{
  "models": [
    {
      "id": "text-embedding-ada-002",
      "name": "text-embedding-ada-002",
      "description": "Optimized for generating text embeddings",
      "context_length": 8192,
      "pricing": {
        "prompt": "0.0004"
      }
    }
  ]
}
```

### SDK Usage Examples

#### Standard SDK Usage
```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.models.listEmbeddings();
  console.log(result);
}

run();
```

#### Standalone Function
```typescript
import { OpenRouterCore } from "@openrouter/sdk/core.js";
import { modelsListEmbeddings } from "@openrouter/sdk/funcs/modelsListEmbeddings.js";

const openRouter = new OpenRouterCore({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const res = await modelsListEmbeddings(openRouter);
  if (res.ok) {
    const { value: result } = res;
    console.log(result);
  } else {
    console.log("modelsListEmbeddings failed:", res.error);
  }
}

run();
```
```

--------------------------------

### Sort Providers by Throughput (TypeScript, Python)

Source: https://openrouter.ai/docs/features/provider-routing.mdx

Demonstrates how to explicitly sort AI providers by throughput using the `provider.sort: 'throughput'` option. This example shows implementation in TypeScript via SDK and fetch, and in Python using the `requests` library. It bypasses default load balancing to prioritize providers with higher throughput.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
});

const completion = await openRouter.chat.send({
  model: 'meta-llama/llama-3.1-70b-instruct',
  messages: [{ role: 'user', content: 'Hello' }],
  provider: {
    sort: 'throughput',
  },
  stream: false,
});
```

```typescript
fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer <OPENROUTER_API_KEY>',
    'HTTP-Referer': '<YOUR_SITE_URL>',
    'X-Title': '<YOUR_SITE_NAME>',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'meta-llama/llama-3.1-70b-instruct',
    messages: [{ role: 'user', content: 'Hello' }],
    provider: {
      sort: 'throughput',
    },
  }),
});
```

```python
import requests

headers = {
  'Authorization': 'Bearer <OPENROUTER_API_KEY>',
  'HTTP-Referer': '<YOUR_SITE_URL>',
  'X-Title': '<YOUR_SITE_NAME>',
  'Content-Type': 'application/json',
}

response = requests.post('https://openrouter.ai/api/v1/chat/completions', headers=headers, json={
  'model': 'meta-llama/llama-3.1-70b-instruct',
  'messages': [{ 'role': 'user', 'content': 'Hello' }],
  'provider': {
    'sort': 'throughput',
  },
})
```

--------------------------------

### Create API Key - Swift

Source: https://openrouter.ai/docs/api-reference/api-keys/create-keys.mdx

This Swift code snippet demonstrates how to create a new API key using the OpenRouter.ai API. It constructs and sends a POST request to the `/api/v1/keys` endpoint with the required parameters. Requires a Swift environment with URLSession support.

```Swift
import Foundation

let headers = [
  "Authorization": "Bearer &lt;token&gt;",
  "Content-Type": "application/json"
]
let parameters = [
  "name": "My New API Key",
  "limit": 50,
  "limit_reset": "monthly",
  "include_byok_in_limit": true
] as [String : Any]

let postData = JSONSerialization.data(withJSONObject: parameters, options: [])

let request = NSMutableURLRequest(url: NSURL(string: "https://openrouter.ai/api/v1/keys")! as URL, 
                                        cachePolicy: .useProtocolCachePolicy, 
                                    timeoutInterval: 10.0)
request.httpMethod = "POST"
request.allHTTPHeaderFields = headers
request.httpBody = postData as Data

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
  if (error != nil) {
    print(error as Any)
  } else {
    let httpResponse = response as? HTTPURLResponse
    print(httpResponse)
  }
})

dataTask.resume()
```

--------------------------------

### Chat Completions in TypeScript with OpenRouter SDK

Source: https://openrouter.ai/docs/sdks/typescript.mdx

Perform AI-powered chat completions using the OpenRouter TypeScript SDK. Depends on the @openrouter/sdk package and a valid OpenRouter API key. Inputs: API key via environment, model name, user messages, optional parameters like temperature. Outputs: Chat response object or stream of chunks. Limitations: Requires internet, valid API key, and supported model.

```typescript
import OpenRouter from '@openrouter/sdk';

const client = new OpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY
});

const response = await client.chat.completions.create({
  model: "minimax/minimax-m2",
  messages: [
    { role: "user", content: "Explain quantum computing" }
  ]
});
```

```typescript
import OpenRouter from '@openrouter/sdk';

const client = new OpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY
});

const response = await client.chat.completions.create({
  model: "minimax/minimax-m2",
  messages: [
    { role: "user", content: "Hello" }
    // â† Your IDE validates message structure
  ],
  temperature: 0.7, // â† Type-checked
  stream: true      // â† Response type changes based on this
});
```

```typescript
import OpenRouter from '@openrouter/sdk';

const client = new OpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY
});

const stream = await client.chat.completions.create({
  model: "minimax/minimax-m2",
  messages: [{ role: "user", content: "Write a story" }],
  stream: true
});

for await (const chunk of stream) {
  // Full type information for streaming responses
  const content = chunk.choices[0]?.delta?.content;
}
```

```typescript
import OpenRouter from '@openrouter/sdk';

const client = new OpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY
});

const response = await client.chat.completions.create({
  model: "minimax/minimax-m2",
  messages: [
    { role: "user", content: "Hello!" }
  ]
});

console.log(response.choices[0].message.content);
```

--------------------------------

### SSE Comments and Stream Cancellation

Source: https://openrouter.ai/docs/api-reference/streaming.mdx

This section explains how OpenRouter uses SSE comments for streaming requests and how to implement stream cancellation for supported providers. It includes examples in TypeScript and Python.

```APIDOC
## Handling SSE Comments and Stream Cancellation

### Description
OpenRouter occasionally sends comments in SSE streams to prevent connection timeouts. These comments, formatted as `: COMMENT_TEXT`, can be safely ignored according to SSE specifications but can be used for UX enhancements. This section also details how to cancel streaming requests, which immediately stops model processing and billing for supported providers.

### Supported Providers for Cancellation

**Supported:** OpenAI, Azure, Anthropic, Fireworks, Mancer, Recursal, AnyScale, Lepton, OctoAI, Novita, DeepInfra, Together, Cohere, Hyperbolic, Infermatic, Avian, XAI, Cloudflare, SFCompute, Nineteen, Liquid, Friendli, Chutes, DeepSeek

**Not Currently Supported:** AWS Bedrock, Groq, Modal, Google, Google AI Studio, Minimax, HuggingFace, Replicate, Perplexity, Mistral, AI21, Featherless, Lynn, Lambda, Reflection, SambaNova, Inflection, ZeroOneAI, AionLabs, Alibaba, Nebius, Kluster, Targon, InferenceNet

### Implementation Examples

#### TypeScript SDK
```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: 'YOUR_API_KEY',
});

const controller = new AbortController();

try {
  const stream = await openRouter.chat.send({
    model: 'model-name',
    messages: [{ role: 'user', content: 'Write a story' }],
    stream: true,
  }, {
    signal: controller.signal,
  });

  for await (const chunk of stream) {
    const content = chunk.choices?.[0]?.delta?.content;
    if (content) {
      console.log(content);
    }
  }
} catch (error) {
  if (error.name === 'AbortError') {
    console.log('Stream cancelled');
  } else {
    throw error;
  }
}

// To cancel the stream:
controller.abort();
```

#### Python (requests)
```python
import requests
from threading import Event, Thread

def stream_with_cancellation(prompt: str, cancel_event: Event):
    with requests.Session() as session:
        response = session.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers={"Authorization": f"Bearer YOUR_API_KEY"},
            json={"model": "model-name", "messages": [{"role": "user", "content": prompt}], "stream": True},
            stream=True
        )

        try:
            for line in response.iter_lines():
                if cancel_event.is_set():
                    response.close()
                    return
                if line:
                    print(line.decode(), end="", flush=True)
        finally:
            response.close()

# Example usage:
cancel_event = Event()
stream_thread = Thread(target=lambda: stream_with_cancellation("Write a story", cancel_event))
stream_thread.start()

# To cancel the stream:
cancel_event.set()
```

#### TypeScript (fetch)
```typescript
const controller = new AbortController();

try {
  const response = await fetch(
    'https://openrouter.ai/api/v1/chat/completions',
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer YOUR_API_KEY`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'model-name',
        messages: [{ role: 'user', content: 'Write a story' }],
        stream: true,
      }),
      signal: controller.signal,
    },
  );

  // Process the stream...
} catch (error) {
  if (error.name === 'AbortError') {
    console.log('Stream cancelled');
  } else {
    throw error;
  }
}

// To cancel the stream:
controller.abort();
```

### Warning
Cancellation is only effective for streaming requests with supported providers. For non-streaming requests or unsupported providers, the model will complete processing, and you will be billed accordingly.

### Recommended SSE Clients
*   [eventsource-parser](https://github.com/rexxars/eventsource-parser)
*   [OpenAI SDK](https://www.npmjs.com/package/openai)
*   [Vercel AI SDK](https://www.npmjs.com/package/ai)

```

--------------------------------

### Initialize OpenRouter with Advanced Options - TypeScript

Source: https://openrouter.ai/docs/community/mastra.mdx

Demonstrates how to initialize the OpenRouter client with advanced configuration options, including API key and extra body parameters for reasoning.

```typescript
import { Agent } from '@mastra/core/agent';
import { createOpenRouter } from '@openrouter/ai-sdk-provider';

// Initialize with advanced options
const openrouter = createOpenRouter({
  apiKey: process.env.OPENROUTER_API_KEY,
  extraBody: {
    reasoning: {
      max_tokens: 10,
    },
  },
});

// Create an agent with model-specific options
const chefAgent = new Agent({
  model: openrouter('anthropic/claude-3.7-sonnet', {
    extraBody: {
      reasoning: {
        max_tokens: 10,
      },
    },
  }),
  name: 'Chef',
  instructions: 'You are a chef assistant specializing in French cuisine.',
});
```

--------------------------------

### List Providers using PHP (Guzzle)

Source: https://openrouter.ai/docs/api-reference/providers/list-providers.mdx

This PHP code snippet illustrates fetching AI providers from OpenRouter API using the Guzzle HTTP client. It includes setting the necessary `Authorization` header for the GET request.

```php
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('GET', 'https://openrouter.ai/api/v1/providers', [
  'headers' => [
    'Authorization' => 'Bearer <token>',
  ],
]);

echo $response->getBody();

```

--------------------------------

### Process PDF URL with OpenRouter API

Source: https://openrouter.ai/docs/features/multimodal/pdfs.mdx

Demonstrates how to send a PDF URL to OpenRouter.ai API for processing. The example shows how to configure the API request with optional PDF processing engine settings. Supports TypeScript SDK, TypeScript fetch, and Python.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '{{API_KEY_REF}}',
});

const result = await openRouter.chat.send({
  model: '{{MODEL}}',
  messages: [
    {
      role: 'user',
      content: [
        {
          type: 'text',
          text: 'What are the main points in this document?',
        },
        {
          type: 'file',
          file: {
            filename: 'document.pdf',
            fileData: 'https://bitcoin.org/bitcoin.pdf',
          },
        },
      ],
    },
  ],
  plugins: [
    {
      id: 'file-parser',
      pdf: {
        engine: '{{ENGINE}}',
      },
    },
  ],
  stream: false,
});

console.log(result);
```

```python
import requests
import json

url = "https://openrouter.ai/api/v1/chat/completions"
headers = {
    "Authorization": f"Bearer {API_KEY_REF}",
    "Content-Type": "application/json"
}

messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "text",
                "text": "What are the main points in this document?"
            },
            {
                "type": "file",
                "file": {
                    "filename": "document.pdf",
                    "file_data": "https://bitcoin.org/bitcoin.pdf"
                }
            },
        ]
    }
]

plugins = [
    {
        "id": "file-parser",
        "pdf": {
            "engine": "{{ENGINE}}"
        }
    }
]

payload = {
    "model": "{{MODEL}}",
    "messages": messages,
    "plugins": plugins
}

response = requests.post(url, headers=headers, json=payload)
print(response.json())
```

```typescript
const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    Authorization: `Bearer ${API_KEY_REF}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: '{{MODEL}}',
    messages: [
      {
        role: 'user',
        content: [
          {
            type: 'text',
            text: 'What are the main points in this document?',
          },
          {
            type: 'file',
            file: {
              filename: 'document.pdf',
              file_data: 'https://bitcoin.org/bitcoin.pdf',
            },
          },
        ],
      },
    ],
    plugins: [
      {
        id: 'file-parser',
        pdf: {
          engine: '{{ENGINE}}',
        },
      },
    ],
  }),
});

const data = await response.json();
console.log(data);
```

--------------------------------

### Sort Providers by Latency (TypeScript, Python)

Source: https://openrouter.ai/docs/features/provider-routing.mdx

Demonstrates how to explicitly sort AI providers by the lowest latency using the `provider.sort: 'latency'` option. This example shows implementation in TypeScript via SDK and fetch, and in Python using the `requests` library. It bypasses default load balancing to prioritize providers with the lowest latency.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
});

const completion = await openRouter.chat.send({
  model: 'meta-llama/llama-3.1-70b-instruct',
  messages: [{ role: 'user', content: 'Hello' }],
  provider: {
    sort: 'latency',
  },
  stream: false,
});
```

```typescript
fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer <OPENROUTER_API_KEY>',
    'HTTP-Referer': '<YOUR_SITE_URL>',
    'X-Title': '<YOUR_SITE_NAME>',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'meta-llama/llama-3.1-70b-instruct',
    messages: [{ role: 'user', content: 'Hello' }],
    provider: {
      sort: 'latency',
    },
  }),
});
```

```python
import requests

headers = {
  'Authorization': 'Bearer <OPENROUTER_API_KEY>',
  'HTTP-Referer': '<YOUR_SITE_URL>',
  'X-Title': '<YOUR_SITE_NAME>',
  'Content-Type': 'application/json',
}

response = requests.post('https://openrouter.ai/api/v1/chat/completions', headers=headers, json={
  'model': 'meta-llama/llama-3.1-70b-instruct',
  'messages': [{ 'role': 'user', 'content': 'Hello' }],
  'provider': {
    'sort': 'latency',
  },
})
```

--------------------------------

### GET /activity

Source: https://openrouter.ai/docs/sdks/typescript/analytics.mdx

Returns user activity data grouped by endpoint for the last 30 completed UTC days. This endpoint provides analytics information about API usage patterns and endpoint performance.

```APIDOC
## GET /activity

### Description
Returns user activity data grouped by endpoint for the last 30 completed UTC days

### Method
GET

### Endpoint
/activity

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

### Request Example
```
GET /activity
```

### Response
#### Success Response (200)
- **data** (array) - Array of user activity objects grouped by endpoint
- **metadata** (object) - Response metadata including timing and pagination info

#### Response Example
{
  "data": [
    {
      "endpoint": "/api/models",
      "requests": 1250,
      "avg_response_time": 245,
      "success_rate": 0.987
    },
    {
      "endpoint": "/api/completions",
      "requests": 890,
      "avg_response_time": 1200,
      "success_rate": 0.952
    }
  ],
  "period": "30_days",
  "generated_at": "2024-01-15T10:30:00Z"
}
```

--------------------------------

### Define and Call Weather Tool with OpenRouter API (TypeScript, Python, cURL)

Source: https://openrouter.ai/docs/api-reference/responses-api/tool-calling.mdx

Demonstrates how to define a 'get_weather' tool using the OpenAI function calling format and make an API call to OpenRouter to execute it. This involves specifying the tool's schema, user input, and tool choice. The code is provided in TypeScript, Python, and cURL.

```typescript
const weatherTool = {
    type: 'function' as const,
    name: 'get_weather',
    description: 'Get the current weather in a location',
    strict: null,
    parameters: {
      type: 'object',
      properties: {
        location: {
          type: 'string',
          description: 'The city and state, e.g. San Francisco, CA',
        },
        unit: {
          type: 'string',
          enum: ['celsius', 'fahrenheit'],
        },
      },
      required: ['location'],
    },
  };

  const response = await fetch('https://openrouter.ai/api/v1/responses', {
    method: 'POST',
    headers: {
      'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'openai/o4-mini',
      input: [
        {
          type: 'message',
          role: 'user',
          content: [
            {
              type: 'input_text',
              text: 'What is the weather in San Francisco?',
            },
          ],
        },
      ],
      tools: [weatherTool],
      tool_choice: 'auto',
      max_output_tokens: 9000,
    }),
  });

  const result = await response.json();
  console.log(result);
```

```python
import requests

weather_tool = {
    'type': 'function',
    'name': 'get_weather',
    'description': 'Get the current weather in a location',
    'strict': None,
    'parameters': {
        'type': 'object',
        'properties': {
            'location': {
                'type': 'string',
                'description': 'The city and state, e.g. San Francisco, CA',
            },
            'unit': {
                'type': 'string',
                'enum': ['celsius', 'fahrenheit'],
            },
        },
        'required': ['location'],
    },
}

response = requests.post(
    'https://openrouter.ai/api/v1/responses',
    headers={
        'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
        'Content-Type': 'application/json',
    },
    json={
        'model': 'openai/o4-mini',
        'input': [
            {
                'type': 'message',
                'role': 'user',
                'content': [
                    {
                        'type': 'input_text',
                        'text': 'What is the weather in San Francisco?',
                    },
                ],
            },
        ],
        'tools': [weather_tool],
        'tool_choice': 'auto',
        'max_output_tokens': 9000,
    }
)

result = response.json()
print(result)
```

```bash
curl -X POST https://openrouter.ai/api/v1/responses \
  -H "Authorization: Bearer YOUR_OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/o4-mini",
    "input": [
      {
        "type": "message",
        "role": "user",
        "content": [
          {
            "type": "input_text",
            "text": "What is the weather in San Francisco?"
          }
        ]
      }
    ],
    "tools": [
      {
        "type": "function",
        "name": "get_weather",
        "description": "Get the current weather in a location",
        "strict": null,
        "parameters": {
          "type": "object",
          "properties": {
            "location": {
              "type": "string",
              "description": "The city and state, e.g. San Francisco, CA"
            },
            "unit": {
              "type": "string",
              "enum": ["celsius", "fahrenheit"]
            }
          },
          "required": ["location"]
        }
      }
    ],
    "tool_choice": "auto",
    "max_output_tokens": 9000
}'
```

--------------------------------

### Send audio file for transcription using OpenRouter API

Source: https://openrouter.ai/docs/features/multimodal/audio.mdx

Demonstrates encoding an audio file to base64 and sending it to a model with audio capabilities via the OpenRouter chat completions endpoint. Includes examples for the OpenRouter TypeScript SDK, a raw fetch request in TypeScript, and a Python requests implementation The snippets handle constructing the `input_audio` payload and printing the model's response.

```TypeScript (SDK)
import { OpenRouter } from '@openrouter/sdk';
import fs from "fs/promises";

const openRouter = new OpenRouter({
  apiKey: '{{API_KEY_REF}}',
});

async function encodeAudioToBase64(audioPath: string): Promise<string> {
  const audioBuffer = await fs.readFile(audioPath);
  return audioBuffer.toString("base64");
}

// Read and encode the audio file
const audioPath = "path/to/your/audio.wav";
const base64Audio = await encodeAudioToBase64(audioPath);

const result = await openRouter.chat.send({
  model: "{{MODEL}}",
  messages: [
    {
      role: "user",
      content: [
        {
          type: "text",
          text: "Please transcribe this audio file.",
        },
        {
          type: "input_audio",
          inputAudio: {
            data: base64Audio,
            format: "wav",
          },
        },
      ],
    },
  ],
  stream: false,
});

console.log(result);
```

```Python
import requests
import json
import base64

def encode_audio_to_base64(audio_path):
    with open(audio_path, "rb") as audio_file:
        return base64.b64encode(audio_file.read()).decode('utf-8')

url = "https://openrouter.ai/api/v1/chat/completions"
headers = {
    "Authorization": f"Bearer {API_KEY_REF}",
    "Content-Type": "application/json"
}

# Read and encode the audio file
audio_path = "path/to/your/audio.wav"
base64_audio = encode_audio_to_base64(audio_path)

messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "text",
                "text": "Please transcribe this audio file."
            },
            {
                "type": "input_audio",
                "input_audio": {
                    "data": base64_audio,
                    "format": "wav"
                }
            }
        ]
    }
]

payload = {
    "model": "{{MODEL}}",
    "messages": messages
}

response = requests.post(url, headers=headers, json=payload)
print(response.json())
```

```TypeScript (fetch)
import fs from "fs/promises";

async function encodeAudioToBase64(audioPath: string): Promise<string> {
  const audioBuffer = await fs.readFile(audioPath);
 audioBuffer.toString("base64");
}

// Read and encode the audio file
const audioPath = "path/to/your/audio.wav";
const base64Audio = await encodeAudioToBase64(audioPath);

const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${API_KEY_REF}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    model: "{{MODEL}}",
    messages: [
      {
        role: "user",
        content: [
          {
            type: "text",
            text: "Please transcribe this audio file.",
          },
          {
            type: "input_audio",
            input_audio: {
              data: base64Audio,
              format: "wav",
            },
          },
        ],
      },
    ],
  }),
});

const data = await response.json();
console.log(data);
```

--------------------------------

### List Providers using C# (RestSharp)

Source: https://openrouter.ai/docs/api-reference/providers/list-providers.mdx

This C# code snippet shows how to retrieve a list of AI providers from the OpenRouter API using the RestSharp library. It configures a GET request with the required `Authorization` header.

```csharp
var client = new RestClient("https://openrouter.ai/api/v1/providers");
var request = new RestRequest(Method.GET);
request.AddHeader("Authorization", "Bearer <token>");
IRestResponse response = client.Execute(request);
```

--------------------------------

### Create Coinbase Charge React Hook - TSX

Source: https://openrouter.ai/docs/sdks/typescript/credits.mdx

Integrates Coinbase charge creation into React components using a mutation hook. Requires @openrouter/sdk/react-query/creditsCreateCoinbaseCharge.js and a React Query setup. Inputs are handled via the hook; triggers API calls on demand. Depends on React Query for caching and state management; not suitable for non-React environments.

```tsx
import {
  // Mutation hook for triggering the API call.
  useCreditsCreateCoinbaseChargeMutation
} from "@openrouter/sdk/react-query/creditsCreateCoinbaseCharge.js";
```

--------------------------------

### Get Current API Key Metadata using OpenRouter SDK (TypeScript)

Source: https://openrouter.ai/docs/sdks/typescript/apikeys.mdx

Illustrates how to retrieve metadata for the API key associated with the current authentication session using the `getCurrentKeyMetadata` method of the OpenRouter SDK. This requires an initialized `OpenRouter` instance with an API key.

```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.apiKeys.getCurrentKeyMetadata();

  console.log(result);
}

run();

```

--------------------------------

### Generate Completions using OpenRouter TypeScript SDK

Source: https://openrouter.ai/docs/sdks/typescript/completions.mdx

Demonstrates how to create a text completion using the OpenRouter TypeScript SDK's 'generate' method. It initializes the SDK with an API key and makes a POST request to the /completions endpoint. Supports both streaming and non-streaming modes.

```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.completions.generate({
    prompt: "<value>",
  });

  console.log(result);
}

run();
```

--------------------------------

### OpenAPI YAML specification for models endpoint

Source: https://openrouter.ai/docs/api-reference/models/list-models-user.mdx

Defines a GET endpoint at /models/user that returns AI models filtered by user preferences. Requires API key authentication. Includes response schemas for success (200), unauthorized (401), and server errors (500).

```yaml
openapi: 3.1.1
info:
  title: List models filtered by user provider preferences
  version: endpoint_models.listModelsUser
paths:
  /models/user:
    get:
      operationId: list-models-user
      summary: List models filtered by user provider preferences
      tags:
        - - subpackage_models
      parameters:
        - name: Authorization
          in: header
          description: API key as bearer token in Authorization header
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Returns a list of models filtered by user provider preferences
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ModelsListResponse'
        '401':
          description: Unauthorized - Missing or invalid authentication
          content: {}
        '500':
          description: Internal Server Error
          content: {}
components:
  schemas:
    BigNumberUnion:
      oneOf:
        - type: number
          format: double
        - type: string
        - type: number
          format: double
    PublicPricing:
      type: object
      properties:
        prompt:
          $ref: '#/components/schemas/BigNumberUnion'
        completion:
          $ref: '#/components/schemas/BigNumberUnion'
        request:
          $ref: '#/components/schemas/BigNumberUnion'
        image:
          $ref: '#/components/schemas/BigNumberUnion'
        image_output:
          $ref: '#/components/schemas/BigNumberUnion'
        audio:
          $ref: '#/components/schemas/BigNumberUnion'
        input_audio_cache:
          $ref: '#/components/schemas/BigNumberUnion'
        web_search:
          $ref: '#/components/schemas/BigNumberUnion'
        internal_reasoning:
          $ref: '#/components/schemas/BigNumberUnion'
        input_cache_read:
          $ref: '#/components/schemas/BigNumberUnion'
        input_cache_write:
          $ref: '#/components/schemas/BigNumberUnion'
        discount:
          type: number
          format: double
      required:
        - prompt
        - completion
    ModelGroup:
      type: string
      enum:
        - value: Router
        - value: Media
        - value: Other
        - value: GPT
        - value: Claude
        - value: Gemini
        - value: Grok
        - value: Cohere
        - value: Nova
        - value: Qwen
        - value: Yi
        - value: DeepSeek
        - value: Mistral
        - value: Llama2
        - value: Llama3
        - value: Llama4
        - value: PaLM
        - value: RWKV
        - value: Qwen3
    ModelArchitectureInstructType:
      type: string
      enum:
        - value: none
        - value: airoboros
        - value: alpaca
        - value: alpaca-modif
        - value: chatml
        - value: claude
        - value: code-llama
        - value: gemma
        - value: llama2
        - value: llama3
        - value: mistral
        - value: nemotron
        - value: neural
        - value: openchat
        - value: phi3
        - value: rwkv
        - value: vicuna
        - value: zephyr
        - value: deepseek-r1
        - value: deepseek-v3.1
        - value: qwq
        - value: qwen3
    InputModality:
      type: string
      enum:
        - value: text
        - value: image
        - value: file
        - value: audio
        - value: video
    OutputModality:
      type: string
      enum:
        - value: text
        - value: image
        - value: embeddings
    ModelArchitecture:
      type: object
      properties:
        tokenizer:
          $ref: '#/components/schemas/ModelGroup'
        instruct_type:
          oneOf:
            - $ref: '#/components/schemas/ModelArchitectureInstructType'
            - type: 'null'
        modality:
          type:
            - string
            - 'null'
        input_modalities:
          type: array
          items:
            $ref: '#/components/schemas/InputModality'
        output_modalities:
          type: array
          items:
            $ref: '#/components/schemas/OutputModality'
      required:
        - modality
        - input_modalities
        - output_modalities
    TopProviderInfo:
      type: object
      properties:
        context_length:
          type:
            - number
            - 'null'
          format: double
        max_completion_tokens:
          type:
            - number
            - 'null'
          format: double
        is_moderated:
          type: boolean
      required:
        - is_moderated
    PerRequestLimits:
      type: object
      properties:
        prompt_tokens:
          type: number
          format: double
        completion_tokens:
          type: number
          format: double
      required:
        - prompt_tokens
        - completion_tokens
    Parameter:
      type: string
      enum:
        - value: temperature
        - value: top_p
        - value: top_k
```

--------------------------------

### Get Generation Metadata (TypeScript SDK)

Source: https://openrouter.ai/docs/sdks/typescript/generations.mdx

Fetches request and usage metadata for a specific generation using the OpenRouter TypeScript SDK. Requires an API key and a generation ID. Returns detailed metadata about the generation.

```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.generations.getGeneration({
    id: "<id>",
  });

  console.log(result);
}

run();
```

--------------------------------

### POST /openrouter.ai/llmstxt

Source: https://openrouter.ai/docs/api-reference/beta-responses/create-responses.mdx

This endpoint allows users to interact with various Large Language Models through the OpenRouter platform. It supports text generation, tool usage, and streaming responses.

```APIDOC
## POST /openrouter.ai/llmstxt

### Description
This endpoint facilitates text generation and interaction with Large Language Models (LLMs) via the OpenRouter API. It supports various configurations for model selection, tool integration, and response streaming.

### Method
POST

### Endpoint
/openrouter.ai/llmstxt

### Parameters
#### Request Body
- **input** (object) - Required - The primary input for the LLM, typically containing prompts or data.
- **instructions** (string | null) - Optional - Specific instructions to guide the LLM's behavior.
- **metadata** (object) - Optional - Additional metadata associated with the request.
- **tools** (array) - Optional - An array of tools that the LLM can utilize. Each item in the array is an object with an 'id' (string, e.g., 'moderation', 'web', 'file-parser').
  - **tool.id** (string) - Required - The identifier for the tool.
  - **tool.max_results** (number) - Optional - Maximum number of results for web search tools.
  - **tool.search_prompt** (string) - Optional - The prompt to use for web search.
  - **tool.engine** (string) - Optional - The engine to use for web search (e.g., 'native', 'exa').
  - **tool.max_files** (number) - Optional - Maximum number of files for file parser tools.
  - **tool.pdf** (object) - Optional - PDF processing configuration for file parser tools.
    - **tool.pdf.engine** (string) - Optional - The engine to use for PDF processing (e.g., 'mistral-ocr', 'pdf-text', 'native').
- **tool_choice** (object) - Optional - Specifies how the LLM should choose tools.
- **parallel_tool_calls** (boolean | null) - Optional - Whether to allow parallel tool calls.
- **model** (string) - Optional - The specific model to use for the request.
- **models** (array of strings) - Optional - A list of preferred models.
- **text** (object) - Optional - Configuration for text response handling.
- **reasoning** (object) - Optional - Configuration for LLM reasoning output.
- **max_output_tokens** (number | null) - Optional - Maximum number of tokens for the output.
- **temperature** (number | null) - Optional - Controls the randomness of the output (0.0 to 2.0).
- **top_p** (number | null) - Optional - Controls nucleus sampling (0.0 to 1.0).
- **top_k** (number) - Optional - Controls top-k sampling.
- **prompt_cache_key** (string | null) - Optional - A key for caching prompts.
- **previous_response_id** (string | null) - Optional - The ID of a previous response to continue a conversation.
- **prompt** (object) - Optional - Configuration for the prompt structure.
- **include** (array | null) - Optional - Specifies resources to include in the response.
- **background** (boolean | null) - Optional - Whether to process the request in the background.
- **safety_identifier** (string | null) - Optional - An identifier for safety checks.
- **store** (boolean | null) - Optional - Whether to store the request and response.
- **service_tier** (object) - Optional - Specifies the service tier for the request.
- **truncation** (object) - Optional - Configuration for input truncation.
- **stream** (boolean) - Required - Whether to stream the response.
- **provider** (object | null) - Optional - Specifies the LLM provider.
- **plugins** (array of objects) - Optional - An array of plugins to use with the request. Each plugin is an object with an 'id' (string).
- **user** (string) - Optional - An identifier for the user making the request.

### Request Example
```json
{
  "model": "gpt-4o",
  "messages": [
    {"role": "user", "content": "Hello, who are you?"}
  ],
  "stream": false
}
```

### Response
#### Success Response (200)
- **response** (string) - The LLM's generated text response.
- **usage** (object) - Information about token usage.
- **finish_reason** (string) - The reason the LLM stopped generating text (e.g., 'stop', 'length').

#### Response Example
```json
{
  "id": "chatcmpl-123",
  "object": "chat.completion",
  "created": 1700000000,
  "model": "gpt-4o",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "I am a large language model, trained by Google."
      },
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 20,
    "total_tokens": 30
  }
}
```
```

--------------------------------

### Get Parameters API

Source: https://openrouter.ai/docs/sdks/typescript/parameters.mdx

Retrieves parameters for LLM text operations. This endpoint allows you to fetch configuration details necessary for making requests to the LLM text service. It includes options for security, request customization, and retry mechanisms.

```APIDOC
## GET /openrouter.ai/llmstxt

### Description
Retrieves parameters for LLM text operations. This endpoint allows you to fetch configuration details necessary for making requests to the LLM text service. It includes options for security, request customization, and retry mechanisms.

### Method
GET

### Endpoint
/openrouter.ai/llmstxt

### Parameters
#### Query Parameters
- **request** (operations.GetParametersRequest) - Required - The request object to use for the request.
- **security** (operations.GetParametersSecurity) - Required - The security requirements to use for the request.
- **options** (RequestOptions) - Optional - Used to set various options for making HTTP requests.
  - **options.fetchOptions** (RequestInit) - Optional - Options that are passed to the underlying HTTP request. This can be used to inject extra headers for examples. All `Request` options, except `method` and `body`, are allowed.
  - **options.retries** (RetryConfig) - Optional - Enables retrying HTTP requests under certain failure conditions.

### Request Example
```json
{
  "request": { ... },
  "security": { ... },
  "options": {
    "fetchOptions": { ... },
    "retries": { ... }
  }
}
```

### Response
#### Success Response (200)
- **Promise<operations.GetParametersResponse>** - The response object containing parameters for LLM text operations.

#### Response Example
```json
{
  // Example response structure based on operations.GetParametersResponse
}
```

### Errors
- **errors.UnauthorizedResponseError** (401, application/json)
- **errors.NotFoundResponseError** (404, application/json)
- **errors.InternalServerResponseError** (500, application/json)
- **errors.OpenRouterDefaultError** (4XX, 5XX, */*)
```

--------------------------------

### Create API Key - Python

Source: https://openrouter.ai/docs/api-reference/api-keys/create-keys.mdx

This Python code snippet demonstrates how to create a new API key using the OpenRouter.ai API. It uses the `requests` library to send a POST request to the `/api/v1/keys` endpoint with the necessary parameters. Requires the `requests` library.

```Python
import requests

url = "https://openrouter.ai/api/v1/keys"

payload = {
    "name": "My New API Key",
    "limit": 50,
    "limit_reset": "monthly",
    "include_byok_in_limit": True
}
headers = {
    "Authorization": "Bearer <token>",
    "Content-Type": "application/json"
}

response = requests.post(url, json=payload, headers=headers)

print(response.json())
```

--------------------------------

### Anthropic Claude User Message Caching Example (JSON)

Source: https://openrouter.ai/docs/features/prompt-caching.mdx

Illustrates prompt caching for a user message in Anthropic Claude, specifically when providing a large text body for context. The `cache_control` property is applied to the text content block containing the book data, allowing it to be cached for repeated use within a short timeframe.

```json
{
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "Given the book below:"
        },
        {
          "type": "text",
          "text": "HUGE TEXT BODY",
          "cache_control": {
            "type": "ephemeral"
          }
        },
        {
          "type": "text",
          "text": "Name all the characters in the above book"
        }
      ]
    }
  ]
}
```

--------------------------------

### Inference Request with Tools (JSON)

Source: https://openrouter.ai/docs/features/tool-calling.mdx

This JSON snippet demonstrates how to structure an inference request that includes tool definitions. It specifies a tool for searching books in Project Gutenberg and is used in the first step of tool calling. The model will suggest tool calls based on user input.

```json
{
  "model": "google/gemini-2.0-flash-001",
  "messages": [
    {
      "role": "user",
      "content": "What are the titles of some James Joyce books?"
    }
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "search_gutenberg_books",
        "description": "Search for books in the Project Gutenberg library",
        "parameters": {
          "type": "object",
          "properties": {
            "search_terms": {
              "type": "array",
              "items": {"type": "string"},
              "description": "List of search terms to find books"
            }
          },
          "required": ["search_terms"]
        }
      }
    }
  ]
}
```

--------------------------------

### Get User Activity using OpenRouter SDK (TypeScript)

Source: https://openrouter.ai/docs/sdks/typescript/analytics.mdx

Demonstrates how to fetch user activity data, grouped by endpoint, using the OpenRouter TypeScript SDK. It initializes the SDK with an API key and calls the `getUserActivity` method. The result is then logged to the console. This is the primary method for analytics retrieval.

```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.analytics.getUserActivity();

  console.log(result);
}

run();
```

--------------------------------

### OpenRouter Responses API Beta - Web Search

Source: https://context7_llms

Enable web search capabilities with real-time information retrieval and citation annotations using OpenRouter's Responses API Beta.

```APIDOC
## Responses API Beta - Web Search

### Description
This guide explains how to enable web search functionality within OpenRouter's Responses API Beta. It covers real-time information retrieval and the use of citation annotations.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### TypeScript SDK: Completions Method Documentation

Source: https://context7_llms

Documentation for the completions method in the OpenRouter TypeScript SDK. This method is used for generating text completions based on a given prompt. It's suitable for tasks like content generation, summarization, and text continuation.

```typescript
import OpenRouter from '@openrouter/sdk';

const openrouter = new OpenRouter({
  apiKey: 'YOUR_OPENROUTER_API_KEY',
});

async function getCompletion() {
  try {
    const response = await openrouter.completions.create({
      model: 'openai/gpt-3.5-turbo-instruct',
      prompt: 'The quick brown fox jumps over the lazy',
      max_tokens: 10,
    });
    console.log(response.choices[0].text);
  } catch (error) {
    console.error('Error calling completion:', error);
  }
}

getCompletion();
```

--------------------------------

### Nitro Shortcut for Throughput Sorting (TypeScript, Python)

Source: https://openrouter.ai/docs/features/provider-routing.mdx

Utilizes the `:nitro` shortcut to automatically sort providers by throughput. This method is equivalent to setting `provider.sort: 'throughput'`. Examples are provided for TypeScript (SDK and fetch) and Python, demonstrating how to append `:nitro` to the model slug.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
});

const completion = await openRouter.chat.send({
  model: 'meta-llama/llama-3.1-70b-instruct:nitro',
  messages: [{ role: 'user', content: 'Hello' }],
  stream: false,
});
```

```typescript
fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer <OPENROUTER_API_KEY>',
    'HTTP-Referer': '<YOUR_SITE_URL>',
    'X-Title': '<YOUR_SITE_NAME>',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'meta-llama/llama-3.1-70b-instruct:nitro',
    messages: [{ role: 'user', content: 'Hello' }],
  }),
});
```

```python
import requests

headers = {
  'Authorization': 'Bearer <OPENROUTER_API_KEY>',
  'HTTP-Referer': '<YOUR_SITE_URL>',
  'X-Title': '<YOUR_SITE_NAME>',
  'Content-Type': 'application/json',
}

response = requests.post('https://openrouter.ai/api/v1/chat/completions', headers=headers, json={
  'model': 'meta-llama/llama-3.1-70b-instruct:nitro',
  'messages': [{ 'role': 'user', 'content': 'Hello' }],
})
```

--------------------------------

### Specify search context size in API request (JSON)

Source: https://openrouter.ai/docs/features/web-search.mdx

Demonstrates how to set the search_context_size parameter in a web_search_options object when making an API request to OpenRouter.ai. The example shows a GPT-4.1 query with high search context.

```json
{
  "model": "openai/gpt-4.1",
  "messages": [
    {
      "role": "user",
      "content": "What are the latest developments in quantum computing?"
    }
  ],
  "web_search_options": {
    "search_context_size": "high"
  }
}
```

--------------------------------

### Create API Key - PHP

Source: https://openrouter.ai/docs/api-reference/api-keys/create-keys.mdx

This PHP code snippet demonstrates how to create a new API key using the OpenRouter.ai API. It uses the `GuzzleHttp` library to send a POST request to the `/api/v1/keys` endpoint with the necessary parameters. Requires the `GuzzleHttp` library.

```PHP
<?php

$client = new \GuzzleHttp\Client();

$response = $client->request('POST', 'https://openrouter.ai/api/v1/keys', [
  'body' => '{\n  "name": "My New API Key",\n  "limit": 50,\n  "limit_reset": "monthly",\n  "include_byok_in_limit": true\n}',
  'headers' => [
    'Authorization' => 'Bearer <token>',
    'Content-Type' => 'application/json',
  ],
]);

echo $response->getBody();
```

--------------------------------

### Order Specific Providers for Model Requests (TypeScript, Fetch, Python)

Source: https://openrouter.ai/docs/features/provider-routing.mdx

Illustrates how to use the 'provider.order' field to specify a prioritized list of providers for a model request. This allows for targeted provider selection, with fallbacks to default load balancing if specified providers are unavailable. Examples are provided for the OpenRouter TypeScript SDK, a direct TypeScript fetch request, and a Python requests call.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
});

const completion = await openRouter.chat.send({
  model: 'mistralai/mixtral-8x7b-instruct',
  messages: [{ role: 'user', content: 'Hello' }],
  provider: {
    order: ['openai', 'together'],
  },
  stream: false,
});
```

```typescript
fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer <OPENROUTER_API_KEY>',
    'HTTP-Referer': '<YOUR_SITE_URL>',
    'X-Title': '<YOUR_SITE_NAME>',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'mistralai/mixtral-8x7b-instruct',
    messages: [{ role: 'user', content: 'Hello' }],
    provider: {
      order: ['openai', 'together'],
    },
  }),
});
```

```python
import requests

headers = {
  'Authorization': 'Bearer <OPENROUTER_API_KEY>',
  'HTTP-Referer': '<YOUR_SITE_URL>',
  'X-Title': '<YOUR_SITE_NAME>',
  'Content-Type': 'application/json',
}

response = requests.post('https://openrouter.ai/api/v1/chat/completions', headers=headers, json={
  'model': 'mistralai/mixtral-8x7b-instruct',
  'messages': [{ 'role': 'user', 'content': 'Hello' }],
  'provider': {
    'order': ['openai', 'together'],
  },
})
```

--------------------------------

### Get Generation Metadata (Standalone Function - TypeScript)

Source: https://openrouter.ai/docs/sdks/typescript/generations.mdx

A standalone function for retrieving generation request and usage metadata, optimized for tree-shaking. It takes an OpenRouterCore instance and generation ID as input. Handles successful responses and errors.

```typescript
import { OpenRouterCore } from "@openrouter/sdk/core.js";
import { generationsGetGeneration } from "@openrouter/sdk/funcs/generationsGetGeneration.js";

// Use `OpenRouterCore` for best tree-shaking performance.
// You can create one instance of it to use across an application.
const openRouter = new OpenRouterCore({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const res = await generationsGetGeneration(openRouter, {
    id: "<id>",
  });
  if (res.ok) {
    const { value: result } = res;
    console.log(result);
  } else {
    console.log("generationsGetGeneration failed:", res.error);
  }
}

run();
```

--------------------------------

### Update API Key - Go

Source: https://openrouter.ai/docs/api-reference/api-keys/update-keys.mdx

This Go program demonstrates how to update an API key using the standard `net/http` package. It constructs a PATCH request with a JSON payload and custom headers, then prints the response status and body.

```go
package main

import (
	"fmt"
	"strings"
	"net/http"
	"io"
)

func main() {

	url := "https://openrouter.ai/api/v1/keys/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"

	payload := strings.NewReader("{\n  \"name\": \"Updated API Key Name\",\n  \"disabled\": false,\n  \"limit\": 75,\n  \"limit_reset\": \"daily\",\n  \"include_byok_in_limit\": true\n}")

	req, _ := http.NewRequest("PATCH", url, payload)

	req.Header.Add("Authorization", "Bearer <token>")
	req.Header.Add("Content-Type", "application/json")

	res, _ := http.DefaultClient.Do(req)

	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)

	fmt.Println(res)
	fmt.Println(string(body))

}
```

--------------------------------

### OpenAPI Specification for User Activity Endpoint

Source: https://openrouter.ai/docs/api-reference/analytics/get-user-activity.mdx

Complete OpenAPI 3.1.1 specification defining the user activity endpoint with GET /activity operation. Includes request parameters for date filtering and authentication, response schemas for 200/400/401/403/500 status codes, and detailed ActivityItem data model with usage metrics and token counts.

```yaml
openapi: 3.1.1
info:
  title: Get user activity grouped by endpoint
  version: endpoint_analytics.getUserActivity
paths:
  /activity:
    get:
      operationId: get-user-activity
      summary: Get user activity grouped by endpoint
      description: >-
        Returns user activity data grouped by endpoint for the last 30
        (completed) UTC days
      tags:
        - - subpackage_analytics
      parameters:
        - name: date
          in: query
          description: Filter by a single UTC date in the last 30 days (YYYY-MM-DD format).
          required: false
          schema:
            type: string
        - name: Authorization
          in: header
          description: API key as bearer token in Authorization header
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Returns user activity data grouped by endpoint
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Analytics_getUserActivity_Response_200'
        '400':
          description: Bad Request - Invalid date format or date range
          content: {}
        '401':
          description: Unauthorized - Authentication required or invalid credentials
          content: {}
        '403':
          description: Forbidden - Only provisioning keys can fetch activity
          content: {}
        '500':
          description: Internal Server Error - Unexpected server error
          content: {}
components:
  schemas:
    ActivityItem:
      type: object
      properties:
        date:
          type: string
        model:
          type: string
        model_permaslug:
          type: string
        endpoint_id:
          type: string
        provider_name:
          type: string
        usage:
          type: number
          format: double
        byok_usage_inference:
          type: number
          format: double
        requests:
          type: number
          format: double
        prompt_tokens:
          type: number
          format: double
        completion_tokens:
          type: number
          format: double
        reasoning_tokens:
          type: number
          format: double
      required:
        - date
        - model
        - model_permaslug
        - endpoint_id
        - provider_name
        - usage
        - byok_usage_inference
        - requests
        - prompt_tokens
        - completion_tokens
        - reasoning_tokens
    Analytics_getUserActivity_Response_200:
      type: object
      properties:
        data:
          type: array
          items:
            $ref: '#/components/schemas/ActivityItem'
      required:
        - data
```

--------------------------------

### Advanced Reasoning Chain-of-Thought (TypeScript)

Source: https://openrouter.ai/docs/use-cases/reasoning-tokens.mdx

This TypeScript example demonstrates a chain-of-thought pattern using reasoning tokens. It first calls a model to generate reasoning for a given question and then uses that reasoning as context in a subsequent call to another model to produce a more informed answer. The `doReq` function handles the API calls, and the logic orchestrates the retrieval and injection of reasoning for improved output quality.

```typescript
import OpenAI from 'openai';

const openai = new OpenAI({
  baseURL: 'https://openrouter.ai/api/v1',
  apiKey: '{{API_KEY_REF}}',
});

async function doReq(model, content, reasoningConfig) {
  const payload = {
    model,
    messages: [{ role: 'user', content }],
    stop: '</think>',
    ...reasoningConfig,
  };

  return openai.chat.completions.create(payload);
}

async function getResponseWithReasoning() {
  const question = 'Which is bigger: 9.11 or 9.9?';
  const reasoningResponse = await doReq(
    'deepseek/deepseek-r1',
    `${question} Please think this through, but don't output an answer`,
  );
  const reasoning = reasoningResponse.choices[0].message.reasoning;

  // Let's test! Here's the naive response:
  const simpleResponse = await doReq('openai/gpt-4o-mini', question);
  console.log(simpleResponse.choices[0].message.content);

  // Here's the response with the reasoning token injected:
  const content = `${question}. Here is some context to help you: ${reasoning}`;
  const smartResponse = await doReq('openai/gpt-4o-mini', content);
  console.log(smartResponse.choices[0].message.content);
}

getResponseWithReasoning();
```

--------------------------------

### Check Available Credits with Fetch API

Source: https://openrouter.ai/docs/use-cases/crypto-api.mdx

This snippet demonstrates how to check available credits by making a direct GET request to the OpenRouter API's credits endpoint using the Fetch API. It includes setting the Authorization header with the API key and parsing the JSON response to extract credit data.

```typescript
const response = await fetch('https://openrouter.ai/api/v1/credits', {
  method: 'GET',
  headers: { Authorization: 'Bearer <OPENROUTER_API_KEY>' },
});
const { data } = await response.json();
```

--------------------------------

### OpenRouter Responses API Beta - Reasoning

Source: https://context7_llms

Access advanced reasoning capabilities with configurable effort levels and encrypted reasoning chains using OpenRouter's Responses API Beta.

```APIDOC
## Responses API Beta - Reasoning

### Description
This section details how to utilize advanced reasoning capabilities within OpenRouter's Responses API Beta. It covers configurable effort levels and the use of encrypted reasoning chains.

### Method
N/A

### Endpoint
N/A

### Parameters
N/A

### Request Example
N/A

### Response
N/A
```

--------------------------------

### GET /api/v1/endpoints/zdr

Source: https://openrouter.ai/docs/api-reference/endpoints/list-endpoints-zdr.mdx

This endpoint allows users to preview the impact of Zero Data Retention (ZDR) on the available endpoints. It returns information on how ZDR affects data handling for various API resources. Use this to evaluate compliance and functionality changes before enabling ZDR.

```APIDOC
## GET /api/v1/endpoints/zdr

### Description
Preview the impact of Zero Data Retention (ZDR) on the available endpoints. This helps assess how ZDR policies influence data retention across API resources.

### Method
GET

### Endpoint
/api/v1/endpoints/zdr

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

### Request Example
No request body required for GET request.

### Response
#### Success Response (200)
Returns details on ZDR impact, including affected endpoints and retention changes.

#### Response Example
{
  "zdr_impact": "Details on affected endpoints"
}
```

--------------------------------

### Complex Search Query API Call - TypeScript & Python

Source: https://openrouter.ai/docs/api-reference/responses-api/web-search.mdx

Demonstrates advanced API usage with structured input containing messages and plugins for web search functionality. Shows how to implement multi-part queries with role-based messages and plugin configuration. The example uses the web plugin with configurable result limits for enhanced research capabilities.

```typescript
const response = await fetch('https://openrouter.ai/api/v1/responses', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/o4-mini',
    input: [
      {
        type: 'message',
        role: 'user',
        content: [
          {
            type: 'input_text',
            text: 'Compare OpenAI and Anthropic latest models',
          },
        ],
      },
    ],
    plugins: [{ id: 'web', max_results: 5 }],
    max_output_tokens: 9000,
  }),
});

const result = await response.json();
console.log(result);
```

```python
import requests

response = requests.post(
    'https://openrouter.ai/api/v1/responses',
    headers={
        'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
        'Content-Type': 'application/json',
    },
    json={
        'model': 'openai/o4-mini',
        'input': [
            {
                'type': 'message',
                'role': 'user',
                'content': [
                    {
                        'type': 'input_text',
                        'text': 'Compare OpenAI and Anthropic latest models',
                    },
                ],
            },
        ],
        'plugins': [{'id': 'web', 'max_results': 5}],
        'max_output_tokens': 9000,
    }
)

result = response.json()
print(result)
```

--------------------------------

### Implement MCP Client with Python

Source: https://openrouter.ai/docs/use-cases/mcp-servers.mdx

MCP client implementation for interacting with MCP servers via OpenRouter. Includes session management, tool listing, and query processing.

```python
class MCPClient:
    def __init__(self):
        self.session: Optional[ClientSession] = None
        self.exit_stack = AsyncExitStack()
        self.openai = OpenAI(
            base_url="https://openrouter.ai/api/v1"
        )

    async def connect_to_server(self, server_config):
        server_params = StdioServerParameters(**server_config)
        stdio_transport = await self.exit_stack.enter_async_context(stdio_client(server_params))
        self.stdio, self.write = stdio_transport
        self.session = await self.exit_stack.enter_async_context(ClientSession(self.stdio, self.write))

        await self.session.initialize()

        # List available tools from the MCP server
        response = await self.session.list_tools()
        print("\nConnected to server with tools:", [tool.name for tool in response.tools])

        self.messages = []

    async def process_query(self, query: str) -> str:

        self.messages.append({
            "role": "user",
            "content": query
        })

        response = await self.session.list_tools()
        available_tools = [convert_tool_format(tool) for tool in response.tools]

        response = self.openai.chat.completions.create(
            model=MODEL,
            tools=available_tools,
            messages=self.messages
        )
        self.messages.append(response.choices[0].message.model_dump())

        final_text = []
        content = response.choices[0].message
        if content.tool_calls is not None:
            tool_name = content.tool_calls[0].function.name
            tool_args = content.tool_calls[0].function.arguments
            tool_args = json.loads(tool_args) if tool_args else {}

            # Execute tool call
            try:
                result = await self.session.call_tool(tool_name, tool_args)
                final_text.append(f"[Calling tool {tool_name} with args {tool_args}]")
            except Exception as e:
                print(f"Error calling tool {tool_name}: {e}")
                result = None

            self.messages.append({
                "role": "tool",
                "tool_call_id": content.tool_calls[0].id,
                "name": tool_name,
                "content": result.content
            })

            response = self.openai.chat.completions.create(
                model=MODEL,
                max_tokens=1000,
                messages=self.messages,
            )

            final_text.append(response.choices[0].message.content)
        else:
            final_text.append(content.content)

        return "\n".join(final_text)

    async def chat_loop(self):
        """Run an interactive chat loop"""
        print("\nMCP Client Started!")
```

--------------------------------

### Target Specific Provider Endpoints

Source: https://openrouter.ai/docs/features/provider-routing.mdx

Shows how to target specific provider endpoints using exact provider slugs. This example demonstrates requesting the DeepSeek R1 model through the DeepInfra turbo endpoint. Provider slugs can be copied from the model detail page to ensure requests are routed to the exact endpoint variant you want.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
});

const completion = await openRouter.chat.send({
  model: 'deepseek/deepseek-r1',
  messages: [{ role: 'user', content: 'Hello' }],
  provider: {
    order: ['deepinfra/turbo'],
    allowFallbacks: false,
  },
  stream: false,
});
```

```typescript
fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer <OPENROUTER_API_KEY>',
    'HTTP-Referer': '<YOUR_SITE_URL>',
    'X-Title': '<YOUR_SITE_NAME>',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'deepseek/deepseek-r1',
    messages: [{ role: 'user', content: 'Hello' }],
    provider: {
      order: ['deepinfra/turbo'],
      allow_fallbacks: false,
    },
  }),
});
```

```python
import requests

headers = {
  'Authorization': 'Bearer <OPENROUTER_API_KEY>',
  'HTTP-Referer': '<YOUR_SITE_URL>',
  'X-Title': '<YOUR_SITE_NAME>',
  'Content-Type': 'application/json',
}

response = requests.post('https://openrouter.ai/api/v1/chat/completions', headers=headers, json={
  'model': 'deepseek/deepseek-r1',
  'messages': [{ 'role': 'user', 'content': 'Hello' }],
  'provider': {
    'order': ['deepinfra/turbo'],
    'allow_fallbacks': False,
  },
})
```

--------------------------------

### POST /api/v1/credits/coinbase

Source: https://openrouter.ai/docs/api-reference/credits/create-coinbase-charge.mdx

This endpoint allows users to purchase credits via Coinbase. It requires authentication and accepts parameters for amount, sender address, and chain ID.

```APIDOC
## POST /api/v1/credits/coinbase

### Description
Allows authenticated users to purchase credits through Coinbase by specifying the amount, sender address, and chain ID.

### Method
POST

### Endpoint
https://openrouter.ai/api/v1/credits/coinbase

### Parameters
#### Request Body
- **amount** (integer) - Required - The amount of credits to purchase
- **sender** (string) - Required - The sender's wallet address
- **chain_id** (integer) - Required - The ID of the blockchain network

### Request Example
{
  "amount": 100,
  "sender": "0x1234567890123456789012345678901234567890",
  "chain_id": 1
}

### Response
#### Success Response (200)
- **data** (object) - The response data from the credit purchase

#### Response Example
{
  "data": {
    "transaction_id": "txn_12345",
    "credits_added": 100,
    "status": "success"
  }
}

### Authentication
Required: Bearer token in Authorization header

### Error Handling
- 401 Unauthorized: Invalid or missing authentication token
- 400 Bad Request: Invalid request parameters
- 500 Internal Server Error: Server-side processing error
```

--------------------------------

### Simulate and Send ETH Transaction with Viem

Source: https://openrouter.ai/docs/use-cases/crypto-api.mdx

This snippet demonstrates how to set up Viem clients to simulate and send an Ethereum transaction for purchasing credits. It includes configuring clients for Base chain, handling private keys, and constructing the transaction request with contract details and values. The simulation step helps prevent common transaction reverts.

```typescript
const abi = [
  {
    inputs: [
      {
        components: [
          { internalType: 'address', name: 'recipient', type: 'address' },
          { internalType: 'uint256', name: 'recipientAmount', type: 'uint256' },
          { internalType: 'uint256', name: 'deadline', type: 'uint256' },
          { internalType: 'address', name: 'refundDestination', type: 'address' },
          { internalType: 'uint256', name: 'feeAmount', type: 'uint256' },
          { internalType: 'bytes32', name: 'id', type: 'bytes32' },
          { internalType: 'bytes', name: 'operator', type: 'bytes' },
          { internalType: 'bytes', name: 'signature', type: 'bytes' },
          { internalType: 'bytes', name: 'prefix', type: 'bytes' },
        ],
        internalType: 'struct TransferIntent',
        name: '_intent',
        type: 'tuple',
      },
    ],
    name: 'wrapAndTransfer',
    outputs: [],
    stateMutability: 'payable',
    type: 'function',
  },
  { stateMutability: 'payable', type: 'receive' },
];

// Set up viem clients
const publicClient = createPublicClient({
  chain: base,
  transport: http(),
});
const account = privateKeyToAccount('0x...');
const walletClient = createWalletClient({
  chain: base,
  transport: http(),
  account,
});

// Use the calldata included in the charge response
const { contract_address } = responseJSON.data.web3_data.transfer_intent.metadata;
const call_data = responseJSON.data.web3_data.transfer_intent.call_data;

const poolFeesTier = 500;

// Simulate the transaction first to prevent most common revert reasons
const { request } = await publicClient.simulateContract({
  abi,
  account,
  address: contract_address,
  functionName: 'swapAndTransferUniswapV3Native',
  args: [
    {
      recipientAmount: BigInt(call_data.recipient_amount),
      deadline: BigInt(
        Math.floor(new Date(call_data.deadline).getTime() / 1000),
      ),
      recipient: call_data.recipient,
      recipientCurrency: call_data.recipient_currency,
      refundDestination: call_data.refund_destination,
      feeAmount: BigInt(call_data.fee_amount),
      id: call_data.id,
      operator: call_data.operator,
      signature: call_data.signature,
      prefix: call_data.prefix,
    },
    poolFeesTier,
  ],
  value: parseEther('0.004'),
});

// Send the transaction on chain
const txHash = await walletClient.writeContract(request);
console.log('Transaction hash:', txHash);
```

--------------------------------

### React Hooks for Get Current API Key Metadata (TypeScript)

Source: https://openrouter.ai/docs/sdks/typescript/apikeys.mdx

Provides an overview of React hooks and utilities available in the OpenRouter SDK for managing the current API key metadata within React applications. This includes query hooks for fetching and suspense, as well as utilities for prefetching and invalidating data.

```tsx
import {
  // Query hooks for fetching data.
  useApiKeysGetCurrentKeyMetadata,
  useApiKeysGetCurrentKeyMetadataSuspense,

  // Utility for prefetching data during server-side rendering and in React
  // Server Components that will be immediately available to client components
  // using the hooks.
  prefetchApiKeysGetCurrentKeyMetadata,
  
  // Utility to invalidate the query cache for this query in response to
  // mutations and other user actions.
  invalidateAllApiKeysGetCurrentKeyMetadata,
} from "@openrouter/sdk/react-query/apiKeysGetCurrentKeyMetadata.js";
```

--------------------------------

### Use OpenRouter Auto Router for Model Selection (TypeScript, Python)

Source: https://openrouter.ai/docs/features/model-routing.mdx

Demonstrates how to use the 'openrouter/auto' model ID to dynamically select between high-quality models. This feature is powered by NotDiamond. The code examples show usage with the OpenRouter SDK and direct API calls.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
});

const completion = await openRouter.chat.send({
  model: 'openrouter/auto',
  messages: [
    {
      role: 'user',
      content: 'What is the meaning of life?',
    },
  ],
});

console.log(completion.choices[0].message.content);
```

```typescript
const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer <OPENROUTER_API_KEY>',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openrouter/auto',
    messages: [
      {
        role: 'user',
        content: 'What is the meaning of life?',
      },
    ],
  }),
});

const data = await response.json();
console.log(data.choices[0].message.content);
```

```python
import requests
import json

response = requests.post(
  url="https://openrouter.ai/api/v1/chat/completions",
  headers={
    "Authorization": "Bearer <OPENROUTER_API_KEY>",
    "Content-Type": "application/json",
  },
  data=json.dumps({
    "model": "openrouter/auto",
    "messages": [
      {
        "role": "user",
        "content": "What is the meaning of life?"
      }
    ]
  })
)

data = response.json()
print(data['choices'][0]['message']['content'])
```

--------------------------------

### Allow Only Specific Providers with OpenRouter (TypeScript, Python)

Source: https://openrouter.ai/docs/features/provider-routing.mdx

Demonstrates how to restrict a request to use only selected providers (e.g., Azure) by setting the `only` field in the provider object. Includes examples for the OpenRouter TypeScript SDK, a raw fetch call, and a Python requests implementation. Shows required headers and request payload.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
});\nconst completion = await openRouter.chat.send({
  model: 'openai/gpt-4o',
  messages: [{ role: 'user', content: 'Hello' }],
  provider: {
    only: ['azure'],
  },
  stream: false,
});
```

```typescript
fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer <OPENROUTER_API_KEY>',
    'HTTP-Referer': '<YOUR_SITE_URL>',
    'X-Title': '<YOUR_SITE_NAME>',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/gpt-4o',
    messages: [{ role: 'user', content: 'Hello' }],
    provider: {
      only: ['azure'],
    },
  }),
});
```

```python
import requests

headers = {
  'Authorization': 'Bearer <OPENROUTER_API_KEY>',
  'HTTP-Referer': '<YOUR_SITE_URL>',
  'X-Title': '<YOUR_SITE_NAME>',
  'Content-Type': 'application/json',
}

response = requests.post('https://openrouter.ai/api/v1/chat/completions', headers=headers, json={
  'model': 'openai/gpt-4o',
  'messages': [{ 'role': 'user', 'content': 'Hello' }],
  'provider': {
    'only': ['azure'],
  },
})
```

--------------------------------

### Configure and Use OpenRouter with PydanticAI

Source: https://openrouter.ai/docs/community/pydantic-ai.mdx

Demonstrates how to configure PydanticAI to use an OpenRouter model through its OpenAI-compatible interface. It shows model instantiation with a specific OpenRouter model, base URL, and API key, followed by agent creation and running a query.

```python
from pydantic_ai import Agent
from pydantic_ai.models.openai import OpenAIModel

model = OpenAIModel(
    "anthropic/claude-3.5-sonnet",  # or any other OpenRouter model
    base_url="https://openrouter.ai/api/v1",
    api_key="sk-or-...",
)

agent = Agent(model)
result = await agent.run("What is the meaning of life?")
print(result)
```

--------------------------------

### Tool Execution (JavaScript)

Source: https://openrouter.ai/docs/features/tool-calling.mdx

This JavaScript snippet shows how to execute a tool locally after receiving a tool call suggestion from the model. It simulates calling a function named searchGutenbergBooks with specific arguments. The result would be used in a subsequent request to the model.

```javascript
// Model responds with tool_calls, you execute the tool locally
const toolResult = await searchGutenbergBooks(["James", "Joyce"]);

```

--------------------------------

### POST /api/v1/responses

Source: https://openrouter.ai/docs/api-reference/beta-responses/create-responses.mdx

Sends a request to the OpenRouter AI model to generate a response based on user messages and optional function calling tools. You can specify the model, temperature, top_p, and include tool definitions for function calls.

```APIDOC
## POST /api/v1/responses

### Description
Sends a request to the OpenRouter AI model to generate a response based on user messages and optional function calling tools.

### Method
POST

### Endpoint
https://openrouter.ai/api/v1/responses

### Parameters
#### Path Parameters
*None*

#### Query Parameters
*None*

#### Request Body
- **input** (array) - Required - An array of message objects. Each object must contain `type`, `role`, and `content`.
- **tools** (array) - Optional - An array of tool definitions for function calling. Each tool includes `type`, `name`, `description`, and `parameters`.
- **model** (string) - Required - Identifier of the model to use, e.g., `anthropic/claude-4.5-sonnet-20250929`.
- **temperature** (number) - Optional - Controls randomness of output (default 0.7).
- **top_p** (number) - Optional - Controls nucleus sampling (default 09).

### Request Example
{
  "input": [
    {
      "type": "message",
      "role": "user",
      "content": "Hello, how are you?"
    }
  ],
  "tools": [
    {
      "type": "function",
      "name": "get_current_weather",
      "description": "Get the current weather in a given location",
      "parameters": {
        "type": "object",
        "properties": {
          "location": {
            "type": "string"
          }
        }
      }
    }
  ],
  "model": "anthropic/claude-4.5-sonnet-20250929",
  "temperature": 0.7,
  "top_p": 0.9
}

### Response
#### Success Response (200)
- **id** (string) - Identifier of the generated response.
- **choices** (array) - Array of generated messages.
- **usage** (object) - Token usage statistics.

#### Response Example
{
  "id": "resp_12345",
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "I'm doing well, thank you!"
      }
    }
  ],
  "usage": {
    "prompt_tokens": 15,
    "completion_tokens": 12,
    "total_tokens": 27
  }
}
```

--------------------------------

### Define Model Parameters API in OpenAPI YAML

Source: https://openrouter.ai/docs/api-reference/parameters/get-parameters.mdx

This YAML defines an OpenAPI 3.1.1 specification for a GET endpoint that retrieves supported parameters for a specified AI model, along with data on popular parameters. It requires path parameters 'author' and 'slug' for model identification, an optional 'provider' query parameter from a predefined enum of AI providers, and an 'Authorization' header with a bearer token. The endpoint returns a 200 response with the model name and a list of supported parameters (e.g., temperature, top_p) in JSON format; errors include 401 for unauthorized access, 404 for non-existent models, and 500 for server issues. No external dependencies are specified, but it assumes an API server implementation.

```yaml
openapi: 3.1.1
info:
  title: Get a model's supported parameters and data about which are most popular
  version: endpoint_parameters.getParameters
paths:
  /parameters/{author}/{slug}:
    get:
      operationId: get-parameters
      summary: Get a model's supported parameters and data about which are most popular
      tags:
        - - subpackage_parameters
      parameters:
        - name: author
          in: path
          required: true
          schema:
            type: string
        - name: slug
          in: path
          required: true
          schema:
            type: string
        - name: provider
          in: query
          required: false
          schema:
            $ref: '#/components/schemas/ParametersAuthorSlugGetParametersProvider'
        - name: Authorization
          in: header
          description: API key as bearer token in Authorization header
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Returns the parameters for the specified model
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Parameters_getParameters_Response_200'
        '401':
          description: Unauthorized - Authentication required or invalid credentials
          content: {}
        '404':
          description: Not Found - Model or provider does not exist
          content: {}
        '500':
          description: Internal Server Error - Unexpected server error
          content: {}
components:
  schemas:
    ParametersAuthorSlugGetParametersProvider:
      type: string
      enum:
        - value: AI21
        - value: AionLabs
        - value: Alibaba
        - value: Amazon Bedrock
        - value: Anthropic
        - value: AtlasCloud
        - value: Atoma
        - value: Avian
        - value: Azure
        - value: BaseTen
        - value: Cerebras
        - value: Chutes
        - value: Cirrascale
        - value: Clarifai
        - value: Cloudflare
        - value: Cohere
        - value: CrofAI
        - value: Crusoe
        - value: DeepInfra
        - value: DeepSeek
        - value: Enfer
        - value: Featherless
        - value: Fireworks
        - value: Friendli
        - value: GMICloud
        - value: Google
        - value: Google AI Studio
        - value: Groq
        - value: Hyperbolic
        - value: Inception
        - value: InferenceNet
        - value: Infermatic
        - value: Inflection
        - value: Kluster
        - value: Lambda
        - value: Liquid
        - value: Mancer 2
        - value: Meta
        - value: Minimax
        - value: ModelRun
        - value: Mistral
        - value: Modular
        - value: Moonshot AI
        - value: Morph
        - value: NCompass
        - value: Nebius
        - value: NextBit
        - value: Nineteen
        - value: Novita
        - value: Nvidia
        - value: OpenAI
        - value: OpenInference
        - value: Parasail
        - value: Perplexity
        - value: Phala
        - value: Relace
        - value: SambaNova
        - value: SiliconFlow
        - value: Stealth
        - value: Switchpoint
        - value: Targon
        - value: Together
        - value: Ubicloud
        - value: Venice
        - value: WandB
        - value: xAI
        - value: Z.AI
        - value: FakeProvider
    ParametersAuthorSlugGetResponsesContentApplicationJsonSchemaDataSupportedParametersItems:
      type: string
      enum:
        - value: temperature
        - value: top_p
        - value: top_k
        - value: min_p
        - value: top_a
        - value: frequency_penalty
        - value: presence_penalty
        - value: repetition_penalty
        - value: max_tokens
        - value: logit_bias
        - value: logprobs
        - value: top_logprobs
        - value: seed
        - value: response_format
        - value: structured_outputs
        - value: stop
        - value: tools
        - value: tool_choice
        - value: parallel_tool_calls
        - value: include_reasoning
        - value: reasoning
        - value: web_search_options
        - value: verbosity
    ParametersAuthorSlugGetResponsesContentApplicationJsonSchemaData:
      type: object
      properties:
        model:
          type: string
        supported_parameters:
          type: array
          items:
            $ref: >-
              #/components/schemas/ParametersAuthorSlugGetResponsesContentApplicationJsonSchemaDataSupportedParametersItems
      required:
        - model
        - supported_parameters
    Parameters_getParameters_Response_200:
      type: object
      properties:
        data:
          $ref: >-
            #/components/schemas/ParametersAuthorSlugGetResponsesContentApplicationJsonSchemaData
      required:
        - data
```

--------------------------------

### Extract Authorization Code from URL

Source: https://openrouter.ai/docs/use-cases/oauth-pkce.mdx

Extracts the authorization 'code' query parameter from the current page's URL after the user is redirected back from OpenRouter. This code is essential for exchanging it for an API key. It utilizes the URLSearchParams API available in modern browsers.

```typescript
const urlParams = new URLSearchParams(window.location.search);
const code = urlParams.get('code');
```

--------------------------------

### OpenRouter API: Simple String Input

Source: https://openrouter.ai/docs/api-reference/responses-api/basic-usage.mdx

Demonstrates making a POST request to the OpenRouter Responses API with a simple string as input. This method is suitable for straightforward text generation tasks. The request includes authorization headers, content type, and a JSON body specifying the model, input string, and maximum output tokens.

```typescript
const response = await fetch('https://openrouter.ai/api/v1/responses', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/o4-mini',
    input: 'What is the meaning of life?',
    max_output_tokens: 9000,
  }),
});

const result = await response.json();
console.log(result);
```

```python
import requests

response = requests.post(
    'https://openrouter.ai/api/v1/responses',
    headers={
        'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
        'Content-Type': 'application/json',
    },
    json={
        'model': 'openai/o4-mini',
        'input': 'What is the meaning of life?',
        'max_output_tokens': 9000,
    }
)

result = response.json()
print(result)
```

```bash
curl -X POST https://openrouter.ai/api/v1/responses \
  -H "Authorization: Bearer YOUR_OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/o4-mini",
    "input": "What is the meaning of life?",
    "max_output_tokens": 9000
  }'
```

--------------------------------

### Encrypted Reasoning Detail Object Example

Source: https://openrouter.ai/docs/use-cases/reasoning-tokens.mdx

This JSON object exemplifies an 'encrypted' type reasoning detail. It contains the type, encrypted data, a unique ID, the format, and an optional index. The data field holds base64 encoded encrypted content.

```json
{
  "type": "reasoning.encrypted",
  "data": "eyJlbmNyeXB0ZWQiOiJ0cnVlIiwiY29udGVudCI6IltSRURBQ1RFRF0ifQ==",
  "id": "reasoning-encrypted-1",
  "format": "anthropic-claude-v1",
  "index": 1
}
```

--------------------------------

### POST /api/v1/chat/completions

Source: https://openrouter.ai/docs/features/provider-routing.mdx

Creates a chat completion using specified model with optional quantization filtering and pricing controls. Supports streaming and non-streaming responses.

```APIDOC
## POST /api/v1/chat/completions

### Description
Creates a chat completion by sending messages to a specified LLM model. Supports quantization-based provider filtering and pricing controls to optimize cost and performance.

### Method
POST

### Endpoint
https://openrouter.ai/api/v1/chat/completions

### Parameters
#### Request Body
- **model** (string) - Required - Model identifier (e.g., 'meta-llama/llama-3.1-8b-instruct')
- **messages** (array) - Required - Array of message objects with 'role' and 'content' fields
- **provider** (object) - Optional - Provider configuration object
  - **quantizations** (array) - Optional - List of quantization levels to filter by (e.g., ["fp8", "int4", "int8"])
  - **sort** (string) - Optional - Provider sorting criteria (e.g., "price", "throughput")
  - **max_price** (object) - Optional - Maximum pricing thresholds
    - **prompt** (number) - Optional - Max price per million prompt tokens
    - **completion** (number) - Optional - Max price per million completion tokens
    - **request** (number) - Optional - Max price per request
    - **image** (number) - Optional - Max price per image
- **stream** (boolean) - Optional - Enable streaming responses (default: false)

### Request Example
{
  "model": "meta-llama/llama-3.1-8b-instruct",
  "messages": [{ "role": "user", "content": "Hello" }],
  "provider": {
    "quantizations": ["fp8"],
    "sort": "throughput",
    "max_price": {
      "prompt": 1,
      "completion": 2
    }
  },
  "stream": false
}

### Response
#### Success Response (200)
- **id** (string) - Completion ID
- **object** (string) - Always "chat.completion"
- **created** (number) - Unix timestamp
- **model** (string) - Model used for completion
- **choices** (array) - Array of completion choices
- **usage** (object) - Token usage statistics

#### Response Example
{
  "id": "cmpl-abc123",
  "object": "chat.completion",
  "created": 1677652288,
  "model": "meta-llama/llama-3.1-8b-instruct",
  "choices": [{
    "index": 0,
    "message": {
      "role": "assistant",
      "content": "Hello! How can I help you today?"
    },
    "finish_reason": "stop"
  }],
  "usage": {
    "prompt_tokens": 5,
    "completion_tokens": 9,
    "total_tokens": 14
  }
}

### Supported Quantization Levels
- **int4**: Integer (4 bit)
- **int8**: Integer (8 bit)
- **fp4**: Floating point (4 bit)
- **fp6**: Floating point (6 bit)
- **fp8**: Floating point (8 bit)
- **fp16**: Floating point (16 bit)
- **bf16**: Brain floating point (16 bit)
- **fp32**: Floating point (32 bit)
- **unknown**: Unknown quantization
```

--------------------------------

### Basic Chat Completion with Reasoning - OpenAI SDK TypeScript

Source: https://openrouter.ai/docs/use-cases/reasoning-tokens.mdx

TypeScript implementation using OpenAI SDK compatibility layer with OpenRouter. Includes proper TypeScript typing for reasoning fields, demonstrates async/await patterns, and shows how to access both reasoning and content from the response.

```typescript
import OpenAI from 'openai';

const openai = new OpenAI({
  baseURL: 'https://openrouter.ai/api/v1',
  apiKey: '{{API_KEY_REF}}',
});

async function getResponseWithReasoning() {
  const response = await openai.chat.completions.create({
    model: '{{MODEL}}',
    messages: [
      {
        role: 'user',
        content: "How would you build the world's tallest skyscraper?",
      },
    ],
    reasoning: {
      effort: 'high',
    },
  });

  type ORChatMessage = (typeof response)['choices'][number]['message'] & {
    reasoning?: string;
    reasoning_details?: unknown;
  };

  const msg = response.choices[0].message as ORChatMessage;
  console.log('REASONING:', msg.reasoning);
  console.log('CONTENT:', msg.content);
}

getResponseWithReasoning();
```

--------------------------------

### Exchange Authorization Code for API Key

Source: https://openrouter.ai/docs/use-cases/oauth-pkce.mdx

Exchanges the received authorization code for a user-controlled API key by making a POST request to the OpenRouter API endpoint. Requires the extracted 'code', and optionally 'code_verifier' and 'code_challenge_method' if PKCE was used during the initial authentication step. Returns the API key upon successful exchange.

```typescript
const response = await fetch('https://openrouter.ai/api/v1/auth/keys', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    code: '<CODE_FROM_QUERY_PARAM>',
    code_verifier: '<CODE_VERIFIER>', // If code_challenge was used
    code_challenge_method: '<CODE_CHALLENGE_METHOD>', // If code_challenge was used
  }),
});

const { key } = await response.json();
```

--------------------------------

### List Embeddings (TypeScript)

Source: https://openrouter.ai/docs/sdks/typescript/models.mdx

Demonstrates how to list available embeddings models using the OpenRouter SDK in TypeScript. It initializes the OpenRouter client with an API key and then calls the `listEmbeddings()` method to retrieve a list of embedding models. The result is then printed to the console.

```typescript
import { OpenRouter } from "@openrouter/sdk";

const openRouter = new OpenRouter({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const result = await openRouter.models.listEmbeddings();

  console.log(result);
}

run();
```

--------------------------------

### React Hook for Chat Completion (TypeScript)

Source: https://openrouter.ai/docs/sdks/typescript/chat.mdx

Provides the import statement for the React Query mutation hook used to trigger chat completion API calls within React applications. This hook simplifies state management and data fetching for the chat functionality. Refer to the linked guide for detailed usage instructions.

```typescript
import {
  // Mutation hook for triggering the API call.
  useChatSendMutation
} from "@openrouter/sdk/react-query/chatSend.js";
```

--------------------------------

### Advanced Reasoning Chain-of-Thought (Python)

Source: https://openrouter.ai/docs/use-cases/reasoning-tokens.mdx

This Python example illustrates an advanced use case for reasoning tokens, implementing a chain-of-thought process. It involves obtaining reasoning from one model ('deepseek/deepseek-r1') and then injecting that reasoning into a subsequent request to another model ('openai/gpt-4o-mini') to improve response quality. The code defines a helper function `do_req` to manage requests and processes the reasoning to enhance the final output.

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key="{{API_KEY_REF}}",
)

question = "Which is bigger: 9.11 or 9.9?"

def do_req(model: str, content: str, reasoning_config: dict | None = None):
    payload = {
        "model": model,
        "messages": [{"role": "user", "content": content}],
        "stop": "</think>",
    }
    if reasoning_config:
        payload.update(reasoning_config)
    return client.chat.completions.create(**payload)

# Get reasoning from a capable model
content = f"{question} Please think this through, but don't output an answer"
reasoning_response = do_req("deepseek/deepseek-r1", content)
reasoning = getattr(reasoning_response.choices[0].message, "reasoning", "")

# Let's test! Here's the naive response:
simple_response = do_req("openai/gpt-4o-mini", question)
print(getattr(simple_response.choices[0].message, "content", None))

# Here's the response with the reasoning token injected:
content = f"{question}. Here is some context to help you: {reasoning}"
smart_response = do_req("openai/gpt-4o-mini", content)
print(getattr(smart_response.choices[0].message, "content", None))
```

--------------------------------

### Parallel Tool Calls with OpenRouter API (TypeScript & Python)

Source: https://openrouter.ai/docs/api-reference/responses-api/tool-calling.mdx

Illustrates how to make parallel tool calls by including multiple tools in a single API request to OpenRouter. The API can process requests that require outputs from different tools simultaneously. The response from this call will contain information about the executed tool calls.

```typescript
const response = await fetch('https://openrouter.ai/api/v1/responses', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'openai/o4-mini',
    input: [
      {
        type: 'message',
        role: 'user',
        content: [
          {
            type: 'input_text',
            text: 'Calculate 10*5 and also tell me the weather in Miami',
          },
        ],
      },
    ],
    tools: [weatherTool, calculatorTool],
    tool_choice: 'auto',
    max_output_tokens: 9000,
  }),
});

const result = await response.json();
console.log(result);
```

```python
import requests

response = requests.post(
    'https://openrouter.ai/api/v1/responses',
    headers={
        'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
        'Content-Type': 'application/json',
    },
    json={
        'model': 'openai/o4-mini',
        'input': [
            {
                'type': 'message',
                'role': 'user',
                'content': [
                    {
                        'type': 'input_text',
                        'text': 'Calculate 10*5 and also tell me the weather in Miami',
                    },
                ],
            },
        ],
        'tools': [weather_tool, calculator_tool],
        'tool_choice': 'auto',
        'max_output_tokens': 9000,
    }
)

result = response.json()
print(result)
```

--------------------------------

### POST /api/v1/responses

Source: https://openrouter.ai/docs/api-reference/responses-api/basic-usage.mdx

This endpoint generates AI responses with optional streaming support for real-time output. It allows submitting a model, input text or messages, and parameters like temperature and max tokens. Streaming returns Server-Sent Events (SSE) for incremental response data.

```APIDOC
## POST /api/v1/responses

### Description
Generates an AI response for the given input, with support for streaming to receive real-time updates via Server-Sent Events (SSE).

### Method
POST

### Endpoint
https://openrouter.ai/api/v1/responses

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
- **model** (string) - Required - Model to use (e.g., `openai/o4-mini`)
- **input** (string or array) - Required - Text or message array
- **stream** (boolean) - Optional - Enable streaming responses (default: false)
- **max_output_tokens** (integer) - Optional - Maximum tokens to generate
- **temperature** (number) - Optional - Sampling temperature between 0 and 2
- **top_p** (number) - Optional - Nucleus sampling parameter between 0 and 1

#### Headers
- **Authorization** (string) - Required - Bearer token: `Bearer YOUR_OPENROUTER_API_KEY`
- **Content-Type** (string) - Required - Must be `application/json`

### Request Example
```json
{
  "model": "openai/o4-mini",
  "input": "Write a short story about AI",
  "stream": true,
  "max_output_tokens": 9000
}
```

### Response
#### Success Response (200)
Returns a stream of Server-Sent Events (SSE) with data lines containing JSON objects describing the response creation and content deltas.

#### Response Example
```
data: {"type":"response.created","response":{"id":"resp_1234567890","object":"response","status":"in_progress"}}

data: {"type":"response.output_item.added","response_id":"resp_1234567890","output_index":0,"item":{"type":"message","id":"msg_abc123","role":"assistant","status":"in_progress","content":[]}}

data: {"type":"response.content_part.added","response_id":"resp_1234567890","output_index":0,"content_index":0,"part":{"type":"output_text","text":""}}

data: {"type":"response.content_part.delta","response_id":"resp_1234567890","output_index":0,"content_index":0,"delta":"Once"}

data: {"type":"response.content_part.delta","response_id":"resp_1234567890","output_index":0,"content_index":0,"delta":" upon"}

data: {"type":"response.content_part.delta","response_id":"resp_1234567890","output_index":0,"content_index":0,"delta":" a"}

data: {"type":"response.content_part.delta","response_id":"resp_1234567890","output_index":0,"content_index":0,"delta":" time"}

data: {"type":"response.output_item.done","response_id":"resp_1234567890","output_index":0,"item":{"type":"message","id":"msg_abc123","role":"assistant","status":"completed","content":[{"type":"output_text","text":"Once upon a time, in a world where artificial intelligence had become as common as smartphones..."}]}}

data: {"type":"response.done","response":{"id":"resp_1234567890","object":"response","status":"completed","usage":{"input_tokens":12,"output_tokens":45,"total_tokens":57}}}

data: [DONE]
```

#### Error Responses
- **401 Unauthorized**: Invalid or missing API key
- **400 Bad Request**: Invalid parameters or model not available
- **429 Too Many Requests**: Rate limit exceeded
```

--------------------------------

### OpenAI Responses API Error Event Types (JSON)

Source: https://openrouter.ai/docs/api-reference/errors.mdx

These JSON examples illustrate the different event types used by the OpenAI Responses API to signal errors during response generation or processing. They include official failure events, errors during generation, and undocumented plain error events.

```json
{
  "type": "response.failed",
  "response": {
    "id": "resp_abc123",
    "status": "failed",
    "error": {
      "code": "server_error",
      "message": "Internal server error"
    }
  }
}
```

```json
{
  "type": "response.error",
  "error": {
    "code": "rate_limit_exceeded",
    "message": "Rate limit exceeded"
  }
}
```

```json
{
  "type": "error",
  "error": {
    "code": "invalid_api_key",
    "message": "Invalid API key provided"
  }
}
```

--------------------------------

### Check Available Credits with OpenRouter SDK

Source: https://openrouter.ai/docs/use-cases/crypto-api.mdx

This snippet shows how to use the OpenRouter TypeScript SDK to fetch and display available credits. It initializes the SDK with an API key and calls the `credits.get()` method to retrieve credit balance and usage information.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
});

const credits = await openRouter.credits.get();
console.log('Available credits:', credits.totalCredits - credits.totalUsage);
```

--------------------------------

### TypeScript SDK: Credits Method Documentation

Source: https://context7_llms

Documentation for the credits method in the OpenRouter TypeScript SDK. This method allows users to check their remaining credits or usage quotas associated with their OpenRouter account.

```typescript
import OpenRouter from '@openrouter/sdk';

const openrouter = new OpenRouter({
  apiKey: 'YOUR_OPENROUTER_API_KEY',
});

async function checkCredits() {
  try {
    const credits = await openrouter.credits.get();
    console.log('Your Credits:', credits);
  } catch (error) {
    console.error('Error checking credits:', error);
  }
}

checkCredits();
```

--------------------------------

### POST /v1/chat/completions

Source: https://openrouter.ai/docs/api-reference/parameters.mdx

Creates a chat completion using the specified model. Accepts various sampling and generation to control output diversity, repetition, and token limits.

```APIDOC
## POST /v1/chat/completions

### Description
Creates a chat completion using the selected model. The request body can include a wide range of optional sampling parameters to fine‑tune the generated response.

### Method
POST

### Endpoint
/v1/chat/completions

### Parameters
#### Path Parameters
*None*

#### Query Parameters
*None*

#### Request Body
- **model** (string) - Required - Identifier of the model to use (e.g., "openrouter/anthropic-claude-v2").
- **messages** (array) - Required - List of messages forming the conversation.
- **temperature** (float) - Optional - Controls randomness; 0.0 = deterministic, default 1.0.
- **top_p** (float) - Optional - Nucleus sampling probability, default 1.0.
- **top_k** (integer) - Optional - Limits token selection to top K tokens, default 0 (disabled).
- **frequency_penalty** (float) - Optional - Penalizes new tokens based on their existing frequency in the prompt, default 0.0.
- **presence_penalty** (float) - Optional - Penalizes tokens that already appear in the prompt, default 0.0.
- **repetition_penalty**float) - Optional - Reduces repetition of tokens, default 1.0.
- **min_p** (float) - Optional - Minimum probability threshold relative to the most likely token, default 0.0.
- **top_a** (float) - Optional - Dynamic top‑A sampling, default 0.0.
- **seed** (integer) - Optional - Deterministic seed for reproducible outputs.
- **max_tokens** (integer) - Optional - Maximum number of tokens to generate, default is model‑specific.

### Request Example
{
  "model": "openrouter/anthropic-claude-v2",
  "messages": [{"role": "user", "content": "Explain quantum entanglement in simple terms."}],
  "temperature": 0.7,
  "top_p": 0.9,
  "max_tokens": 150
}

### Response
#### Success Response (200)
- **id** (string) - Completion identifier.
- **object** (string) - Typically "chat.completion".
- **created** (integer) - Unix timestamp.
- **model** (string) - Model used.
- **choices** (array) - Generated messages with role and content.

 Response Example
{
  "id": "chatcmpl-12345",
  "object": "chat.completion",
  "created": 1730567890,
  "model": "openrouter/anthropic-claude-v2",
  "choices": [
    {
      "message": {"role": "assistant", "content": "Quantum entanglement is..."},
      "finish_reason": "stop",
      "index": 0
    }
  ]
}
```

--------------------------------

### Retrieve User Credits via Standalone Function - TypeScript

Source: https://openrouter.ai/docs/sdks/typescript/credits.mdx

Provides a standalone function version to get total credits purchased and used for the authenticated user, optimized for tree-shaking performance with OpenRouterCore. Dependencies include the @openrouter/sdk/core.js and creditsGetCredits from funcs, requiring an OPENROUTER_API_KEY for authentication. It returns a result object with ok/error handling and the credits value on success. Limitations include the need for authentication; errors may occur with 401, 403, or 500 status codes.

```typescript
import { OpenRouterCore } from "@openrouter/sdk/core.js";
import { creditsGetCredits } from "@openrouter/sdk/funcs/creditsGetCredits.js";

// Use `OpenRouterCore` for best tree-shaking performance.
// You can create one instance of it to use across an application.
const openRouter = new OpenRouterCore({
  apiKey: process.env["OPENROUTER_API_KEY"] ?? "",
});

async function run() {
  const res = await creditsGetCredits(openRouter);
  if (res.ok) {
    const { value: result } = res;
    console.log(result);
  } else {
    console.log("creditsGetCredits failed:", res.error);
  }
}

run();
```

--------------------------------

### Send request to OpenRouter API with function tool (Python, JavaScript, Go, Ruby, Java, PHP)

Source: https://openrouter.ai/docs/api-reference/beta-responses/create-responses.mdx

These snippets show how to post a user message and a function tool payload to the OpenRouter API using various languages. They include setting the Authorization header, JSON body, and handling the. Adjust the <token> placeholder with your API key.

```python
import requests\n\nurl = "https://openrouter.ai/api/v1/responses"\n\npayload = {\n    "input": [\n        {\n            "type": "message",\n            "role": "user",\n            "content": "Hello, how are you?"\n        }\n    ],\n    "tools": [\n        {\n            "type": "function",\n            "name": "get_current_weather",\n            "description": "Get the current weather in a given location",\n            "parameters": {\n                "type": "object",\n                "properties": { "location": { "type": "string" } }\n            }\n        }\n    ],\n    "model": "anthropic/claude-4.5-sonnet-20250929",\n    "temperature": 0.7,\n    "top_p": 0.9\n}\nheaders = {\n    "Authorization": "Bearer <token>",\n    "Content-Type": "application/json"\n}\n\nresponse = requests.post(url, json=payload, headers=headers)\n\nprint(response.json())
```

```javascript
const url = 'https://openrouter.ai/api/v1/responses';\nconst options = {\n  method: 'POST',\n  headers: {Authorization: 'Bearer <token>', 'Content-Type': 'application/json'},\n  body: '{"input":[{"type":"message","role":"user","content":"Hello, how are you?"}],"tools":[{"type":"function","name":"get_current_weather","description":"Get the current weather in a given location","parameters":{"type":"object","properties":{"location":{"type":"string"}}}}],"model":"anthropic/claude-4.5-sonnet-20250929","temperature":0.7,"top_p":0.9}'\n};\n\ntry {\n  const response await fetch(url, options);\n  const data = await response.json();\n  console.log(data);\n} catch (error) {\n  console.error(error);\n}
```

```go
package main\n\nimport (\n    \"fmt\"\n    \"strings\"\n    \"net/http\"\n    \"io\"\n)\n\nfunc main() {\n\n    url := \"https://openrouter.ai/api/v1/responses\"\n\n    payload := strings.NewReader("{\n  \"input\": [\n    {\n      \"type\": \"message\",\n      \"role\": \"user\",\n      \"content\": \"Hello, how are you?\"\n    }\n  ],\n  \"tools\": [\n    {\n      \"type\": \"function\",\n      \"name\": \"get_current_weather\",\n      \"description\": \"Get the current weather in a given location\",\n      \"parameters\": {\n        \"type\": \"object\",\n        \"properties\": {\n          \"location\": {\n            \"type\": \"string\"\n          }\n        }\n      }\n    }\n  ],\n  \"model\": \"anthropic/claude-4.5-sonnet-20250929\",\n  \"temperature\": 0.7,\n  \"top_p\": 0.9\n}")\n\n    req, _ := http.NewRequest(\"POST\", url, payload)\n\n    req.Header.Add(\"Authorization\", \"Bearer <token>\")\n    req.Header.Add(\"Content-Type\", \"application/json\")\n\n    res, _ := http.DefaultClient.Do(req)\n\n    defer res.Body.Close()\n    body, _ := io.ReadAll(res.Body)\n\n    fmt.Println(res)\n    fmt.Println(string(body))\n\n}
```

```ruby
require 'uri'\nrequire 'net/http'\n\nurl = URI("https://openrouter.ai/api/v1/responses")\n\nhttp = Net::HTTP.new(url.host, url.port)\nhttp.use_ssl = true\n\nrequest = Net::HTTP::Post.new(url)\nrequest[\"Authorization\"] = 'Bearer <token>'\nrequest[\"Content-Type\"] = 'application/json'\nrequest.body = "{\n  \"input\": [\n    {\n      \"type\": \"message\",\n      \"role\": \"user\",\n      \"content\": \"Hello, how are you?\"\n    }\n  ],\n  \"tools\": [\n    {\n      \"type\": \"function\",\n      \"name\ \"get_current_weather\",\n      \"description\": \"Get the current weather in a given location\",\n      \"parameters\": {\n        \"type\": \"object\",\n        \"properties\": {\n          \"location\": {\n            \"type\": \"string\"\n          }\n        }\n      }\n    }\n  ],\n  \"model\": \"anthropic/claude-4.5-sonnet-20250929\",\n  \"temperature\": 0.7,\n  \"top_p\": 0.9\n}"\n\nresponse = http.request(request)\nputs response.read_body
```

```java
HttpResponse<String> response = Unirest.post("https://openrouter.ai/api/v1/responses")\n  .header("Authorization", "Bearer <token>")\n  .header("Content-Type", "application/json")\n  .body("{n  \"input\": [\n    {\n      \"type\": \"message\",\n      \"role\": \"user\",\n      \"content\": \"Hello, how are you?\"\n    }\n  ],\n  \"tools\": [\n    {\n      \"type\": \"function\",\n      \"name\": \"get_current_weather\",\n      \"description\": \"Get the current weather in a given location\",\n      \"parameters\": {\n        \"type\": \"object\",\n        \"properties\": {\n          \"location\": {\n            \"type\": \"string\"\n          }\n        }\n      }\n    }\n  ],\n  \"model\": \"anthropic/claude-4.5-sonnet-20250929\",\n  \"temperature\": 0.7,\n  \"top_p\": 0.9\n}")\n  .asString();
```

```php
<?php\n\n$client = new \GuzzleHttp\Client();\n\n$response = $client->request('POST', 'https://openrouter.ai/api/v1/responses', [\n  'body' => '{\n  "input": [\n    {\n      "type": "message",\n      "role": "user",\n      "content": "Hello, how are you?"\n    }\n  ],\n  "tools": [\n    {\n      "type": "function",\n      "name": "get_current_weather",\n      "description": "Get the current weather in a given location",\n      "parameters": {\n        "type": "object",\n        "properties": {\n          "location": {\n            "type": "string"\n          }\n        }\n      }\n    }\n  ],\n  "model": "anthropic/claude-4.5-sonnet-20250929",\n  "temperature": 0.7,\n  "top_p": 0.9\n}'\n]);
```

--------------------------------

### POST /api/v1/responses (Streaming Tool Calls)

Source: https://openrouter.ai/docs/api-reference/responses-api/tool-calling.mdx

Monitor tool calls in real-time with streaming. This endpoint accepts a request with tools defined and returns a streaming response that can be parsed for tool call events. It supports models capable of function calling and allows for dynamic tool invocation.

```APIDOC
## POST /api/v1/responses

### Description
This endpoint generates responses from LLMs with support for streaming tool calls. By setting stream to true, the response is delivered in real-time chunks, allowing clients to monitor and process tool invocations as they occur.

### Method
POST

### Endpoint
https://openrouter.ai/api/v1/responses

### Parameters
#### Path Parameters
- No path parameters.

#### Query Parameters
- No query parameters.

#### Request Body
- **model** (string) - Required - The model identifier, e.g., 'openai/o4-mini'.
- **input** (array of objects) - Required - Array of input messages, each with type, role, and content.
- **tools** (array of objects) - Required - Array of tool definitions for function calling.
- **tool_choice** (string) - Optional - Specifies how tools are selected, e.g., 'auto'.
- **stream** (boolean) - Required for streaming - Set to true to enable streaming responses.
- **max_output_tokens** (integer) - Optional - Maximum number of output tokens, e.g., 9000.

### Request Example
```json
{
  "model": "openai/o4-mini",
  "input": [
    {
      "type": "message",
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "What is the weather like in Tokyo, Japan? Please check the weather."
        }
      ]
    }
  ],
  "tools": [weatherTool],
  "tool_choice": "auto",
  "stream": true,
  "max_output_tokens": 9000
}
```

### Response
#### Success Response (200)
Streaming response consisting of newline-delimited JSON objects. Key events include:
- **response.output_item.added** (object) - Indicates a new output item, such as a function call.
- **response.function_call_arguments.done** (object) - Signals completion of function call arguments.

#### Response Example
Streaming chunks like:
```json
data: {"type": "response.output_item.added", "item": {"type": "function_call", "name": "get_weather"}}
data: {"type": "response.function_call_arguments.done", "arguments": "{\"location\":\"Tokyo, Japan\"}"}
data: [DONE]
```
```

--------------------------------

### POST /api/v1/responses

Source: https://openrouter.ai/docs/api-reference/responses-api/reasoning.mdx

Creates a response using the OpenRouter API, supporting multi‑turn conversation input with optional reasoning configuration. Include model selection, message sequence, and token limits in the request body.

```APIDOC
## POST /api/v1/responses

### Description
Creates a response using the OpenRouter API, supporting multi‑turn conversation input with optional reasoning parameters.

### Method
POST

### Endpoint
https://openrouter.ai/api/v1/responses

### Parameters
#### Path Parameters
*None*

#### Query Parameters
*None*

#### Request Body
- **model** (string) - Required - Identifier of the model to use (e.g., "openai/o4-mini").
- **input** (array) - Required - List of message objects forming the conversation. Each message includes:
  - **type** (string) - Required - Should be "message".
  - **role** (string) - Required - "user" or "assistant".
  - **content** (array) - Required - Content objects with type and text.
  - **id** (string) - Optional - Assistant message identifier.
  - **status** (string) - Optional - Status of assistant message.
- **reasoning** (object) - Optional - Configuration for reasoning, e.g., "effort".
- **max_output_tokens** (integer) - Optional - Maximum tokens for the response.

### Request Example
{
  "model": "openai/o4-mini",
  "input": [
    {
      "type": "message",
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "What is your favorite color?"
        }
      ]
    },
    {
      "type": "messagen      "role": "assistant",
      "id": "msg_abc123",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "text": "I don't have a favorite color.",
          "annotations": []
        }
      ]
    },
    {
      "type": "message",
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "How many Earths can fit on Mars?"
        }
      ]
    }
  ],
  "reasoning": {
    "effort": "high"
  },
  "max_output_tokens": 9000
}

### Response
#### Success Response (200)
- **id** (string) - Identifier of the generated response.
- **output** (object) - Contains the assistant's reply and any annotations.
- **usage** (object) - Token usage statistics.

### Response Example
{
  "id": "resp_xyz789",
  "output": {
    "type": "output_text",
    "text": "Approximately 0.1 Earths could fit on Mars."
  },
  "usage": {
    "prompt_tokens": 150,
    "completion_tokens": 30,
    "total_tokens": 180
  }
}
```

--------------------------------

### Configuring AWS Credentials in JSON

Source: https://openrouter.ai/docs/use-cases/byok.mdx

This JSON snippet provides an example of AWS credentials in JSON format for authenticating with Amazon Bedrock via OpenRouter. It includes access key ID, secret access key, and region. Ensure the AWS IAM user has bedrock:InvokeModel and bedrock:InvokeModelWithResponseStream permissions. This method offers flexibility but requires secure storage of sensitive keys.

```json
{
  "accessKeyId": "your-aws-access-key-id",
  "secretAccessKey": "your-aws-secret-access-key",
  "region": "your-aws-region"
}
```

--------------------------------

### Basic Chat Completion with Reasoning - OpenRouter SDK

Source: https://openrouter.ai/docs/use-cases/reasoning-tokens.mdx

Demonstrates basic chat completion using the official OpenRouter SDK with reasoning tokens enabled. Shows how to configure the client, send messages, and retrieve both reasoning and content responses. Uses the 'high' effort setting for maximum reasoning depth.

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '{{API_KEY_REF}}',
});

const response = await openRouter.chat.send({
  model: '{{MODEL}}',
  messages: [
    {
      role: 'user',
      content: "How would you build the world's tallest skyscraper?",
    },
  ],
  reasoning: {
    effort: 'high',
  },
  stream: false,
});

console.log('REASONING:', response.choices[0].message.reasoning);
console.log('CONTENT:', response.choices[0].message.content);
```

--------------------------------

### Disable Tool Calling in API Request (TypeScript, Python)

Source: https://openrouter.ai/docs/api-reference/responses-api/tool-calling.mdx

This example demonstrates how to disable all tool calling in an OpenRouter API request by setting the 'tool_choice' parameter to 'none'. It provides code for both TypeScript and Python, showing the request structure and necessary headers. This is useful when you only want a text-based response and not a tool-use action from the model. Dependencies include 'fetch' for TypeScript and 'requests' for Python.

```TypeScript
const response = await fetch('https://openrouter.ai/api/v1/responses', {
    method: 'POST',
    headers: {
      'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'openai/o4-mini',
      input: [
        {
          type: 'message',
          role: 'user',
          content: [
            {
              type: 'input_text',
              text: 'What is the weather in Paris?',
            },
          ],
        },
      ],
      tools: [weatherTool],
      tool_choice: 'none',
      max_output_tokens: 9000,
    }),
  });
```

```Python
import requests

response = requests.post(
    'https://openrouter.ai/api/v1/responses',
    headers={
        'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
        'Content-Type': 'application/json',
    },
    json={
        'model': 'openai/o4-mini',
        'input': [
            {
                'type': 'message',
                'role': 'user',
                'content': [
                    {
                        'type': 'input_text',
                        'text': 'What is the weather in Paris?',
                    },
                ],
            },
        ],
        'tools': [weather_tool],
        'tool_choice': 'none',
        'max_output_tokens': 9000,
    }
)
```

--------------------------------

### Reusing PDF Annotations in OpenRouter API (Python & TypeScript)

Source: https://openrouter.ai/docs/features/multimodal/pdfs.mdx

This functionality demonstrates encoding a PDF as base64, sending it to the OpenRouter API for initial analysis, extracting file annotations from the response, and reusing those annotations in subsequent requests without re-sending the PDF. It depends on libraries like requests and json in Python, or fs and fetch in TypeScript, with inputs being PDF paths and API keys, outputting API responses with processed document insights. Limitations include incomplete TypeScript example and assumption of valid API responses; handle errors for production use.

```python
import requests
import json
import base64
from pathlib import Path

# First, encode and send the PDF
def encode_pdf_to_base64(pdf_path):
    with open(pdf_path, "rb") as pdf_file:
        return base64.b64encode(pdf_file.read()).decode('utf-8')

url = "https://openrouter.ai/api/v1/chat/completions"
headers = {
    "Authorization": f"Bearer {API_KEY_REF}",
    "Content-Type": "application/json"
}

# Read and encode the PDF
pdf_path = "path/to/your/document.pdf"
base64_pdf = encode_pdf_to_base64(pdf_path)
data_url = f"data:application/pdf;base64,{base64_pdf}"

# Initial request with the PDF
messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "text",
                "text": "What are the main points in this document?"
            },
            {
                "type": "file",
                "file": {
                    "filename": "document.pdf",
                    "file_data": data_url
                }
            },
        ]
    }
]

payload = {
    "model": "{{MODEL}}",
    "messages": messages
}

response = requests.post(url, headers=headers, json=payload)
response_data = response.json()

# Store the annotations from the response
file_annotations = None
if response_data.get("choices") and len(response_data["choices"]) > 0:
    if "annotations" in response_data["choices"][0]["message"]:
        file_annotations = response_data["choices"][0]["message"]["annotations"]

# Follow-up request using the annotations (without sending the PDF again)
if file_annotations:
    follow_up_messages = [
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "What are the main points in this document?"
                },
                {
                    "type": "file",
                    "file": {
                        "filename": "document.pdf",
                        "file_data": data_url
                    }
                }
            ]
        },
        {
            "role": "assistant",
            "content": "The document contains information about...",
            "annotations": file_annotations
        },
        {
            "role": "user",
            "content": "Can you elaborate on the second point?"
        }
    ]

    follow_up_payload = {
        "model": "{{MODEL}}",
        "messages": follow_up_messages
    }

    follow_up_response = requests.post(url, headers=headers, json=follow_up_payload)
    print(follow_up_response.json())
```

```typescript
import fs from 'fs/promises';

async function encodePDFToBase64(pdfPath: string): Promise<string> {
  const pdfBuffer = await fs.readFile(pdfPath);
  const base64PDF = pdfBuffer.toString('base64');
  return `data:application/pdf;base64,${base64PDF}`;
}

// Initial request with the PDF
async function processDocument() {
  // Read and encode the PDF
  const pdfPath = 'path/to/your/document.pdf';
  const base64PDF = await encodePDFToBase64(pdfPath);

  const initialResponse = await fetch(
    'https://openrouter.ai/api/v1/chat/completions',
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${API_KEY_REF}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: '{{MODEL}}',
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: 'What are the main points in this document?',
              },
              {
                type: 'file',
                file: {
                  filename: 'document.pdf',
                  file_data: base64PDF,
                },
              },
            ],
          },
        ],
      }),
    },
  );

  const initialData = await initialResponse.json();

  // Store the annotations from the response
  let fileAnnotations = null;
  if (initialData.choices && initialData.choices.length > 0) {

```

--------------------------------

### Send Completion Request - JavaScript

Source: https://openrouter.ai/docs/api-reference/completions/create-completions.mdx

This snippet shows how to make a completion API call using JavaScript and the `fetch` API.  It handles potential errors and logs the response data to the console. Ensure you have a suitable environment that supports asynchronous JavaScript code.

```JavaScript
const url = 'https://openrouter.ai/api/v1/completions';
const options = {
  method: 'POST',
  headers: {Authorization: 'Bearer &lt;token&gt;', 'Content-Type': 'application/json'},
  body: '{\n  "prompt":"string"\n}'
};

try {
  const response = await fetch(url, options);
  const data = await response.json();
  console.log(data);
} catch (error) {
  console.error(error);
}
```

--------------------------------

### Send Base64 Encoded Images with TypeScript Fetch API

Source: https://openrouter.ai/docs/features/multimodal/images.mdx

Illustrates sending a base64 encoded local image using the TypeScript `fetch` API to the OpenRouter API. This example includes a function to encode the image and then makes a POST request to the chat completions endpoint with the image data in the message content. It returns the JSON response.

```typescript
async function encodeImageToBase64(imagePath: string): Promise<string> {
  const imageBuffer = await fs.promises.readFile(imagePath);
  const base64Image = imageBuffer.toString('base64');
  return `data:image/jpeg;base64,${base64Image}`;
}

// Read and encode the image
const imagePath = 'path/to/your/image.jpg';
const base64Image = await encodeImageToBase64(imagePath);

const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    Authorization: `Bearer ${API_KEY_REF}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: '{{MODEL}}',
    messages: [
      {
        role: 'user',
        content: [
          {
            type: 'text',
            text: "What's in this image?",
          },
          {
            type: 'image_url',
            image_url: {
              url: base64Image,
            },
          },
        ],
      },
    ],
  }),
});

const data = await response.json();
console.log(data);
```

--------------------------------

### POST /api/v1/keys

Source: https://openrouter.ai/docs/api-reference/api-keys/create-keys.mdx

Creates a new API key. This endpoint allows users to generate API keys for accessing OpenRouter services, with customizable options for usage limits and naming.

```APIDOC
## POST /api/v1/keys

### Description
Creates a new API key with optional usage limits.

### Method
POST

### Endpoint
https://openrouter.ai/api/v1/keys

### Parameters
#### Header Parameters
- **Authorization** (string) - Required - API key as bearer token in Authorization header

#### Request Body
- **name** (string) - Required - The name for the API key.
- **limit** (number | null) - Optional - The usage limit for the API key. Format: double.
- **limit_reset** (string | null) - Optional - The reset period for the usage limit. Enum: daily, weekly, monthly.
- **include_byok_in_limit** (boolean) - Optional - Whether to include BYOK (Bring Your Own Key) usage in the limit.

### Request Example
```json
{
  "name": "My API Key",
  "limit": 1000,
  "limit_reset": "daily",
  "include_byok_in_limit": false
}
```

### Response
#### Success Response (201)
- **data** (object) - Information about the created API key.
  - **hash** (string) - The unique hash of the API key.
  - **name** (string) - The name of the API key.
  - **label** (string) - A label for the API key.
  - **disabled** (boolean) - Whether the API key is disabled.
  - **limit** (number | null) - The usage limit.
  - **limit_remaining** (number | null) - The remaining usage limit.
  - **limit_reset** (string | null) - The reset period for the limit.
  - **include_byok_in_limit** (boolean) - Whether BYOK usage is included in the limit.
  - **usage** (number) - Total usage.
  - **usage_daily** (number) - Daily usage.
  - **usage_weekly** (number) - Weekly usage.
  - **usage_monthly** (number) - Monthly usage.
  - **byok_usage** (number) - BYOK usage.
  - **byok_usage_daily** (number) - Daily BYOK usage.
  - **byok_usage_weekly** (number) - Weekly BYOK usage.
  - **byok_usage_monthly** (number) - Monthly BYOK usage.
  - **created_at** (string) - The creation timestamp.
  - **updated_at** (string | null) - The last update timestamp.
- **key** (string) - The newly generated API key.

#### Response Example
```json
{
  "data": {
    "hash": "key_hash_12345",
    "name": "My API Key",
    "label": "Default Label",
    "disabled": false,
    "limit": 1000,
    "limit_remaining": 1000,
    "limit_reset": "daily",
    "include_byok_in_limit": false,
    "usage": 0,
    "usage_daily": 0,
    "usage_weekly": 0,
    "usage_monthly": 0,
    "byok_usage": 0,
    "byok_usage_daily": 0,
    "byok_usage_weekly": 0,
    "byok_usage_monthly": 0,
    "created_at": "2023-10-27T10:00:00Z",
    "updated_at": null
  },
  "key": "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
```

#### Error Responses
- **400** Bad Request - Invalid request parameters.
- **401** Unauthorized - Missing or invalid authentication.
- **429** Too Many Requests - Rate limit exceeded.
- **500** Internal Server Error
```

--------------------------------

### Authenticate and Request Code (Python)

Source: https://openrouter.ai/docs/api-reference/o-auth/create-auth-keys-code.mdx

This code snippet demonstrates how to authenticate and request a code challenge from the OpenRouter.ai API using Python and the 'requests' library. It sends a POST request with necessary parameters and prints the response.

```Python
import requests

url = "https://openrouter.ai/api/v1/auth/keys/code"

payload = {
    "callback_url": "https://myapp.com/auth/callback",
    "code_challenge": "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM",
    "code_challenge_method": "S256",
    "limit": 100
}
headers = {
    "Authorization": "Bearer <token>",
    "Content-Type": "application/json"
}

response = requests.post(url, json=payload, headers=headers)

print(response.json())
```

--------------------------------

### Create OpenRouter LLM Session

Source: https://openrouter.ai/docs/community/live-kit.mdx

Demonstrates the basic usage of creating an `AgentSession` with an OpenRouter Large Language Model (LLM). It specifies the model to be used, such as 'anthropic/claude-sonnet-4.5', and includes placeholders for other necessary session configurations like text-to-speech, speech-to-text, and voice activity detection.

```python
from livekit.plugins import openai

session = AgentSession(
    llm=openai.LLM.with_openrouter(model="anthropic/claude-sonnet-4.5"),
    # ... tts, stt, vad, turn_detection, etc.
)
```

--------------------------------

### Web Search Integration in OpenRouter API Conversations

Source: https://openrouter.ai/docs/api-reference/responses-api/web-search.mdx

Demonstrates how to integrate web search plugins in multi-turn conversations using the OpenRouter API. This implementation requires an OpenRouter API key and handles complex conversation structures with user and assistant messages. The code shows how to configure web search parameters, manage conversation state, and process responses. Note that API rate limits and token usage constraints apply when using web search plugins.

```TypeScript
const response = await fetch('https://openrouter.ai/api/v1/responses', {
    method: 'POST',
    headers: {
      'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'openai/o4-mini',
      input: [
        {
          type: 'message',
          role: 'user',
          content: [
            {
              type: 'input_text',
              text: 'What is the latest version of React?',
            },
          ],
        },
        {
          type: 'message',
          id: 'msg_1',
          status: 'in_progress',
          role: 'assistant',
          content: [
            {
              type: 'output_text',
              text: 'Let me search for the latest React version.',
              annotations: [],
            },
          ],
        },
        {
          type: 'message',
          role: 'user',
          content: [
            {
              type: 'input_text',
              text: 'Yes, please find the most recent information',
            },
          ],
        },
      ],
      plugins: [{ id: 'web', max_results: 2 }],
      max_output_tokens: 9000,
    }),
  });

  const result = await response.json();
  console.log(result);
```

```Python
import requests

  response = requests.post(
      'https://openrouter.ai/api/v1/responses',
      headers={
          'Authorization': 'Bearer YOUR_OPENROUTER_API_KEY',
          'Content-Type': 'application/json',
      },
      json={
          'model': 'openai/o4-mini',
          'input': [
              {
                  'type': 'message',
                  'role': 'user',
                  'content': [
                      {
                          'type': 'input_text',
                          'text': 'What is the latest version of React?',
                      },
                  ],
              },
              {
                  'type': 'message',
                  'id': 'msg_1',
                  'status': 'in_progress',
                  'role': 'assistant',
                  'content': [
                      {
                          'type': 'output_text',
                          'text': 'Let me search for the latest React version.',
                          'annotations': [],
                      },
                  ],
              },
              {
                  'type': 'message',
                  'role': 'user',
                  'content': [
                      {
                          'type': 'input_text',
                          'text': 'Yes, please find the most recent information',
                      },
                  ],
              },
          ],
          'plugins': [{'id': 'web', 'max_results': 2}],
          'max_output_tokens': 9000,
      }
  )

  result = response.json()
  print(result)
```

--------------------------------

### OpenAPI Specification for Model Count Endpoint

Source: https://openrouter.ai/docs/api-reference/models/list-models-count.mdx

This YAML defines the OpenAPI 3.1.1 specification for the endpoint that returns the total count of available models. It requires an Authorization header with a bearer token. The response is a JSON object with the count under the 'data' property; supports HTTP 200 for success and 500 for errors. No additional dependencies beyond standard OpenAPI tools.

```yaml
openapi: 3.1.1
info:
  title: Get total count of available models
  version: endpoint_models.listModelsCount
paths:
  /models/count:
    get:
      operationId: list-models-count
      summary: Get total count of available models
      tags:
        - - subpackage_models
      parameters:
        - name: Authorization
          in: header
          description: API key as bearer token in Authorization header
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Returns the total count of available models
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ModelsCountResponse'
        '500':
          description: Internal Server Error
          content: {}
components:
  schemas:
    ModelsCountResponseData:
      type: object
      properties:
        count:
          type: number
          format: double
      required:
        - count
    ModelsCountResponse:
      type: object
      properties:
        data:
          $ref: '#/components/schemas/ModelsCountResponseData'
      required:
        - data

```

--------------------------------

### POST /api/v1/responses

Source: https://openrouter.ai/docs/api-reference/responses-api/overview.mdx

This endpoint allows you to interact with AI models through OpenRouter's Responses API Beta. It supports sending text input and receiving AI-generated responses, with capabilities for reasoning, tool calling, and web search.

```APIDOC
## POST /api/v1/responses

### Description
This endpoint serves as the primary interface for the OpenRouter Responses API Beta. It is designed to be an OpenAI-compatible, stateless service enabling advanced AI interactions including reasoning, tool calling, and web search.

### Method
POST

### Endpoint
https://openrouter.ai/api/v1/responses

### Parameters
#### Headers
- **Authorization** (string) - Required - Your OpenRouter API key in the format 'Bearer YOUR_OPENROUTER_API_KEY'.
- **Content-Type** (string) - Required - Must be 'application/json'.

#### Request Body
- **model** (string) - Required - The AI model to use (e.g., 'openai/o4-mini').
- **input** (string) - Required - The text prompt or input for the AI model.
- **reasoning** (object) - Optional - Configuration for reasoning capabilities.
- **tools** (array) - Optional - Definitions of tools the model can call.
- **web_search** (object) - Optional - Configuration for web search capabilities.

### Request Example
```json
{
  "model": "openai/o4-mini",
  "input": "Hello, world!"
}
```

### Response
#### Success Response (200)
- **output** (string) - The AI-generated response.
- **usage** (object) - Information about token usage.
- **tool_calls** (array) - If tool calling was invoked, this contains the tool call details.
- **citations** (array) - If web search was used, this contains citation information.

#### Response Example
```json
{
  "output": "Hello! How can I help you today?",
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 15,
    "total_tokens": 25
  },
  "tool_calls": [],
  "citations": []
}
```

## Error Handling

### Error Response Example
```json
{
  "error": {
    "code": "invalid_prompt",
    "message": "Missing required parameter: 'model'."
  },
  "metadata": null
}
```
```