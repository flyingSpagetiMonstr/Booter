ASSUME CS:CODES, DS:DATA, SS:STACKS
DATA SEGMENT
DATA ENDS

STACKS SEGMENT
STACKS ENDS

CODES SEGMENT
start:
    MOV AX, DATA
    MOV DS, AX
    
    MOV AX, CS
    MOV ES, AX
    MOV BX, OFFSET Bootor
    MOV DL, 0 ; A:
    MOV DH, 0 ; surface
    MOV CL, 1 ; sector
    MOV CH, 0 ; track
    MOV AL, 4 ; sector num; 4 sectors = 4*512 B = 2*1024 B; 2KB in machine code
    MOV AH, 3 ; write disk
    INT 13H

    MOV AH, 4CH
    INT 21H

;=================================================================================
; IP == 7C00H + , CS == 0, DS == 0 
; ORG 7C00H

Bootor:
    JMP NEAR PTR Bootor_start
    ; l = 16
    Menu    DB '> ==============', '$'
            DB '> RESET PC     1', '$'
            DB '> START SYSTEM 2', '$'
            DB '> CLOCK        3', '$'
            DB '> SET CLOCK    4', '$'
    MenuEnd DB 0
    ; l = 20
    ; TimeMap DB ' ---------------- ', '$'
    ;         DB '|-              -|', '$'
    ;         DB '|-  2022/06/06  -|', '$'
    ;         DB '|-   18:53:30   -|', '$'
    ;         DB '|- Steins;Gate\ -|', '$'
    ;         DB '|-              -|', '$'
    ;         DB ' ---------------- ', '$'
    TimeMap DB ' ---------------- ', '$'
            DB '|-              -|', '$'
            DB '|-  20  /  /    -|', '$'
            DB '|-     :  :     -|', '$'
            DB '|- Steins;Gate\ -|', '$'
            DB '|-              -|', '$'
            DB ' ---------------- ', '$'
    TIM_END DB '                  ', '$'
    
    MenuPos DB 12 - 3, 39 - 7 ; ROW, COL
    KlocPos DB 12 - 3, 39 - 9 + 1 ; ROW, COL

    TimePosTable DB 0 ; Only for a prettier table, no use
    DB 12 - 3 + 2    , 39 - 9 + 1 + 6 ; ROW, COL
    DB 12 - 3 + 2    , 39 - 9 + 1 + 6 + 3 ; ROW, COL
    DB 12 - 3 + 2    , 39 - 9 + 1 + 6 + 6; ROW, COL
    DB 12 - 3 + 2 + 1, 39 - 9 + 1 + 6 + 9  - 10; ROW, COL
    DB 12 - 3 + 2 + 1, 39 - 9 + 1 + 6 + 12 - 10; ROW, COL
    DB 12 - 3 + 2 + 1, 39 - 9 + 1 + 6 + 15 - 10; ROW, COL
    
    ; DW: Word = 16-bit = 2 Byte
    JumpTable       DW Restart - Bootor + 7C00H, Startsystem - Bootor + 7C00H, CLOCK - Bootor + 7C00H, SET_CLOCK - Bootor + 7C00H 
    ResAddr         DW 0, 0FFFFH
    Int9_OrgAddr    DW 0, 0

    Bootor_start:

    MOV AX, 0
    MOV DS, AX

    ; =================================================
    ; Copy The Bootor In Sector that not copied
    
    MOV AX, 0
    MOV ES, AX

    MOV BX, 7E00H ; 7C00H + 200H
    MOV DL, 0 ; A:
    MOV DH, 0 ; surface
    MOV CL, 2 ; sector
    MOV CH, 0 ; track
    MOV AL, 3 ; sector num
    MOV AH, 2 ; read disk
    INT 13H


    ; =================================================
    ; Print MENU:
    MOV DI, MenuPos - Bootor + 7C00H
    MOV DH, DS:[DI]
    MOV DL, DS:[DI + 1]
    MOV BH, 0
    MOV BL, 00000010B
    ; MOV BL, 0(blink) 000(background) 0(highlight) 010(char) B
    MOV SI, Menu - Bootor + 7C00H
    MOV CX, 5
    BootorPutsS:
        ; DS->SI, '$', BH == 0 (PAGE), DH == ROW, DL ==COL
        CALL Prt
        ADD SI, (MenuEnd - Menu) / 5
        INC DH
        LOOP BootorPutsS
    ; ================================================
    Getchar_s:
        ; SCANF:
        MOV AH, 0
        INT 16H

        MOV CX, 4
        MOV DL, '1'
        NumCmp_s:
            CMP AL, DL
            JE Getchar_sEnd
            INC DL
            LOOP NumCmp_s

        JMP SHORT Getchar_s
        Getchar_sEnd:

    MOV AH, 0
    MOV BP, AX
    SUB	BP,	'0'
    DEC	BP ; BP REAMINED
    ; ==============================================
    ; HIGHLIGHT THE CHOOSEN OPTION:
    MOV AX, 0
    MOV CX, BP
    INC CX
    MULT:
        ADD AX, (MenuEnd - Menu) / 5
        LOOP MULT
    ; ADD AX, (MenuEnd - Menu) / 5
    MOV SI, Menu - Bootor + 7C00H
    ADD SI, AX
    MOV BH, 0
    MOV BL, 00001010B
    MOV DX, BP
    MOV DH, DL
    MOV DI, MenuPos - Bootor + 7C00H
    ADD DH, DS:[DI]
    INC DH
    MOV DL, DS:[DI + 1]
    CALL Prt

    CALL DELAY
    ; ==============================================
    ; JUMP 
    MOV DI, JumpTable - Bootor + 7C00H
    ADD BP, BP
    CALL DS:[BP + DI] ; to the selected function

    JMP NEAR PTR Bootor_start
    RET
; ==============================================
Restart:
    MOV BX, ResAddr - Bootor + 7C00H
    JMP DWORD PTR DS:[BX]
; ==============================================
Startsystem:
    ; copy the code of Trans to 0200H, then jmp there
    ; (since the current code is at 07C00H, 
    ; u can't directly read C to 07C00H)
    MOV AX, 0
    MOV ES, AX
    MOV DI, 0200H
    MOV SI, Trans - Bootor + 7C00H
    MOV CX, Trans_end - Trans
    CLD
    REP MOVSB

    MOV AX, 0200H
    JMP AX

Trans:
    ; read C to 07C00H
    MOV AX, 0
    MOV ES, AX
    MOV BX, 7C00H
    MOV AH, 2 ; 3: write, 2:read 
    MOV AL, 1 ; sector num
    MOV CH, 0 ; track
    MOV CL, 1 ; sector
    MOV DH, 0 ; surface
    MOV DL, 80H ; 0: A, 80H: C
    INT 13H

    MOV BX, 7C00H
    JMP BX
    Trans_end: NOP
; ==============================================
CLOCK:
    ; install a new int9 to detect key events:
    CALL INSTALL_INT9

    CALL Print_TimeMap
    
    ; Hide cursor:
    MOV CX, 200H
    MOV AH, 01H
    INT 10H

    ; Set ScanCode to 0:
    MOV SI, ScanCode - Bootor + 7C00H
    MOV BYTE PTR DS:[SI], 0

    ; Set SI to count whether to spin:
    MOV SI, 0
    PUSH SI


    LAPSE:
        MOV SI, ScanCode - Bootor + 7C00H

        CMP BYTE PTR DS:[SI], 1 ; 01H: Esc
        JE LapsEnd

        ; =========================
        ; Color when last is make and current is break
        CMP BYTE PTR DS:[SI], 3BH + 80H
        ; < break code = make code + 80H 
        JNE Color_end
        CMP BYTE PTR DS:[SI + 1], 3BH
        JNE Color_end

        ; Adjust color:
        MOV BYTE PTR DS:[SI + 1], 0

        MOV SI, Color - Bootor + 7C00H
        SHR BYTE PTR DS:[SI], 1
        
        CMP BYTE PTR DS:[SI], 0
        JNE ColorNoMod ; % Mod 
        MOV BYTE PTR DS:[SI], 00000100B
        ColorNoMod:

        Color_end:


        JMP SHORT Lapstart
        SPIN_TABLE DB '|', '\', '-', '/'
        Spin_ptr   DW SPIN_TABLE - Bootor + 7C00H
        ScanCode   DB 0, 0 
        ; < code read from user keyboard input (F1/Esc)
        ; < ScanCode[1]: last code, ScanCode[0]: current code 
        ; < Esc: 01H; F1: 3BH
        Color      DB 00000010B
        
        Lapstart:

        ; Set frame color
        CALL Frame_color

        MOV CX, 6

        MOV AL, 9
        MOV BH, 0 
        MOV SI, Color - Bootor + 7C00H
        MOV BL, DS:[SI]
        MOV SI, TimePosTable - Bootor + 7C00H + 1
        MOV DH, DS:[SI]
        MOV DL, DS:[SI + 1]

        TIME_S:
            ; AL == Ctrl CODE, BH == 0, BL == COLOR, DH == ROW ,DL ==COL
            ; PARAS SAVED
            CALL PrtCmos
            CALL PrtCmAjust
            LOOP TIME_S

        CALL DELAY
        POP SI
        CALL SPIN
        PUSH SI

        JMP SHORT LAPSE

    LapsEnd:
    POP SI

    CALL UNINSTALL_INT9

    CALL Clear_screen

    ; Show cursor:
    MOV CX, 0607H
    MOV AH, 01H
    INT 10H

    RET
; ==============================================
SET_CLOCK:

    JMP NEAR PTR Scstart

    TypAlt  DB "Type '<-' or '->' to alter", '$'
    Und     DB 'And Press "Enter" to confirm and select', '$'
    Notice  DB 'Notice: You can enter at most 2 numbers', '$'
    Can     DB 'Active keys: Backspace, Enter, and any number', '$'

    ; len(total str) = [len(str) = 6] + 1 = 7
    Year    DB 'Year  ', '$'
    Month   DB 'Month ', '$'
    Day     DB 'Day   ', '$'
    Hour    DB 'Hour  ', '$'
    Minute  DB 'Minute', '$'
    Second  DB 'Second', '$'

    Prompt  DB '> ','$'
    ; Max     DB 'Max length!', '$'

    CmTable DB 9, 8, 7, 4, 2, 0

    Scstart:

    MOV SI, Und - Bootor + 7C00H
    MOV DI, TypAlt - Bootor + 7C00H
    CALL PrtPrompt

    CALL Print_TimeMap
    
    MOV CX, 1 ; ptr to mark which to change£¬ 1 ~ 6
    MOV BH, 0
    MOV BL, 00000111B
    MOV SI, TimePosTable - Bootor + 7C00H + 1
    MOV DH, DS:[SI]
    MOV DL, DS:[SI + 1]

    Alter_s:
        PUSH DX

        ; Set DH, DL
        MOV SI, KlocPos - Bootor + 7C00H
        MOV DH, DS:[SI]
        MOV DL, DS:[SI + 1]
        ADD DH, 7

        ; Set SI
        MOV SI, CX
        DEC SI
        MOV AX, 7
        PUSH DX
        MUL SI
        POP DX
        MOV SI, AX
        ADD SI, Year - Bootor + 7C00H

        ; DS->SI, '$', BH == 0, BL == COLOR, DH == ROW ,DL ==COL
        ; PARAS WILL BE SAVED
        CALL Prt

        POP DX

        ; ==============================================

        MOV AH, 2 ; TO SET CURSOR
        INT 10H

        ; SCANF:
        MOV AH, 0
        INT 16H

        CMP AH, 1CH ; Enter
        JE Alter_sEnd

        CMP AH, 4BH ; left
        JNE No_left
        DEC CX
        No_left:
        CMP AH, 4DH ; right
        JNE No_right
        INC CX
        No_right:

        CMP CX, 7 ; Upside overflow
        JNE No_Uverflow
        MOV CX, 1
        No_Uverflow:
        CMP CX, 0 ; Downside overflow
        JNE No_Dverflow
        MOV CX, 6
        No_Dverflow:

        MOV SI, CX
        DEC SI
        ADD SI, SI

        ADD SI, TimePosTable - Bootor + 7C00H + 1
        MOV DH, DS:[SI]
        MOV DL, DS:[SI + 1]

        JMP SHORT Alter_s
    Alter_sEnd:

    MOV SI, Can - Bootor + 7C00H
    MOV DI, Notice - Bootor + 7C00H
    CALL PrtPrompt

    ; Print Prompt mark:
    MOV BH, 0
    MOV BL, 00000111B
    MOV SI, KlocPos - Bootor + 7C00H
    MOV DH, DS:[SI]
    MOV DL, DS:[SI + 1]
    ADD DH, 8
    MOV SI, Prompt - Bootor + 7C00H
    ; DS->SI, '$', BH == 0, BL == COLOR, DH == ROW ,DL ==COL
    ; PARAS WILL BE SAVED
    CALL Prt

    CALL Get_str

    MOV SI, CmTable - Bootor + 7C00H
    ADD SI, CX
    DEC SI

    MOV AL, DS:[SI]
    OUT 70H, AL
    
    ; PUSH CX
    MOV SI, GOT - Bootor + 7C00H

    MOV CL, 4
    SHL BYTE PTR DS:[SI], CL
    MOV AL, DS:[SI]
    ADD AL, DS:[SI + 1]
    OUT 71H, AL 
    ; POP CX

    CALL Clear_screen

    RET
; ==============================================
; DS->SI, '$', BH == 0(PAGE), BL == COLOR, DH == ROW ,DL ==COL
; PARAS WILL BE SAVED
Prt:
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV CX, 1 ; Time of single char's rep 
    Prt_S:
    MOV AH, 2 ; TO SET CURSOR
    INT 10H

    MOV AL, DS:[SI]
    MOV AH, 9 ; (PUTCHAR)
    INT 10H
    
    INC SI
    CMP BYTE PTR DS:[SI], '$'
    JE Prt_END
    INC DL ; COL
    JMP SHORT Prt_S

    Prt_END:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
; ==============================================
DELAY:
    PUSH AX
    PUSH DX

    MOV DX, 1125H
    ; MOV DX, 2250H
    ; MOV DX, 4500H
    ; MOV DX, 9000H
    ; MOV DX, 10H
    MOV AX, 0
    S1:
    SUB AX, 1
    SBB	DX,	0
    CMP	AX,	0
    JNE S1
    CMP	DX,	0
    JNE S1

    POP DX
    POP AX
    RET
; ==============================================
; AL == Ctrl CODE, BH == 0, BL == COLOR, DH == ROW ,DL ==COL
; PARAS SAVED
PrtCmos:
    JMP SHORT PrtCmstart
    TMP DB 0, 0
    PrtCmstart:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI

    MOV DI, TMP - Bootor + 7C00H

    OUT 70H, AL
    IN AL, 71H
    ; WRITE DATE INTO MEM
    MOV BYTE PTR DS:[DI], AL ; STORE LOW
    AND BYTE PTR DS:[DI], 00001111B
    ADD BYTE PTR DS:[DI], '0'
    MOV CL, 4
    SHR AL, CL
    ADD AL, '0' 
    MOV BYTE PTR DS:[DI + 1], AL ; STORE HIGH

    MOV CX, 2
    PrtCm_S:
    PUSH CX
        MOV AH, 2 ; TO SET CURSOR
        INT 10H

        MOV AL, BYTE PTR DS:[DI + 1]
        MOV AH, 9 ; (PUTCHAR)
        MOV CX, 1
        INT 10H
        INC DL
        DEC DI
        
        POP CX
        LOOP PrtCm_S

    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    RET

; ==============================================
SPIN:
    PUSH BP

    INC SI
    ; CMP SI, 0FFFFH / 32
    CMP SI, 1
    JNE NO_SPIN

    MOV BH, 0
    MOV BP, Color- Bootor +7C00H
    MOV BL, DS:[BP]
    MOV DH, 12 - 3 + 4
    MOV DL, 39 - 9 + 1 + 14
    MOV AH, 2 ; TO SET CURSOR
    INT 10H

    MOV BP, Spin_ptr - Bootor + 7C00H
    MOV DI, DS:[BP]
    MOV AL, DS:[DI]
    MOV AH, 9 ; PUTCHAR()
    MOV CX, 1
    INT 10H

    ; inc spin_ptr
    INC WORD PTR DS:[BP]
    CMP WORD PTR DS:[BP], SPIN_TABLE - Bootor + 7C00H + 4
    JNE NO_RESET
    SUB WORD PTR DS:[BP], 4
    NO_RESET:

    MOV SI, 0

    NO_SPIN:

    POP BP
    RET
; ==============================================
PrtCmAjust:
    ; Adjust AL
    MOV AH, 0
    MOV SI, AX ; STORE AL

    CMP SI, 7
    JB NO_DEC
    DEC AL
    NO_DEC:
    CMP SI, 7
    JA NO_SUB
    SUB AL, 2
    NO_SUB:
    ; end

    ; Adjust DH, DL
    CMP SI, 7
    JNE NO_TRANSLINE
    INC DH
    SUB DL, 8 + 2
    NO_TRANSLINE:

    ADD DL, 3
    ; end

    RET
; ==============================================
INT9:
    PUSH AX
    PUSH BX
    PUSH DI

    JMP SHORT INT9_start
    Ctrl_keys DB 1DH, 2AH, 36H, 37H, 38H, 3AH, 45H, 46H, 0
    ; F11, F12, 5 while Numlocked and Win, This 4 keys will raise error

    INT9_start:

    MOV AX, 0
    MOV ES, AX

    MOV DI, ScanCode - Bootor + 7C00H
    MOV BL, ES:[DI]
    MOV ES:[DI + 1], BL
    IN AL, 60H
    MOV BYTE PTR ES:[DI], AL
    
    MOV DI, Int9_OrgAddr - Bootor + 7C00H
    
    PUSHF

    PUSHF
    POP BX
    AND BH, 11111100B
    PUSH BX
    POPF
    CALL DWORD PTR ES:[DI]


    ; clear the key casher
    CMP AL, 80H
    JA No_clear

    MOV DI, Ctrl_keys - Bootor + 7C00H
    INT9_S:
    CMP AL, ES:[DI]
    JE No_clear
    INC DI
    CMP BYTE PTR ES:[DI], 0
    JNE INT9_S

    MOV AH, 0
    INT 16H
    No_clear:

    POP DI
    POP BX
    POP AX
    IRET
; ==============================================
INSTALL_INT9:
    PUSH AX
    PUSH DX
    PUSH DI

    MOV AX, 0
    MOV DS, AX

    MOV DI, Int9_OrgAddr - Bootor + 7C00H
    MOV DX, DS:[9 * 4]
    MOV DS:[DI], DX
    MOV DX, DS:[9 * 4 + 2]
    MOV DS:[DI + 2], DX

    MOV WORD PTR DS:[9 * 4], INT9 - Bootor + 7C00H
    MOV WORD PTR DS:[9 * 4 + 2], 0

    POP DI
    POP DX
    POP AX
    RET
; ==============================================
UNINSTALL_INT9:
    PUSH AX
    PUSH DX
    PUSH DI


    MOV AX, 0
    MOV DS, AX

    MOV DI, Int9_OrgAddr - Bootor + 7C00H
    MOV DX, DS:[DI]
    MOV DS:[9 * 4] , DX
    MOV DX, DS:[DI + 2]
    MOV DS:[9 * 4 + 2], DX

    POP DI
    POP DX
    POP AX
    RET
; =================================================
Frame_color:    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV AX, 0B800H
    MOV ES, AX
    MOV DI, KlocPos - Bootor + 7C00H
    MOV DL, DS:[DI]
    MOV DH, 0
    MOV BL, DS:[DI + 1]
    MOV BH, 0

    MOV DI, 0
    MOV CX, 160
    DI_mul:
        ADD DI, DX
        LOOP DI_mul
    ADD DI, BX
    ADD DI, BX
    INC DI

    MOV SI, Color - Bootor + 7C00H
    MOV BL, DS:[SI]
    MOV CX, 7

    Color_s:
        PUSH CX
        MOV CX, (TIM_END - TimeMap) / 7
        Color_inner:
            MOV ES:[DI], BL
            INC DI
            INC DI
            LOOP Color_inner
        ADD DI, 160
        SUB DI, 2 * ((TIM_END - TimeMap) / 7)
        POP CX
        LOOP Color_s

    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
; ==========================================
Print_TimeMap:
    PUSH CX
    PUSH BX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV SI, TimeMap - Bootor + 7C00H
    MOV BH, 0
    MOV BL, 00000111B ; white
    MOV DI, KlocPos - Bootor + 7C00H
    MOV DH, DS:[DI]
    MOV DL, DS:[DI + 1]
    MOV CX, 7

    Prtimap_s:
        ; DS->SI, '$', BH == 0, BL == COLOR, DH == ROW ,DL ==COL
        ; PARAS WILL BE SAVED
        CALL Prt

        INC DH
        ADD SI, (TIM_END - TimeMap) / 7
        LOOP Prtimap_s

    POP DI
    POP SI
    POP DX
    POP BX
    POP CX
    RET
; ==============================================
PrtPrompt:
    PUSH BX
    PUSH DX
    PUSH SI

    MOV BH, 0
    MOV BL, 00000111B
    MOV DH, 1
    MOV DL, 0

    CALL Prt

    DEC DH
    MOV SI, DI 
    CALL Prt
    
    POP SI
    POP DX
    POP BX
    RET
; ==============================================
; Infact, the last line is not completely cleared,
; but it does not matter, any way.
Clear_screen:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BH, 0
    MOV DH, 0
    MOV DL, 0
    MOV AH, 2 ; TO SET CURSOR
    INT 10H

    MOV AL, ' ' ; CHAR
    MOV BL, 0 ; COLOR
    MOV AH, 0EH ; TO PUTCHAR AND SUSUME
    MOV CX, 80 * 25
    Cls_s:
        INT 10H
        LOOP Cls_s

    POP DX
    POP CX
    POP BX
    POP AX
    RET
; ==============================================
Get_str:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH BP
    PUSH SI

    JMP SHORT Get_strstart
    GOT DB 0, 0
    Get_strstart:


    MOV BP, 0 ; 0 ~ 2
    Get_str_s:

        ; SCANF:
        MOV AH, 0
        INT 16H
        
        ; if Enter:
        CMP AH, 1CH
        JNE No_enter
        CMP BP, 2
        JNE No_enter
            JMP SHORT Get_str_sEnd
        No_enter:

        ; if Backspace:
        CMP AH, 0EH
        JNE No_backspace
        CMP BP, 0
        JE No_backspace
            MOV BH, 0
            MOV AH, 3
            INT 10H ; Read cursor pos
            DEC DL

            MOV AH, 2 ;Set cursor pos
            INT 10H

            MOV AL, ' '
            ; MOV BL, 00000111B
            MOV CX, 1
            MOV AH, 9
            INT 10H
            
            DEC BP
        No_backspace:
            
        ; if Number:
        CMP BP, 2
        JE Nonumopra
        
        MOV DL, '0'
        MOV CX, 10
        Decicmp_s:
            CMP AL, DL
            JE Num_opera
            INC DL
            LOOP Decicmp_s
        JMP SHORT Nonumopra

        Num_opera:
            MOV BL, 111B ; COLOR
            MOV AH, 0EH ; TO PUTCHAR AND SUSUME
            INT 10H

            INC BP

            MOV SI, GOT - Bootor + 7C00H
            MOV DS:[SI + BP - 1], AL
            SUB BYTE PTR DS:[SI + BP - 1], '0'
            
        Nonumopra:

        JMP SHORT Get_str_s
    Get_str_sEnd:

    POP SI
    POP BP
    POP DX
    POP CX
    POP BX
    POP AX
    RET ; Get_str

CODES ENDS
END start

