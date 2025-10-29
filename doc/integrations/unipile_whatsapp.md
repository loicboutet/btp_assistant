### Request WhatsApp QR Code using cURL

Source: https://developer.unipile.com/docs/whatsapp

Makes a POST request to the Unipile API to obtain a QR code for WhatsApp authentication. This requires setting the 'provider' to 'WHATSAPP' in the request body and including necessary authentication headers like 'X-API-KEY'. Replace placeholders with your actual DSN and access token.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/accounts \
     --header 'X-API-KEY: {YOUR_ACCESS_TOKEN}' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data \
'{
  "provider": "WHATSAPP"
}'
```

--------------------------------

### Request WhatsApp QR Code using JavaScript SDK

Source: https://developer.unipile.com/docs/whatsapp

Initiates the process of connecting a WhatsApp account by requesting a QR code. This function relies on the Unipile client SDK and returns both the QR code string and an internal code for further processing. Ensure the Unipile client is properly initialized before use.

```javascript
const { qrCodeString, code } = await client.account.connectWhatsapp();
```

--------------------------------

### Reply to WhatsApp Messages with AI using n8n

Source: https://developer.unipile.com/docs/example-workflow-n8n

This workflow outlines how to receive a WhatsApp message via webhook, generate an AI-powered answer, and send a reply using n8n. It requires setting up a webhook, an LLM node for AI generation, and an HTTP Request node to send the reply. Ensure correct chat_id, account_id, and text parameters are configured.

```JSON
{
  "name": "WhatsApp AI Reply Workflow",
  "nodes": [
    {
      "parameters": {},
      "type": "n8n-nodes-base.webhook",
      "id": "webhookNode"
    },
    {
      "parameters": {
        "model": "your-llm-model",
        "prompt": "={{ $json.getNodeData('webhookNode').message }}" 
      },
      "type": "n8n-nodes-base.llmNode",
      "id": "llmNode",
      "executeOutFilters": [],
      "inputIndexes": [
        0
      ]
    },
    {
      "parameters": {
        "url": "={{ 'https://YOUR_DSN/api/v1/whatsapp/messages/' + $json.getNodeData('webhookNode').chat_id }}",
        "method": "POST",
        "body": {
          "account_id": "YOUR_ACCOUNT_ID",
          "text": "={{ $json.getNodeData('llmNode').generated_text }}"
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "id": "httpRequestNode",
      "executeOutFilters": [],
      "inputIndexes": [
        1
      ]
    }
  ],
  "connections": {
    "webhookNode": [
      {
        "node": "llmNode",
        "type": "main",
        "index": 0
      }
    ],
    "llmNode": [
      {
        "node": "httpRequestNode",
        "type": "main",
        "index": 0
      }
    ]
  }
}
```

--------------------------------

### Connect Accounts and Fetch Data with Unipile Node.js SDK

Source: https://developer.unipile.com/docs/nodejs-sdk

Example demonstrating how to initialize the UnipileClient and connect various social media and messaging accounts (LinkedIn, Instagram, WhatsApp, Telegram, Messenger). It also shows how to fetch all chats, messages, and attendees. Requires valid DSN and access token.

```javascript
import { UnipileClient } from 'unipile-node-sdk';

const client = new UnipileClient('https://{YOUR_DSN}', '{YOUR_ACCESS_TOKEN}');

//LINKEDIN
await client.account.connectLinkedin({
  username: 'your LinkedIn username',
  password: 'your LinkedIn password',
});

//INSTAGRAM
await client.account.connectInstagram({
  username: 'your Instagram username',
  password: 'your Instagram password',
});

//WHATSAPP
const { qrCodeString: whatsappQrCode } = await client.account.connectWhatsapp();
console.log(whatsappQrCode); // scan the QR code to finish the connection

//TELEGRAM
const { qrCodeString: telegramQrCode } = await client.account.connectTelegram();
console.log(telegramQrCode); // scan the QR code to finish the connection

//MESSENGER
await client.account.connectMessenger({
  username: 'your Messenger username',
  password: 'your Messenger password',
});

const chats = await client.messaging.getAllChats();
const messages = await client.messaging.getAllMessages();
const attendees = await client.messaging.getAllAttendees();
```

--------------------------------

### Get Chat Message History (JavaScript SDK)

Source: https://developer.unipile.com/docs/get-messages

Retrieves all messages from a specific chat using the Unipile JavaScript SDK. This function takes a chat ID as an argument and returns a promise that resolves with the message data. It abstracts the underlying API call and handles response parsing.

```javascript
const response = await client.messaging.getAllMessagesFromChat({
  chat_id: "e9d087d67",
});
```

--------------------------------

### Start New Chat with User via Unipile SDK

Source: https://developer.unipile.com/docs/send-messages

Use the Unipile SDK to start a new chat with a user. This method handles the creation of a new chat if it doesn't exist. It takes the account_id, message text, and attendee IDs as parameters.

```javascript
const response = await client.messaging.startNewChat({
  account_id: 'Yk08cDzzdsqs9_8ds',
  text: 'Hello world !',
  attendees_ids: ["ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E"],
})
```

--------------------------------

### Send Message to Existing Chat via Unipile SDK

Source: https://developer.unipile.com/docs/send-messages

Send a message to an existing chat using the Unipile SDK. This function requires the chat_id and the text content of the message. It simplifies the process of interacting with the Unipile API for messaging.

```javascript
const response = await client.messaging.sendMessage({
  chat_id: "9f9uio56sopa456s",
  text: "Hello world !"
})
```

--------------------------------

### Send Message

Source: https://developer.unipile.com/docs/index

Send a message to a specific chat.

```APIDOC
## POST /api/v1/chats/:chatId/messages

### Description
Sends a message to a specified chat.

### Method
POST

### Endpoint
/api/v1/chats/:chatId/messages

### Parameters
#### Path Parameters
- **chatId** (string) - Required - The unique identifier of the chat to send the message to.

#### Request Body
- **text** (string) - Required - The content of the message to send.

### Request Example
```json
{
  "example": {
    "text": "This is a test message."
  }
}
```

### Response
#### Success Response (200)
- **messageId** (string) - The unique identifier of the sent message.
- **timestamp** (string) - The timestamp when the message was sent.

#### Response Example
```json
{
  "example": {
    "messageId": "msg_456",
    "timestamp": "2023-10-27T10:05:00Z"
  }
}
```
```

--------------------------------

### Send a message to a User (Start New Chat)

Source: https://developer.unipile.com/docs/send-messages

Initiate a new conversation with a user when you don't have an existing chat ID or when the connected account has no prior conversation history with the user. This method will create a new chat if one doesn't exist.

```APIDOC
## POST /chats

### Description
Starts a new chat with one or more users. If a chat does not exist, it will be created.

### Method
POST

### Endpoint
`/api/v1/chats`

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
- **account_id** (string) - Required - The ID of the connected account from which to send the message.
- **text** (string) - Required - The content of the message to send.
- **attendees_ids** (array of strings) - Required - A list of user Provider internal IDs to include in the chat.
- **linkedin** (object) - Optional - Specific options for LinkedIn messages.
  - **api** (string) - Optional - Specifies the LinkedIn API to use (e.g., 'classic', 'recruiter', 'sales_navigator').
  - **inmail** (boolean) - Optional - Set to true to send an InMail message (requires a Premium LinkedIn account).

### Request Example
```json
{
  "account_id": "Yk08cDzzdsqs9_8ds",
  "text": "Hello world !",
  "attendees_ids": ["ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E"],
  "options": {
    "linkedin": {
      "api": "classic",
      "inmail": true
    }
  }
}
```

### Response
#### Success Response (200)
- **chat_id** (string) - The unique identifier of the newly created or existing chat.
- **message_id** (string) - The unique identifier of the sent message.
- **sent_at** (string) - The timestamp when the message was sent.

#### Response Example
```json
{
  "chat_id": "cht_xyz789",
  "message_id": "msg_def456",
  "sent_at": "2023-10-27T10:05:00Z"
}
```
```

--------------------------------

### Receive Messages API

Source: https://developer.unipile.com/docs/list-provider-features

Receive messages in real-time from various platforms. This endpoint facilitates real-time communication monitoring.

```APIDOC
## GET /docs/get-messages

### Description
Receives messages in real-time.

### Method
GET

### Endpoint
/docs/get-messages

### Parameters
#### Path Parameters
None

#### Query Parameters
- **platform** (string) - Optional - Filter messages by platform (e.g., 'linkedin').

#### Request Body
None

### Request Example
None

### Response
#### Success Response (200)
- **messages** (array) - A list of received message objects.

#### Response Example
```json
{
  "messages": [
    {
      "message_id": "msg001",
      "sender": "external_user",
      "content": "Hi there!",
      "received_at": "2023-10-27T11:00:00Z"
    }
  ]
}
```
```

--------------------------------

### List Chats

Source: https://developer.unipile.com/docs/index

Retrieve a list of all chats available through the Unipile API.

```APIDOC
## GET /api/v1/chats

### Description
Retrieves a list of all chats associated with the Unipile account.

### Method
GET

### Endpoint
/api/v1/chats

### Parameters
#### Query Parameters
- **limit** (integer) - Optional - The maximum number of chats to return.
- **offset** (integer) - Optional - The number of chats to skip before starting to collect the result set.

### Request Example
```json
{
  "example": "GET /api/v1/chats?limit=10&offset=0"
}
```

### Response
#### Success Response (200)
- **chats** (array) - A list of chat objects.
  - **chatId** (string) - The unique identifier for the chat.
  - **provider** (string) - The messaging provider (e.g., 'whatsapp', 'linkedin').
  - **contactName** (string) - The name of the contact associated with the chat.
  - **lastMessage** (object) - Details of the last message in the chat.
    - **text** (string) - The content of the last message.
    - **timestamp** (string) - The timestamp of the last message.

#### Response Example
```json
{
  "example": {
    "chats": [
      {
        "chatId": "chat_123",
        "provider": "whatsapp",
        "contactName": "John Doe",
        "lastMessage": {
          "text": "Hello!",
          "timestamp": "2023-10-27T10:00:00Z"
        }
      }
    ]
  }
}
```
```

--------------------------------

### Send Message to Existing Chat via curl

Source: https://developer.unipile.com/docs/send-messages

Send a message to an existing chat or group by providing the chat_id. This method is preferred when the chat_id is known, such as from a webhook trigger or chat list retrieval. Requires an API key and DSN.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/chats/9f9uio56sopa456s/messages \
     --header 'X-API-KEY: {YOUR_ACCESS_TOKEN}' \
     --header 'accept: application/json' \
     --header 'content-type: multipart/form-data' \
     --form 'text=Hello world !'
```

--------------------------------

### Get Chat Message History (cURL)

Source: https://developer.unipile.com/docs/get-messages

Retrieves the most recent messages from a specific chat using the Unipile API. It requires a chat ID and an API key for authentication. By default, it returns up to 100 messages, ordered by date. This method supports pagination for fetching older messages.

```curl
curl --request GET \
     --url https://{YOUR_DSN}/api/v1/chats/{CHAT_ID}/messages \
     --header 'X-API-KEY: {YOUR_ACCESS_TOKEN}' \
     --header 'accept: application/json'
```

--------------------------------

### Get Message History of a Chat

Source: https://developer.unipile.com/docs/get-messages

Retrieve existing messages within a specific chat. Messages are returned in reverse chronological order, with a default limit of 100 messages.

```APIDOC
## GET /api/v1/chats/{CHAT_ID}/messages

### Description
Retrieves the message history for a given chat.

### Method
GET

### Endpoint
`/api/v1/chats/{CHAT_ID}/messages`

### Parameters
#### Path Parameters
- **CHAT_ID** (string) - Required - The unique identifier for the chat.

#### Query Parameters
- **limit** (integer) - Optional - The maximum number of messages to return. Defaults to 100.

### Request Example
```json
{
  "chat_id": "e9d087d67"
}
```

### Response
#### Success Response (200)
- **messages** (array) - An array of message objects, ordered from most recent to oldest.
  - **id** (string) - The unique identifier for the message.
  - **sender** (object) - Information about the message sender.
  - **content** (string) - The content of the message.
  - **timestamp** (string) - The timestamp when the message was sent.

#### Response Example
```json
{
  "messages": [
    {
      "id": "msg_123",
      "sender": {
        "id": "user_abc",
        "name": "John Doe"
      },
      "content": "Hello there!",
      "timestamp": "2023-10-27T10:00:00Z"
    }
  ]
}
```
```

--------------------------------

### Solve 2FA Checkpoint

Source: https://developer.unipile.com/docs/instagram

Submit the 2FA code to solve an active checkpoint and complete the Instagram account connection.

```APIDOC
## POST /api/v1/accounts/checkpoint

### Description
Solves an active 2FA checkpoint for an Instagram account connection by providing the account ID and the verification code.

### Method
POST

### Endpoint
https://{YOUR_DSN}/api/v1/accounts/checkpoint

### Parameters
#### Query Parameters
None

#### Request Body
- **provider** (string) - Required - The service provider, must be 'INSTAGRAM'.
- **account_id** (string) - Required - The ID of the account that requires checkpoint solving.
- **code** (string) - Required - The 2FA code received.

### Request Example
```json
{
  "provider": "INSTAGRAM",
  "account_id": "098dez89d",
  "code": "******"
}
```

### Response
#### Success Response (200)
Indicates the 2FA checkpoint was successfully solved and the account is connected.

#### Response Example
(Details of successful connection response, specific example not provided in source text)

#### Error Response (408/400)
- **408 Request Timeout**: If the request is made after the 5-minute intent window.
- **400 Bad Request**: If the intent has expired and self-destructed.
```

--------------------------------

### Start New Chat with User via curl

Source: https://developer.unipile.com/docs/send-messages

Initiate a new chat with a user when an existing chat_id is not available. This method creates a new chat if one doesn't exist between the sender and receiver. It requires the account_id, text, and a list of attendee IDs.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/chats \
     --header 'X-API-KEY: {YOUR_ACCESS_TOKEN}' \
     --header 'accept: application/json' \
     --header 'content-type: multipart/form-data' \
     --form account_id=Yk08cDzzdsqs9_8ds \
     --form 'text=Hello world !' \
     --form attendees_ids=ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E \

```

--------------------------------

### POST /chats - Create a group chat

Source: https://developer.unipile.com/docs/send-messages

Initiates a new group chat by providing a list of attendee IDs and an optional group title.

```APIDOC
## POST /chats

### Description
Starts a new group chat by providing a list of user's Provider internal ID in `attendees_ids` along an optional `title` for the group name. The chat and its group participants will be synced.

### Method
POST

### Endpoint
/api/v1/chats

### Parameters
#### Query Parameters
- **account_id** (string) - Required - The account ID for the chat.
- **text** (string) - Required - The initial message for the chat.
- **attendees_ids** (array of strings) - Required - A list of user Provider internal IDs.
- **title** (string) - Optional - The title for the group chat.

### Request Example
```json
{
  "account_id": "k0_s8cdss9Dz8ds",
  "text": "Hello world !",
  "attendees_ids": [
    "33600000000@s.whatsapp.net",
    "33600000001@s.whatsapp.net"
  ],
  "title": "Vacation"
}
```

### Response
#### Success Response (200)
- **chat_id** (string) - The ID of the created chat.
- **title** (string) - The title of the chat.
- **created_at** (string) - The timestamp when the chat was created.

#### Response Example
```json
{
  "chat_id": "chat_12345",
  "title": "Vacation",
  "created_at": "2023-10-27T10:00:00Z"
}
```
```

--------------------------------

### Send a message in an existing Chat / Group

Source: https://developer.unipile.com/docs/send-messages

Use this endpoint to send a message to a specific chat or group by providing its unique `chat_id`. This is useful for automating replies or continuing existing conversations.

```APIDOC
## POST /chats/{chat_id}/messages

### Description
Sends a message into an existing chat or group.

### Method
POST

### Endpoint
`/api/v1/chats/{chat_id}/messages`

### Parameters
#### Path Parameters
- **chat_id** (string) - Required - The unique identifier of the chat or group.

#### Query Parameters
None

#### Request Body
- **text** (string) - Required - The content of the message to send.

### Request Example
```json
{
  "text": "Hello world !"
}
```

### Response
#### Success Response (200)
- **message_id** (string) - The unique identifier of the sent message.
- **chat_id** (string) - The identifier of the chat where the message was sent.
- **sent_at** (string) - The timestamp when the message was sent.

#### Response Example
```json
{
  "message_id": "msg_abc123",
  "chat_id": "9f9uio56sopa456s",
  "sent_at": "2023-10-27T10:00:00Z"
}
```
```

--------------------------------

### Solve Instagram 2FA Checkpoint (JavaScript)

Source: https://developer.unipile.com/docs/instagram

Solve a two-factor authentication (2FA) checkpoint for an Instagram account using the Unipile SDK. Requires the account ID and the 2FA code. This must be done within 5 minutes of receiving the checkpoint.

```javascript
const response = await client.account.solveCodeCheckpoint({
  provider: "INSTAGRAM",
  account_id: "098dez89d",
  code: "******",
});
```

--------------------------------

### Send Messages API

Source: https://developer.unipile.com/docs/list-provider-features

Send messages through various Unipile integrations. This endpoint allows for programmatic communication.

```APIDOC
## POST /docs/send-messages

### Description
Sends messages through various Unipile integrations.

### Method
POST

### Endpoint
/docs/send-messages

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
- **message_details** (object) - Required - Details of the message to send.
  - **recipient** (string) - Required - The recipient's identifier.
  - **content** (string) - Required - The message content.
  - **platform** (string) - Optional - The platform to send the message on (e.g., 'linkedin').

### Request Example
```json
{
  "message_details": {
    "recipient": "user123",
    "content": "Hello, checking in.",
    "platform": "linkedin"
  }
}
```

### Response
#### Success Response (200)
- **status** (string) - Indicates the status of the message sending.

#### Response Example
```json
{
  "status": "sent"
}
```
```

--------------------------------

### Create Group Chat via cURL

Source: https://developer.unipile.com/docs/send-messages

This cURL command demonstrates how to start a new group chat using the Unipile API's POST /chats method. It requires your DSN, access token, account ID, and a list of attendee IDs. An optional title can be provided for the group name. The 'text' parameter is for an initial message.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/chats \
     --header 'X-API-KEY: {YOUR_ACCESS_TOKEN}' \
     --header 'accept: application/json' \
     --header 'content-type: multipart/form-data' \
     --form account_id=k0_s8cdss9Dz8ds \
     --form 'text=Hello world !' \
     --form attendees_ids=33600000000@s.whatsapp.net \
     --form attendees_ids=33600000001@s.whatsapp.net \
     --form title=Vacation
```

--------------------------------

### Start New Chat using HTTP Request

Source: https://developer.unipile.com/docs/createpost-request-n8n

This snippet illustrates how to initiate a new chat via the Unipile API using an HTTP POST request. Similar to commenting, it requires the correct HTTP method and headers. The response includes details about the newly created chat, such as its ID and a message ID.

```bash
--header 'X-API-KEY: YOUR_API_KEY' \
--header 'accept: application/json'
```

```json
[
  {
    "object": "ChatStarted",
    "chat_id": "dMW1cjFwXq-dYoAEaMXo2d",
    "message_id": "Gav3xjVKVNe0IRZBEC9mSg"
  }
]
```

--------------------------------

### Solve Instagram 2FA Checkpoint (cURL)

Source: https://developer.unipile.com/docs/instagram

Submit a cURL POST request to solve an Instagram 2FA checkpoint. Requires the provider, account ID, and the verification code in the JSON payload. The request must be made within the 5-minute authentication intent window.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/accounts/checkpoint \
     --header 'X-API-KEY: {YOUR_ACCESS_TOKEN}' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
  "provider": "INSTAGRAM",
  "account_id": "098dez89d",
  "code": "******"
}'
```

--------------------------------

### Recall LinkedIn Message

Source: https://developer.unipile.com/docs/get-raw-data-example

Deletes a sent LinkedIn message. This action is only possible within the first 60 minutes after the message is sent and requires the `account_id` and the `messageUrn`.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/linkedin \
     --header 'X-API-KEY: XXXX' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
  "body": {"messageUrn":"urn:li:msg_message:(urn:li:fsd_profile:ACoAAAXxg9sBsVmolZ8Oq_7jEe92IOOpRSI8dPE,2-MTc1OTQyMTE0ODY2N2I2OTcwMy0xMDAmYmNlNTYzYWYtYzg2Mi00NTM2LWE2NmUtNDc1NDgzMTAxOTk5XzAxMA==)"},
  "account_id": "dfR-rG0tQfGhfeP2l5_Bdw",
  "method": "POST",
  "request_url": "https://www.linkedin.com/voyager/api/voyagerMessagingDashMessengerMessages?action=recall",
  "encoding": false
}'
```

--------------------------------

### Delete message

Source: https://developer.unipile.com/docs/get-raw-data-example

This endpoint allows you to recall (delete) a sent LinkedIn message. This is only possible within the first 60 minutes after the message is sent. You need to provide the `account_id`, the `request_url` for the messaging API with the 'recall' action, and the `body` containing the `messageUrn`.

```APIDOC
## Delete message

### Description
This endpoint allows you to recall (delete) a sent LinkedIn message. This is only possible within the first 60 minutes after the message is sent. You need to provide the `account_id`, the `request_url` for the messaging API with the 'recall' action, and the `body` containing the `messageUrn`.

### Method
POST

### Endpoint
https://{YOUR_DSN}/api/v1/linkedin

### Parameters
#### Request Body
- **body** (object) - Required - Contains the message URN to recall.
  - **messageUrn** (string) - Required - The URN of the message to recall.
- **account_id** (string) - Required - The account ID for the LinkedIn profile.
- **method** (string) - Required - The HTTP method to use, typically 'POST'.
- **request_url** (string) - Required - The URL for the LinkedIn messaging API with the 'recall' action.
- **encoding** (boolean) - Optional - Set to false if not encoding.

### Request Example
```json
{
  "body": {
    "messageUrn": "urn:li:msg_message:(urn:li:fsd_profile:ACoAAAXxg9sBsVmolZ8Oq_7jEe92IOOpRSI8dPE,2-MTc1OTQyMTE0ODY2N2I2OTcwMy0xMDAmYmNlNTYzYWYtYzg2Mi00NTM2LWE2NmUtNDc1NDgzMTAxOTk5XzAxMA==)"
  },
  "account_id": "dfR-rG0tQfGhfeP2l5_Bdw",
  "method": "POST",
  "request_url": "https://www.linkedin.com/voyager/api/voyagerMessagingDashMessengerMessages?action=recall",
  "encoding": false
}
```
```

--------------------------------

### Connect Instagram Account

Source: https://developer.unipile.com/docs/instagram

Initiate the Instagram account connection by sending user credentials to the Unipile API.

```APIDOC
## POST /api/v1/accounts

### Description
Initiates the connection process for an Instagram account by providing the user's username and password.

### Method
POST

### Endpoint
https://{YOUR_DSN}/api/v1/accounts

### Parameters
#### Query Parameters
None

#### Request Body
- **provider** (string) - Required - The service provider, must be 'INSTAGRAM'.
- **username** (string) - Required - The Instagram username.
- **password** (string) - Required - The Instagram password.

### Request Example
```json
{
  "provider": "INSTAGRAM",
  "username": "unipile",
  "password": "********"
}
```

### Response
#### Success Response (200)
Indicates the account connection was successfully initiated. May return a checkpoint if 2FA is enabled.

#### Response Example
```json
{
  "object": "Checkpoint",
  "account_id": "098dez89d",
  "checkpoint": {
    "type": "2FA"
  }
}
```
```

--------------------------------

### Send attachments

Source: https://developer.unipile.com/docs/send-messages

Send attachments along with your text messages. The standard maximum size for attachments is 15MB, and supported formats include PDF, images, and videos. Limitations may vary by provider.

```APIDOC
## POST /chats (with attachments)

### Description
Sends a message with an additional attachment.

### Method
POST

### Endpoint
`/api/v1/chats`

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
- **account_id** (string) - Required - The ID of the connected account.
- **text** (string) - Required - The content of the message.
- **attendees_ids** (array of strings) - Required - User Provider internal IDs.
- **attachments** (file) - Optional - The attachment file to send (e.g., PDF, image, video). Max size typically 15MB.

### Request Example
(Note: `curl` example shows file upload syntax)
```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/chats \
     --header 'X-API-KEY: {YOUR_ACCESS_TOKEN}' \
     --header 'accept: application/json' \
     --header 'content-type: multipart/form-data' \
     --form account_id=sSR22ds5dd_ds \
     --form 'text=Hello world !' \
     --form attendees_ids=ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E \
     --form 'attachments=@C:\Documents\cute_dog.png'
```

### Response
#### Success Response (200)
- **chat_id** (string) - The unique identifier of the chat.
- **message_id** (string) - The unique identifier of the sent message with attachment.
- **sent_at** (string) - The timestamp when the message was sent.

#### Response Example
```json
{
  "chat_id": "cht_xyz789",
  "message_id": "msg_ghi789",
  "sent_at": "2023-10-27T10:10:00Z"
}
```
```

--------------------------------

### POST /api/v1/accounts/checkpoint - Solve 2FA Checkpoint

Source: https://developer.unipile.com/docs/messenger

Solves a two-factor authentication (2FA) checkpoint for a Messenger account. This is used when the initial authentication triggers a 2FA challenge.

```APIDOC
## POST /api/v1/accounts/checkpoint

### Description
Solves a two-factor authentication (2FA) checkpoint for a Messenger account. This endpoint is called when the initial authentication requires a 2FA code.

### Method
POST

### Endpoint
https://{YOUR_DSN}/api/v1/accounts/checkpoint

### Parameters
#### Request Body
- **provider** (string) - Required - Specifies the service provider, should be 'MESSENGER'.
- **account_id** (string) - Required - The account ID obtained from the initial authentication or checkpoint response.
- **code** (string) - Required - The 2FA code or a special value like 'in_app_validation' to solve the checkpoint.

### Request Example
```json
{
  "provider": "MESSENGER",
  "account_id": "098dez89d",
  "code": "******"
}
```

### Request Example (In-App Validation)
```json
{
  "provider": "MESSENGER",
  "account_id": "098dez89d",
  "code": "in_app_validation"
}
```

### Response
#### Success Response (200)
- **object** (string) - Indicates successful connection, e.g., 'Account'.
- **account_id** (string) - The unique identifier for the connected account.

#### Error Response (408 - Request Timeout)
Returned if the checkpoint is not solved within the 5-minute intent window.

#### Error Response (400 - Bad Request)
Returned if the authentication intent has expired and the checkpoint cannot be solved.

### Response Example (Success)
```json
{
  "object": "Account",
  "account_id": "098dez89d"
}
```
```

--------------------------------

### Get New Messages (Cron Job)

Source: https://developer.unipile.com/docs/get-messages

Retrieve new messages periodically using a cron job if real-time webhooks are not feasible. It's recommended to fetch a broader period than the cron interval to avoid message loss.

```APIDOC
## GET /messages

### Description
Retrieves new messages since the last fetch. Recommended for systems that cannot handle webhooks or do not require real-time updates.

### Method
GET

### Endpoint
`/messages`

### Parameters
#### Query Parameters
- **since** (string) - Optional - Timestamp to fetch messages received after this point. Use with caution to avoid missing messages.
- **before** (string) - Optional - Timestamp to fetch messages received before this point.

### Request Example
```json
{
  "since": "2023-10-27T09:00:00Z"
}
```

### Response
#### Success Response (200)
- **messages** (array) - An array of new message objects.
  - **id** (string) - The unique identifier for the message.
  - **chat_id** (string) - The identifier of the chat this message belongs to.
  - **content** (string) - The content of the message.
  - **timestamp** (string) - The timestamp when the message was sent.

#### Response Example
```json
{
  "messages": [
    {
      "id": "msg_456",
      "chat_id": "chat_xyz",
      "content": "Got your message!",
      "timestamp": "2023-10-27T10:30:00Z"
    }
  ]
}
```
```

--------------------------------

### Authenticate Instagram Account (JavaScript)

Source: https://developer.unipile.com/docs/instagram

Connect an Instagram account using the Unipile SDK. Requires the user's Instagram username and password. Does not support Facebook credentials for Instagram authentication.

```javascript
const response = await client.account.connectInstagram({
  username: "unipile",
  password: "********"
})
```

--------------------------------

### Example API Calls for Unipile (Conceptual)

Source: https://developer.unipile.com/docs/index

These conceptual examples demonstrate how to interact with the Unipile API for common tasks such as listing chats and sending messages. They highlight the HTTP methods and endpoints involved, requiring previously obtained DSN and token for authentication.

```http
GET /api/v1/chats
POST /api/v1/chats/:chatId/messages
```

--------------------------------

### Send Message with Attachment via curl

Source: https://developer.unipile.com/docs/send-messages

Send a message along with an attachment using the Unipile API. This is done by including the attachment file in the form data. The standard limit for attachments is 15MB, supporting PDF, image, and video formats.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/chats \
     --header 'X-API-KEY: {YOUR_ACCESS_TOKEN}' \
     --header 'accept: application/json' \
     --header 'content-type: multipart/form-data' \
     --form account_id=sSR22ds5dd_ds \
     --form 'text=Hello world !' \
     --form attendees_ids=ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E \
     --form 'attachments=@C:\\Documents\\cute_dog.png' \

```

--------------------------------

### Solve Messenger 2FA Checkpoint

Source: https://developer.unipile.com/docs/messenger

Solves a two-factor authentication (2FA) checkpoint for a Messenger account. This is used when a 202 status is received, indicating a 2FA challenge. It requires the provider, account ID, and the 2FA code (or 'in_app_validation' for in-app confirmation).

```javascript
const response = await client.account.solveCodeCheckpoint({
  provider: "MESSENGER",
  account_id: "098dez89d",
  code: "******",
});
```

```php
todo
```

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/accounts/checkpoint \
     --header 'X-API-KEY: {YOUR_ACCESS_TOKEN}' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
  "provider": "MESSENGER",
  "account_id": "098dez89d",
  "code": "******"
}'
```

--------------------------------

### Unipile New Messages Webhook Example Payload

Source: https://developer.unipile.com/docs/new-messages-webhook

This JSON payload demonstrates the structure of data received from Unipile's New Messages Webhook. It includes details about the account, event type, chat, message content, sender, attendees, and attachments. It's applicable for various platforms supported by Unipile.

```json
{
  "account_id": "dfXlh46vQYCsMbVarumWlg",
  "account_type": "LINKEDIN", // 'LINKEDIN' | 'INSTAGRAM' | 'WHATSAPP' | 'TELEGRAM'
  "account_info":{
    "type":"LINKEDIN", // 'LINKEDIN' | 'INSTAGRAM'
    "feature":"classic", // 'organization' | 'sales_navigator' | 'recruiter' | 'classic'
    "user_id":"ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E" 
},
  "event":  "message_received", // 'message_reaction' | 'message_read' | 'message_received' | 'message_edited' | 'message_deleted'
  "chat_id": "R8J-xM9WX7eoHLp6gSVtWQ",
  "timestamp": "2023-09-24T13:49:07.965Z",
  "webhook_name": "Webhook demo",
  "message_id": "ykmhfXlRW0W_cqReJYrfBw",
  "message": "Hello World !",
  "sender": {
    "attendee_id": "C8zaRZTlVcmfnke_Vai4Gg",
    "attendee_name": "Kim Unipile",
    "attendee_provider_id": "ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E",
    "attendee_profile_url": "https://www.linkedin.com/in/ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E/",
  }
 "attendees": [
    {
      "attendee_id": "12Siz1Vcmfnke_Vai4Gg",
      "attendee_name": "Bastien Unipile ",
      "attendee_provider_id": "AA1212sqqsMQBODyLwZrRcgYhrkCafURGqva0U4E",
      "attendee_profile_url": "https://www.linkedin.com/in/ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E/"
    }
	],
  "attachments":
    {
      "id": "2-MTY5MzQ3ODM0MTgxOWI4MDA4My0wMDMmNjg2M2E2MTgtNjM2Yi01OWNkLWFjNmQtYjE3Y2NjNTU5ZWZkXzAxMw==",
      "size": {
        "height": "150",
        "width": "150"
        },
      "sticker": "false",
      "unavailable": "false",
      "mimetype": "image/jpeg",
      "type": "img",
      "url": "att://iWfwCtGXSr288YQm5MbWVaeGtYNHQyaEZQcVpPbW5PdGNsQQ=="
    },
  "reaction": "😄", // only for event "message_reaction"
  "reaction_sender": { // only for event "message_reaction"
    "attendee_id": "C8zaRZTlVcmfnke_Vai4Gg",
    "attendee_name": "Kim Unipile",
    "attendee_provider_id": "ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E",
    "attendee_profile_url: "https://www.linkedin.com/in/ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E/",
  }
}
```

--------------------------------

### Create Post

Source: https://developer.unipile.com/docs/posts-and-comments

Creates a new post on a social media platform.

```APIDOC
## POST /api/v1/posts

### Description
Creates a new post on a social media platform. This endpoint allows users to publish content, including text and optional media attachments.

### Method
POST

### Endpoint
`/api/v1/posts`

### Parameters
#### Request Body
- **account_id** (string) - Required - The account ID associated with the request.
- **text** (string) - Required - The content of the post.
- **attachments** (array) - Optional - A list of attachments to include in the post (e.g., images, videos).
  - **url** (string) - Required - The URL of the attachment.
  - **type** (string) - Required - The type of attachment (e.g., "image", "video").

### Request Example
(Specific request example for creating a post is not provided in the input text, but it would typically include the post text and any associated media URLs.)

### Response
#### Success Response (200)
- **post_id** (string) - The unique ID of the newly created post.
- **post_url** (string) - The URL of the newly created post.

#### Response Example
(Example response not provided in the input text.)
```

--------------------------------

### Solve 2FA Checkpoint

Source: https://developer.unipile.com/docs/twitter-x-guide

Provides the necessary code to resolve a two-factor authentication (2FA) challenge for X (Twitter).

```APIDOC
## POST /api/v1/accounts/checkpoint

### Description
Solves a 2FA checkpoint for an X (Twitter) account connection. This endpoint must be called within 5 minutes of receiving the checkpoint.

### Method
POST

### Endpoint
https://{YOUR_DSN}/api/v1/accounts/checkpoint

### Parameters
#### Query Parameters
None

#### Headers
- **X-API-KEY** (string) - Required - Your Unipile access token.
- **accept** (string) - Required - `application/json`
- **content-type** (string) - Required - `application/json`

#### Request Body
- **provider** (string) - Required - `TWITTER`
- **account_id** (string) - Required - The `account_id` received from the initial authentication request.
- **code** (string) - Required - The 2FA code received from X (Twitter).

### Request Example
```json
{
  "provider": "TWITTER",
  "account_id": "098dez89d",
  "code": "******"
}
```

### Response
#### Success Response (200)
Indicates successful account connection.

#### Error Response (408 Request Timeout)
Returned if the checkpoint is not solved within the 5-minute intent window.

#### Error Response (400 Bad Request)
Returned if the authentication intent has expired and the checkpoint cannot be solved.
```

--------------------------------

### Reply to a Comment and Add Mentions using cURL

Source: https://developer.unipile.com/docs/posts-and-comments

This example shows how to reply to an existing comment and include mentions in the reply. It requires the 'social_id' of the post, the 'comment_id' of the comment being replied to, the text of the reply, and details of the mentioned user. The request is made using cURL with appropriate headers and a JSON payload.

```shell
curl --request POST \
  --url https://apiX.unipile.com:XXXX/api/v1/posts/urn:li:activity:7332661864792854528/comments \
  --header 'Content-Type: application/json' \
  --header 'X-API-KEY: XXXX' \
  --data '{ 
"account_id": "7ioiu6zHRO67yQBazvXDuQ", 
"text": "Hi {{0}}, thanks", 
"comment_id": "7335000001439513601", 
"mentions": [ 
{ 
"name": "John Doe", 
"profile_id": "ACoAASss4UBzQV9fDt_ziQ45zzpCVnAhxbW" 
} 
] 
}'
```

--------------------------------

### Retrieve posts from Feed

Source: https://developer.unipile.com/docs/get-raw-data-example

This endpoint retrieves posts from the LinkedIn feed. Pagination can be managed by using the `paginationToken` from the response to perform subsequent requests.

```APIDOC
## Retrieve posts from Feed

### Description
This endpoint retrieves posts from the LinkedIn feed. Pagination can be managed by using the `paginationToken` from the response to perform subsequent requests.

### Method
POST

### Endpoint
https://{YOUR_DSN}/api/v1/linkedin

### Parameters
#### Request Body
- **account_id** (string) - Required - The account ID for the LinkedIn profile.
- **method** (string) - Required - The HTTP method to use for the request, typically 'GET'.
- **request_url** (string) - Required - The URL for the LinkedIn GraphQL API endpoint.

### Request Example
```json
{
  "account_id": "91gPYl0eS0q-VE9HA-VLYA",
  "method": "GET",
  "request_url": "https://www.linkedin.com/voyager/api/graphql?queryId=voyagerFeedDashMainFeed.7a50ef8ba5a7865c23ad5df46f735709"
}
```

### Response
#### Success Response (200)
- **data** (object) - Contains the feed data and metadata, including `paginationToken` for pagination.

#### Response Example
```json
{
  "data": {
    "data": {
      "feedDashMainFeedByMainFeed": {
        "metadata": {
          "paginationToken": "99714011-1754950579467-a40e9db9d667b7ce2ba183fc50169e1b"
        },
        "elements": [
          {
            "urn": "urn:li:fsd_post:(urn:li:fsd_profile:ACoAAAXxg9sBsVmolZ8Oq_7jEe92IOOpRSI8dPE,2-comments-2792285975,ugcPost)",
            "author": {
              "name": "Jane Doe"
            },
            "content": {
              "text": "Check out this new article!"
            }
          }
        ]
      }
    }
  }
}
```

## Retrieve paginated posts from Feed

### Description
This endpoint retrieves paginated posts from the LinkedIn feed using a `paginationToken` obtained from a previous request.

### Method
POST

### Endpoint
https://{YOUR_DSN}/api/v1/linkedin

### Parameters
#### Request Body
- **account_id** (string) - Required - The account ID for the LinkedIn profile.
- **method** (string) - Required - The HTTP method to use for the request, typically 'GET'.
- **request_url** (string) - Required - The URL for the LinkedIn GraphQL API endpoint, including pagination parameters.

### Request Example
```json
{
  "account_id": "91gPYl0eS0q-VE9HA-VLYA",
  "method": "GET",
  "request_url": "https://www.linkedin.com/voyager/api/graphql?variables=(start:20,count:10,paginationToken:99714011-1754950579467-a40e9db9d667b7ce2ba183fc50169e1b,sortOrder:MEMBER_SETTING)&queryId=voyagerFeedDashMainFeed.7a50ef8ba5a7865c23ad5df46f735709"
}
```
```

--------------------------------

### Invite People to Follow Company Page

Source: https://developer.unipile.com/docs/get-raw-data-example

Invites multiple LinkedIn users to follow a specified company page. This API call requires the `account_id`, the `organizationUrn` of the company, and the `inviteeMember` URNs for each user.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/linkedin \
     --header 'X-API-KEY: XXXX' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
"account_id": "91gPYl0eSeY4IClOgJ5FA",
"request_url": "https://www.linkedin.com/voyager/api/voyagerRelationshipsDashInvitations",
"method": "POST",
"body": {"elements":[{"inviteeMember":"urn:li:fsd_profile:ACoAAAAA4McB8YEREZF3LfNq00l1IgqTzd8crg","genericInvitationType":"ORGANIZATION"},{"inviteeMember":"urn:li:fsd_profile:ACoAAAAA3W4B6ERE8pWg_l5gb6bCaBEa_SEGvGc","genericInvitationType":"ORGANIZATION"}]},

"query_params": {
"inviter": "(organizationUrn:urn%3Ali%3Afsd_company%3A38114588)"
},
"headers": {
"x-restli-method": "batch_create"
},
"encoding": false
}
'
```

--------------------------------

### Authenticate Instagram Account (cURL)

Source: https://developer.unipile.com/docs/instagram

Perform Instagram authentication via a cURL POST request to the Unipile API. Requires provider, username, and password in the request body. Authentication via Facebook is not supported.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/accounts \
     --header 'X-API-KEY: {YOUR_ACCESS_TOKEN}' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
  "provider": "INSTAGRAM",
  "username": "unipile",
  "password": "********"
}'
```

--------------------------------

### Retrieve LinkedIn Feed Posts

Source: https://developer.unipile.com/docs/get-raw-data-example

Fetches posts from a LinkedIn feed. Subsequent requests for pagination require the `paginationToken` from the previous response, along with `start` and `count` parameters.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/linkedin \
     --header 'X-API-KEY: XXXX' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
"account_id": "91gPYl0eS0q-VE9HA-VLYA",
"method": "GET",
"request_url": "https://www.linkedin.com/voyager/api/graphql?queryId=voyagerFeedDashMainFeed.7a50ef8ba5a7865c23ad5df46f735709"
} 
'
```

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/linkedin \
     --header 'X-API-KEY: XXXX' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
"account_id": "91gPYl0eS0q-VE9HA-VLYA",
"method": "GET",
"request_url": "https://www.linkedin.com/voyager/api/graphql?variables=(start:20,count:10,paginationToken:99714011-1754950579467-a40e9db9d667b7ce2ba183fc50169e1b,sortOrder:MEMBER_SETTING)&queryId=voyagerFeedDashMainFeed.7a50ef8ba5a7865c23ad5df46f735709"
}'
```

--------------------------------

### List of Contacts/Relations API

Source: https://developer.unipile.com/docs/list-provider-features

Retrieve a list of contacts or relations associated with your Unipile account. This endpoint provides access to your network data.

```APIDOC
## GET /reference/userscontroller_getrelations

### Description
Retrieves a list of contacts or relations.

### Method
GET

### Endpoint
/reference/userscontroller_getrelations

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
None

### Request Example
None

### Response
#### Success Response (200)
- **contacts** (array) - A list of contact objects.

#### Response Example
```json
{
  "contacts": [
    {
      "id": "user123",
      "name": "John Doe",
      "email": "john.doe@example.com"
    }
  ]
}
```
```

--------------------------------

### Retrieve Post

Source: https://developer.unipile.com/docs/posts-and-comments

Retrieves details of a specific post using its ID.

```APIDOC
## GET /api/v1/posts/{post_id}/

### Description
Retrieves details of a specific post using its ID. The post ID can be extracted from a post URL.

### Method
GET

### Endpoint
`/api/v1/posts/{post_id}/`

### Parameters
#### Path Parameters
- **post_id** (string) - Required - The unique identifier of the post.

#### Query Parameters
- **account_id** (string) - Required - The account ID associated with the request.

### Request Example
```curl
curl --request GET \
  --url 'https://apiX.unipile.com:XXXX/api/v1/posts/7332661864792854528/?account_id=7ioiu6zHRO67yQBazvXDuQ' \
  --header 'X-API-KEY: XXXX'
```

### Response
#### Success Response (200)
- **object** (string) - The type of object returned (e.g., "Post").
- **provider** (string) - The social media provider (e.g., "LINKEDIN").
- **social_id** (string) - The unique social ID of the post (e.g., "urn:li:activity:7332661864792854528").
- **share_url** (string) - The shareable URL of the post.
- **date** (string) - The relative date of the post (e.g., "3d").
- **parsed_datetime** (string) - The ISO 8601 formatted datetime of the post.
- **comment_counter** (integer) - The number of comments on the post.
- **impressions_counter** (integer) - The number of impressions for the post.
- **reaction_counter** (integer) - The number of reactions on the post.
- **repost_counter** (integer) - The number of reposts.
- **permissions** (object) - An object containing user permissions for the post.
  - **can_post_comments** (boolean) - Whether the user can post comments.
  - **can_react** (boolean) - Whether the user can react.
  - **can_share** (boolean) - Whether the user can share.
- **text** (string) - The text content of the post.
- **attachments** (array) - An array of attachments associated with the post.
  - **id** (string) - The attachment ID.
  - **sticker** (boolean) - Whether the attachment is a sticker.
  - **size** (object) - The dimensions of the attachment.
    - **height** (integer) - Height of the attachment.
    - **width** (integer) - Width of the attachment.
  - **unavailable** (boolean) - Whether the attachment is unavailable.
  - **type** (string) - The type of attachment (e.g., "img").
  - **url** (string) - The URL of the attachment.
- **author** (object) - Information about the post's author.
  - **public_identifier** (string) - The public identifier of the author.
  - **id** (any) - The author's internal ID (can be null).
  - **name** (string) - The name of the author.
  - **is_company** (boolean) - Whether the author is a company.
- **is_repost** (boolean) - Whether the post is a repost.
- **id** (string) - The internal ID of the post.

#### Response Example
```json
{
  "object": "Post",
  "provider": "LINKEDIN",
  "social_id": "urn:li:activity:7332661864792854528",
  "share_url": "https://www.linkedin.com/posts/unipile_nocode-automation-solopreneurs-activity-7332661864792854528-hcGT?utm_source=social_share_send&utm_medium=member_desktop_web&rcm=ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E",
  "date": "3d",
  "parsed_datetime": "2025-05-26T19:01:02.468Z",
  "comment_counter": 0,
  "impressions_counter": 0,
  "reaction_counter": 6,
  "repost_counter": 0,
  "permissions": {
    "can_post_comments": true,
    "can_react": true,
    "can_share": true
  },
  "text": "What’s the #1 automation you rely on as a solo founder or no-code builder?\n\nWhether you're managing outreach, lead [...]",
  "attachments": [
    {
      "id": "D4D22AQE5ozOIW8_vfQ",
      "sticker": false,
      "size": { "height": 1002, "width": 800 },
      "unavailable": false,
      "type": "img",
      "url": "https://media.licdn.com/dms/image/v2/D4D22AQE5ozOIW8_vfQ/feedshare-shrink_800/B4DZb9tG7dHEAg-/0/1748013186578?e=1751500800&v=beta&t=4h3iZrbqUdd87EYUeISJ9wcw9fea8pMT9ONNId8hC3o"
    }
  ],
  "author": {
    "public_identifier": "unipile",
    "id": null,
    "name": "Unipile",
    "is_company": true
  },
  "is_repost": false,
  "id": "7332661864792854528"
}
```
```

--------------------------------

### Delete relation

Source: https://developer.unipile.com/docs/get-raw-data-example

This endpoint allows you to remove a connection from your LinkedIn network. You need to provide the `account_id`, the `request_url`, and the `body` containing the `connectionUrn` of the connection to be removed.

```APIDOC
## Delete relation

### Description
This endpoint allows you to remove a connection from your LinkedIn network. You need to provide the `account_id`, the `request_url`, and the `body` containing the `connectionUrn` of the connection to be removed.

### Method
POST

### Endpoint
https://{YOUR_DSN}/api/v1/linkedin

### Parameters
#### Request Body
- **account_id** (string) - Required - The account ID for the LinkedIn profile.
- **method** (string) - Required - The HTTP method to use, typically 'POST'.
- **request_url** (string) - Required - The URL for the LinkedIn relationships API.
- **query_params** (object) - Required - Query parameters for the request.
  - **action** (string) - Required - Set to 'removeFromMyConnections'.
  - **decorationId** (string) - Required - A specific decoration ID for relationship actions.
- **body** (object) - Required - Contains details of the connection to remove.
  - **connectionUrn** (string) - Required - The URN of the connection to remove.

### Request Example
```json
{
  "account_id": "91gPYl0eSeY4IClOgJ5FA",
  "method": "POST",
  "request_url": "https://www.linkedin.com/voyager/api/relationships/dash/memberRelationships",
  "query_params": {
    "action": "removeFromMyConnections",
    "decorationId": "com.linkedin.voyager.dash.deco.relationships.MemberRelationship-34"
  },
  "body": {
    "connectionUrn": "urn:li:fsd_connection:ACoAACQsq45qSVu3WqOYZw8cueJ0isJ5r9v94"
  },
  "encoding": false
}
```
```

--------------------------------

### Companies Profiles API

Source: https://developer.unipile.com/docs/list-provider-features

Fetch company profiles from LinkedIn. This endpoint allows you to retrieve detailed information about companies.

```APIDOC
## GET /reference/linkedincontroller_getcompanyprofile

### Description
Retrieves company profiles from LinkedIn.

### Method
GET

### Endpoint
/reference/linkedincontroller_getcompanyprofile

### Parameters
#### Path Parameters
None

#### Query Parameters
- **company_id** (string) - Required - The unique identifier of the company.

#### Request Body
None

### Request Example
None

### Response
#### Success Response (200)
- **company_profile** (object) - An object containing the company's profile details.

#### Response Example
```json
{
  "company_profile": {
    "name": "Example Corp",
    "website": "https://example.com",
    "industry": "Technology"
  }
}
```
```

--------------------------------

### Send LinkedIn InMail via Unipile SDK

Source: https://developer.unipile.com/docs/send-messages

Utilize the Unipile SDK to send an InMail message on LinkedIn. This method allows setting specific LinkedIn options, such as the API type and enabling InMail for premium accounts. It facilitates sending messages to users outside of direct connections.

```javascript
const response = await client.messaging.startNewChat({
  account_id: 'Yk08cDzzdsqs9_8ds',
  text: 'Hello world !',
  attendees_ids: ["ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E"],
  options: {
    linkedin: {
      api: 'classic',
      inmail: true
    }
  }
})
```

--------------------------------

### Solve X (Twitter) 2FA Checkpoint

Source: https://developer.unipile.com/docs/twitter-x-guide

Solves a two-factor authentication (2FA) checkpoint for an X (Twitter) account. This function requires the account ID obtained from a previous checkpoint event and the 2FA code provided by the user. It must be called within 5 minutes of receiving the checkpoint.

```javascript
const response = await client.account.solveCodeCheckpoint({
  provider: "TWITTER",
  account_id: "098dez89d",
  code: "******",
});
```

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/accounts/checkpoint \
     --header 'X-API-KEY: {YOUR_ACCESS_TOKEN}' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
  "provider": "TWITTER",
  "account_id": "098dez89d",
  "code": "******"
}'
```

--------------------------------

### Reply to an Email

Source: https://developer.unipile.com/docs/send-email

Reply to an existing email by providing its provider ID.

```APIDOC
## POST /api/v1/emails (reply)

### Description
Send a reply to a specific email.

### Method
POST

### Endpoint
https://{YOUR_DSN}/api/v1/emails

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
- **account_id** (string) - Required - The ID of the account to send the email from.
- **subject** (string) - Required - The subject of the reply.
- **body** (string) - Required - The content of the reply.
- **to** (array of objects) - Required - A list of recipients.
- **reply_to** (string) - Required - The provider ID of the email to reply to.

### Request Example
```json
{
  "account_id": "kzAxdybMQ7ipVxK1U6kwZw",
  "subject": "Re:Hello from Unipile",
  "body": "Hello, this is a test reply from Unipile",
  "to": [
    {
      "display_name": "John Doe",
      "identifier": "john.doe@gmail.com"
    }
  ],
  "reply_to": "X4R9___qXQKIu80oAF0lJA"
}
```

### Response
#### Success Response (200)
(Details of success response not provided in source text)

#### Response Example
(No example provided in source text)
```

--------------------------------

### Send LinkedIn InMail via curl

Source: https://developer.unipile.com/docs/send-messages

Send an InMail message on LinkedIn using the Unipile API. This requires specifying the LinkedIn API type (e.g., 'classic') and setting the 'inmail' option to true. It's used when direct chat is not possible and requires a Premium account.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/chats \
     --header 'X-API-KEY: {YOUR_ACCESS_TOKEN}' \
     --header 'accept: application/json' \
     --header 'content-type: multipart/form-data' \
     --form account_id=Asdq-j08dsqQS89QSD \
     --form 'text=Hello world !' \
     --form attendees_ids=ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E \
     --form linkedin[api]=classic \
     --form linkedin[inmail]=true \

```

--------------------------------

### Create 'New Relation' Webhook - cURL

Source: https://developer.unipile.com/docs/detecting-accepted-invitations

This cURL command demonstrates how to create a webhook to monitor new connections on LinkedIn. The webhook is triggered by the 'new_relation' event, which includes accepted invitations. Ensure you replace placeholders like 'XXXXX' and 'https://yourendpoint' with your actual API key and callback URL. This webhook is not real-time and may have a delay of up to 8 hours.

```curl
curl --request POST \
  --url https://apiX.unipile.com:XXXX/api/v1/webhooks \
  --header 'Content-Type: application/json' \
  --header 'X-API-KEY: XXXXX' \
  --data '{
  "source": "users",
  "request_url": "https://yourendpoint",
  "name": "New relation",
	"headers": [
    {
      "key": "Content-Type",
      "value": "application/json"
    }
  ]
}'
```

--------------------------------

### List Reactions on Post

Source: https://developer.unipile.com/docs/posts-and-comments

Lists all reactions on a specific post.

```APIDOC
## GET /api/v1/posts/{post_social_id}/reactions

### Description
Lists all reactions on a specific post, providing details about who reacted and with what type of reaction.

### Method
GET

### Endpoint
`/api/v1/posts/{post_social_id}/reactions`

### Parameters
#### Path Parameters
- **post_social_id** (string) - Required - The social ID of the post to list reactions for.

#### Query Parameters
- **account_id** (string) - Required - The account ID associated with the request.

### Request Example
(Specific request example for listing reactions is not provided in the input text, but it would follow a similar structure to retrieving a post.)

### Response
#### Success Response (200)
- **reactions** (array) - A list of reactions on the post.
  - **user_id** (string) - The ID of the user who reacted.
  - **reaction_type** (string) - The type of reaction.
  - **timestamp** (string) - The time the reaction was added.

#### Response Example
(Example response not provided in the input text.)
```

--------------------------------

### Invite to LinkedIn Event

Source: https://developer.unipile.com/docs/get-raw-data-example

Sends an invitation to a user for a LinkedIn event. Requires the `account_id`, `inviteeMember` URN, and the `eventUrn` in the query parameters.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/linkedin \
     --header 'X-API-KEY: XXXX' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
"account_id": "91gPYl0eSeY4IClOgJ5FA",
"request_url": "https://www.linkedin.com/voyager/api/voyagerRelationshipsDashInvitations",
"method": "POST",
"body": {
"elements": [{
"inviteeMember": "urn:li:fsd_profile:ACoAACQsq45qSVu3WqOYZw8cueJ0isJ5r9v94",
"genericInvitationType": "EVENT"
}]
},
"query_params": {
"inviter": "(eventUrn:urn%3Ali%3Afsd_professionalEvent%3A7315105458780465155)"
},
"headers": {
"x-restli-method": "batch_create"
},
"encoding": false
}
'
```

--------------------------------

### Delete LinkedIn Connection

Source: https://developer.unipile.com/docs/get-raw-data-example

Removes a connection from your LinkedIn network. This operation requires the `account_id` and the `connectionUrn` of the member to be removed.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/linkedin \
     --header 'X-API-KEY: XXXX' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
  "account_id": "91gPYl0eSeY4IClOgJ5FA",
  "method": "POST",
  "request_url": "https://www.linkedin.com/voyager/api/relationships/dash/memberRelationships",
  "query_params": {
    "action": "removeFromMyConnections",
    "decorationId": "com.linkedin.voyager.dash.deco.relationships.MemberRelationship-34"
  },
  "body": {
    "connectionUrn": "urn:li:fsd_connection:ACoAACQsq45qSVu3WqOYZw8cueJ0isJ5r9v94"
  },
  "encoding": false
}'
```

--------------------------------

### Webhook Payload for New Relation - JSON

Source: https://developer.unipile.com/docs/detecting-accepted-invitations

This JSON object represents the payload received when the 'new_relation' webhook is triggered. It contains details about the newly established connection, including the user's full name, provider ID, profile URL, and picture URL. This payload is crucial for identifying accepted invitations and for subsequent processing.

```json
{
  "event":"new_relation",
  "account_id":"SDF4tGaPSPSzNe1D1xsOs",
  "account_type":"LINKEDIN",
  "webhook_name":"",
  "user_full_name":"Julien Crépieux",
  "user_provider_id":"ACoAAAh_Ffqss54sqAGQOD8u7sl5of04y9_3AwyM",
  "user_public_identifier":"julien-crepieux",
  "user_profile_url":"https://www.linkedin.com/in/julien-crepieux/",
  "user_picture_url":"https://media.licdn.com/dms/image/v2/D56S3AQHfRb8KQLb56A/profile-displayphoto-shrink_400_400/profile-displayphoto-shrink_400_400/0/14545ssssdde=45465465456&v=beta&t=B_Tqss45Go_ETxNHWbK31fFbHGXjreE1dcW-1weM"
}
```

--------------------------------

### Inbox Search Example using cURL

Source: https://developer.unipile.com/docs/get-raw-data-example

This cURL snippet demonstrates how to perform an inbox search on LinkedIn using the Unipile API. It requires your DSN, API key, and account ID. The query parameters allow for filtering by keyword and specifying the type of list to search within.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/linkedin \
     --header 'X-API-KEY: XXXX' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
  "query_params": {
    "variables": "(keyword:arnaud,types:List(CONNECTIONS))", 
"queryId":"voyagerMessagingDashMessagingTypeahead.47f3aa32ab0b43221f99db7c350a2cc3"
  },
  "account_id": "dfR-rG0tQfGhfeP2l5_Bdw",
  "method": "GET",
  "request_url": "https://www.linkedin.com/voyager/api/graphql",
  "encoding": false
}'
```

--------------------------------

### Following a User on LinkedIn using cURL

Source: https://developer.unipile.com/docs/get-raw-data-example

This cURL example shows how to follow a LinkedIn user via the Unipile API. You need to replace the placeholder in `request_url` with the private ID of the target user. This request uses the POST method to update the following state.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/linkedin \
     --header 'X-API-KEY: XXXX' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
  "body": {"patch":{"$set":{"following":true}}},
  "account_id": "dfR-rG0tQfGhfeP2l5_Bdw",
  "method": "POST",
  "request_url": "https://www.linkedin.com/voyager/api/feed/dash/followingStates/urn:li:fsd_followingState:urn:li:fsd_profile:ACoAAAcDMMQBODyLwZrRcgYhrkCafURGqva0U4E",
  "encoding": false
}'
```

--------------------------------

### Add Reaction to Post

Source: https://developer.unipile.com/docs/posts-and-comments

Adds a reaction to a specific post.

```APIDOC
## POST /api/v1/posts/{post_social_id}/reactions

### Description
Adds a reaction to a specific post. This endpoint allows users to express their sentiment towards a post.

### Method
POST

### Endpoint
`/api/v1/posts/{post_social_id}/reactions`

### Parameters
#### Path Parameters
- **post_social_id** (string) - Required - The social ID of the post to react to.

#### Request Body
- **account_id** (string) - Required - The account ID associated with the request.
- **reaction_type** (string) - Required - The type of reaction to add (e.g., 'like', 'celebrate', etc.).

### Request Example
(Specific request example for adding a reaction is not provided in the input text, but it would follow a similar structure to posting a comment.)

### Response
#### Success Response (200)
(Response details for adding a reaction are not provided in the input text. Typically, this would include confirmation of the reaction being added.)

#### Response Example
(Example response not provided in the input text.)
```

--------------------------------

### Authenticate to X (Twitter)

Source: https://developer.unipile.com/docs/twitter-x-guide

Initiate the X (Twitter) authentication process by sending user credentials to the Unipile API.

```APIDOC
## POST /api/v1/accounts

### Description
Initiates the X (Twitter) authentication process. Requires user credentials (username/email/phone and password).

### Method
POST

### Endpoint
https://{YOUR_DSN}/api/v1/accounts

### Parameters
#### Query Parameters
None

#### Headers
- **X-API-KEY** (string) - Required - Your Unipile access token.
- **accept** (string) - Required - `application/json`
- **content-type** (string) - Required - `application/json`

#### Request Body
- **provider** (string) - Required - `TWITTER`
- **username** (string) - Required - The X (Twitter) username, email, or phone number.
- **password** (string) - Required - The X (Twitter) password.

### Request Example
```json
{
  "provider": "TWITTER",
  "username": "unipile",
  "password": "********"
}
```

### Response
#### Success Response (200)
- **object** (string) - Indicates the type of response, e.g., `Checkpoint`.
- **account_id** (string) - The unique identifier for the account connection attempt.
- **checkpoint** (object) - Details about any required checkpoint.
  - **type** (string) - The type of checkpoint, e.g., `2FA`.

#### Response Example (2FA Checkpoint)
```json
{
  "object": "Checkpoint",
  "account_id": "098dez89d",
  "checkpoint": {
    "type": "2FA"
  }
}
```
```

--------------------------------

### Create Webhook for New Relations

Source: https://developer.unipile.com/docs/detecting-accepted-invitations

This endpoint allows you to create a webhook that triggers a 'new_relation' event. This event can indicate an accepted LinkedIn invitation. Note that this webhook is not real-time and may have a delay of up to 8 hours.

```APIDOC
## POST /api/v1/webhooks

### Description
Creates a webhook to monitor for new relations, including accepted LinkedIn invitations.

### Method
POST

### Endpoint
/api/v1/webhooks

### Parameters
#### Request Body
- **source** (string) - Required - The source of the webhook, typically 'users'.
- **request_url** (string) - Required - The URL where the webhook events will be sent.
- **name** (string) - Required - The name of the webhook, e.g., 'New relation'.
- **headers** (array) - Optional - An array of header objects to be sent with the webhook request.
  - **key** (string) - Required - The header key.
  - **value** (string) - Required - The header value.

### Request Example
```json
{
  "source": "users",
  "request_url": "https://yourendpoint",
  "name": "New relation",
  "headers": [
    {
      "key": "Content-Type",
      "value": "application/json"
    }
  ]
}
```

### Response
#### Success Response (200)
- **webhook_id** (string) - The ID of the created webhook.
- **message** (string) - Confirmation message.

#### Response Example
```json
{
  "webhook_id": "whk_12345abcde",
  "message": "Webhook created successfully"
}
```

### Webhook Payload Example (on 'new_relation' trigger)
```json
{
  "event":"new_relation",
  "account_id":"SDF4tGaPSPSzNe1D1xsOs",
  "account_type":"LINKEDIN",
  "webhook_name":"",
  "user_full_name":"Julien Crépieux",
  "user_provider_id":"ACoAAAh_Ffqss54sqAGQOD8u7sl5of04y9_3AwyM",
  "user_public_identifier":"julien-crepieux",
  "user_profile_url":"https://www.linkedin.com/in/julien-crepieux/",
  "user_picture_url":"https://media.licdn.com/dms/image/v2/D56S3AQHfRb8KQLb56A/profile-displayphoto-shrink_400_400/profile-displayphoto-shrink_400_400/0/14545ssssdde=45465465456&v=beta&t=B_Tqss45Go_ETxNHWbK31fFbHGXjreE1dcW-1weM"
}
```
```

--------------------------------

### Get Social Selling Index using cURL

Source: https://developer.unipile.com/docs/get-raw-data-example

This cURL command fetches your Social Selling Index (SSI) score from LinkedIn via the Unipile API. It requires your DSN and account ID. This endpoint is part of the LinkedIn Sales API.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/linkedin \
     --header 'X-API-KEY: XXXX' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
"account_id": "dfR-rG0tQfGhfeP2l5_Bdw",
"request_url": "https://www.linkedin.com/sales-api/salesApiSsi",
"method": "GET"
'
```

--------------------------------

### LinkedIn Search API

Source: https://developer.unipile.com/docs/list-provider-features

Perform searches on LinkedIn using URLs or parameters. This endpoint provides advanced search capabilities.

```APIDOC
## GET /docs/linkedin-search

### Description
Performs searches on LinkedIn using URLs or parameters.

### Method
GET

### Endpoint
/docs/linkedin-search

### Parameters
#### Path Parameters
None

#### Query Parameters
- **query** (string) - Required - The search query string.
- **search_type** (string) - Optional - The type of entity to search for (e.g., 'people', 'companies', 'posts', 'jobs').

#### Request Body
None

### Request Example
None

### Response
#### Success Response (200)
- **search_results** (array) - A list of search results.

#### Response Example
```json
{
  "search_results": [
    {
      "url": "https://www.linkedin.com/in/johndoe",
      "name": "John Doe"
    }
  ]
}
```
```

--------------------------------

### POST /api/v1/accounts - Authenticate to Messenger

Source: https://developer.unipile.com/docs/messenger

Initiates the authentication process for a Messenger account. This endpoint is used to connect your Messenger account by providing username and password.

```APIDOC
## POST /api/v1/accounts

### Description
Initiates the authentication process for a Messenger account by providing username and password.

### Method
POST

### Endpoint
https://{YOUR_DSN}/api/v1/accounts

### Parameters
#### Request Body
- **provider** (string) - Required - Specifies the service provider, should be 'MESSENGER'.
- **username** (string) - Required - The username for the Messenger account.
- **password** (string) - Required - The password for the Messenger account.

### Request Example
```json
{
  "provider": "MESSENGER",
  "username": "unipile",
  "password": "********"
}
```

### Response
#### Success Response (200)
- **account_id** (string) - The unique identifier for the connected account.
- **object** (string) - Indicates the type of response, e.g., 'Account'.

#### Error Response (202)
- **object** (string) - Indicates a checkpoint is required, value is 'Checkpoint'.
- **account_id** (string) - The identifier for the account that requires a checkpoint.
- **checkpoint** (object) - Contains details about the checkpoint.
  - **type** (string) - The type of checkpoint, e.g., '2FA'.

### Response Example (Success)
```json
{
  "object": "Account",
  "account_id": "098dez89d"
}
```

### Response Example (Checkpoint)
```json
{
  "object": "Checkpoint",
  "account_id": "098dez89d",
  "checkpoint": {
    "type": "2FA"
  }
}
```
```

--------------------------------

### Comment a LinkedIn Post using n8n HTTP Request Nodes

Source: https://developer.unipile.com/docs/example-workflow-n8n

This workflow demonstrates how to comment on a LinkedIn post using n8n's HTTP Request nodes. It involves fetching post details first and then sending a comment. Ensure you replace placeholder values with your actual Unipile DSN and post/social IDs.

```JSON
{
  "name": "LinkedIn Comment Workflow",
  "nodes": [
    {
      "parameters": {
        "url": "https://YOUR_DSN.unipile.com:{port}/api/v1/posts/POST_ID",
        "method": "GET"
      },
      "type": "n8n-nodes-base.httpRequest",
      "id": "node1"
    },
    {
      "parameters": {
        "url": "https://YOUR_DSN/api/v1/posts/SOCIAL_ID/comments",
        "method": "POST",
        "body": {
          "text": "Your comment here"
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "id": "node2",
      "executeOutFilters": [],
      "inputIndexes": [
        0
      ]
    }
  ],
  "connections": {
    "node1": [
      {
        "node": "node2",
        "type": "main",
        "index": 0
      }
    ]
  }
}
```

--------------------------------

### Invite to an event

Source: https://developer.unipile.com/docs/get-raw-data-example

This endpoint allows you to invite a LinkedIn member to an event. You need to provide the `account_id`, the `request_url` for the invitations API, and the `body` containing the `inviteeMember` URN and `genericInvitationType` set to 'EVENT'.

```APIDOC
## Invite to an event

### Description
This endpoint allows you to invite a LinkedIn member to an event. You need to provide the `account_id`, the `request_url` for the invitations API, and the `body` containing the `inviteeMember` URN and `genericInvitationType` set to 'EVENT'.

### Method
POST

### Endpoint
https://{YOUR_DSN}/api/v1/linkedin

### Parameters
#### Request Body
- **account_id** (string) - Required - The account ID for the LinkedIn profile.
- **request_url** (string) - Required - The URL for the LinkedIn invitations API.
- **method** (string) - Required - The HTTP method to use, typically 'POST'.
- **body** (object) - Required - Contains details of the invitation.
  - **elements** (array) - Required - A list of invitation elements.
    - **inviteeMember** (string) - Required - The URN of the member to invite.
    - **genericInvitationType** (string) - Required - The type of invitation, set to 'EVENT'.
- **query_params** (object) - Optional - Query parameters for the request.
  - **inviter** (string) - Required - Details about the inviter, including the event URN.
- **headers** (object) - Optional - Headers for the request.
  - **x-restli-method** (string) - Required - Set to 'batch_create' for batch invitations.

### Request Example
```json
{
  "account_id": "91gPYl0eSeY4IClOgJ5FA",
  "request_url": "https://www.linkedin.com/voyager/api/voyagerRelationshipsDashInvitations",
  "method": "POST",
  "body": {
    "elements": [
      {
        "inviteeMember": "urn:li:fsd_profile:ACoAACQsq45qSVu3WqOYZw8cueJ0isJ5r9v94",
        "genericInvitationType": "EVENT"
      }
    ]
  },
  "query_params": {
    "inviter": "(eventUrn:urn%3Ali%3Afsd_professionalEvent%3A7315105458780465155)"
  },
  "headers": {
    "x-restli-method": "batch_create"
  },
  "encoding": false
}
```
```

--------------------------------

### Perform Classic Companies Search with Location IDs (cURL)

Source: https://developer.unipile.com/docs/linkedin-search

This snippet demonstrates how to search for companies using the 'classic' LinkedIn API. It targets companies that have job offers and are located in specific areas identified by their IDs (e.g., 102277331, 102448103). This requires obtaining location IDs in a prior step. Remember to replace placeholders.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/linkedin/search?account_id=!!YOURACCOUNTID!! \
     --header 'X-API-KEY: XXXX' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
	"api": "classic",
	"category": "companies",
	"has_job_offers": true,
	"location": [102277331, 102448103]
}'
```

--------------------------------

### Invite people to follow your company page

Source: https://developer.unipile.com/docs/get-raw-data-example

This endpoint allows you to invite people to follow a LinkedIn company page. You need to provide the `account_id`, the `request_url` for the invitations API, and the `body` containing a list of `inviteeMember` URNs and `genericInvitationType` set to 'ORGANIZATION'.

```APIDOC
## Invite people to follow your company page

### Description
This endpoint allows you to invite people to follow a LinkedIn company page. You need to provide the `account_id`, the `request_url` for the invitations API, and the `body` containing a list of `inviteeMember` URNs and `genericInvitationType` set to 'ORGANIZATION'.

### Method
POST

### Endpoint
https://{YOUR_DSN}/api/v1/linkedin

### Parameters
#### Request Body
- **account_id** (string) - Required - The account ID for the LinkedIn profile.
- **request_url** (string) - Required - The URL for the LinkedIn invitations API.
- **method** (string) - Required - The HTTP method to use, typically 'POST'.
- **body** (object) - Required - Contains details of the invitation.
  - **elements** (array) - Required - A list of invitation elements.
    - **inviteeMember** (string) - Required - The URN of the member to invite.
    - **genericInvitationType** (string) - Required - The type of invitation, set to 'ORGANIZATION'.
- **query_params** (object) - Optional - Query parameters for the request.
  - **inviter** (string) - Required - Details about the inviter, including the organization URN.
- **headers** (object) - Optional - Headers for the request.
  - **x-restli-method** (string) - Required - Set to 'batch_create' for batch invitations.

### Request Example
```json
{
  "account_id": "91gPYl0eSeY4IClOgJ5FA",
  "request_url": "https://www.linkedin.com/voyager/api/voyagerRelationshipsDashInvitations",
  "method": "POST",
  "body": {
    "elements": [
      {
        "inviteeMember": "urn:li:fsd_profile:ACoAAAAA4McB8YEREZF3LfNq00l1IgqTzd8crg",
        "genericInvitationType": "ORGANIZATION"
      },
      {
        "inviteeMember": "urn:li:fsd_profile:ACoAAAAA3W4B6ERE8pWg_l5gb6bCaBEa_SEGvGc",
        "genericInvitationType": "ORGANIZATION"
      }
    ]
  },
  "query_params": {
    "inviter": "(organizationUrn:urn%3Ali%3Afsd_company%3A38114588)"
  },
  "headers": {
    "x-restli-method": "batch_create"
  },
  "encoding": false
}
```
```

--------------------------------

### Publish Job Posting API

Source: https://developer.unipile.com/docs/list-provider-features

Publish an existing job posting. Use this endpoint to make a previously created job posting visible to applicants.

```APIDOC
## POST /reference/linkedincontroller_publishjobposting

### Description
Publishes an existing job posting.

### Method
POST

### Endpoint
/reference/linkedincontroller_publishjobposting

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
- **job_id** (string) - Required - The ID of the job posting to publish.

### Request Example
```json
{
  "job_id": "job789"
}
```

### Response
#### Success Response (200)
- **status** (string) - Indicates the success of the publication.

#### Response Example
```json
{
  "status": "published"
}
```
```

--------------------------------

### Connect to X (Twitter) Account

Source: https://developer.unipile.com/docs/twitter-x-guide

Initiates the connection to an X (Twitter) account by sending credentials to the Unipile API. This method requires the user's Twitter username and password. It's the first step in the authentication process.

```javascript
const response = await client.account.connectTwitter({
  username: "unipile",
  password: "********"
})
```

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/accounts \
     --header 'X-API-KEY: {YOUR_ACCESS_TOKEN}' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data '
{
  "provider": "TWITTER",
  "username": "unipile",
  "password": "********"
}'
```

--------------------------------

### POST /api/v1/linkedin/search (Classic Company Search)

Source: https://developer.unipile.com/docs/linkedin-search

Perform a LinkedIn search to retrieve companies that have job offers in specified locations. Uses the classic LinkedIn search API.

```APIDOC
## POST /api/v1/linkedin/search

### Description
This endpoint allows you to search for companies that have job offers in specified locations using the classic LinkedIn search API.

### Method
POST

### Endpoint
/api/v1/linkedin/search

### Parameters
#### Query Parameters
- **account_id** (string) - Required - The ID of your account.

#### Request Body
- **api** (string) - Required - Set to "classic".
- **category** (string) - Required - Set to "companies".
- **has_job_offers** (boolean) - Required - Set to true to filter for companies with job offers.
- **location** (array) - Required - An array of location IDs.

### Request Example
```json
{
	"api": "classic",
	"category": "companies",
	"has_job_offers": true,
	"location": [102277331, 102448103]
}
```

### Response
#### Success Response (200)
- Returns a JSON object containing the search results.

#### Response Example
```json
{
  "example": "response body"
}
```
```

--------------------------------

### List User/Company Posts

Source: https://developer.unipile.com/docs/posts-and-comments

Lists all posts made by a specific user or company.

```APIDOC
## GET /api/v1/users/{user_id}/posts

### Description
Retrieves a list of all posts published by a specific user or company.

### Method
GET

### Endpoint
`/api/v1/users/{user_id}/posts`

### Parameters
#### Path Parameters
- **user_id** (string) - Required - The ID of the user or company whose posts are to be retrieved.

#### Query Parameters
- **account_id** (string) - Required - The account ID associated with the request.

### Request Example
(Specific request example is not provided in the input text, but it would follow a similar structure to retrieving a post.)

### Response
#### Success Response (200)
- **posts** (array) - A list of posts made by the user or company. Each item in the array would be a post object similar to the response of the 'Retrieve Post' endpoint.

#### Response Example
(Example response not provided in the input text.)
```

--------------------------------

### List of Relations

Source: https://developer.unipile.com/docs/detecting-accepted-invitations

Retrieves a list of your relations, which can be sorted by the most recently added. This can be used periodically to check for new connections that might indicate accepted invitations.

```APIDOC
## GET /api/v1/relations

### Description
Fetches a list of the user's relations, sortable by the most recently added.

### Method
GET

### Endpoint
/api/v1/relations

### Parameters
#### Query Parameters
- **sort_by** (string) - Optional - Field to sort the relations by. Use 'created_at_desc' for most recently added.

### Response
#### Success Response (200)
- **relations** (array) - A list of relation objects.
  - **user_id** (string) - The unique identifier for the user.
  - **full_name** (string) - The full name of the relation.
  - **profile_url** (string) - The URL to the relation's profile.
  - **created_at** (string) - Timestamp when the relation was established.

#### Response Example
```json
{
  "relations": [
    {
      "user_id": "rel_12345",
      "full_name": "Jane Doe",
      "profile_url": "https://www.linkedin.com/in/janedoe/",
      "created_at": "2023-10-27T10:00:00Z"
    }
  ]
}
```
```

--------------------------------

### GET /api/users/profile (Retrieve Profile)

Source: https://developer.unipile.com/docs/createpost-request-n8n

This endpoint retrieves a user's profile information. It requires specifying the GET method and includes necessary headers for authentication and content type.

```APIDOC
## GET /api/users/profile

### Description
Retrieves a user's profile information.

### Method
GET

### Endpoint
/api/users/profile

### Parameters
#### Headers
- **X-API-KEY** (string) - Required - Your Unipile API key.
- **accept** (string) - Required - `application/json`

#### Query Parameters
- **identifier** (string) - Required - The identifier for the user profile to retrieve.

### Request Example
```bash
--header 'X-API-KEY: YOUR_API_KEY' \
--header 'accept: application/json'
```

### Response
#### Success Response (200)
- **object** (string) - Type of object returned (e.g., "UserProfile").
- **provider** (string) - The social media provider (e.g., "LINKEDIN").
- **provider_id** (string) - The user's ID on the specific provider.
- **public_identifier** (string) - The user's public profile identifier.
- **member_urn** (string) - The user's URN.
- **first_name** (string) - The user's first name.
- **last_name** (string) - The user's last name.
- **headline** (string) - The user's professional headline.
- **primary_locale** (object) - The user's primary locale.
  - **country** (string) - Country code.
  - **language** (string) - Language code.
- **is_open_profile** (boolean) - Indicates if the profile is open.
- **is_premium** (boolean) - Indicates if the user has a premium account.
- **is_influencer** (boolean) - Indicates if the user is an influencer.
- **is_creator** (boolean) - Indicates if the user is a content creator.
- **is_relationship** (boolean) - Indicates if there is a relationship with the user.
- **network_distance** (string) - The network distance (e.g., "FIRST_DEGREE").
- **is_self** (boolean) - Indicates if the profile belongs to the authenticated user.
- **websites** (array) - Array of website URLs.
- **follower_count** (integer) - Number of followers.
- **connections_count** (integer) - Number of connections.
- **location** (string) - The user's location.
- **birthdate** (object) - The user's birthdate.
  - **month** (integer) - Birth month.
  - **day** (integer) - Birth day.
- **profile_picture_url** (string) - URL to the user's profile picture.
- **profile_picture_url_large** (string) - URL to a larger version of the profile picture.
- **background_picture_url** (string) - URL to the user's background picture.
- **hashtags** (array) - Array of relevant hashtags.

#### Response Example
```json
[
  {
    "object": "UserProfile",
    "provider": "LINKEDIN",
    "provider_id": "ACoAAAXxg9sBsVmolZ8Oq_7jEe92IOOpRSI8dPE",
    "public_identifier": "arnaud-hartmann",
    "member_urn": "99714011",
    "first_name": "Arnaud",
    "last_name": "Hartmann",
    "headline": "Co-founder & CTO at Unipile | One API to Enhance your App with Multi-Channel Messaging",
    "primary_locale": {
      "country": "US",
      "language": "en"
    },
    "is_open_profile": true,
    "is_premium": true,
    "is_influencer": false,
    "is_creator": true,
    "is_relationship": true,
    "network_distance": "FIRST_DEGREE",
    "is_self": false,
    "websites": [
      "http://www.unipile.com"
    ],
    "follower_count": 6296,
    "connections_count": 6145,
    "location": "Riorges, Auvergne-Rhône-Alpes, France",
    "birthdate": {
      "month": 5,
      "day": 4
    },
    "profile_picture_url": "https://media.licdn.com/dms/image/v2/D4E03AQEtIsqhaZFc8Q/profile-displayphoto-shrink_100_100/profile-displayphoto-shrink_100_100/0/1693819290815?e=1755129600&v=beta&t=KonSfCOwQeua3nhsnaJdd0ncySWA-y-RuEQ64eeFFJc",
    "profile_picture_url_large": "https://media.licdn.com/dms/image/v2/D4E03AQEtIsqhaZFc8Q/profile-displayphoto-shrink_800_800/profile-displayphoto-shrink_800_800/0/1693819290815?e=1755129600&v=beta&t=LH4MACfmW_A_yP9mFBrz2nssZMiPyPN9EhN9Ejhl5lE",
    "background_picture_url": "https://media.licdn.com/dms/image/v2/D4E16AQEmOsNC5se14A/profile-displaybackgroundimage-shrink_350_1400/B4EZaHJSXMH8Ak-/0/1746024081353?e=1755129600&v=beta&t=xLah9joKveS5uZfS0Bx91YxIJYJ2sE3qNg5hkNYKBTQ",
    "hashtags": [
      "#saas",
      "#0inbox",
      "#allistask",
      "#productivity",
      "#unifiedinbox"
    ]
  }
]
```
```

--------------------------------

### POST /api/posts (Create LinkedIn Post With Attachment)

Source: https://developer.unipile.com/docs/createpost-request-n8n

This endpoint allows you to create a LinkedIn post with an attachment. It requires specifying the POST method and includes necessary headers for authentication and content type.

```APIDOC
## POST /api/posts

### Description
Creates a LinkedIn post with an attachment.

### Method
POST

### Endpoint
/api/posts

### Parameters
#### Headers
- **X-API-KEY** (string) - Required - Your Unipile API key.
- **accept** (string) - Required - `application/json`

#### Request Body
(Details for the request body would typically be found on the linked endpoint page, but are not explicitly provided in the input text. The example response suggests a post creation).

### Request Example
```bash
--header 'X-API-KEY: YOUR_API_KEY' \
--header 'accept: application/json'
```

### Response
#### Success Response (200)
- **object** (string) - Type of object created (e.g., "PostCreated").
- **post_id** (string) - The unique identifier for the created post.

#### Response Example
```json
[
  {
    "object": "PostCreated",
    "post_id": "7368649927968571392"
  }
]
```
```

--------------------------------

### Post a Comment

Source: https://developer.unipile.com/docs/posts-and-comments

Posts a comment on a specific post.

```APIDOC
## POST /api/v1/posts/{post_social_id}/comments

### Description
Posts a comment on a specific post. You can also reply to a specific comment using the `comment_id` parameter and use mentions.

### Method
POST

### Endpoint
`/api/v1/posts/{post_social_id}/comments`

### Parameters
#### Path Parameters
- **post_social_id** (string) - Required - The social ID of the post to comment on.

#### Request Body
- **account_id** (string) - Required - The account ID associated with the request.
- **text** (string) - Required - The content of the comment.
- **comment_id** (string) - Optional - The ID of the comment to reply to.
- **mentions** (array) - Optional - A list of mentions to include in the comment.
  - **name** (string) - Required - The name of the mentioned user.
  - **profile_id** (string) - Required - The profile ID of the mentioned user.

### Request Example
**Basic Comment:**
```curl
curl --request POST \
  --url https://apiX.unipile.com:XXXX/api/v1/posts/urn:li:activity:7332661864792854528/comments \
  --header 'Content-Type: application/json' \
  --header 'X-API-KEY: XXXX' \
  --data '{ 
  "account_id": "7ioiu6zHRO67yQBazvXDuQ", 
  "text": "Hey"
}'
```

**Comment with Reply and Mentions:**
```curl
curl --request POST \
  --url https://apiX.unipile.com:XXXX/api/v1/posts/urn:li:activity:7332661864792854528/comments \
  --header 'Content-Type: application/json' \
  --header 'X-API-KEY: XXXX' \
  --data '{  
"account_id": "7ioiu6zHRO67yQBazvXDuQ",  
"text": "Hi {{0}}, thanks",  
"comment_id": "7335000001439513601",  
"mentions": [  
{  
"name": "John Doe",  
"profile_id": "ACoAASss4UBzQV9fDt_ziQ45zzpCVnAhxbW"  
}  
]
}'
```

### Response
#### Success Response (200)
(Response details for posting a comment are not provided in the input text. Typically, this would include confirmation of the comment being posted, its ID, and potentially a timestamp.)

#### Response Example
(Example response not provided in the input text.)
```

--------------------------------

### New Email Webhook Payload Example (JSON)

Source: https://developer.unipile.com/docs/new-emails-webhook

This JSON payload represents a real-time notification from Unipile's New Email Webhook. It includes details about the email event, sender, recipients, subject, and other relevant metadata. This structure is used for both received and sent emails.

```json
{
  "email_id": "--R9___qXQKIu80oAF0lJA",
  "account_id": "GxwlUMaZTHefegva16XcWw",
  "event": "mail_received", // "mail_sent" | "mail_moved"
  "webhook_name": "webhook name",
  "date": "2023-06-14T23:54:12.000Z",
  "from_attendee": {
    "display_name": "Julien Crépieux",
    "identifier": "julien@unipile.com",
    "identifier_type": "EMAIL_ADDRESS"
  },
  "to_attendees": [
    {
      "display_name": "Arnaud Hartmann",
      "identifier": "arnaud@unipile.com",
      "identifier_type": "EMAIL_ADDRESS"
    }
  ],
  "bcc_attendees": [],
  "cc_attendees": [],
  "reply_to_attendees": [],
  "provider_id": "{\"message_id\":\"<D8.08.07528.0034A846@unipile.com>\",\"uid\":\"AQMkADAwATM3ZmYAZS04YjYyLTkzMwA4LTAwAi0wMAoARgAAA6SPCWnzzEdJj0W3b32H3c8HAPXMsqSCUH9FpzZzxeMbKMQAAAIBDAAAAPXMsqSCUH9FpzZzxeMbKMQABHfkN3EAAAA=\"}",
  "message_id": "<D8.08.07528.0034A846@unipile.com>",
  "has_attachments": false,
  "subject": "Hello",
  "body": "Hello World",
  "body_plain": "",
  "attachments": [],
  "folders": ["Inbox"],
  "role": "inbox",
  "read_date": null,
  "is_complete": false,
  "in_reply_to": {
    "message_id": "<DB9P251MB0524C459227C8A2AF82CC523C21A2@unipile.com>",
    "id": "GxwlUMaZTHefegva16XcWw"
  },
  "tracking_id": "Z-4Nx5bMR86b9NVCloU1gg",
  "origin": "unipile" // "external"
}
```

--------------------------------

### Send Email with Attachments

Source: https://developer.unipile.com/docs/send-email

Send an email with one or more attachments.

```APIDOC
## POST /api/v1/emails (with attachments)

### Description
Send an email with attached files.

### Method
POST

### Endpoint
https://{YOUR_DSN}/api/v1/emails

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
- **account_id** (string) - Required - The ID of the account to send the email from.
- **subject** (string) - Required - The subject of the email.
- **body** (string) - Required - The main content of the email.
- **to** (array of objects) - Required - A list of recipients.
- **attachments** (array of arrays) - Optional - A list of attachments. Each attachment is an array where the first element is the filename (string) and the second is the file content (Buffer).

### Request Example
```json
{
  "account_id": "kzAxdybMQ7ipVxK1U6kwZw",
  "to": [
    {
      "display_name": "John Doe",
      "identifier": "john.doe@gmail.com"
    }
  ],
  "subject": "Hello from Unipile",
  "body": "Hello, this is a test email from Unipile",
  "attachments": [
    ["cute_dog.png", "<Buffer...>" ]
  ]
}
```

### Response
#### Success Response (200)
(Details of success response not provided in source text)

#### Response Example
(No example provided in source text)
```

--------------------------------

### Request QR Code for Telegram Auth (cURL)

Source: https://developer.unipile.com/docs/telegram

Makes a POST request to the Unipile API to generate a QR code for Telegram authentication. This command requires your DSN and an access token. The request body specifies 'TELEGRAM' as the authentication provider. The response will contain the QR code data.

```curl
curl --request POST \
     --url https://{YOUR_DSN}/api/v1/accounts \
     --header 'X-API-KEY: {YOUR_ACCESS_TOKEN}' \
     --header 'accept: application/json' \
     --header 'content-type: application/json' \
     --data \
'{
  "provider": "TELEGRAM"
}'
```

--------------------------------

### Get Resume of Applicants API

Source: https://developer.unipile.com/docs/list-provider-features

Retrieve the resume of a specific applicant. This endpoint provides access to candidate resumes for review.

```APIDOC
## GET /reference/linkedincontroller_getjobapplicantresume

### Description
Retrieves the resume of an applicant.

### Method
GET

### Endpoint
/reference/linkedincontroller_getjobapplicantresume

### Parameters
#### Path Parameters
None

#### Query Parameters
- **applicant_id** (string) - Required - The ID of the applicant.

#### Request Body
None

### Request Example
None

### Response
#### Success Response (200)
- **resume** (string) - The resume content of the applicant (e.g., text or URL).

#### Response Example
```json
{
  "resume": "(Resume content here...)"
}
```
```