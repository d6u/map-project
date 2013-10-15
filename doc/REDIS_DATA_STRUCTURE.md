# Redis Data Structure

1. `user:#{user_id}:socket_ids` (set)

Contains id of socket connections belongs to specific user.

2. `user:#{user_id}:friend_ids` (set)

Contains user_id of firends of particular user, no matter online or offline.

3. `#{_session_id}` (value)

Store session data for Rails

4. `project:#{project_id}:user_ids` (set)

IDs of all participating users for a particular project, including project owner.
