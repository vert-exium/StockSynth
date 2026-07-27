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
