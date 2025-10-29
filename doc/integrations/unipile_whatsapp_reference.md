### Whatsapp Account Connection

Source: https://developer.unipile.com/reference/accountscontroller_createaccount

Connect a Whatsapp account. Supports QR code authentication by default, or phone number pairing with an optional code.

```APIDOC
## POST /api/connect/whatsapp

### Description
Connect a Whatsapp account. Uses QR code authentication by default. Can also use phone number pairing for authentication.

### Method
POST

### Endpoint
/api/connect/whatsapp

### Parameters
#### Query Parameters
- **country** (string) - Optional - An ISO 3166-1 A-2 country code to set the proxy's location.
- **ip** (string) - Optional - An IPv4 address to infer the proxy's location.

#### Request Body
- **disabled_features** (array) - Optional - An array of features to disable for this account (e.g., `linkedin_recruiter`).
- **provider** (string) - Required - The service provider, must be 'WHATSAPP'.
- **proxy** (object) - Optional - Proxy configuration for the connection.
  - **protocol** (string) - Required - Proxy protocol (`https`, `http`, `socks5`).
  - **port** (number) - Required - Proxy port.
  - **host** (string) - Required - Proxy host.
  - **username** (string) - Optional - Username for proxy authentication.
  - **password** (string) - Optional - Password for proxy authentication.
- **pairing_phone_number** (string) - Optional - (Beta) The phone number to use for login. If provided, a code will be returned; otherwise, a QR code will be returned.

### Request Example
```json
{
  "provider": "WHATSAPP",
  "pairing_phone_number": "+1234567890",
  "proxy": {
    "protocol": "socks5",
    "port": 9050,
    "host": "127.0.0.1"
  }
}
```

### Response
#### Success Response (200)
- **checkpoint** (string) - The checkpoint required for authentication (QR code data or pairing code).

#### Response Example
```json
{
  "checkpoint": "WEBRTMP" // QR code data or pairing code
}
```
```

--------------------------------

### POST /api/v1/messages/{message_id}/forward

Source: https://developer.unipile.com/reference/messagescontroller_forwardmessage

Forward a message to a specified chat. This endpoint is specifically designed for WhatsApp message forwarding.

```APIDOC
## POST /api/v1/messages/{message_id}/forward

### Description
Forward a message to a chat. (Whatsapp only)

### Method
POST

### Endpoint
/api/v1/messages/{message_id}/forward

### Parameters
#### Path Parameters
- **message_id** (string) - Required - The id of the message to forward.

#### Request Body
- **chat_id** (string) - Required - The id of the chat to forward the message to.

### Request Example
```json
{
  "chat_id": "REPLACE_WITH_CHAT_ID"
}
```

### Response
#### Success Response (200)
- **object** (string) - Must be 'MessageForwarded'.
- **message_id** (string, nullable) - The Unipile ID of the newly forwarded message.

#### Response Example
```json
{
  "object": "MessageForwarded",
  "message_id": "fwd_abc123xyz"
}
```

#### Error Responses
- **401 Unauthorized**: Handles various authentication and authorization errors including missing credentials, multiple sessions, wrong account, invalid credentials, expired credentials, insufficient privileges, disconnected accounts, and unsupported captcha.

```

--------------------------------

### WhatsApp Account Object

Source: https://developer.unipile.com/reference/accountscontroller_getaccountbyid

Defines the structure for a WhatsApp account, including its connection parameters, ID, name, creation timestamp, and signature details.

```APIDOC
## WhatsApp Account Object Schema

### Description
Represents a WhatsApp account within the system. This schema outlines the expected properties for a WhatsApp account, including its unique identifier, name, creation date, and connection-specific parameters.

### Object Type
`Whatsapp`

### Properties
- **object** (string) - Required - Must be `Account`.
- **type** (string) - Required - Must be `WHATSAPP`.
- **connection_params** (object) - Required - Contains parameters specific to the WhatsApp connection.
  - **im** (object) - Required - Instant Messaging parameters.
    - **phone_number** (string) - Required - The phone number associated with the WhatsApp account.
- **id** (string) - Required - A unique identifier for the account. Minimum length is 1.
- **name** (string) - Required - The name of the WhatsApp account.
- **created_at** (string) - Required - An ISO 8601 UTC datetime (YYYY-MM-DDTHH:MM:SS.sssZ) indicating when the account was created. Note: All links expire upon daily restart. A new link must be generated each time a user clicks on your app to connect.
- **current_signature** (string) - Optional - A unique identifier for the current signature.
- **signatures** (array) - Optional - A list of available signatures for the account.
  - **title** (string) - Required - The title of the signature.
  - **content** (string) - Required - The content of the signature.

### Response Example (Success)
```json
{
  "object": "Account",
  "type": "WHATSAPP",
  "connection_params": {
    "im": {
      "phone_number": "+1234567890"
    }
  },
  "id": "acc_123abc",
  "name": "My WhatsApp Business Account",
  "created_at": "2023-10-27T10:30:00.000Z",
  "current_signature": "sig_xyz789",
  "signatures": [
    {
      "title": "Welcome Message",
      "content": "Welcome to our service!"
    }
  ]
}
```
```

--------------------------------

### Whatsapp Authentication

Source: https://developer.unipile.com/reference/accountscontroller_reconnectaccount

Connect a Whatsapp account. Supports QR code authentication by default, or phone number login via beta feature.

```APIDOC
## Whatsapp Authentication

### Description
Connect a Whatsapp account. By default, this uses QR code authentication. You can optionally specify a country or IP for proxy location, disable features, or use a proxy. A beta feature allows login with a phone number.

### Method
POST

### Endpoint
/websites/developer_unipile_reference/whatsapp

### Parameters
#### Query Parameters
- **country** (string) - Optional - An ISO 3166-1 A-2 country code to set as proxy's location.
- **ip** (string) - Optional - An IPv4 address to infer proxy's location.

#### Request Body
- **provider** (string) - Required - Must be 'WHATSAPP'.
- **disabled_features** (array) - Optional - An array of features to disable (e.g., 'linkedin_recruiter', 'linkedin_sales_navigator', 'linkedin_organizations_mailboxes').
- **proxy** (object) - Optional - Proxy configuration for the connection.
  - **protocol** (string) - Required - Proxy protocol ('https', 'http', 'socks5').
  - **port** (number) - Required - Proxy port.
  - **host** (string) - Required - Proxy host.
  - **username** (string) - Optional - Username for proxy authentication.
  - **password** (string) - Optional - Password for proxy authentication.
- **pairing_phone_number** (string) - Optional (Beta) - The phone number to log in with. If provided, a code will be returned. If empty, a QR code will be returned.

### Request Example (QR Code)
```json
{
  "provider": "WHATSAPP"
}
```

### Request Example (Phone Number Login)
```json
{
  "provider": "WHATSAPP",
  "pairing_phone_number": "+1234567890"
}
```

### Request Example (with Proxy)
```json
{
  "provider": "WHATSAPP",
  "proxy": {
    "protocol": "https",
    "port": 8080,
    "host": "proxy.example.com",
    "username": "proxyuser",
    "password": "proxypassword"
  }
}
```

### Response
#### Success Response (200)
- **checkpoint** (string) - The QR code to scan or the code to enter in the Whatsapp app.
- **message** (string) - Indicates successful connection setup.

#### Response Example (QR Code)
```json
{
  "checkpoint": "<QR_CODE_DATA>",
  "message": "Whatsapp connection initiated. Scan the QR code."
}
```

#### Response Example (Phone Number Login)
```json
{
  "checkpoint": "123456",
  "message": "Enter the code 123456 in your Whatsapp app."
}
```
```

--------------------------------

### UserProfile API Documentation

Source: https://developer.unipile.com/reference/userscontroller_getprofilebyidentifier

This section details the structure and requirements for UserProfile objects, including LinkedIn, Whatsapp, and Instagram profiles.

```APIDOC
## UserProfile Object Structure

### Description
Defines the schema for user profile data, encompassing details from various social platforms.

### Method
N/A (Schema definition)

### Endpoint
N/A (Schema definition)

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
This describes the potential fields within a UserProfile object:

##### LinkedIn Profile Schema
- **provider** (string) - Required - The provider of the profile data, e.g., "LINKEDIN".
- **provider_id** (string) - Required - The unique identifier for the user on the provider platform.
- **public_identifier** (string) - Required - A public-facing identifier for the user.
- **first_name** (string) - Required - The user's first name.
- **last_name** (string) - Required - The user's last name.
- **headline** (string) - Required - The user's professional headline.
- **websites** (array) - Required - A list of website URLs associated with the user.
- **profile_picture_url** (string) - Optional - URL to the user's profile picture.
- **follower_count** (number) - Optional - The number of followers the user has.
- **connections_count** (number) - Optional - The number of connections the user has.
- **shared_connections_count** (number) - Optional - The number of shared connections.
- **network_distance** (string) - Optional - The network distance from the current user (e.g., "FIRST_DEGREE", "SECOND_DEGREE", "THIRD_DEGREE", "OUT_OF_NETWORK").
- **public_profile_url** (string) - Optional - The URL to the user's public profile.
- **object** (string) - Required - Indicates the object type, should be "UserProfile".

##### Whatsapp Profile Schema
- **provider** (string) - Required - The provider of the profile data, e.g., "WHATSAPP".
- **id** (string) - Required - The unique identifier for the user on the provider platform.
- **object** (string) - Required - Indicates the object type, should be "UserProfile".

##### Instagram Profile Schema
- **provider** (string) - Required - The provider of the profile data, e.g., "INSTAGRAM".
- **provider_id** (string) - Required - The unique identifier for the user on the provider platform.
- **provider_messaging_id** (string) - Optional - Messaging identifier on the provider platform.
- **public_identifier** (string) - Optional - A public-facing identifier for the user.
- **full_name** (string) - Optional - The user's full name.
- **profile_picture_url** (string) - Optional - URL to the user's profile picture.
- **profile_picture_url_large** (string) - Optional - URL to a larger version of the user's profile picture.
- **biography** (string) - Optional - The user's biography.
- **category** (string) - Optional - The category of the Instagram profile.
- **followers_count** (number) - Optional - The number of followers.
- **mutual_followers_count** (number) - Optional - The number of mutual followers.
- **following_count** (number) - Optional - The number of users the profile is following.
- **posts_count** (number) - Optional - The number of posts made by the profile.
- **profile_type** (string) - Optional - The type of Instagram profile (e.g., "BUSINESS", "CREATOR", "PERSONAL").
- **object** (string) - Required - Indicates the object type, should be "UserProfile".

### Request Example
```json
{
  "provider": "LINKEDIN",
  "provider_id": "example_linkedin_id",
  "public_identifier": "john-doe-12345",
  "first_name": "John",
  "last_name": "Doe",
  "headline": "Software Engineer at Example Corp",
  "websites": ["https://example.com"],
  "follower_count": 1500,
  "network_distance": "SECOND_DEGREE",
  "public_profile_url": "https://linkedin.com/in/johndoe",
  "object": "UserProfile"
}
```

### Response
#### Success Response (200)
- **provider** (string) - The provider of the profile data.
- **provider_id** (string) - The unique identifier on the provider platform.
- **public_identifier** (string) - A public-facing identifier.
- **first_name** (string) - The user's first name.
- **last_name** (string) - The user's last name.
- **headline** (string) - The user's professional headline.
- **websites** (array) - A list of website URLs.
- **profile_picture_url** (string) - URL to the user's profile picture.
- **follower_count** (number) - The number of followers.
- **connections_count** (number) - The number of connections.
- **shared_connections_count** (number) - The number of shared connections.
- **network_distance** (string) - The network distance from the current user.
- **public_profile_url** (string) - The URL to the user's public profile.
- **object** (string) - Indicates the object type, "UserProfile".

#### Response Example
```json
{
  "provider": "LINKEDIN",
  "provider_id": "example_linkedin_id",
  "public_identifier": "john-doe-12345",
  "first_name": "John",
  "last_name": "Doe",
  "headline": "Software Engineer at Example Corp",
  "websites": ["https://example.com"],
  "follower_count": 1500,
  "network_distance": "SECOND_DEGREE",
  "public_profile_url": "https://linkedin.com/in/johndoe",
  "object": "UserProfile"
}
```
```

--------------------------------

### List all chats

Source: https://developer.unipile.com/reference/messaging

Retrieves a list of chats with optional filtering and pagination parameters.

```APIDOC
## GET https://{subdomain}.unipile.com:{port}/api/v1/chats

### Description
Returns a list of chats. Some optional parameters are available to filter the results.

### Method
GET

### Endpoint
`https://{subdomain}.unipile.com:{port}/api/v1/chats`

### Parameters
#### Query Parameters
- **unread** (boolean) - Optional - Whether you want to get either unread chats only, or read chats only.
- **cursor** (string) - Optional - A cursor for pagination purposes. To get the next page of entries, you need to make a new request and fulfill this field with the cursor received in the preceding request. This process should be repeated until all entries have been retrieved.
- **before** (string) - Optional - A filter to target items created before the datetime (exclusive). Must be an ISO 8601 UTC datetime (YYYY-MM-DDTHH:MM:SS.sssZ).
- **after** (string) - Optional - A filter to target items created after the datetime (exclusive). Must be an ISO 8601 UTC datetime (YYYY-MM-DDTHH:MM:SS.sssZ).
- **limit** (integer) - Optional - A limit for the number of items returned in the response. The value can be set between 1 and 250.
- **account_type** (string) - Optional - An enum filter to target items related to a certain provider. Allowed values: `WHATSAPP`, `LINKEDIN`, `SLACK`, `TWITTER`, `MESSENGER`, `INSTAGRAM`, `TELEGRAM`.
- **account_id** (string) - Optional - A filter to target items related to a certain account. Can be a comma-separated list of ids.

### Response
#### Success Response (200)
- **items** (array of objects) - An array of chat objects.
  - **id** (string) - A unique identifier.
  - **account_id** (string) - A unique identifier for the account.
  - **account_type** (string) - The type of account (provider).
  - **provider_id** (string) - The provider's unique identifier.
  - **attendee_provider_id** (string) - The attendee's provider unique identifier.
  - **name** (string) - The name of the chat.
  - **type** (string) - The type of the chat.
  - **timestamp** (string) - The timestamp of the last message.
  - **unread_count** (number) - The number of unread messages.
  - **archived** (boolean) - Whether the chat is archived.
  - **muted_until** (string) - Timestamp until which the chat is muted.
  - **read_only** (boolean) - Whether the chat is read-only.
  - **disabledFeatures** (array) - List of disabled features for the chat.
  - **subject** (string) - The subject of the chat (e.g., for LinkedIn mailboxes).
  - **organization_id** (string) - Linkedin specific ID for organization mailboxes.
  - **mailbox_id** (string) - Linkedin specific ID for organization mailboxes.
  - **content_type** (string) - The content type of the chat.
  - **folder** (array) - Folders associated with the chat.
  - **pinned** (boolean) - Whether the chat is pinned.
  - **cursor** (string) - Cursor for pagination.

#### Response Example (200)
```json
{
  "items": [
    {
      "id": "chat_123",
      "account_id": "acc_abc",
      "account_type": "WHATSAPP",
      "provider_id": "prov_xyz",
      "attendee_provider_id": "att_pqr",
      "name": "John Doe",
      "type": "individual",
      "timestamp": "2023-10-27T10:00:00.000Z",
      "unread_count": 0,
      "archived": false,
      "muted_until": null,
      "read_only": false,
      "disabledFeatures": [],
      "subject": null,
      "organization_id": null,
      "mailbox_id": null,
      "content_type": "message",
      "folder": [],
      "pinned": false,
      "cursor": "next_cursor_123"
    }
  ]
}
```

#### Error Responses
- **401 Unauthorized**:
  - `errors/missing_credentials`: Missing credentials.
  - `errors/multiple_sessions`: Multiple sessions detected (LinkedIn specific).
  - `errors/wrong_account`: Provided credentials do not match the correct account.
  - `errors/invalid_credentials`: Invalid credentials.
  - `errors/invalid_proxy_credentials`: Invalid proxy credentials.
  - `errors/invalid_imap_configuration`: Invalid IMAP configuration.
  - `errors/invalid_smtp_configuration`: Invalid SMTP configuration.
  - `errors/invalid_checkpoint_solution`: Checkpoint resolution failed.
  - `errors/checkpoint_error`: Checkpoint error.
  - `errors/expired_credentials`: Expired credentials.
  - `errors/expired_link`: Expired link.
  - `errors/insufficient_privileges`: Insufficient privileges.
  - `errors/disconnected_account`: Account is disconnected.
  - `errors/disconnected_feature`: Service feature is disconnected.
```

--------------------------------

### POST /api/v1/chats

Source: https://developer.unipile.com/reference/chatscontroller_startnewchat

Initiate a new chat conversation with one or more attendees. Supports various platforms like LinkedIn and Instagram, with specific fields for each.

```APIDOC
## POST /api/v1/chats

### Description
Start a new conversation with one or more attendee. Supports rich text formatting for LinkedIn messages and specific parameters for different platforms.

### Method
POST

### Endpoint
/api/v1/chats

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
- **account_id** (string) - Required - An Unipile account id.
- **text** (string) - Required - The message that will start the new conversation. Supports HTML tags for LinkedIn (e.g., &lt;strong&gt;, &lt;em&gt;, &lt;a&gt;, &lt;ul&gt;, &lt;ol&gt;, &lt;li&gt;).
- **attachments** (array of binary) - Optional - Files to attach to the message.
- **voice_message** (binary) - Optional - For LinkedIn messaging only.
- **video_message** (binary) - Optional - For LinkedIn messaging only.
- **attendees_ids** (array of string) - Required - One or more attendee provider IDs. Use 'provider_messaging_id' for Instagram and 'messaging/id' for LinkedIn company messaging.
- **subject** (string) - Optional - The subject of the conversation.
- **linkedin** (object) - Optional - Extra fields for LinkedIn products.
  - **api** (string) - Optional - The LinkedIn API to use (e.g., 'classic'). Defaults to classic.
  - **topic** (string) - Optional - Mandatory for starting a conversation with a company (e.g., 'service_request', 'request_demo').
  - **applicant_id** (string) - Optional - Mandatory for starting a conversation with a job applicant.
  - **invitation_id** (string) - Optional - Mandatory for starting a conversation with a user from whom you received an invitation.
  - **inmail** (boolean) - Optional - If true, starts the conversation with an inMail.

### Request Example
```json
{
  "account_id": "your_account_id",
  "text": "Hello, this is a test message.",
  "attendees_ids": ["attendee1_id", "attendee2_id"],
  "linkedin": {
    "inmail": true,
    "topic": "request_demo"
  }
}
```

### Response
#### Success Response (200)
- **chat_id** (string) - The ID of the newly created chat.
- **status** (string) - The status of the chat creation.

#### Response Example
```json
{
  "chat_id": "chat_12345",
  "status": "success"
}
```
```

--------------------------------

### GET /api/v1/chats

Source: https://developer.unipile.com/reference/messaging

Retrieves a list of chats from the Unipile API. This endpoint allows fetching chat data with various details.

```APIDOC
## GET /api/v1/chats

### Description
Retrieves a list of chats from the Unipile API. This endpoint allows fetching chat data with various details.

### Method
GET

### Endpoint
https://api1.unipile.com:13111/api/v1/chats

### Parameters
#### Query Parameters
* None

#### Request Body
* None

### Request Example
```shell
curl --request GET \
     --url https://api1.unipile.com:13111/api/v1/chats \
     --header 'accept: application/json'
```

### Response
#### Success Response (200)
- **object** (string) - "ChatList"
- **items** (array) - An array of chat objects.
  - **object** (string) - "Chat"
  - **id** (string) - Unique identifier for the chat.
  - **account_id** (string) - Identifier for the associated account.
  - **account_type** (string) - Type of the account (e.g., "WHATSAPP").
  - **provider_id** (string) - Identifier from the chat provider.
  - **attendee_provider_id** (string) - Identifier for the attendee from the chat provider.
  - **name** (string) - Name of the chat.
  - **type** (number) - Type of the chat.
  - **timestamp** (string) - Timestamp of the last message.
  - **unread_count** (number) - Number of unread messages.
  - **archived** (number) - Indicates if the chat is archived.
  - **muted_until** (number) - Timestamp until which the chat is muted.
  - **read_only** (number) - Indicates if the chat is read-only.
  - **disabledFeatures** (array) - List of disabled features (e.g., "reactions", "reply").
  - **subject** (string) - Subject of the chat.
  - **organization_id** (string) - Identifier for the organization.
  - **mailbox_id** (string) - Identifier for the mailbox.
  - **content_type** (string) - Type of the content (e.g., "inmail").
  - **folder** (array) - List of folders the chat belongs to (e.g., "INBOX", "INBOX_LINKEDIN_CLASSIC").
  - **pinned** (number) - Indicates if the chat is pinned.

#### Response Example
```json
{
  "object": "ChatList",
  "items": [
    {
      "object": "Chat",
      "id": "string",
      "account_id": "string",
      "account_type": "WHATSAPP",
      "provider_id": "string",
      "attendee_provider_id": "string",
      "name": "string",
      "type": 0,
      "timestamp": "string",
      "unread_count": 0,
      "archived": 0,
      "muted_until": -1,
      "read_only": 0,
      "disabledFeatures": [
        "reactions",
        "reply"
      ],
      "subject": "string",
      "organization_id": "string",
      "mailbox_id": "string",
      "content_type": "inmail",
      "folder": [
        "INBOX",
        "INBOX_LINKEDIN_CLASSIC",
        "INBOX_LINKEDIN_RECRUITER",
        "INBOX_LINKEDIN_SALES_NAVIGATOR",
        "INBOX_LINKEDIN_ORGANIZATION"
      ],
      "pinned": 0
    }
  ]
}
```
```

--------------------------------

### GET /api/v1/chats

Source: https://developer.unipile.com/reference/chatscontroller_listallchats

Retrieves a list of all chats available in the Unipile platform. This endpoint supports filtering by unread status, date range, account type, and specific accounts. It also includes pagination capabilities.

```APIDOC
## GET /api/v1/chats

### Description
Returns a list of chats. Some optional parameters are available to filter the results.

### Method
GET

### Endpoint
/api/v1/chats

### Parameters
#### Query Parameters
- **unread** (boolean) - Optional - Whether you want to get either unread chats only, or read chats only.
- **cursor** (string) - Optional - A cursor for pagination purposes. To get the next page of entries, you need to make a new request and fulfill this field with the cursor received in the preceding request. This process should be repeated until all entries have been retrieved.
- **before** (string) - Optional - A filter to target items created before the datetime (exclusive). Must be an ISO 8601 UTC datetime (YYYY-MM-DDTHH:MM:SS.sssZ).
- **after** (string) - Optional - A filter to target items created after the datetime (exclusive). Must be an ISO 8601 UTC datetime (YYYY-MM-DDTHH:MM:SS.sssZ).
- **limit** (integer) - Optional - A limit for the number of items returned in the response. The value can be set between 1 and 250.
- **account_type** (string) - Optional - A filter to target items related to a certain provider. Possible values: WHATSAPP, LINKEDIN, SLACK, TWITTER, MESSENGER, INSTAGRAM, TELEGRAM.
- **account_id** (string) - Optional - A filter to target items related to a certain account. Can be a comma-separated list of ids.

### Request Example
```json
{
  "example": "No request body for GET request"
}
```

### Response
#### Success Response (200)
- **object** (string) - Indicates the type of object returned, expected to be "ChatList".
- **items** (array) - An array of chat objects.
  - **object** (string) - Indicates the type of object, expected to be "Chat".
  - **id** (string) - The unique identifier for the chat.

#### Response Example
```json
{
  "object": "ChatList",
  "items": [
    {
      "object": "Chat",
      "id": "chat_abc123"
    }
  ]
}
```
```

--------------------------------

### GET /api/v1/chats/{chat_id}/messages

Source: https://developer.unipile.com/reference/chatscontroller_listchatmessages

Retrieves a list of messages from a specific chat. Supports filtering by sender, date range, and pagination.

```APIDOC
## GET /api/v1/chats/{chat_id}/messages

### Description
Returns a list of messages related to the given chat. Some parameters are available to filter the results.

### Method
GET

### Endpoint
/api/v1/chats/{chat_id}/messages

### Parameters
#### Path Parameters
- **chat_id** (string) - Required - The id of the chat related to requested messages.

#### Query Parameters
- **cursor** (string) - Optional - A cursor for pagination purposes. To get the next page of entries, you need to make a new request and fulfill this field with the cursor received in the preceding request. This process should be repeated until all entries have been retrieved.
- **before** (string) - Optional - A filter to target items created before the datetime (exclusive). Must be an ISO 8601 UTC datetime (YYYY-MM-DDTHH:MM:SS.sssZ).
- **after** (string) - Optional - A filter to target items created after the datetime (exclusive). Must be an ISO 8601 UTC datetime (YYYY-MM-DDTHH:MM:SS.sssZ).
- **limit** (integer) - Optional - A limit for the number of items returned in the response. The value can be set between 1 and 250.
- **sender_id** (string) - Optional - A filter to target messages received from a certain sender. The id of the sender targeted.

### Request Example
```json
{
  "example": "request body"
}
```

### Response
#### Success Response (200)
- **object** (string) - Enum: MessageList
- **items** (array) - Array of Message objects
  - **object** (string) - Enum: Message
  - **provider_id** (string)
  - **sender_id** (string)
  - **text** (string or null)
  - **attachments** (array)

#### Response Example
```json
{
  "object": "MessageList",
  "items": [
    {
      "object": "Message",
      "provider_id": "msg_abc123",
      "sender_id": "user_xyz789",
      "text": "Hello there!",
      "attachments": []
    }
  ]
}
```
```

--------------------------------

### Send Message in Chat using Unipile Node.js SDK

Source: https://developer.unipile.com/reference/chatscontroller_sendmessageinchat

This snippet demonstrates how to send a message to a specified chat using the Unipile Node.js SDK. It requires the chat ID and message text as input. The SDK handles the API interaction, and error handling is included. Ensure the `unipile-node-sdk` is installed.

```node
import { UnipileClient } from "unipile-node-sdk"

// SDK setup
const BASE_URL = "your base url"
const ACCESS_TOKEN = "your access token"
// Inputs
const chat_id = "chat id"
const text = "text"

try {
	const client = new UnipileClient(BASE_URL, ACCESS_TOKEN)

	const response = await client.messaging.sendMessage({
		chat_id,
		text,
	})
} catch (error) {
	console.log(error)
}

```

--------------------------------

### POST /api/v1/chats/{chat_id}/messages

Source: https://developer.unipile.com/reference/chatscontroller_sendmessageinchat

Send a message to the given chat with the possibility to link some attachments.

```APIDOC
## POST /api/v1/chats/{chat_id}/messages

### Description
Send a message to the given chat with the possibility to link some attachments.

### Method
POST

### Endpoint
/api/v1/chats/{chat_id}/messages

### Parameters
#### Path Parameters
- **chat_id** (string) - Required - The id of the chat where to send the message.

#### Query Parameters
None

#### Request Body
- **text** (string) - Required - The content of the message.
- **account_id** (string) - Optional - An account_id can be specified to prevent the user from sending messages in chats not belonging to the account.
- **thread_id** (string) - Optional - Optional and for Slack’s messaging only. The id of the thread to send the message in.
- **quote_id** (string) - Optional - The id of a message to quote. The id of the message to quote / reply to.
- **voice_message** (binary) - Optional - For Linkedin messaging only.
- **video_message** (binary) - Optional - For Linkedin messaging only.
- **attachments** (array) - Optional - Array of binary files to attach to the message.
- **typing_duration** (string) - Optional - (WhatsApp only) Set a duration in milliseconds to simulate a typing status for that duration before sending the message.

### Request Example
```json
{
  "text": "Hello, world!",
  "attachments": [
    "file_content_as_binary"
  ]
}
```

### Response
#### Success Response (201)
- **object** (string) - Enum: "MessageSent" - Indicates the type of the response object.
- **message_id** (string) - The Unipile ID of the newly sent message.

#### Response Example
```json
{
  "object": "MessageSent",
  "message_id": "msg_12345"
}
```
```

--------------------------------

### List All Chats with unipile-node-sdk

Source: https://developer.unipile.com/reference/chatscontroller_listallchats

This code snippet demonstrates how to list all chats using the unipile-node-sdk. It requires the base URL and an access token for authentication. The function can be filtered by unread status, cursor for pagination, creation time (before/after), limit, account type, and account ID.

```node
import { UnipileClient } from "unipile-node-sdk"

const BASE_URL = "your base url"
const ACCESS_TOKEN = "your access token"

try {
	const client = new UnipileClient(BASE_URL, ACCESS_TOKEN)

	const response = await client.messaging.getAllChats()
} catch (error) {
	console.log(error)
}

```

--------------------------------

### GET /api/v1/chats/{chat_id}

Source: https://developer.unipile.com/reference/chatscontroller_getchat

Retrieve the details of a specific chat using its ID. This endpoint can filter by account ID if the chat ID is a provider ID.

```APIDOC
## GET /api/v1/chats/{chat_id}

### Description
Retrieve the details of a chat.

### Method
GET

### Endpoint
/api/v1/chats/{chat_id}

### Parameters
#### Path Parameters
- **chat_id** (string) - Required - The Unipile or provider ID of the chat.

#### Query Parameters
- **account_id** (string) - Optional - Mandatory if the chat ID is a provider ID.

### Response
#### Success Response (200)
- **id** (string) - A unique identifier.
- **account_id** (string) - A unique identifier.
- **account_type** (string) - The type of account (e.g., WHATSAPP, LINKEDIN, SLACK, TWITTER, MESSENGER, INSTAGRAM, TELEGRAM).
- **provider_id** (string) - The provider's chat ID.
- **attendee_provider_id** (string) - The provider's attendee ID.
- **name** (string | null) - The name of the chat.
- **type** (number) - The type of chat (0, 1, or 2).
- **timestamp** (string) - The timestamp of the chat.

#### Response Example
{
  "id": "634b493821325000117a804d",
  "account_id": "634b493821325000117a804d",
  "account_type": "WHATSAPP",
  "provider_id": "1234567890@broadcast.whatsapp.com",
  "attendee_provider_id": "1234567890",
  "name": null,
  "type": 0,
  "timestamp": "2022-10-14T10:00:00.000Z"
}
```

--------------------------------

### List Chat Messages with Unipile Node.js SDK

Source: https://developer.unipile.com/reference/chatscontroller_listchatmessages

This code snippet demonstrates how to retrieve all messages from a specific chat using the Unipile Node.js SDK. It requires the base URL, access token, and chat ID for initialization and execution. The function returns a list of messages and can be filtered by various parameters.

```node
import { UnipileClient } from "unipile-node-sdk"

// SDK setup
const BASE_URL = "your base url"
const ACCESS_TOKEN = "your access token"
// Inputs
const chat_id = "chat id"

try {
	const client = new UnipileClient(BASE_URL, ACCESS_TOKEN)

	const response = await client.messaging.getAllMessagesFromChat({
		chat_id,
	})
} catch (error) {
	console.log(error)
}

```

--------------------------------

### Retrieve Chat Details with unipile-node-sdk

Source: https://developer.unipile.com/reference/chatscontroller_getchat

This Node.js code snippet demonstrates how to retrieve chat details using the unipile-node-sdk. It requires the base URL, an access token, and the chat ID as input. The SDK handles the API interaction, and potential errors are caught and logged.

```node
import { UnipileClient } from "unipile-node-sdk"

// SDK setup
const BASE_URL = "your base url"
const ACCESS_TOKEN = "your access token"
// Inputs
const chat_id = "chat id"

try {
	const client = new UnipileClient(BASE_URL, ACCESS_TOKEN)

	const response = await client.messaging.getChat(chat_id)
} catch (error) {
	console.log(error)
}

```

--------------------------------

### POST /websites/developer_unipile_reference

Source: https://developer.unipile.com/reference/chatscontroller_startnewchat

Initiates a new chat with specified attendees and sends an initial message. Supports different API integrations like Sales Navigator.

```APIDOC
## POST /websites/developer_unipile_reference

### Description
Initiates a new chat with specified attendees and sends an initial message. Supports different API integrations like Sales Navigator.

### Method
POST

### Endpoint
/websites/developer_unipile_reference

### Parameters
#### Request Body
- **account_id** (string) - Required - The Unipile account ID.
- **attendees_ids** (array of strings) - Required - A list of attendee Unipile IDs.
- **subject** (string) - Required - The subject of the initial message.
- **text** (string) - Required - The content of the initial message.
- **scheduled_time** (object) - Required - The time to schedule the message.
  - **weeks** (integer) - Required - The number of weeks in the future to schedule.
  - **timezone** (string) - Required - The timezone for scheduling (e.g., 'Europe/Paris').
- **api** (object) - Optional - Specifies the API integration to use.
  - **api** (string) - Required - The API to use (e.g., 'sales_navigator').

### Request Example
```json
{
  "account_id": "acc_12345",
  "attendees_ids": ["user_abc", "user_def"],
  "subject": "Meeting Request",
  "text": "Hi, let's schedule a meeting.",
  "scheduled_time": {
    "weeks": 1,
    "timezone": "America/New_York"
  },
  "api": {
    "api": "sales_navigator"
  }
}
```

### Response
#### Success Response (201)
- **object** (string) - Type of the created object (ChatStarted).
- **chat_id** (string | null) - The Unipile ID of the newly started chat.
- **message_id** (string | null) - The Unipile ID of the message that started the chat.

#### Response Example
```json
{
  "object": "ChatStarted",
  "chat_id": "chat_xyz789",
  "message_id": "msg_abc123"
}
```

#### Error Response (400)
- **title** (string) - The error title.
- **detail** (string) - A detailed explanation of the error.
- **instance** (string) - The error instance identifier.
- **type** (string) - The type of error (e.g., 'errors/too_many_characters').
- **status** (number) - The HTTP status code (400).

#### Error Response Example
```json
{
  "title": "Bad Request",
  "detail": "The provided content exceeds the character limit.",
  "instance": "/error/instance/123",
  "type": "errors/too_many_characters",
  "status": 400
}
```
```

--------------------------------

### GET /api/v1/chats/{chat_id}/sync

Source: https://developer.unipile.com/reference/chatscontroller_syncchathistory

Synchronize a conversation from its beginning. This route can be used both to initiate a synchronization process and to monitor its status via regular polling.

```APIDOC
## GET /api/v1/chats/{chat_id}/sync

### Description
Synchronize a conversation from its beginning. This route can be used both to initiate a synchronization process and to monitor its status via regular polling.

### Method
GET

### Endpoint
`/api/v1/chats/{chat_id}/sync`

### Parameters
#### Path Parameters
- **chat_id** (string) - Required - The id of the chat to be synced.

### Request Example
```json
{
  "example": "request body"
}
```

### Response
#### Success Response (200)
- **object** (string) - Enum: ["ChatHistorySync"]
- **chat_id** (string) - A unique identifier.
- **status** (string) - Enum: ["SYNC_STARTED", "CHAT_DELETED", "SYNC_RUNNING", "SYNC_DONE", "SYNC_ERROR"] - The status of the chat synchronization. You can setup a regular polling on the same route to get updates on its status. A new request after a SYNC_DONE or SYNC_ERROR response will start a fresh sync.

#### Response Example
```json
{
  "object": "ChatHistorySync",
  "chat_id": "unique_chat_id",
  "status": "SYNC_RUNNING"
}
```

#### Error Response (401)
- **title** (string)
- **detail** (string)
- **instance** (string)
- **type** (string) - Enum: ["errors/missing_credentials", "errors/multiple_sessions", "errors/invalid_checkpoint_solution", "errors/invalid_proxy_credentials", "errors/checkpoint_error", "errors/invalid_credentials", "errors/expired_credentials", "errors/insufficient_privileges", "errors/disconnected_account", "errors/disconnected_feature", "errors/invalid_credentials_but_valid_account_imap", "errors/expired_link", "errors/wrong_account", "errors/captcha_not_supported"]
- **status** (number) - Enum: [401]
- **connectionParams** (object) - Optional - Contains connection parameters for re-authentication.
  - **imap_host** (string)
  - **imap_encryption** (string)
  - **imap_port** (number)

```

--------------------------------

### Messaging Management API

Source: https://developer.unipile.com/reference/chatscontroller_listchatmessages

Endpoints for managing messages, including sending, receiving, and retrieving message history.

```APIDOC
## Messaging Management API

### Description
This section details the API endpoints for managing messages within the Unipile platform. These endpoints allow for sending new messages, retrieving existing messages, and managing message threads.

### Method
GET, POST, PUT, DELETE

### Endpoint
/messaging/{messageId}
/messaging

### Parameters
#### Path Parameters
- **messageId** (string) - Required - The unique identifier for a message.

#### Query Parameters
- **limit** (integer) - Optional - The maximum number of messages to return.
- **offset** (integer) - Optional - The number of messages to skip.

#### Request Body
##### POST /messaging
- **to** (string) - Required - The recipient's identifier.
- **from** (string) - Required - The sender's identifier.
- **subject** (string) - Optional - The subject of the message.
- **body** (string) - Required - The content of the message.

### Request Example
```json
{
  "to": "recipient@example.com",
  "from": "sender@example.com",
  "subject": "Meeting Update",
  "body": "Hello, just a reminder about our meeting tomorrow at 10 AM."
}
```

### Response
#### Success Response (200)
- **messageId** (string) - The unique identifier of the sent or retrieved message.
- **status** (string) - The status of the message (e.g., 'sent', 'delivered', 'read').
- **timestamp** (string) - The time the message was sent or received.

#### Response Example
```json
{
  "messageId": "msg_12345abcde",
  "status": "sent",
  "timestamp": "2023-10-27T10:00:00Z"
}
```
```

--------------------------------

### Perform Chat Action with Unipile Node.js SDK

Source: https://developer.unipile.com/reference/chatscontroller_patchchat

This code sample demonstrates how to perform actions on a chat using the Unipile Node.js SDK. It requires the base URL, access token, chat ID, action type, and a boolean value. The available actions include setting read status, mute status, archive status, and pinned status, with platform-specific limitations noted.

```node
import { UnipileClient } from "unipile-node-sdk"

// SDK setup
const BASE_URL = "your base url"
const ACCESS_TOKEN = "your access token"
// Inputs
const chat_id = "chat id"
const action = "setReadStatus"
const value = true

try {
	const client = new UnipileClient(BASE_URL, ACCESS_TOKEN)

	const response = await client.messaging.performAction({
		chat_id,
		action,
		value,
	})
} catch (error) {
	console.log(error)
}

```

--------------------------------

### Messaging Management API

Source: https://developer.unipile.com/reference/messagescontroller_forwardmessage

Endpoints for managing messaging functionalities, including creating, retrieving, updating, and deleting messages.

```APIDOC
## POST /websites/developer_unipile_reference/messages

### Description
Creates a new message.

### Method
POST

### Endpoint
/websites/developer_unipile_reference/messages

### Parameters
#### Request Body
- **title** (string) - Required - The title of the message.
- **type** (string) - Required - The type of the message.
- **status** (string) - Required - The status of the message.

### Request Example
{
  "title": "Example Message",
  "type": "email",
  "status": "sent"
}

### Response
#### Success Response (200)
- **message_id** (string) - The unique identifier of the created message.

#### Response Example
{
  "message_id": "msg_12345abcde"
}
```

--------------------------------

### Get Chats List via cURL

Source: https://developer.unipile.com/reference/messaging

This snippet demonstrates how to fetch a list of chats from the Unipile API using a cURL request. It includes the necessary headers and the base URL. The response is a JSON object containing a list of chat items, each with detailed properties like ID, account type, and unread count.

```curl
curl --request GET \
     --url https://api1.unipile.com:13111/api/v1/chats \
     --header 'accept: application/json'
```

--------------------------------

### GET /api/v1/chat_attendees/{attendee_id}/chats

Source: https://developer.unipile.com/reference/chatattendeescontroller_listchatsbyattendee

Retrieves a list of all 1-to-1 chats associated with a specific attendee. This endpoint supports pagination and filtering by date, account, and attendee.

```APIDOC
## GET /api/v1/chat_attendees/{attendee_id}/chats

### Description
List all 1to1 chats for a given attendee. Returns a list of chats where a given attendee is involved.

### Method
GET

### Endpoint
/api/v1/chat_attendees/{attendee_id}/chats

### Parameters
#### Path Parameters
- **attendee_id** (string) - Required - The Unipile ID OR provider_id of the attendee. Can be a comma-separated list of multiple ids.

#### Query Parameters
- **cursor** (string) - Optional - A cursor for pagination purposes. To get the next page of entries, you need to make a new request and fulfill this field with the cursor received in the preceding request. This process should be repeated until all entries have been retrieved.
- **before** (string) - Optional - A filter to target items created before the datetime (exclusive). Must be an ISO 8601 UTC datetime (YYYY-MM-DDTHH:MM:SS.sssZ).
- **after** (string) - Optional - A filter to target items created after the datetime (exclusive). Must be an ISO 8601 UTC datetime (YYYY-MM-DDTHH:MM:SS.sssZ).
- **limit** (integer) - Optional - A limit for the number of items returned in the response. The value can be set between 1 and 250.
- **account_id** (string) - Optional - A filter to target items related to a certain account. Can be a comma-separated list of ids.

### Request Example
```json
{
  "example": "No request body for GET requests"
}
```

### Response
#### Success Response (200)
- **object** (string) - Enum: ChatList - Indicates the type of the response object.
- **items** (array) - Contains a list of chat objects.
  - **object** (string) - Enum: Chat - Indicates the type of the item object.
  - **id** (string) - A unique identifier.
  - **account_id** (string) - The Unipile account ID associated with the chat.

#### Response Example
```json
{
  "object": "ChatList",
  "items": [
    {
      "object": "Chat",
      "id": "chat_id_123",
      "account_id": "acc_abc"
    }
  ]
}
```
```

--------------------------------

### GET /api/v1/chat_attendees/{id}/picture

Source: https://developer.unipile.com/reference/chatattendeescontroller_getattendeeprofilepicture

Download the profile picture of a chat attendee or the picture of a group chat.

```APIDOC
## GET /api/v1/chat_attendees/{id}/picture

### Description
Download the profile picture of an attendee or picture of a group chat.

### Method
GET

### Endpoint
/api/v1/chat_attendees/{id}/picture

### Parameters
#### Path Parameters
- **id** (string) - Required - The id of the attendee. Use a chat id to get the picture of a group chat.

### Response
#### Success Response (200)
(No specific details provided in the schema)

#### Error Response (401)
- **title** (string) - Error title
- **detail** (string) - Error detail description
- **instance** (string) - URI that identifies the specific occurrence of the problem.
- **type** (string) - URI that identifies the error, e.g., "errors/missing_credentials"
- **status** (number) - HTTP status code, should be 401
- **connectionParams** (object) - Optional - Connection parameters for certain error types (e.g., IMAP configuration)
  - **imap_host** (string) - IMAP host if applicable
  - **imap_encryption** (string) - IMAP encryption type if applicable

### Error Codes
- **errors/missing_credentials**: Some credentials are necessary to perform the request.
- **errors/multiple_sessions**: LinkedIn limits the use of multiple sessions on certain Recruiter accounts.
- **errors/wrong_account**: The provided credentials do not match the correct account.
- **errors/invalid_credentials**: The provided credentials are invalid.
- **errors/invalid_proxy_credentials**: The provided proxy credentials are invalid.
- **errors/invalid_imap_configuration**: The provided IMAP configuration is invalid.
- **errors/invalid_smtp_configuration**: The provided SMTP configuration is invalid.
- **errors/invalid_checkpoint_solution**: The checkpoint resolution did not pass successfully. Please retry.
- **errors/checkpoint_error**: The checkpoint does not appear to be resolvable. Please try again and contact support if the problem persists.
- **errors/expired_credentials**: Invalid credentials. Please check your username and password and try again.
- **errors/expired_link**: This link has expired. Please return to the application and generate a new one.
- **errors/insufficient_privileges**: This resource seems to be out of your scopes.
- **errors/disconnected_account**: The account appears to be disconnected from the provider service.
- **errors/disconnected_feature**: The service you're trying to reach appears to be disconnected.
- **errors/captcha_not_supported**: We encounter captcha checkpoint, we currently working to manage it
```

--------------------------------

### Messaging Management API

Source: https://developer.unipile.com/reference/chatscontroller_sendmessageinchat

This section covers endpoints related to managing messages within the Unipile platform. It includes operations for sending, receiving, and managing message threads.

```APIDOC
## Messaging Management API

This API allows for the management of messaging functionalities within Unipile.

### Description

Endpoints related to messaging operations, including sending and receiving messages.

### Method

GET, POST, PUT, DELETE

### Endpoint

`/messaging` (example base path, actual paths may vary)

### Parameters

#### Path Parameters

None

#### Query Parameters

None

#### Request Body

_Specific request body details depend on the exact operation (e.g., sending a message would require recipient and content).

### Request Example

```json
{
  "example": "Request body for a messaging operation"
}
```

### Response

#### Success Response (200)

- **message** (string) - A success message.
- **data** (object) - Contains the relevant data for the operation.

#### Response Example

```json
{
  "example": "Success response body for a messaging operation"
}
```

#### Error Response (e.g., 504)

- **title** (string) - The title of the error.
- **type** (string) - The type of error, e.g., `errors/request_timeout`.
- **status** (number) - The HTTP status code, e.g., `504`.
- **detail** (string) - A detailed description of the error.
- **instance** (string) - A specific instance identifier for the error.

#### Error Response Example

```json
{
  "title": "Gateway Timeout",
  "type": "errors/request_timeout",
  "status": 504,
  "detail": "The server did not receive a timely response from an upstream server.",
  "instance": "/websites/developer_unipile_reference"
}
```
```

--------------------------------

### Messaging API

Source: https://developer.unipile.com/reference/chatattendeescontroller_listchatsbyattendee

Endpoints for managing messaging operations within Unipile.

```APIDOC
## Messaging Management

### Description
Provides endpoints for managing messaging operations, including sending and receiving messages.

### Method
GET, POST, PUT, DELETE

### Endpoint
/messaging

### Parameters
#### Path Parameters
None

#### Query Parameters
None

#### Request Body
- **message** (object) - Required - The message payload.
  - **content** (string) - Required - The text content of the message.
  - **recipient** (string) - Required - The identifier of the message recipient.

### Request Example
```json
{
  "message": {
    "content": "Hello from Unipile!",
    "recipient": "user123"
  }
}
```

### Response
#### Success Response (200)
- **status** (number) - Indicates the success status of the operation.
- **messageId** (string) - The unique identifier for the message.

#### Response Example
```json
{
  "status": 200,
  "messageId": "msg_abc123"
}
```

#### Error Response (504)
- **title** (string) - A brief summary of the error.
- **type** (string) - The type of error, e.g., "errors/request_timeout".
- **status** (number) - The HTTP status code, e.g., 504.
- **detail** (string) - A more detailed description of the error.
- **instance** (string) - A URI that identifies this specific occurrence of the problem.
```

--------------------------------

### Messaging Management API

Source: https://developer.unipile.com/reference/chatscontroller_listallchats

This section covers endpoints related to managing messages within the Unipile platform. It includes operations for sending, retrieving, and managing message threads.

```APIDOC
## Messaging Endpoints

### Description
Provides endpoints for managing messaging functionalities, including sending and retrieving messages.

### Method
GET, POST

### Endpoint
/messages

### Parameters
#### Query Parameters
- **limit** (integer) - Optional - The maximum number of messages to return.
- **offset** (integer) - Optional - The number of messages to skip before returning results.

#### Request Body (for POST)
- **recipient** (string) - Required - The recipient's identifier.
- **subject** (string) - Required - The subject of the message.
- **body** (string) - Required - The content of the message.

### Request Example (POST)
```json
{
  "recipient": "user@example.com",
  "subject": "Meeting Update",
  "body": "The meeting has been rescheduled to tomorrow."
}
```

### Response
#### Success Response (200)
- **messages** (array) - An array of message objects.
  - **id** (string) - The unique identifier of the message.
  - **sender** (string) - The sender's identifier.
  - **timestamp** (string) - The time the message was sent.
  - **content** (string) - The content of the message.

#### Response Example (200)
```json
{
  "messages": [
    {
      "id": "msg_123",
      "sender": "system@unipile.com",
      "timestamp": "2023-10-27T10:00:00Z",
      "content": "Your request has been processed."
    }
  ]
}
```
```

--------------------------------

### GET /api/v1/chat_attendees/{sender_id}/messages

Source: https://developer.unipile.com/reference/chatattendeescontroller_listmessagesbyattendee

Retrieves a list of messages for a specified attendee. Supports pagination and filtering by date and account.

```APIDOC
## GET /api/v1/chat_attendees/{sender_id}/messages

### Description
Returns a list of messages where a given attendee is involved.

### Method
GET

### Endpoint
/api/v1/chat_attendees/{sender_id}/messages

### Parameters
#### Path Parameters
- **sender_id** (string) - Required - The Unipile ID OR provider_id of the attendee.

#### Query Parameters
- **cursor** (string) - Optional - A cursor for pagination purposes. To get the next page of entries, you need to make a new request and fulfill this field with the cursor received in the preceding request. This process should be repeated until all entries have been retrieved.
- **before** (string) - Optional - A filter to target items created before the datetime (exclusive). Must be an ISO 8601 UTC datetime (YYYY-MM-DDTHH:MM:SS.sssZ).
- **after** (string) - Optional - A filter to target items created after the datetime (exclusive). Must be an ISO 8601 UTC datetime (YYYY-MM-DDTHH:MM:SS.sssZ).
- **limit** (integer) - Optional - A limit for the number of items returned in the response. The value can be set between 1 and 250.
- **account_id** (string) - Optional - A filter to target items related to a certain account. Can be a comma-separated list of ids.

### Response
#### Success Response (200)
- **object** (string) - Enum: MessageList
- **items** (array) - List of messages.
  - **object** (string) - Enum: Message
  - **provider_id** (string)
  - **sender_id** (string)
  - **text** (string)

#### Response Example
```json
{
  "object": "MessageList",
  "items": [
    {
      "object": "Message",
      "provider_id": "some_provider_id",
      "sender_id": "some_sender_id",
      "text": "Hello!"
    }
  ]
}
```
```

--------------------------------

### Messaging Management API

Source: https://developer.unipile.com/reference/chatattendeescontroller_listmessagesbyattendee

Endpoints for managing messages, including sending, receiving, and retrieving message history.

```APIDOC
## Messaging Management API

### Description
Provides endpoints for managing message-related operations within the Unipile platform. This includes functionalities for sending new messages, retrieving existing message threads, and updating message statuses.

### Method
GET, POST, PUT, DELETE

### Endpoint
/messaging

### Parameters
#### Path Parameters
None

#### Query Parameters
- **limit** (integer) - Optional - The maximum number of messages to return.
- **offset** (integer) - Optional - The number of messages to skip.

#### Request Body
* **message_content** (string) - Required - The content of the message to be sent.
* **recipient_id** (string) - Required - The ID of the recipient.
* **sender_id** (string) - Required - The ID of the sender.

### Request Example
```json
{
  "message_content": "Hello, this is a test message.",
  "recipient_id": "user123",
  "sender_id": "user456"
}
```

### Response
#### Success Response (200)
- **messages** (array) - A list of message objects.
- **message_id** (string) - The unique identifier for the message.
- **timestamp** (string) - The time the message was sent or received.

#### Response Example
```json
{
  "messages": [
    {
      "message_id": "msg789",
      "message_content": "Hi there!",
      "sender_id": "user456",
      "recipient_id": "user123",
      "timestamp": "2023-10-27T10:00:00Z"
    }
  ]
}
```
```

--------------------------------

### Messaging Management API

Source: https://developer.unipile.com/reference/chatscontroller_patchchat

Endpoints for managing messages within the Unipile platform.

```APIDOC
## Messaging Management API

### Description
Endpoints for managing messages within the Unipile platform.

### Method
GET

### Endpoint
/v1/messaging

### Parameters
#### Query Parameters
- **limit** (integer) - Optional - The maximum number of messages to return.
- **offset** (integer) - Optional - The number of messages to skip before returning results.

### Request Example
```json
{
  "example": "GET /v1/messaging?limit=10&offset=0"
}
```

### Response
#### Success Response (200)
- **messages** (array) - A list of message objects.
  - **id** (string) - The unique identifier for the message.
  - **sender** (string) - The identifier of the sender.
  - **recipient** (string) - The identifier of the recipient.
  - **content** (string) - The content of the message.
  - **timestamp** (string) - The timestamp when the message was sent.

#### Response Example
```json
{
  "example": "{\"messages\": [{\"id\": \"msg_123\", \"sender\": \"user_abc\", \"recipient\": \"user_xyz\", \"content\": \"Hello there!\", \"timestamp\": \"2023-10-27T10:00:00Z\"}] }"
}
```
```

--------------------------------

### List Chats by Attendee with Unipile Node SDK

Source: https://developer.unipile.com/reference/chatattendeescontroller_listchatsbyattendee

This code sample demonstrates how to retrieve all 1-to-1 chats associated with a specific attendee using the Unipile Node.js SDK. It requires the Unipile base URL, an access token, and the attendee's ID. The function returns a list of chats or logs an error if the request fails.

```node
import { UnipileClient } from "unipile-node-sdk"

// SDK setup
const BASE_URL = "your base url"
const ACCESS_TOKEN = "your access token"
// Inputs
const attendee_id = "attendee id"

try {
	const client = new UnipileClient(BASE_URL, ACCESS_TOKEN)

	const response = await client.messaging.getAllChatsFromAttendee({
		attendee_id,
	})
} catch (error) {
	console.log(error)
}

```

--------------------------------

### Set Sync Limit API

Source: https://developer.unipile.com/reference/accountscontroller_createaccount

Allows you to set a synchronization limit for chats, messages, or both. The chat limit applies to each inbox, and the message limit applies to each chat. Setting no value reverts to the default behavior without limits. Providers may have partial support for these limits.

```APIDOC
## POST /websites/developer_unipile_reference

### Description
Sets a sync limit for chats, messages, or both.

### Method
POST

### Endpoint
/websites/developer_unipile_reference

### Parameters
#### Request Body
- **chats** (object | number) - Optional - The limit for chats. Can be an ISO 8601 UTC datetime to start sync from or a quantity of data. If a number, 0 will not sync history.
  - **Example for datetime**: "2025-12-31T23:59:59.999Z"
  - **Example for quantity**: 1000
- **messages** (object | number) - Optional - The limit for messages. Can be an ISO 8601 UTC datetime to start sync from or a quantity of data. If a number, 0 will not sync history.
  - **Example for datetime**: "2025-12-31T23:59:59.999Z"
  - **Example for quantity**: 500
- **provider** (string) - Required - The provider for which to set the sync limit. Supported values: "LINKEDIN".
- **proxy** (object) - Optional - Proxy configuration for the connection.
  - **protocol** (string) - Required - The proxy protocol. Supported values: "https", "http", "socks5".
  - **port** (number) - Required - The proxy port.
  - **host** (string) - Required - The proxy host.
  - **username** (string) - Optional - Username for proxy authentication.
  - **password** (string) - Optional - Password for proxy authentication.
- **user_agent** (string) - Optional - The exact user agent of the browser on which the account has been connected. Useful for troubleshooting disconnection issues.
- **recruiter_contract_id** (string) - Optional - The contract ID to be used with Linkedin Recruiter.
- **access_token** (string) - Required - The Linkedin access token (li_at).

### Request Example
```json
{
  "chats": 500,
  "messages": 1000,
  "provider": "LINKEDIN",
  "proxy": {
    "protocol": "https",
    "port": 8080,
    "host": "proxy.example.com",
    "username": "proxy_user",
    "password": "proxy_password"
  },
  "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
  "recruiter_contract_id": "contract-12345",
  "access_token": "li_at_xxxxxxxxxxxxxxxxx"
}
```

### Response
#### Success Response (200)
- **status** (string) - Indicates the success of the operation.
- **message** (string) - A confirmation message.

#### Response Example
```json
{
  "status": "success",
  "message": "Sync limits set successfully."
}
```
```

--------------------------------

### Video Meeting Object

Source: https://developer.unipile.com/reference/chatscontroller_listchatmessages

Represents a video meeting object.

```APIDOC
## Video Meeting Object

### Description
Represents a video meeting object with its associated metadata.

### Properties

- **id** (string) - Required - Unique identifier for the video meeting.
- **unavailable** (boolean) - Required - Indicates if the video meeting is unavailable.
- **type** (string) - Required - Must be 'video_meeting'.
- **file_size** (number) - Optional - The size of the video meeting recording.
- **mimetype** (string) - Optional - The MIME type of the video meeting recording.
- **url** (string) - Optional - The URL to access the video meeting recording.
- **url_expires_at** (number) - Optional - Timestamp when the video meeting URL expires.
- **starts_at** (number) - Optional - Timestamp when the video meeting starts.
- **expires_at** (number) - Optional - Timestamp when the video meeting expires.
```

--------------------------------

### PATCH /api/v1/chats/{chat_id}

Source: https://developer.unipile.com/reference/chatscontroller_patchchat

Perform an action on a given chat, such as changing its read status, mute status, archive status, or pinned status.

```APIDOC
## PATCH /api/v1/chats/{chat_id}

### Description
Perform an action like changing the read status, muting the chat, etc.

### Method
PATCH

### Endpoint
`/api/v1/chats/{chat_id}`

### Parameters
#### Path Parameters
- **chat_id** (string) - Required - The id of the chat to be patched

#### Request Body
- **action** (string) - Required - The action to perform on the chat: `setReadStatus`, `setMuteStatus`, `setArchiveStatus`, `setPinnedStatus`
- **value** (boolean) - Required - The value to set for the action (e.g., true for read, false for unread).

### Request Example
```json
{
  "action": "setReadStatus",
  "value": true
}
```

### Response
#### Success Response (200)
- **object** (string) - Indicates the object type, expected to be `ChatPatched`.

#### Response Example
```json
{
  "object": "ChatPatched"
}
```
```

--------------------------------

### Conversations API

Source: https://developer.unipile.com/reference/chatattendeescontroller_listchatsbyattendee

This section details the structure of conversation objects, including account types, provider IDs, names, types, timestamps, unread counts, and archiving/muting status.

```APIDOC
## Conversations API Details

### Description
This API provides details about conversation objects within the Unipile platform. It includes information about various account types, identifiers, conversation metadata, and user interaction metrics.

### Parameters
#### Request Body (Example Structure)
- **id** (string) - Required - A unique identifier.
- **account_type** (string) - Required - The type of account (e.g., WHATSAPP, LINKEDIN, SLACK, TWITTER, MESSENGER, INSTAGRAM, TELEGRAM).
- **provider_id** (string) - Required - The identifier provided by the service provider.
- **attendee_provider_id** (string) - Required - The identifier for the attendee from the service provider.
- **name** (string/nullable) - Optional - The name associated with the conversation.
- **type** (number) - Required - The type of conversation (e.g., 0, 1, 2).
- **timestamp** (string/nullable) - Optional - The timestamp of the last message or event.
- **unread_count** (number) - Required - The number of unread messages in the conversation.
- **archived** (number) - Required - Indicates if the conversation is archived (0 for false, 1 for true).
- **muted_until** (number/string/nullable) - Optional - Indicates until when the conversation is muted (-1 for never, or a timestamp string).

### Response
#### Success Response (200)
- **id** (string) - A unique identifier.
- **account_type** (string) - The type of account (e.g., WHATSAPP, LINKEDIN, SLACK, TWITTER, MESSENGER, INSTAGRAM, TELEGRAM).
- **provider_id** (string) - The identifier provided by the service provider.
- **attendee_provider_id** (string) - The identifier for the attendee from the service provider.
- **name** (string/nullable) - The name associated with the conversation.
- **type** (number) - The type of conversation (e.g., 0, 1, 2).
- **timestamp** (string/nullable) - The timestamp of the last message or event.
- **unread_count** (number) - The number of unread messages in the conversation.
- **archived** (number) - Indicates if the conversation is archived (0 for false, 1 for true).
- **muted_until** (number/string/nullable) - Indicates until when the conversation is muted (-1 for never, or a timestamp string).

#### Response Example
```json
{
  "id": "conv_12345",
  "account_type": "WHATSAPP",
  "provider_id": "wp_provider_abc",
  "attendee_provider_id": "wp_attendee_xyz",
  "name": "John Doe",
  "type": 0,
  "timestamp": "2023-10-27T10:00:00Z",
  "unread_count": 5,
  "archived": 0,
  "muted_until": null
}
```
```

--------------------------------

### List Chat Attendees with unipile-node-sdk

Source: https://developer.unipile.com/reference/chatscontroller_listattendees

This Node.js code snippet demonstrates how to list all attendees from a specific chat using the unipile-node-sdk. It requires the base URL, access token, and the chat ID as input. Ensure the SDK is installed via npm.

```node
import { UnipileClient } from "unipile-node-sdk"

// SDK setup
const BASE_URL = "your base url"
const ACCESS_TOKEN = "your access token"
// Inputs
const chat_id = "chat id"

try {
	const client = new UnipileClient(BASE_URL, ACCESS_TOKEN)

	const response = await client.messaging.getAllAttendeesFromChat(chat_id)
} catch (error) {
	console.log(error)
}

```

--------------------------------

### GET /api/v1/chat_attendees

Source: https://developer.unipile.com/reference/chatattendeescontroller_listallattendees

Returns a list of messaging attendees. Optional parameters are available to filter the results.

```APIDOC
## GET /api/v1/chat_attendees

### Description
Returns a list of messaging attendees. Some optional parameters are available to filter the results.

### Method
GET

### Endpoint
/api/v1/chat_attendees

### Parameters
#### Query Parameters
- **cursor** (string) - Optional - A cursor for pagination purposes. To get the next page of entries, you need to make a new request and fulfill this field with the cursor received in the preceding request. This process should be repeated until all entries have been retrieved.
- **limit** (integer) - Optional - A limit for the number of items returned in the response. The value can be set between 1 and 250.
- **account_id** (string) - Optional - A filter to target attendees related to a certain linked account. The id of the account targeted.

### Response
#### Success Response (200)
- **object** (string) - Must be "ChatAttendeeList".
- **items** (array) - An array of chat attendee objects.
  - **object** (string) - Must be "ChatAttendee".
  - **id** (string) - A unique identifier.
  - **account_id** (string) - A unique identifier.
  - **provider_id** (string) - The ID of the provider.
  - **name** (string) - The name of the attendee.
  - **is_self** (number) - Indicates if the attendee is the current user (1 for true, 0 for false).
  - **hidden** (number) - Indicates if the attendee is hidden (1 for true, 0 for false).

#### Response Example
```json
{
  "object": "ChatAttendeeList",
  "items": [
    {
      "object": "ChatAttendee",
      "id": "a1b2c3d4e5f6",
      "account_id": "account-xyz",
      "provider_id": "provider-123",
      "name": "John Doe",
      "is_self": 0,
      "hidden": 0
    }
  ]
}
```
```

--------------------------------

### List Messages by Attendee (Node.js SDK)

Source: https://developer.unipile.com/reference/chatattendeescontroller_listmessagesbyattendee

This code snippet demonstrates how to retrieve all messages for a specific attendee using the Unipile Node.js SDK. It requires the base URL, an access token, and the attendee's ID. The function returns a list of messages or logs an error if the request fails. It utilizes the `unipile-node-sdk` package.

```node
import { UnipileClient } from "unipile-node-sdk"

// SDK setup
const BASE_URL = "your base url"
const ACCESS_TOKEN = "your access token"
// Inputs
const attendee_id = "attendee id"

try {
	const client = new UnipileClient(BASE_URL, ACCESS_TOKEN)

	const response = await client.messaging.getAllMessagesFromAttendee({
		attendee_id,
	})
} catch (error) {
	console.log(error)
}

```

--------------------------------

### Messaging Management API

Source: https://developer.unipile.com/reference/chatattendeescontroller_getattendeebyid

This section covers endpoints related to managing messages within the Unipile platform.

```APIDOC
## Messaging Management API

### Description
Endpoints for managing and interacting with messages.

### Method
GET, POST, PUT, DELETE

### Endpoint
/messages

### Parameters
#### Query Parameters
- **limit** (integer) - Optional - The maximum number of messages to return.
- **offset** (integer) - Optional - The number of messages to skip before starting to collect the result set.

### Request Example
```json
{
  "limit": 10,
  "offset": 0
}
```

### Response
#### Success Response (200)
- **messages** (array) - A list of message objects.
- **total** (integer) - The total number of messages available.

#### Response Example
```json
{
  "messages": [
    {
      "id": "msg_123",
      "sender": "user@example.com",
      "recipient": "agent@example.com",
      "content": "Hello, how can I help you?",
      "timestamp": "2023-10-27T10:00:00Z"
    }
  ],
  "total": 50
}
```
```

--------------------------------

### Resynchronize Account Data with Unipile Node SDK

Source: https://developer.unipile.com/reference/accountscontroller_resyncaccount

Initiates or monitors the resynchronization of messaging data for a given account. This sample uses the unipile-node-sdk to connect to the Unipile API. Ensure you have the SDK installed (`npm install unipile-node-sdk`) and provide your base URL and access token. The function takes an `account_id` as input and returns the synchronization status.

```node
import { UnipileClient } from "unipile-node-sdk"

// SDK setup
const BASE_URL = "your base url"
const ACCESS_TOKEN = "your access token"
// Inputs
const account_id = "account id"

try {
	const client = new UnipileClient(BASE_URL, ACCESS_TOKEN)

	const response = await client.account.getOne(account_id)
} catch (error) {
	console.log(error)
}

```

--------------------------------

### Sync Limit Configuration

Source: https://developer.unipile.com/reference/accountscontroller_reconnectaccount

Allows setting sync limits for chats and messages, with options for date-time or quantity.

```APIDOC
## PUT /websites/developer_unipile_reference/sync_limit

### Description
Configures the sync limit for chats and messages. Limits can be set by date or quantity.

### Method
PUT

### Endpoint
/websites/developer_unipile_reference/sync_limit

### Parameters
#### Request Body
- **sync_limit** (object) - Set a sync limit either for chats, messages or both.
  - **chats** (object | number) - Either a UTC Datetime to start sync from, or a quantity of data.
    - **description** (string) - An ISO 8601 UTC datetime (YYYY-MM-DDTHH:MM:SS.sssZ) or a quantity of data.
    - **example** (string) - "2025-12-31T23:59:59.999Z"
    - **pattern** (string) - "^[1-2]\d{3}-[0-1]\d-[0-3]\dT\d{2}:\d{2}:\d{2}.\d{3}Z$"
    - **minimum** (number) - 0
  - **messages** (object | number) - Either a UTC Datetime to start sync from, or a quantity of data.
    - **description** (string) - An ISO 8601 UTC datetime (YYYY-MM-DDTHH:MM:SS.sssZ) or a quantity of data.
    - **example** (string) - "2025-12-31T23:59:59.999Z"
    - **pattern** (string) - "^[1-2]\d{3}-[0-1]\d-[0-3]\dT\d{2}:\d{2}:\d{2}.\d{3}Z$"
    - **minimum** (number) - 0

### Request Example
```json
{
  "sync_limit": {
    "chats": 100,
    "messages": "2024-01-01T00:00:00.000Z"
  }
}
```

### Response
#### Success Response (200)
- **message** (string) - Confirmation message.

#### Response Example
```json
{
  "message": "Sync limit updated successfully."
}
```
```

--------------------------------

### Messaging Management API

Source: https://developer.unipile.com/reference/chatscontroller_getchat

This section details the APIs related to messaging management. It includes endpoints for sending messages and handling potential gateway timeouts.

```APIDOC
## Gateway Timeout

### Description
Handles gateway timeout errors. This typically occurs when a request times out on the server.

### Method
N/A (Error Response)

### Endpoint
N/A (Error Response)

### Parameters
N/A

### Request Example
N/A

### Response
#### Success Response (504)
- **title** (string) - A short, human-readable summary of the error.
- **detail** (string) - A more detailed explanation of the error.
- **instance** (string) - A URI that identifies the specific occurrence of the error.
- **type** (string) - A URI that identifies the error type. Expected value: "errors/request_timeout".
- **status** (number) - The HTTP status code for the error. Expected value: 504.

#### Response Example
```json
{
  "title": "Gateway Timeout",
  "detail": "Request timed out. Please try again, and if the issue persists, contact support.",
  "instance": "/error/instance/12345",
  "type": "errors/request_timeout",
  "status": 504
}
```
```

--------------------------------

### GET /api/v1/messages/{message_id}/attachments/{attachment_id}

Source: https://developer.unipile.com/reference/messagescontroller_getattachment

Retrieve an attachment from a message. This endpoint allows you to fetch a specific attachment linked to a particular message.

```APIDOC
## GET /api/v1/messages/{message_id}/attachments/{attachment_id}

### Description
Retrieve one of the attachment linked to a message.

### Method
GET

### Endpoint
/api/v1/messages/{message_id}/attachments/{attachment_id}

### Parameters
#### Path Parameters
- **attachment_id** (string) - Required - The id of the wanted attachment.
- **message_id** (string) - Required - The id of the message to which the attachment is linked.

### Request Example
```json
{
  "example": "request body"
}
```

### Response
#### Success Response (200)
- **binary** (string) - The content of the attachment.

#### Response Example
```json
{
  "example": "response body"
}
```

#### Error Response
- **401**: Unauthorized. This could be due to missing or invalid credentials, multiple sessions, wrong account, expired credentials, insufficient privileges, or disconnected accounts/features. Specific error types include:
  - errors/missing_credentials
  - errors/multiple_sessions
  - errors/wrong_account
  - errors/invalid_credentials
  - errors/invalid_proxy_credentials
  - errors/invalid_imap_configuration
  - errors/invalid_smtp_configuration
  - errors/invalid_checkpoint_solution
  - errors/checkpoint_error
  - errors/expired_credentials
  - errors/expired_link
  - errors/insufficient_privileges
  - errors/disconnected_account
  - errors/disconnected_feature
  - errors/captcha_not_supported
```

--------------------------------

### Provider Configuration

Source: https://developer.unipile.com/reference/accountscontroller_reconnectaccount

Specifies the provider for the service, with Instagram as a current option.

```APIDOC
## PUT /websites/developer_unipile_reference/provider

### Description
Configures the service provider. Currently supports Instagram.

### Method
PUT

### Endpoint
/websites/developer_unipile_reference/provider

### Parameters
#### Request Body
- **provider** (string) - The provider for the service.
  - **enum** - ["INSTAGRAM"]

### Request Example
```json
{
  "provider": "INSTAGRAM"
}
```

### Response
#### Success Response (200)
- **message** (string) - Confirmation message.

#### Response Example
```json
{
  "message": "Provider updated successfully."
}
```
```

--------------------------------

### Account and Proxy Configuration

Source: https://developer.unipile.com/reference/accountscontroller_createaccount

This section details the configuration options for various social media accounts, including Instagram and Messenger. It covers proxy settings, user agent, session IDs, and synchronization limits.

```APIDOC
## Instagram Account Configuration

### Description
Configuration details for an Instagram account, including provider, session ID, and optional proxy settings.

### Method
N/A (Configuration Structure)

### Endpoint
N/A (Configuration Structure)

### Parameters
#### Request Body
- **provider** (string) - Required - Must be 'INSTAGRAM'.
- **sessionid** (string) - Required - Instagram session ID.
- **proxy** (object) - Optional - Proxy configuration for the account.
  - **protocol** (string) - Enum: ['https', 'http', 'socks5'] - The protocol for the proxy.
  - **port** (number) - Required - The port number for the proxy.
  - **host** (string) - Required - The host address for the proxy.
  - **username** (string) - Optional - Username for proxy authentication.
  - **password** (string) - Optional - Password for proxy authentication.
- **user_agent** (string) - Optional - The exact user agent of the browser used for connection, recommended for troubleshooting disconnection issues.

### Request Example
```json
{
  "provider": "INSTAGRAM",
  "sessionid": "YOUR_SESSION_ID",
  "proxy": {
    "protocol": "https",
    "port": 8080,
    "host": "proxy.example.com",
    "username": "proxy_user",
    "password": "proxy_password"
  },
  "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}
```

### Response
#### Success Response (200)
N/A (Configuration Structure)

#### Response Example
N/A (Configuration Structure)

## Messenger Account Configuration

### Description
Configuration details for a Messenger account, including location, disabled features, and synchronization limits.

### Method
N/A (Configuration Structure)

### Endpoint
N/A (Configuration Structure)

### Parameters
#### Request Body
- **country** (string) - Optional - An ISO 3166-1 A-2 country code for the proxy's location.
- **ip** (string) - Optional - An IPv4 address to infer the proxy's location.
- **disabled_features** (array) - Optional - An array of features to disable for this account. Items can be: 'linkedin_recruiter', 'linkedin_sales_navigator', 'linkedin_organizations_mailboxes'.
- **sync_limit** (object) - Optional - Set a synchronization limit for chats or messages.
  - **chats** (object or number) - Optional - Either a UTC Datetime (ISO 8601) to start sync from, or a quantity of data. Example: \"2025-12-31T23:59:59.999Z\" or 1000.
  - **messages** (object or number) - Optional - Either a UTC Datetime (ISO 8601) to start sync from, or a quantity of data. Example: \"2025-12-31T23:59:59.999Z\" or 500.

### Request Example
```json
{
  "country": "US",
  "disabled_features": ["linkedin_recruiter"],
  "sync_limit": {
    "chats": "2025-12-31T23:59:59.999Z",
    "messages": 500
  }
}
```

### Response
#### Success Response (200)
N/A (Configuration Structure)

#### Response Example
N/A (Configuration Structure)
```

--------------------------------

### GET /api/v1/chats/{chat_id}/attendees

Source: https://developer.unipile.com/reference/chatscontroller_listattendees

Retrieves a list of all attendees from a specified chat. This endpoint allows for fetching chat participants and includes optional parameters for filtering.

```APIDOC
## GET /api/v1/chats/{chat_id}/attendees

### Description
List all attendees from a chat. Returns a list of messaging attendees related to a given chat. Some optional parameters are available to filter the results.

### Method
GET

### Endpoint
/api/v1/chats/{chat_id}/attendees

### Parameters
#### Path Parameters
- **chat_id** (string) - Required - The id of the chat related to requested attendees.

### Response
#### Success Response (200)
- **object** (string) - Enum: "ChatAttendeeList"
- **items** (array) - List of chat attendees.
  - **object** (string) - Enum: "ChatAttendee"
  - **id** (string) - A unique identifier.
  - **account_id** (string) - A unique identifier.
  - **provider_id** (string)
  - **name** (string)
  - **is_self** (number) - Enum: 1 or 0
  - **hidden** (number) - Enum: 1 or 0
  - **picture_url** (string)
  - **profile_url** (string)
  - **specifics** (object) - Provider specific additional data.
    - **provider** (string) - Enum: "LINKEDIN"
    - **member_urn** (string)

#### Response Example
```json
{
  "object": "ChatAttendeeList",
  "items": [
    {
      "object": "ChatAttendee",
      "id": "61e21007e4b062861e36e557",
      "account_id": "61e21007e4b062861e36e557",
      "provider_id": "urn:li:person:aBcDeFgHiJ",
      "name": "Jane Doe",
      "is_self": 0,
      "hidden": 0,
      "picture_url": "https://example.com/picture.jpg",
      "profile_url": "https://example.com/profile.html",
      "specifics": {
        "provider": "LINKEDIN",
        "member_urn": "urn:li:person:aBcDeFgHiJ"
      }
    }
  ]
}
```
```