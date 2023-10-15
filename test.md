<!-- test code> ####################################### -->
<!-- <test code ####################################### -->

Lookup_s:
- INT 10H, 02H (2): Set Cursor Position
  - AH: 02h
  - BH: Display page number
  - DH: Row
  - DL: Column

Todo_s:
- add Esc for time setting func

Log_s:
- [23/10/15 11:44] after several hours of struggle/test in vain, the bug of CLOCK function finnaly get fixed by simply adding a CALL DELAY in the display loop. NOW I STILL DON'T KNOW WHY IT WORKS THOUGH. 
 