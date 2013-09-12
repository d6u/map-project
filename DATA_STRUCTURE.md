# Data Structures

## PostgreSQL (TODO)

## MongoDB

### Notice - collection

#### Intro

Notices will first be stored in MongoDB then pushed to related sockets through Node.js server.

#### Brief

Fields       | Type    | Description
------       | ----    | -----------
id           | String  | MongoDB default ID field, note id is string extracted from MongoDB id object
type         | String  | Specify type of a notice*
sender       | Hash    | Store basic sender(user) information: __id, name, fb_user_picture__
receiver_id  | Integer | Receiver's id, if specified, this notice will be send to specified user
body         | Hash    | Dynamic notice object, contents varies by notice type (see more in explanation of notice type)

_*: valid type include:_

* `addFriendRequest`
* `addFriendRequestAccepted`
* `newChatMessage`
* `projectInvitation`
* `projectInvitationAccepted`
* `projectInvitationRejected`
* `newPlaceAdded`
* `newUserAdded`
* `projectPlaceListUpdated`
* `projectUserListUpdated`
* `projectAttributesUpdated`
* `youAreRemovedFromProject`
* `projectDeleted`

_A detail explanation of each notice type can be found following this section_


#### Detailed Explanation of Notice Type

_*: "Rails" field marked methods generate specific notice (notices will be sent to Node.js server and distributed to clients)_

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

---

##### TODO: the following needs to be updated

1. _newChatMessage_

        project: project_id,
        body: {
          sample_message_content: String,
          unread_count: Integer
        }




1. _newPlaceAdded_

        project: project_id,
        body: {
          place: {
            name: String,
            address: String,
            notes: String
          }
        }

1. _projectPlaceListUpdated_

        project: project_id,
        body: {
          project: {
            name: String
          }
        }

1. _projectUserListUpdated_

        project: project_id,
        body: {
          project: {
            name: String
          }
        }

1. _projectAttributesUpdated_

        project: project_id,
        body: {
          project: {
            name: String,
            notes: String
          }
        }

1. _youAreRemovedFromProject_

        receiver: user_id,
        body: {
          project: {
            name: String
          }
        }

1. _projectDeleted_

        receiver: user_id,
        body: {
          project: {
            name: String
          }
        }
