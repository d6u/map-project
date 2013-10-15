# Websocket Connection Lifecycle

## Brief

Websocket connection in this project relies on Node.js and Socket.IO.

## Lifecycle Stages

### 1. connection

When user logged in, socket client will connect to Node.js and trigger this event on Socket.IO. Server will store current socket id into Redis set (data type) with `user:#{user_id}:socket_ids` as key.

Server then load user's friends' ids and push online friends' ids to current socket connection with `friendsOnlineIds` event emitted.

If this is the first socket connection for this user, server will also emit `friendGoOnline` event to every sockets of every friends that current user have.

### 2. listening

After connection stage, server listen to `requestOnlineFriendsList` event on socket and return online friends' ids when triggered.

Server will push the following events during listening stage:

Event Name        | Data Content
----------------- | --------------------------
`friendGoOnline`  | friend id number (Integer)
`friendGoOffline` | friend id number (Integer)
`pushData`        | real time push data (Hash)


### 3. disconnect

When user logout or lose connection, server will remove disconnected socket's id from `user:#{user_id}:socket_ids` set. If no member exists after the removal, the set key will be deleted (whether this is necessary haven't been determined).

If no more sockets of current user is connected, server will emit a `friendGoOffline` event to user's friends.