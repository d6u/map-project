# Chat History

## Brief

Chat History records are hold in `chat_histories` table. Records have a column with JSON data type, so only PostgreSQL could support this object.

## Types

`item_type` code | Type Name     | Content Column Structure
---------------- | ---------     | ------------------------
0                | chat message  | `{m: "message"}`
1                | place added   | `{pl_id: place_id, pl_rf: "reference string for Google API"}`
2                | place removed | `{pl_rf: "reference string for Google API"}`

## Lifecycle

When ever a chat_history record is generated, it will be broadcasted to every one in the same project, including the sender.
