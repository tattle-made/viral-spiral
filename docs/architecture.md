# Architecture

Each Game Room should be a dynamically supervised GenServer.
So any crashes in one room should be isolated.


# Should all structs be colocated under a Room struct or no?
Colocation makes it easy for developers to see everything in a struct but are the added memory requirements worth it-



# Changes
type : can be any atom

Reserved atoms :
- :ignore : when you want to skip making any changes.

