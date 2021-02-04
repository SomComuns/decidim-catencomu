# Connecting Decidim + CiViCRM

## What is CiViCRM?

CiViCRM is a Drupal-based CRM.

## OAuth

Drupal has the oauth2-server module which implements the server logic so that other applications can sign in users with their CiViCRM data.

To set up Decidim to work with this OAuth2 module, we must set up an OmniAuth strategy (see `lib/omniauth/strategies/civicrm.rb`). Which uses the following fields:

- `uid` (which contains the unique user ID) is provided in the `raw_info` hash (returned by the `UserInfo` endpoint), inside the `sub` key
- `email` and `picture` (the user's profile picture) are also provided in the `raw_info` hash
- With the given `uid`, a request is made to the CiViCRM API to obtain the `name` and `nickname` fields for the user (which are not present in the response from `UserInfo`)

This allows Decidim to use this strategy to sign in and log in users from CiViCRM.

### Setup in current project

Load the following environment variables:

```sh
CIVICRM_SITE=<Drupal/CiViCRM site URL>
CIVICRM_CLIENT_ID=<OAuth2 Server client id>
CIVICRM_CLIENT_SECRET=<OAuth2 Server client secret>
```

## Authorization

Different kinds of authorization are available to restrict certain actions for users that meet some particular criteria:

The CiViCRM Group authorization checks that the given user belongs to a certain "smart group" in the CiViCRM database. The active groups are available in the [admin section for Decidim users](http://localhost:3000/admin/authorization_workflows)

## CiViCRM API

This project uses the [REST interface for the CiViCRM API](https://docs.civicrm.org/dev/en/latest/api/interfaces/#rest).

Requests are all made to the same base url (https://www.example.org/path/to/civi/codebase/civicrm/extern/rest.php) and query parameters define the results a given request will return.

### Mandatory parameters

- `entity`: the name of the object to be retrieved (e.g. `"User"`)
- `action`: the name of the action (e.g. `"Get"`)
- `api_key`: key to identify the client making the request
- `key`: secret key paired to the `api_key`

### Additional parameters

- `json`: this can be passed either `1` or a json object to fine-tune the query, such as:
  - `sequential`: whether the results should be returned as an array (as opposed to a hash), to be passed `1`
  - `options`: additional options (use `"options": { "limit": 0 }` to include all results (default limit is 25))
  - `return`: a string with the fields we want to retrieve from the object, separated by commas (e.g `"roles,display_name"`)

### Example requests

#### Get a User

```json
action=Get&
api_key=<api_key>&
key=<secret>&
entity=User&
id=42&
json={
  "sequential": 1
}

// response:
{
  "is_error": 0,
  "version": 3,
  "count": 1,
  "id": 42,
  "values": {
    "42": {
      "id": "42",
      "name": "arthur.dent",
      "email": "arthurdent@example.com",
      "contact_id": "9999"
    }
  }
}
```

#### Get a Contact with its related Regional Scope data (which is stored inside the Address object with the name `"custom_23"`)

```json
action=Get&
api_key=<api_key>&
key=<secret>&
entity=Contact&
contact_id=9999&
json={
  "sequential": 1,
  "return": "roles,display_name",
  "api.Address.get": { "return": "custom_23" }
}

// response:
{
  "is_error": 0,
  "version": 3,
  "count": 1,
  "id": 9999,
  "values": [
    {
      "contact_id": "9999",
      "display_name": "Sir Arthur Dent",
      "id": "9999",
      "api.Address.get": {
        "is_error": 0,
        "version": 3,
        "count": 1,
        "id": 888,
        "values": [
          {
            "id": "888",
            "custom_23": "AT012"
          }
        ]
      },
      "roles": {
        "2": "authenticated user",
        "3": "administrator"
      }
    }
  ]
}
```

#### Get all user groups

```json
action=Get&
api_key=<api_key>&
key=<secret>&
entity=Group&
json={
  "sequential":1,
  "options": { "limit": 0 }
}

// response:
{
  "is_error": 0,
  "version": 3,
  "count": 2,
  "values": [
    {
      "id": "1",
      "name": "Administrators",
      "title": "Administrators",
      "description": "The users in this group are assigned admin privileges.",
      "is_active": "1",
      "visibility": "User and User Admin Only",
      "group_type": [
        "1"
      ],
      "is_hidden": "0",
      "is_reserved": "0"
    },
    {
      "id": "2",
      "name": "Another_Group",
      "title": "Another Group",
      "description": "...",
      "is_active": "1",
      "visibility": "User and User Admin Only",
      "group_type": "2",
      "is_hidden": "0",
      "is_reserved": "0"
    }
  ]
}
```

#### Get all contacts in a group

```json
action=Get&
api_key=<api_key>&
key=<secret>&
entity=Contact&
json={
  "sequential": 1,
  "options": { "limit": 0 },
  "return": "id,display_name,group",
  "group": "Another_Group",
  "api.Usercat.get": { "return": "id" }
}

// response:
{
  "is_error": 0,
  "version": 3,
  "count": 3,
  "values": [
    {
      "contact_id": "9999",
      "display_name": "Sir Arthur Dent",
      "contact_is_deleted": "0",
      "groups": ",2",
      "id": "9999",
      "api.Usercat.get": {
        "is_error": 0,
        "version": 3,
        "count": 1,
        "id": 42,
        "values": [
          {
            "id": "42",
            "name": "arthur.dent",
            "email": "arthurdent@example.com",
            "contact_id": "9999"
          }
        ]
      }
    },
    {
      "contact_id": "777",
      "display_name": " Zaphod Beeblebrox",
      "contact_is_deleted": "0",
      "groups": ",2",
      "id": "777",
      "api.Usercat.get": {
        "is_error": 0,
        "version": 3,
        "count": 1,
        "id": 36,
        "values": [
          {
            "id": "36",
            "name": "i_am_zaphod",
            "email": "zaphod_beeblebrox_1977@example.com",
            "contact_id": "777"
          }
        ]
      }
    },
    {
      "contact_id": "6",
      "display_name": "Marvin",
      "contact_is_deleted": "0",
      "groups": ",2",
      "id": "6",
      "api.Usercat.get": {
        "is_error": 0,
        "version": 3,
        "count": 1,
        "id": 101,
        "values": [
          {
            "id": "101",
            "name": "marvin_sad",
            "email": "marvin@whatever.net",
            "contact_id": "6"
          }
        ]
      }
    }
  ]
}
```

### Setup current project to use CiViCRM API

Load the following environment variables:

```sh
CIVICRM_VERIFICATION_URL=<REST API endpoint URL>
CIVICRM_VERIFICATION_API_KEY=<CiViCRM API client key>
CIVICRM_VERIFICATION_SECRET=<CiViCRM API secret key>
```

### Other links

CiViCRM API V3 Usage
https://docs.civicrm.org/dev/en/latest/api/v3/usage/

CiViCRM API Explorer
https://docs.civicrm.org/dev/en/latest/api/#api-explorer