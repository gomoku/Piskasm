P8086
MODEL TINY

DATASEG
   hlaska1 DB "PiskAsm by Vojta Havranek, 3.9. 2004"
   hlaska2 DB "vojtech.havranek@matfyz.cz"

   key1 DB "1...Player starts"
   key2 DB "2...PC starts"
   key3 DB "3...Quit"

   winstring1 DB "Zvitezil jsem, zkuste to znovu."
   winstring2 DB "Gratuluji, vyhral jste."
   drawstring DB "Hra skoncila remizou."


bodovani DW 0,0, 0,0, 0,0, 2,3, 0,0, 1,2, 2,3, 5,7
   DW 0,0, 1,2, 1,2, 5,7, 2,3, 5,7, 5,7, 25,200
   DW 0,0, 1,2, 1,2, 5,7, 1,2, 5,7, 5,7, 25,200
   DW 2,3, 5,7, 5,7, 25,200, 5,7, 25,200, 25,200, 14500,65000

   DW 0,0, 0,0, 0,0, 2,3, 0,0, 1,2, 4,6, 5,7
   DW 0,0, 1,2, 4,6, 5,7, 4,6, 5,7, 19,135, 25,200
   DW 0,0, 1,2, 4,6, 5,7, 4,6, 5,7, 19,140, 25,200
   DW 4,6, 5,7, 19,140, 25,200, 19,135, 25,200, 700,3200, 14500,65000
   DW 0,0, 0,0, 1,2, 2,3, 1,2, 2,3, 5,7, 5,7
   DW 1,2, 2,3, 5,7, 5,7, 5,7, 5,7, 25,200, 25,200
   DW 2,3, 2,3, 5,7, 5,7, 5,7, 5,7, 25,200, 25,200
   DW 5,7, 5,7, 25,200, 25,200, 25,200, 25,200, 14500,65000, 14500,65000

   DW 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0
   DW 0,0, 0,0, 0,0, 0,0, 5,7, 0,0, 0,0, 0,0
   DW 0,0, 0,0, 0,0, 0,0, 4,6, 0,0, 0,0, 0,0
   DW 5,7, 0,0, 0,0, 0,0, 20,150, 0,0, 0,0, 0,0
   DW 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0
   DW 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0
   DW 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0
   DW 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0
   DW 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0
   DW 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0
   DW 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0
   DW 0,0, 0,0, 0,0, 0,0, 0,0, 700,3200, 0,0, 0,0
   DW 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0
   DW 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0
   DW 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0
   DW 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0
      ;body sablon indexovany jejich binarni hodnotou
      ;0..31 - petice; 32..95 - sestice; 96..223 - sedmice
      ;prvni=obrana, druha=utok

   posun  DB -1,-1,0,1
      ;zmeny y-souradnice pro vsechny 4 smery
      ;zmeny pro x 0,1,1,1 jsou zadratovany v programu

UDATASEG
   plocha DB 19*19 DUP (?) ;herni deska, 0=volno 1=krizek=PC 2=kolecko=clovek
   info DW 19*19 DUP (?) ;body tahu na x, y 0=zadne body nebo obsazeno
   body DW ? ;navratova hodnota podprogramu CountScore
   random DW ? ;nahodne cislo
   volnapole DW ? ;kolik jeste tahu do remizy
   lastPC DW ? ;souradnice posledniho krizku

   DW 100H DUP (?)
MyStack  LABEL WORD ;ukazatel na dno zasobniku

CODESEG
   STARTUPCODE
   MOV SP,OFFSET MyStack

   ;v ES bude segment videoRAM
   MOV BX, 0B800H
   MOV ES, BX

   CALL Intro
   ;zapnuti mysi
   XOR AX, AX
   INT 51
   INC AX
   JNZ Quit
   INC AX
   INT 51

Restart:
   CALL NewGame

  Input1:
;cekam, az prijde vstup, a pritom nastavuji nahodne cislo
   MOV AH, 0BH
   INT 21H
   INC BX
   ADD AL, 0
   JZ Input1

   MOV AH, 8
   INT 21H

   CMP AL, '1'
   JZ OK
   CMP AL, '2'
   JZ Ok
   CMP AL, '3'
   JNZ Input1
  Quit:
   MOV AL,1
   MOV AH,4CH
   INT 21H
   RET

Ok:
   MOV random, BX ;Ulozim si nahodne cislo
   CALL NewBoard ;Nemeni AL
   MOV volnapole, 361
   MOV lastPC, -1

   CMP AL, '1'
   JZ FirstMove

;rozehravka pocitace
;nactu nahodne cislo a generuji dalsi
   CALL GetRandom

;SI <- x-ova souradnice 1. tahu
   MOV AX, CX
   AND AX, 0000000000000011B
   ADD AX, 7
   MOV SI, AX

;BX <- y-ova souradnice 1. tahu * 19
;CL <- y-ova souradnice 1. tahu
   SHR CL, 2
   AND CL, 00000011B
   ADD CL, 7
   MOV AL, 19
   MUL CL
   MOV BX, AX

;polozim krizek
   MOV [plocha+SI+BX], 1
   SUB volnapole, 1
;nakreslim krizek
   MOV AL, 61
   MUL CL
   ADD BX, AX
   SHL SI, 2
   SHL BX, 1
   MOV [ES:(3*80+3)*2+SI+BX], 0011110000000000B + 'X'

; ulozeni posledniho tahu
   MOV DI, BX
   ADD DI, SI
   MOV lastPC, DI

   SHR SI, 2
   SHR BX, 1
   SUB BX, AX
;update plochy
   CALL Update

FirstMove:
; cekam na kliknuti
   MOV AX, 3
Input2:
   INT 51
   AND BL, 1
   JZ Input2
   SHR DX, 3
   SHR CX, 3
; V CX je ted x-ova a v DX y-ova souradnice kurzoru, l.h. roh je 0,0
   SHR CX, 1
   JNC Input2
   DEC CX
   SUB DX, 3
   CMP CX, 19
   JNC Input2
   CMP DX, 19
   JNC Input2
;souradnice jsou nyni v rozmezi 0-18
   MOV AL, 19
   MUL DL
   MOV SI, CX
   MOV BX, AX
;je policko volne?
   MOV AL, [plocha+SI+BX]
   ADD AL, 0
   JNZ FirstMove

;polozim kOLECKO
   MOV [plocha+SI+BX], 2
   SUB volnapole, 1
;nakreslim kolecko
   MOV AL, 61
   MUL DL
   ADD BX, AX
   SHL SI, 2
   SHL BX, 1

   MOV CX, AX
   MOV AX, 2 ;pri kresleni mam vypnuty kurzor
   INT 51
   MOV [ES:(3*80+3)*2+SI+BX], 0011101000000000B + 'O'
   MOV AX, 1
   INT 51

   SHR SI, 2
   SHR BX, 1
   SUB BX, CX
;update plochy
   CALL Update
   ADD AX, 0
   JNZ win2
;test remizy
   ADD volnapole, 0
   JZ draw

;!!!!test remizy!

;tah pocitace:
   CALL PCMove
;polozim krizek
   MOV [plocha+SI+BX], 1
   SUB volnapole, 1
;nakreslim krizek a stary krizek zvetsim
   MOV AL, 61
   MUL CL
   ADD BX, AX
   SHL SI, 2
   SHL BX, 1
   MOV [ES:(3*80+3)*2+SI+BX], 0011110000000000B + 'X'

   MOV DI, lastPC
   CMP DI, -1
   JZ NoRepaint
   MOV [ES:(3*80+3)*2+DI], 0011010000000000B + 'X'
NoRepaint:
;ulozeni posledniho tahu
   MOV DI, BX
   ADD DI, SI
   MOV lastPC, DI

   SHR SI, 2
   SHR BX, 1
   SUB BX, AX
;update plochy
   CALL Update
   ADD AX, 0
   JNZ Win1

;test remizy
   ADD volnapole, 0
   JZ draw

   JMP FirstMove

win1:
;pocitac vyhral
   MOV AH, 00110000B
   MOV BX, -31
  Win1Loop:
   MOV AL, [winstring1+BX+31]
   MOV DI, BX
   MOV [ES:(80+24)*2+BX+DI+62], AX
   INC BX
   JNZ Win1Loop
   JMP Restart

win2:
;hrac vyhral
   MOV AH, 00110000B
   MOV BX, -23
  Win2Loop:
   MOV AL, [winstring2+BX+23]
   MOV DI, BX
   MOV [ES:(80+28)*2+BX+DI+46], AX
   INC BX
   JNZ Win2Loop
   JMP Restart

draw:
;remiza
   MOV AH, 00110000B
   MOV BX, -21
  DrawLoop:
   MOV AL, [drawstring+BX+21]
   MOV DI, BX
   MOV [ES:(80+29)*2+BX+DI+42], AX
   INC BX
   JNZ DrawLoop
   JMP Restart

;*****************************************************

PCMove PROC NEAR
    ;projdu info z nahodne vybraneho mista a vyberu prvni nalezeny tah s max body
    ;vracim v SI souradnici x, v BX y*19 a v CL vracim y-ovou souradnici
    CALL GetRandom
    MOV AX, CX
    MOV DX, 0
    MOV CX, 361
    DIV CX
    ;v DX je index policka, kde zacnu
    SHL DX, 1
    PUSH DX
    MOV DI, DX
    ;DI budu indexovat v plose
    ;SI bude obsahovat souradnice(index) zatim nejlepsiho tahu a DX jeho body
    MOV SI, -1
    MOV DX, 0
PCLoop1:
    MOV AX, [info+DI]
    CMP DX, AX
    JNC PCSkip1
    MOV SI, DI
    MOV DX, AX
PCSkip1:
    ADD DI, 2
    CMP DI, 722
    JNZ PCLoop1

;zbyva projit zbytek info
    POP DI
PCLoop2:
    MOV AX, [info+DI]
    CMP DX, AX
    JNC PCSkip2
    MOV SI, DI
    MOV DX, AX
PCSkip2:
    SUB DI, 2
    CMP DI, -2
    JNZ PCLoop2

;co kdyz stale tah nevybral?
    CMP SI, -1
    JNZ PCEnd1

;vyberem prvni mozny tah:
    XOR DI, DI
PCLoop3:
    MOV AL, [plocha+DI]
    ADD AL, 0
    JNZ PCSkip3
    MOV SI, DI
    JMP PCEnd2
PCSkip3:
    INC DI
    CMP DI, 361
    JNZ PCLoop3
;sem by program nikdy nemel prijit

PCEnd1:
    SHR SI, 1
PCEnd2:
;konvertuju souradnice do pouzivaneho tvaru
    MOV AX, SI
    MOV DL, 19
    DIV DL

    MOV CL, AL

    SHR AX, 8
    SUB SI, AX
    MOV BX, SI
    MOV SI, AX

    RET
PCMove ENDP

GetRandom PROC NEAR
;do CX ulozi nahodne cislo a vygeneruje dalsi
;pouziva jen CX a AX
   MOV CX, random
   MOV AX, 4567
   ADD CX, AX
   MOV RANDOM, CX
   RET
GetRandom ENDP

Intro PROC NEAR ;vypis uvodni hlasky
   MOV AX, 0011000000000000B
   XOR BX, BX
   MOV CX, 2000
   MOV DX, 2
  ClearLoop:
   MOV [ES:BX], AX
   ADD BX, DX
   LOOP ClearLoop

   MOV AH, 00110000B
   MOV BX, -36
  IntroLoop1:
   MOV AL, [hlaska1+BX+36]
   MOV DI, BX
   MOV [ES:(12*80+3)*2+BX+DI+72], AX
   INC BX
   JNZ IntroLoop1

   MOV BX, -26
  IntroLoop2:
   MOV AL, [hlaska2+BX+26]
   MOV DI, BX
   MOV [ES:(13*80+8)*2+BX+DI+52], AX
   INC BX
   JNZ IntroLoop2

   RET
Intro ENDP

NewBoard PROC NEAR ;vycisti info a plochu a nakresli ji, nesmi menit registr AL
   MOV CX, 0011000000000100B
   MOV DH, CH
   MOV DL, ' '

   MOV BX, 480
  NBLoop1:
   MOV DI, -76
  NBLoop2:
   MOV [ES:BX+DI+80], DX
   MOV [ES:BX+DI+82], CX
   ADD DI, 4
   JNZ NBLoop2
   ADD BX, 160
   CMP BX, 3520
   JNZ NBLoop1

   MOV BX, -34
  NBLoop3:
   MOV [ES:(11*80+53)*2+BX+34], DX
   MOV [ES:(12*80+53)*2+BX+34], DX
   MOV [ES:(13*80+53)*2+BX+34], DX
   ADD BX, 2
   JNZ NBLoop3

   XOR CX, CX
   MOV DI, 19*19
   MOV BX, OFFSET plocha
  NBLoop4:
   MOV [BX+DI-1], CL
   MOV BP, DI
   MOV [info+BP+DI-2], CX
   DEC DI
   JNZ NBLoop4

;smazat napisy
   MOV BX, -31
  NBLoop5:
   MOV DI, BX
   MOV [ES:(80+24)*2+BX+DI+62], DX
   INC BX
   JNZ NBLoop5

   RET
NewBoard ENDP

NewGame PROC NEAR ;Vypise vyzvu k nove hre
   MOV AH, 00110000B

   MOV BX, -17
  NGLoop1:
   MOV AL, [key1+BX+17]
   MOV DI, BX
   MOV [ES:(11*80+53)*2+BX+DI+34], AX
   INC BX
   JNZ NGLoop1

   MOV BX, -13
  NGLoop2:
   MOV AL, [key2+BX+13]
   MOV DI, BX
   MOV [ES:(12*80+53)*2+BX+DI+26], AX
   INC BX
   JNZ NGLoop2

   MOV BX, -8
  NGLoop3:
   MOV AL, [key3+BX+8]
   MOV DI, BX
   MOV [ES:(13*80+53)*2+BX+DI+16], AX
   INC BX
   JNZ NGLoop3

   RET
NewGame ENDP

Update PROC NEAR ; Otestuje konec hry
; v SI dostane souradnici x, v BX y*19
; Navic updatuje udaje v info, v AX vraci vysledek
    PUSH BX
    PUSH SI
    MOV DI, 1 ;citac vnejsiho cyklu
TWloop2:
    XOR DX, DX;dl=moje znacky v rade, dh=souperovy
; si <- X-5*posun[1,di]:
    POP SI
    POP BX
    PUSH BX
    PUSH SI

    AND SI, 00FFH
    CMP DI, 1
    JZ TWskip1
    SUB SI, 5
TWskip1:
; bx <- rozmery * (y-5*posun[2,di])
; BP <- rozmery * posun[2,di]
    MOV AL, BYTE PTR [posun-1+di]
    MOV AH, 19
    IMUL AH
    MOV BP, AX
    SUB BX, AX
    SHL AX, 2
    SUB BX, AX

;CX .... citac vnitrniho cyklu
    MOV CX, 9
TWloop1:
;      if DI>1 then inc(x);
    CMP DI, 1
    JZ TWskip2
    INC SI
TWskip2:
;      inkrementace y;
    MOV AX, BP
    ADD BX, AX
;      if (x>=0) and (x<rozmery) and (y>=0) and (y<rozmery) then begin
    CMP SI, 19
    JNC TWout1
    CMP BX, 19 * 19
    JNC TWout1
;if plocha[y][x]=1
    MOV AL, BYTE PTR [PLOCHA+BX+SI]
    CMP AL, 1
    JNZ Testenemy
;zvyseni poctu mich znacek a vynulovani souperovych
    XOR DH, DH
    INC DL
;vynulovani info[x,y]
    XOR AX, AX
    SHL BX, 1
    SHL SI, 1
    MOV [info+BX+SI], AX
    SHR BX, 1
    SHR SI, 1
    JMP TWout2
Testenemy:
;else if plocha[y][x]=2
    CMP AL, 2
    JNZ TWout3
;zvyseni poctu souperovych znacek a vynulovani mich
    XOR DL, DL
    INC DH
;vynulovani info[x,y]
    XOR AX, AX
    SHL BX, 1
    SHL SI, 1
    MOV [info+BX+SI], AX
    SHR BX, 1
    SHR SI, 1
    JMP TWout2

TWout3:
;prazdne pole, updatovat info
;zaloha registru
    PUSH CX
    PUSH DX
    PUSH DI
    PUSH ES
    PUSH BP
    CALL CountScore
    POP BP
    POP ES
    POP DI
    POP DX
    POP CX

;ulozeni vysledku CountScore do info
    SHL BX, 1
    SHL SI, 1
    MOV AX, body
    MOV [info+BX+SI], AX
    SHR BX, 1
    SHR SI, 1

;prazdno nebo mimo desku - vynulovat moje i souperovy
TWout1:
    XOR DX, DX

TWout2:
;vyhral pocitac?
    CMP DL, 5
    JZ TWwin1

;vyhral hrac?
    CMP DH, 5
    JZ TWwin2

;konec vnitrniho cyklu
    LOOP TWloop1

;konec vnejsiho cyklu
    INC DI
    CMP DI, 5
    JZ JSkip1
    JMP TWloop2
   JSkip1:

;nikdo zatim nevyhral
    POP AX
    POP AX
    XOR AX, AX
    RET
;PC vyhral
   TWwin1:
    POP AX
    POP AX
    MOV AX, 1
    RET

;hrac vyhral
   TWwin2:
    POP AX
    POP AX
    MOV AX, 2
    RET
Update ENDP


CountScore PROC NEAR
;v SI dostane x a v BX dostane y*rozmery
;body vraci v pameti na adrese body

;ulozim vstupni parametry:
    PUSH BX
    PUSH SI

;body=0
    XOR AX, AX
    MOV body, AX

;  vnejsi cyklus
    MOV DI, 1
Bloop3:
; es <- hodnota1:=0;
    XOR AX, AX
    MOV ES, AX
; dl <- last1:=4;
    MOV DL, 4
; dh <- last2:=4;
    MOV DH, DL

;vyberu souradnice ze zasobniku
    POP SI
    POP BX
    PUSH BX
    PUSH SI

; si <- x:=j-5*posun[1,k];
    CMP DI, 1
    JZ Bskip1
    SUB SI, 5
Bskip1:
; bx <- rozmery * y:=i-5*posun[2,k]
;  push <- rozmery * posun[2,k]
    MOV AL, byte PTR [posun-1+DI]
    MOV AH, 19
    IMUL AH
    PUSH AX
    SUB BX, AX
    SHL AX, 2
    SUB BX, AX

;    for l:=3 downto 0 do begin         ;nacteni prvnich ctyr policek
    MOV CH, 3
Bloop1:
;      if k>1 then inc(x);
    CMP DI, 1
    JZ Bskip2
    INC SI
Bskip2:
;      y:=y+posun[2,k];
    POP AX
    PUSH AX
    ADD BX, AX
;      hodnota1:=hodnota1 shl 1;
    MOV AX, ES
    SHL AX, 1
    MOV ES, AX
;      if (x>=0) and (x<rozmery) and (y>=0) and (y<rozmery) then begin
    CMP SI, 19
    JNC Bout1
    CMP BX, 19 * 19
    JNC Bout1
;if plocha[y][x]=1 then begin
    MOV AL, byte PTR [plocha+bx+si]
    CMP AL, 1
    JNZ Btestenemy
;          inc(hodnota1);
    MOV AX, ES
    ADD AX, 1
    MOV ES, AX
;          last1:=l;
    MOV DL, CH
    JMP Bout2
Btestenemy:
;        end else if plocha[y][x]=2 then begin
    CMP AL, 2
    JNZ Bout2
;          inc(hodnota1);
    MOV AX, ES
    ADD AX, 1
    MOV ES, AX
;          last2:=l;
    MOV DH, CH
    JMP Bout2
Bout1:
;       last1:=l
;       last2:=l
    MOV DH, CH
    MOV DL, CH
Bout2:
;end for l
    SUB CH, 1 ; NE dec, protoze budem testovat CARRY
    JNC Bloop1
                                         ;testovani:
;v di bude k*2
    SHL DI, 1

;    maxbody:=0;
    XOR AX, AX
    MOV BP, AX

;    for l:=0 to 4 do begin
    MOV CH, 5
Bloop2:
;      inc(last1);
    INC DL
;      inc(last2);
    INC DH
;      if k>1 then inc(x);
    CMP DI, 4
    JC Bskip3
    INC SI
Bskip3:
;      y:=y+posun[2,k];
    POP AX
    PUSH AX
    ADD BX, AX
;      hodnota1:=hodnota1 shl 1;
;hodnota1 bude nacas ulozena v ax
    MOV AX, ES
    SHL AX, 1

;      if l=0 then inc(hodnota1) else
    CMP CH, 5
    JNZ Bnotcenter
    INC AX
    JMP Bout3
Bnotcenter:
;      if (x>=0) and (x<rozmery) and (y>=0) and (y<rozmery) then begin
    CMP SI, 19
    JNC Bout4
    CMP BX, 19*19
    JNC Bout4
;        if plocha[y][x]=1 then begin
    MOV CL, byte PTR [plocha+BX+SI]
    CMP CL, 1
    JNZ Btestenemy2
;          inc(hodnota1);
;          last1:=0;
    INC AX
    XOR DL, DL
    JMP Bout3
Btestenemy2:
;        end else if plocha[y][x]=2 then begin
    CMP CL, 2
    JNZ Bout3
;          inc(hodnota1);
;          last2:=0;
    INC AX
    XOR DH, DH
    JMP Bout3
Bout4:
;        last1:=0;
;        last2:=0;
    XOR DX, DX

Bout3:
;hodnota1 se vraci do ES, x odlozim na zasobnik, v SI bude hodnota2
    MOV ES, AX
    PUSH SI

;      if last2>=5 then begin
    CMP DH, 5
    JC Bout6

;        hodnota2:=hodnota1 mod 32;
    MOV SI, ES
    AND SI, 0000000000011111B
;        if bodovani[hodnota2,true] > maxbody then begin
    SHL SI, 2
    MOV AX, word PTR [BODOVANI+SI+2]
    SHR SI, 2
    CMP BP, AX
    JNC Bworse1
;          maxbody:=bodovani[hodnota2,true];
    MOV BP, AX
Bworse1:
;        if last2>=6 then begin
    CMP DH, 6
    JNC JSkip2
    JMP Bout7
   JSkip2:
;          hodnota2:=hodnota1 mod 64 + 32;
    MOV SI, ES
    AND SI, 0000000000111111B
    ADD SI, 32
;          if bodovani[hodnota2,true] > maxbody then begin
    SHL SI, 2
    MOV AX, WORD ptr [BODOVANI+SI+2]
    SHR SI, 2
    CMP BP, AX
    JNC Bworse2
;          maxbody:=bodovani[hodnota2,true];
    MOV BP, AX
Bworse2:
;          if last2>=7 then begin
    CMP DH, 7
    JC Bout7
;            hodnota2:=hodnota1 mod 128 + 96;
    MOV SI, ES
    AND SI, 0000000001111111B
    ADD SI, 96
;            if bodovani[hodnota2,true] > maxbody then begin
    SHL SI, 2
    MOV AX, word PTR [bodovani+SI+2]
    SHR SI, 2
    CMP BP, AX
    jnc Bout7
;              maxbody:=bodovani[hodnota2,true];
    MOV BP, AX

Bout6:
;        if last1>=5 then begin
    CMP DL, 5
    JC Bout7
;          hodnota2:=hodnota1 mod 32;
    MOV SI, ES
    AND SI, 0000000000011111B
;          if bodovani[hodnota2,false] > maxbody then begin
    SHL SI, 2
    MOV AX, word PTR [bodovani+SI]
    SHR SI, 2
    CMP BP, AX
    JNC Bworse3
;            maxbody:=bodovani[hodnota2,false];
    MOV BP, AX
Bworse3:
;          if last1>=6 then begin
    CMP DL, 6
    JC Bout7
;            hodnota2:=hodnota1 mod 64 + 32;
    MOV SI, ES
    AND SI, 0000000000111111B
    ADD SI, 32
;            if bodovani[hodnota2,false] > maxbody then begin
    SHL SI, 2
    MOV AX, word PTR [bodovani+SI]
    SHR SI, 2
    CMP BP, AX
    JNC Bworse4
;              maxbody:=bodovani[hodnota2,false];
    MOV BP, AX
Bworse4:
;            if last1>=7 then begin
    CMP DL, 7
    JC Bout7
;              hodnota2:=hodnota1 mod 128 + 96;
    MOV SI, ES
    AND SI, 0000000001111111B
    ADD SI, 96
;              if bodovani[hodnota2,false] > maxbody then begin
    SHL SI, 2
    MOV AX, word PTR [BODOVANI+SI]
    SHR SI, 2
    CMP BP, AX
    JNC Bout7
;                maxbody:=bodovani[hodnota2,false];
    MOV BP, AX

Bout7:
;x vyberu ze zasobniku
    POP SI

;konec vnitrniho cyklu pro l
    DEC CH
    JZ JSkip3
    JMP Bloop2
   JSkip3:

;prictu maxbody k vysledku
    MOV AX, body
    ADD AX, BP
    JNC BNotC
    MOV AX, -1
   BNotC:
    MOV BODY, AX

;vydelim k dvema
    SHR DI, 1

;vyberu dy ze zasobniku (a zahodim)
    POP AX

;konec vnejsiho cyklu pro k
    INC DI
    CMP DI, 5
    JZ JSkip4
    JMP Bloop3
   JSkip4:
    POP SI
    POP BX

    RET
CountScore ENDP

END
