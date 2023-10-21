This is the final project of my assembly language course which I took during my freshman year.

it's a booter program that runs on 32-bit x86 machines (probably?). the main function is designed to run before OS starts(or you can consider the code itself as a simple "OS"?). 

the first part of code will write the code below it into floppy disk A, then you can boot your PC from A to see the main functions. 

the main functions:
- RESET PC
- START SYSTEM(the original OS in C)
- CLOCK(display a clock by reading CMOS)
  - Esc: go back
  - F1: change color
- SET CLOCK(change the "system time" by writing new values into CMOS)

Recently I am having a course of OS experiment, which again also has win x86 as the platform, so I am reviewing my code and found that the CLOCK function doesn't work anymore so currently I am debugging and initialized this repo.

The debugging is done.
