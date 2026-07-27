# StockSynth

StockSynth is a tool that utilizes stock market data to adjust parameters for different instruments. It uses a free API that you need to sign up for, and it will feature volume control, stock time control (from past 15 min to past year), multiple instruments, and much more! 

---

## Features:
 - Easy to use intuitive UI
 - Volume control
 - Stock history control
 - Track any valid stock!

---

## How it works:
 - 1: **Cache Check:** The program checks the local memory to see if the stock has been saved in memory from a previous search. If it has, then it will load from cache, saving API credit usage.
 - 2: **API/Error Handling:** If the stock isn't present in the cache, it calls TwelveData's API and handles or prints any errors.
 - 3: **Graph Mapping:** The program calculates the scale of the graph so that all stocks work seamlessly, and then draws it using API information.
 - 4: **Audio Playback:** The scanline moves across the graph, playing the selected noise and adjusting it based on user settings and adjusting the pitch based on the stock graph.

---

## My Process:

### 7/25/2026 - The start
I started with a basic idea of drawing a stock graph and adjusting the pitch according to how well the stock did. I made a basic main menu screen and I searched for an API. I landed on twelvedata, as it allows 8 API credits per minute and up to 800 per day, for free. It's not the absolute best solution as you need to register for an account, but it allows as many users as needed to use the program at the same time, as there isn't one API key being used. I laid out a basic prototype, it simply drew stock data from Tesla from the past 30 minutes and played a synth constantly that pitched up and down.

### 7/26/2026

- #### Morning update:
I polished a lot so far! I custom made a synth in FL Studio using 3x Osc. This synth is static and has no attack or release, so it's the same sound throughout the entire note. This allows the note to be replayed or constantly played and have no affect on the listening experience. I added a volume slider, custom ticker selection box so you can select which stock you want to track, and adjusted the resolution to 1600 points and the time to a month. I also coded a system to dynamically adjust the volume, as when the pitch is low the synth sounds very quiet, but when it becomes louder it can be overwhelming. I also quickly added a low pass filter to cut the high annoying frequencies out. I had to implement this with the volume control as it's constantly adjusting the volume dynamically.

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
