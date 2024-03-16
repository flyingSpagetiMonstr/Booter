This is the final project of my assembly language course.

it's a booter program that runs on 32-bit x86 machines. the main functions run before the operating system starts. 

when started, there will be a menu:
- RESET PC
- START SYSTEM(the original OS in C)
- CLOCK(display a clock by reading CMOS)
  - Esc: go back
  - F1: change color
- SET CLOCK(change the "system time" by writing new values into CMOS)
