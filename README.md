# APB 
Advanced peripheral bus is part of AMBA protocol family and is a simple non-pipelined protocol which supports low-bandwidth transactions. <br><br>
It  has 3 operating states - IDLE, SETUP and ACCESS.<br><br>
The state diagram is shown below - <br><br>
<img width="546" alt="Screenshot 2024-12-09 at 2 39 41 PM" src="https://github.com/user-attachments/assets/1d8f570b-b529-46e8-a7dd-0883bb3349e8"><br><br>
The interconnections between APB master and slave are as shown below - <br><br>
<img width="1470" alt="Screenshot 2024-12-09 at 2 37 00 PM" src="https://github.com/user-attachments/assets/cefd2cc5-1e83-4b1a-96e3-40e06fe5da44"> <br><br>
The waveform for writing without wait state looks like this - <br><br>
<img width="617" alt="Screenshot 2024-12-09 at 2 37 58 PM" src="https://github.com/user-attachments/assets/c6848fa1-e0ab-44ee-917a-3aa690a5732e"><br><br>
In the above image, T0-T1 is IDLE phase, T1-T2 is SETUP phase and T2-T3 is ACCESS phase. <br><br>
The verilog code for the same is written above. <br><br><br><br>

# AHB


