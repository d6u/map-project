# Notice Data Structure

## Intro

"Notice" refers to notification that send to particular user that informs he/she with information that are not observable through current interface. Most often, notices will be stored in database before user interactive it them. When users become online, notices them received offline will be delivered to them.

## Technology Dependencies

* ~~MongoDB: used to store notice~~
* PostgreSQL: notices relies on PG's JSON data type, so no other database can replace it
* Redis: transfer notice from Rails to Node.js using Pub/Sub
* Node.js: host WebSocket server
* WebSocket: deliver notice in real time to users

## Details

### Categories

#### Action Needed

Notice belongs to this category will not be destroyed before user make a decision on it.

#### No Action Needed

Notice will be destroyed after user "read" it. How "read" is defined depends on client side interface design.

#### Aggregated

New notice will cause old, unread notice being destroyed if notice is from the same group/type. The definition of "same" depends on the context.

## Database Entries

Notices will first be stored in ~~MongoDB~~ PostgreSQL then pushed to related sockets through Node.js server.

Fields       | Type    | Description
------       | ----    | -----------
id           | Integer |
notice_type  | Integer | Specify type of a notice* (not null)
sender_id    | Integer | Foreign key to User (not null)
receiver_id  | Integer | Foreign key to User (not null)
project_id   | Integer | Foreign key to Project
content      | JSON    | Dynamic object, content varies by notice type (see more in explanation of notice type)

### Valid types include:

Generally action needed notice will have its signle digits less than 5. Notice with same higher digits belongs to the same type group.

_A detail explanation of each notice type can be found following this section_

`notice_type` code | Type                        | Action Needed | No Action Needed | Aggregated | `project_id` required
------------------ | ----                        | ------------- | ---------------- | ---------- | ---------------------
0                  | `addFriendRequest`          | x             |                  |            |
5                  | `addFriendRequestAccepted`  |               | x                |            |
10                 | `projectInvitation`         | x             |                  |            | x
15                 | `projectInvitationAccepted` |               | x                |            | x
16                 | `projectInvitationRejected` |               | x                |            | x
25                 | `newUserAdded`              |               | x                |            | x
26                 | `projectUserListUpdated`    |               | x                |            | x
35                 | `projectPlaceListUpdated`   |               | x                | x          | x
36                 | `projectAttributesUpdated`  |               | x                | x          | x
45                 | `youAreRemovedFromProject`  |               | x                |            | x
46                 | `projectDeleted`            |               | x                |            |
55                 | `newChatMessage`            |               | x                | x          | x
