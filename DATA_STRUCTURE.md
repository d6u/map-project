# Data Structures

## PostgreSQL (TODO)

## MongoDB

### Notice - collection

Fields    | Type    | Description
------    | ----    | -----------
_id       |         | MongoDB default ID field
type      | String  | Specify type of the notification valid type include __`addFriendRequest`, `addFriendRequestAccepted`, `newChatMessage`, `projectInvitation`, `projectInvitationAccepted`, `projectInvitationRejected`, `newPlaceAdded`, `newUserAdded`, `projectPlaceListUpdated`,`projectUserListUpdated`, `projectAttributesUpdated`, `youAreRemovedFromProject`, `projectDeleted`__. A detail explanation of each notice type can be found after this section
sender    | Hash    | Store basic sender(user) information: __id, name, fb_user_picture__
receiver* | Integer | Receiver's id, if specified, this notice will be send to specified user
project*  | Integer | Project's id, if specified, this notice will be send to all users in specific project
body      | Hash    | Dynamic notice object, contents varies by notice type (see more in explanation of notice type)

_*: between project and receiver, at least one must be specified_


#### Detailed Explanation of Notice Type

1. _addFriendRequest_

        receiver: user_id,
        body: {
	      friendship_id: Integer
	    }

2. _addFriendRequestAccepted_

        receiver: user_id,
        body: {
          friendship_id: Integer
        }

3. _newChatMessage_

        project: project_id,
        body: {
          sample_message_content: String,
          unread_count: Integer
        }

4. _projectInvitation_

        receiver: user_id,
        body: {
          project_participation_id: Integer,
          project: {
            id: Integer,
            title: String,
            notes: String
          }
        }

5. _projectInvitationAccepted_

        receiver: user_id,
        body: {
          project: {
            id: Integer
          }
        }

6. _projectInvitationRejected_

        receiver: user_id,
        body: {
          project: {
            id: Integer
          }
        }

7. _newPlaceAdded_

        project: project_id,
        body: {
          place: {
            name: String,
            address: String,
            notes: String
          }
        }

8. _newUserAdded_

        project: project_id,
        body: {
          user: {
            id: Integer,
            name: String,
            fb_user_picture: String
          }
        }

9. _projectPlaceListUpdated_

        project: project_id,
        body: {
          project: {
            name: String
          }
        }

10. _projectUserListUpdated_

        project: project_id,
        body: {
          project: {
            name: String
          }
        }

11. _projectAttributesUpdated_

        project: project_id,
        body: {
          project: {
            name: String,
            notes: String
          }
        }

12. _youAreRemovedFromProject_

        receiver: user_id,
        body: {
          project: {
            name: String
          }
        }

13. _projectDeleted_

        receiver: user_id,
        body: {
          project: {
            name: String
          }
        }
