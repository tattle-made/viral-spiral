# Nomenclature

## Contexts
Coordinator
GamePlay
Game
    


Game could be the context
    Room is one aggregate
        create
        join
        leave
        pause
        resume
    Round
Canon is is a context
    Article one aggregate
    Deck is one aggregate
    Functions
        load_cards
        load_encylopedia
Canon is the a collection of writing done by the Viral Spiral Writers.
It consists of writings for Cards and Encyclopedia as of now.

Room
This is a shared context where a game of Viral Spiral takes place.
Anyone can create a room and invite their friends to join the room.
Once a room has more than 3 players, you can start playing viral spiral in it. 
Player actions in each room are isolated from other Rooms. 

# Rounds and Play
