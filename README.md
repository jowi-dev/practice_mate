# PracticeMate

This is a small side project to help keep track of music I'm learning in my freetime.

I was hesitant to pick Elixir for this at all because it screams CLI, but given that 
I'm not performance constrained, and just like elixir right now I'm going against
better judgement and using what I know.

No Phoenix planned as I'm not making a Web Interface or API. 

Nx potentially - see point #1 in future

Spotify-as-a-Database because I'm trying to stay away from dependencies as much as I can here.

## Current Roadmap
- [ ] Integrate with the Spotify API
- [ ] Mock API responses for easier testing 
- [ ] Setup basic TUI REPL

## Plans for this Project
#### The MVP of this project will have
- [ ] A TUI interface
- [ ] Viewing a list of songs I want to learn 
- [ ] Choosing a song for playback/doing playback 
- [ ] Seeking Forward/Backward in a song 
- [ ] Marking songs as "Completed"
- [ ] Removing a song from the list 

### Future 
A few nice to haves for the future rainy days:
- [ ] implement a KNN trained algorithm to determine key, time signature, tempo
- [ ] Seeking Forward/backward based on measures rather than time via the meta data from point 1
- [ ] Adjusting playback speed for complex portions
- [ ] integrating with a tool like Splitter.ai to isolate parts of a track 
- [ ] Lead sheet style chord display
- [ ] This has RPI written all over it


## Want to Give it a Spin?
Set the `SPOTIFY_CLIENT_ID` in your environment to the client_id generated from your 
very own spotify app (google spotify web api for info on setting this up).
