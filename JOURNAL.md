# Journal: StockSynth

## My Process:

### 7/25/2026 - The start
I started with a basic idea of drawing a stock graph and adjusting the pitch according to how well the stock did. I made a basic main menu screen and I searched for an API. I landed on twelvedata, as it allows 8 API credits per minute and up to 800 per day, for free. It's not the absolute best solution as you need to register for an account, but it allows as many users as needed to use the program at the same time, as there isn't one API key being used. I laid out a basic prototype, it simply drew stock data from Tesla from the past 30 minutes and played a synth constantly that pitched up and down. It drew a graph using a Line2D node and had a scanline that followed the graph. It was hard to research how to do this, but I eventually got a working prototype out!

### 7/26/2026

- #### Morning update:
I polished a lot so far! I custom made a synth in FL Studio using 3x Osc. This synth is static and has no attack or release, so it's the same sound throughout the entire note. This allows the note to be replayed or constantly played and have no affect on the listening experience. I added a volume slider, custom ticker selection box so you can select which stock you want to track, and adjusted the resolution to 1600 points and the time to a month. I also coded a system to dynamically adjust the volume, as when the pitch is low the synth sounds very quiet, but when it becomes louder it can be overwhelming. I also quickly added a low pass filter to cut the high annoying frequencies out. I had to implement this with the volume control as it's constantly adjusting the volume dynamically. The volume control simply applies an offset to the automatically calculated volume.

The actual system is pretty simple! It checks if the stock ticker is valid. If it is valid, it checks the cache to see if the same ticker is stored in there. This saves on API credit usage, as if you're rapidly calling the same ticker you won't use up a bunch of credits. If it isn't cached, it calls the API. There is an error logging system that prints any errors in Godot's output, and obviously the cache system which will save stocks that you call. Then, it will calculate the min/max stock price so that the graph scales correctly, and maps each data point to a point on the graph. The scan line is then set to visible, and moves along the graph. The pitch is updated every 0.03 seconds and the synth audio starts. It's also smoothed out to avoid harsh sounds. The scanline will loop indefinitely, until you select a new ticker, as will the audio.
- #### Update 1:
I implemented a timescale system! You can now select from several options, ranging from 1 day history to 1 year history. It automatically calculates the resolution within the limits of the API, so it will have less data points for a 3 day history than it would for a 6 month history. 

- #### Update 2:
I implemented two synth windows in the main scene! For now they are both set to the default synth, but I'll add a dropdown menu soon so you can select a wide variety of sounds, including drums, bass, etc.
I also updated the synth sound to be a few seconds long instead of a few minutes long. This drastically improves both performance and loading times, now taking a few hundred milliseconds vs. a few seconds, meaning it loads over 10x faster!

- #### Update 3:
BIG UPDATE!!! I handmade 7 total sounds in FL Studio using 3x osc, FLEX, and Sytrus. A hihat, kick, 2 synths, a woodblock sound, and several plucks. For each window, you can now select which instrument you want to be played. To make the instruments work better together, you can adjust their update rates, all the way from 30ms (good for static synths that update smoothly) to 1920ms (good for kicks or spaced out instruments). I also decided to increase the number of windows to 4 total, so you can essentially assemble an entire song. Because of the vast range of instruments, I also added a manual pitch offset slider. This makes sure your instruments are pitched how you like them!

I also spent a bit of time tidying up the main menu and main scene. It's nowhere near done aesthetically, but I thought I would at least try to make it look a bit nicer.
smaller things: made comments on my code readable, everything is explained. Not sure if this is specific to update 3 but I cleaned up the filesystem with almost all files in folders

### 7/27/2027
- #### Update 1: This was originally update 4 yesterday, but I ended up finishing this update in the early morning hours of Monday. There are a ton of QoL improvements with this update! I made the main menu look great, with custom buttons designed in Canva. I changed all fonts to something nicer, and I added a changing dynamic gradient background for the main scene. I made a tutorial menu with a tutorial to get a free API key and another one to get people started using the graphing feature. I also added a stop button for the synth windows, and laid out the main scene a bit nicer. There is also a scrolling list of 60 popular stocks with their symbols, so people can quickly search up their favorite companies! Most of this update was aesthetics focused and I improved allignment across small elemenents and styled them nicer.

- #### Update 2: Added a scan line and info for hovered data points on the graph. I thought it would be cool to include! More small font/aesthetic improvements. Also added particles that follow the scanline, will have to tweak those though!
