# frisky-shadow-posse
An online collectible card game project. The name's maybe temporary, or maybe not.

(This is my Computer Science assignment!)

## Project structure
As of now, I'm undecided on what to do the frontend in, although HTML/Yaws certainly seems like a decent option.

For the backend, Erlang is going to be used, with Mnesia as the database (it seems to fit for the needs, at least initially; the table structure isn't going to be complex and the tables aren't going to be vast).

## Requirements
- Basic:
  - Authentication, card collection, deck creation
  - Game lobby (without matchmaking)
  - The battle mode
- Advanced:
  - Emotes and opponent cursor view
  - Chat system
  - Robustness to injections, XSS attacks, and somesuch
- High tier
  - Being able to handle 100 battles simultaneously
- Self-inflicted
  - Matchmaking
  - Server distribution over multiple machines
