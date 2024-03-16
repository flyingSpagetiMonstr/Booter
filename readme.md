This is the final project of my assembly language course which I took during my freshman year.

it's a booter program that runs on 32-bit x86 machines. the main functions run before the operating system starts. 

main functions:
- RESET PC
- START SYSTEM(the original OS in C)
- CLOCK(display a clock by reading CMOS)
  - Esc: go back
  - F1: change color
- SET CLOCK(change the "system time" by writing new values into CMOS)

Recently I am having a course of OS experiment, which again also has win x86 as the platform, so I am reviewing my code and found that the CLOCK function doesn't work anymore so currently I am debugging and initialized this repo.

<!-- The debugging is done. -->
