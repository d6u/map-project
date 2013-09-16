# Notice Structure

## Intro

"Notice" refers to notification that send to user which informs users with information that are not observable through current interface. When user is not online, notices will be stored in database and delivered to users when they becomes online.

## Technologies

* MongoDB: used to store notice
* Redis: transfer notice from Rails to Node.js using Sub/Pub
* Node.js: host WebSocket server
* WebSocket: deliver notice in real time to users

## Details

### Categories

#### Point to Point vs. Project notice

Project notice will not be presented to users if there is notice from the same categories, from the same project, for the same use, is existing already. In short, user will not receive notices from one project repeatedly.

Delivery of P2P notice will not be affected by other notices.

_* Note if a notice is not meant to be delivered to user, it will not be saved into database._

#### No Action Required vs. Action Required notice

No action require notice will be removed from database once user "read" the notice on client side.

Action require notice need specific user action to disappear.

_* The definition of "read" is subject to interpretation of client side design.

#### Server Generated vs. User Generated notice

Server generated notice is create alone side with database operations. E.g. user is being invited to join a project.

A typical user generated notice is chat messages that user send in a project. __The lifecycle of user generated notice is different from other types of notice. Details will be explained below.__

## Database Entries

Notices will first be stored in MongoDB then pushed to related sockets through Node.js server.

Fields       | Type    | Description
------       | ----    | -----------
id           | String  | MongoDB default ID field, note id is string extracted from MongoDB id object
type         | String  | Specify type of a notice*
sender       | Hash    | Store basic sender(user) information: __id, name, fb_user_picture__
receiver_id  | Integer | Receiver's id, if specified, this notice will be send to specified user
project_id   | Integer | Identify which project this notice belongs to
body         | Hash    | Dynamic object, content varies by notice type (see more in explanation of notice type)

### Valid types include:

Type                        | P2P | Project | No Action | Action | Server | User
----                        | --- | ------- | --------- | ------ | ------ | ----
`addFriendRequest`          | x   |         |           | x      | x      |
`addFriendRequestAccepted`  | x   |         | x         |        | x      |
`newChatMessage`            |     | x       | x         |        |        | x
`projectInvitation`         | x   |         |           | x      |        | x
`projectInvitationAccepted` | x   |         | x         |        | x      |
`projectInvitationRejected` | x   |         | x         |        | x      |
`newPlaceAdded`             |     | x       | x         |        |        | x
`newUserAdded`              | x   |         | x         |        | x      |
`projectPlaceListUpdated`   |     | x       | x         |        |        | x
`projectUserListUpdated`    |     | x       | x         |        | x      |
`projectAttributesUpdated`  |     | x       | x         |        |        | x
`youAreRemovedFromProject`  | x   |         | x         |        | x      |
`projectDeleted`            | x   |         | x         |        | x      |

_A detail explanation of each notice type can be found following this section_

## Notice Life Cycle

Life cycle between server and user generated notice.

### Server Generated

1. User first invokes some client side actions which alters database base records (in SQL database), whose operation is performed by Rails server. 
2. Then Rails create a notice record in MongoDB. 
3. After creation, notice is published to Redis channel and subscribed by Node server.
4. Finally delivered to specified receiver (receiver_id).

### User Generated

1. Client will first send data to Node server.
2. Node server simply wrap the data into a simple notice (notice will not be saved into MongoDB), and send to related users (whether display to notice or not is subject to client side design)
3. Node server publish this simple notice to Redis, and other server will handle the record saving process. E.g. chat history saving (TODO).
4. After records are saved into database, a notice in MongoDB will be created to send back to Node server to be delivered to users just like server generated data.

## Entry Specifications (TODO)

_*: "Rails" field mark the method that generate the specific notice (notices will be sent to Node.js server and distributed to clients)_

1. _addFriendRequest_

   Rails: __FriendshipsController#create__

        body: {
	      friendship_id: Integer
	    }

1. _addFriendRequestAccepted_

   Rails: __NotificationsController#accept_friend_request__

        body: {
          friendship_id: Integer
        }

1. _projectInvitation_

   Rails: __ProjectsController#add_users__

        body: {
          project_participation_id: Integer,
          project: {
            id: Integer,
            title: String,
            notes: String
          }
        }

1. _projectInvitationAccepted_

   Rails: __NotificationsController#accept_project_invitation__

        body: {
          project_participation_id: Integer,
          project: {
            id: Integer,
            title: String,
            notes: String
          }
        }

1. _projectInvitationRejected_

   Rails: __NotificationsController#reject_project_invitation__

        body: {
          project: {
            id: Integer,
            title: String,
            notes: String
          }
        }

1. _newUserAdded_

   Rails: __NotificationsController#accept_project_invitation__

        body: {
          new_user: {
            id: Integer,
            name: String,
            fb_user_picture: String
          },
          project: {
            id: Integer,
            title: String,
            notes: String
          }
        }
