# Telecom

An (WIP) Lua implementation of a routing structure using a distributed systems approach

## About

Telecom is a lua implementation of a adaptable and scalable routing network that aims to provide a reliable and flexible routing service to a number of clients.

It's made with [CC Tweaked](https://github.com/cc-tweaked/CC-Tweaked)'s modem API in mind, however due to the fairly modular code structure, you can wrap the library around another framework with minor changes to the code. It also natively supports Ale32bit's [Classic Peripherals](github.com/Ale32bit/ClassicPeripherals) towers with the RadioRouter firmware module.  

It implements very common distributed systems algorithms with some assumptions:
- There is only a single shared transmission channel which all messages go though.
- Each router has to have an internal clock that does not ever go backwards
- There is next to zero error correction, if a package contains corrupted data it might be erroneusly treated, error correction can be implemented by an outward layer (as it is standard in other types of network systems through the data link layer), maybe I'll implement one later because Classic Peripherals actually replicates signal corruption in long distances.
- Similarly, there is zero encryption, such service may be implemmented by inserting a new layer between the firmware and the router logic module.
- I do not know what I am doing lol.

Some important aspects to note is
- It only supports 2-way connections (as in, the network always has a topology of a Graph), if router A can see router B but B cannot see A, then both will consider the other one as not directly reachable.
- CC:T calls (and any other peripheral calls) are not included in most modules and are to be exclusively contained in the hardware modules.
- There are no blocking calls in any module but the hardware layer (that uses the standard CC pullevent call to receive messages and run the updates at an standard frequency). This is because routers need to remove dormant routers and endpoints from their memory in order to keep an accurate internal topology of the network.
- Since there are no blocking calls, the router and endpoint logic modules run on the event API, an standard clock event triggers the usual update logic and an message received event triggers the onMessageReceived function.
- Due do the above, endpoints must be ran in somewhat of a 'concurrency' to whatever program is using the endpoint service, and communication between the endpoint service and the program that is running it is done in an producer/consumer basis, where both the endpoint and the program can consume and produce data (when the endpoint receives a network message, it 'produces' it to the program, and when the program wants to send a message, it 'produces' a string).
- Documentation? What is that?????
- Give me 5 dollars
- This module does not follow standard lua OOP syntax and as such might be a little hard to read. There's actually a reason for that: i am stupid.

<img width="1366" height="705" alt="2025-07-22_19 04 54" src="https://github.com/user-attachments/assets/46462eb6-7b88-4539-be2b-1cf654495f0d" />
