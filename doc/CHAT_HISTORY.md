# Chat History

## Intro

### Category

Items (records) in chat history has two categories.

1. Items that will appears in chat history box, when user is editing related project.
2. Records that will be saved into database.

A good example would be user online/offline notice. The notice will appear in chat history box (UI), but will never saved into database.

### Type

Items have three types (for now). Type is different concept with categories. Type gives rules of how to display (might also affect saving) an item.

1. Message: chat text
2. Behavior: user go online/offline, a place deleted from project
3. Place: when user saved a place into a project

## Data Structure by Type

#### Message

    {
        type: 'chatMessage',
        sender: {User},
        message: "String",
        self: Boolean
    }

#### Behavior

    {
        type: 'userBehavior',
        message: 'someone has done something'
    }

#### Place

`placeAdded` is generated in PlacesController#create of Rails, the notice will send to everyone in the project including the sender

    {
        type: 'placeAdded',
        sender: {User},
        receiver_id: Integer,
        place: {Place}
    }
