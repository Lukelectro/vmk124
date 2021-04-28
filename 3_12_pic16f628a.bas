'****************************************************************
'*  Name    : 3_12.BAS                                          *
'*  Author  : Lucas Volwater                                    *
'*  Notice  : Copyright (c) 2010 L.J.P. Volwater                *
'*          : All Rights Reserved                               *
'*  Date    : 27-12-2010                                        *
'*  Version : 3.12                                              *
'*  Notes   : Velleman Kit 124 Hacked. Kan nu tot 128 tekens    *
'*          : weergeven, onthouden in EEPROM, en instelbaar     *
'****************************************************************

' Nieuw in 3.12:
' Naast hoofdletters ook kleine letters, meer tekens, mooier font.
' opstartscherm
' Bug gefixed: per wijziging kwam er een spatie voor de tekst, nu niet meer.
' Er is een easter egg. Druk in standby eens op SET? (voor meer spoilers:
' zie de code, of kijk helemaal onderaan.


Device 16F628A
Config BOREN_ON, CP_OFF, DATA_CP_OFF, PWRTE_ON, WDT_OFF, LVP_OFF, MCLRE_On, RC_OSC_NOCLKOUT

All_Digital = TRUE		   		; alle pinnen digital in/out
PortB_Pullups Off
;        76543210             hulpregeltje
TRISA = %00110000			  ;datarichting.
TRISB = %00000000
Symbol kolom1=PORTB.7		 ; verwijzingen
Symbol kolom2=PORTA.2
Symbol kolom3=PORTA.3
Symbol kolom4=PORTA.0
Symbol kolom5=PORTA.1
Symbol kolom6=PORTB.6
Symbol kolom7=PORTB.1

Symbol rij1=PORTB.3
Symbol rij2=PORTB.5
Symbol rij3=PORTB.4
Symbol rij4=PORTB.2
Symbol rij5=PORTB.0

Symbol stby=PORTB.3
Symbol run=PORTB.4
Symbol sed=PORTB.5

Symbol muxtijd = 9 ' afh. van kloksnelheid. Richtwaarden: voor 4mhz:9. Voor 8Mhz: 18, etc. 
Symbol boottijd = 16 ; tijd dat het startscherm wordt weergegeven.

'symbols voor pointer naar letter:
Symbol t_A = 0 
Symbol t_B = 3
Symbol t_C = 6
Symbol t_D = 9
Symbol t_E = 12
Symbol t_F = 15
Symbol t_G = 18
Symbol t_H = 21
Symbol t_I = 24
Symbol t_J = 27
Symbol t_K = 30
Symbol t_L = 33
Symbol t_M = 36
Symbol t_N = 39
Symbol t_O = 42
Symbol t_P = 45
Symbol t_Q = 48
Symbol t_R = 51
Symbol t_S = 54
Symbol t_T = 57
Symbol t_U = 60
Symbol t_V = 63
Symbol t_W = 66
Symbol t_X = 69
Symbol t_Y = 72
Symbol t_Z = 75
Symbol T_0 = 78
Symbol T_1 = 81
Symbol T_2 = 84
Symbol T_3 = 87
Symbol T_4 = 90
Symbol T_5 = 93
Symbol T_6 = 96
Symbol T_7 = 99
Symbol T_8 = 102
Symbol T_9 = 105
Symbol T_Ex = 108 ; uitroepteken !
Symbol T_qu = 111 ; vraagteken ?
Symbol T_pnt = 114; punt
Symbol T_comma = 117
Symbol T_AT = 120 ; apenstaart @
Symbol T_hs = 123 ; - hoog streepje
Symbol T__ = 126 ; laag streepje
Symbol T_til = 129 ; tilde ~
Symbol T_slash = 132 ; /
Symbol T_sp = 135 ; spatie
Symbol T_Hop = 138 ; Haakje OPenen (
Symbol T_Hsl = 141 ; Hoge Snelheids Lijn... Haakje sluiten )
Symbol T_star = 144 ;  sterretje *
Symbol T_sstr = 147 ; schuine streep \
Symbol T_is = 150 ; = teken
Symbol T_luv = 153; hartje
Symbol T_PR = 156; pijl rechtsaf
Symbol T_PL = 159; pijl linksaf
Symbol T_pls = 162; plusteken +
Symbol T_dp = 165; dubbele punt :
Symbol T_pk = 168 ; puntkomma ;
Symbol T_la = 171; lowercase a
Symbol T_lb = 174
Symbol T_lc = 177
Symbol T_ld = 180
Symbol T_le = 183
Symbol T_lf = 186
Symbol T_lg = 189
Symbol T_lh = 192
Symbol T_li = 24 ; er is geen lowercase I, dat is dezelfde letter 
Symbol t_lj = 195
Symbol t_lk = 198
Symbol t_ll = 201
Symbol t_lm = 204
Symbol t_ln = 207
Symbol t_lo = 210
Symbol t_lp = 213
Symbol t_lq = 216
Symbol t_lr = 219
Symbol t_ls = 222
Symbol t_lt = 225
Symbol t_lu = 228
Symbol t_lv = 231
Symbol t_lw = 234
Symbol t_lx = 237
Symbol t_ly = 240
Symbol t_lz = 243
Symbol t_EOT = 246 ; end of text




Dim DispRam[7] As Byte  ' display ram buffer, 7 bytes, 0 tm 6.
'jaja, 7 hele bytes videogeheugen...
Dim RijReg As Byte 'omdat het niet direct kan...
Dim MuxTel As Byte
Dim Kolom As Byte 'houdt bij welke kolom we aan het muxen zijn.
Dim LetterDeel As Byte  ; dit is het volgende stukje letter dat in de display ram gezet wordt
Dim LetterPointer As Byte 'wijst letterdeel aan in flashromtabel (letterpointer=karakterindex+letterindex)
Dim KarakterIndex As Byte 'wijst karakter aan 
Dim LetterIndex As Byte   'wijst deel van karakter aan
Dim LetterTeller As Byte 'geeft aan hoeveelste letter van de tekst we nu weer moeten gaan geven.
Dim editindex As Byte 'geeft aan hoeveelste letter we aan het editten zijn.
Dim e_letter_nu As Byte 'geeft de huidige te wijzigen letter
Dim e_letter_vorig As Byte 'vorige te wijzigen letter
Dim telbyte As Byte ; tellertje
Dim eitje As Byte 'tussenvariabele voor easter egg animatie...

; opstart scherm:

'even uitkijken dat 'ie niet gespiegeld is.

DispRam[0] = $08
DispRam[1] = $07
DispRam[2] = $04
DispRam[3] = $08
DispRam[4] = $1f
DispRam[5] = $05
DispRam[6] = $02
    For telbyte = 0 To boottijd
    GoSub screenrefresh
    Next

scrolltekst:
Clear ; alle vars starten op 0.
GoSub allesuit
LetterIndex = 3 ; beginnen met een lege kolom en daarna de juiste letter. 
;(anders eerste letter altijd a)
LetterTeller = 0

Repeat    
    If LetterIndex < 3 Then ;
    LetterPointer = (KarakterIndex + LetterIndex)
    ' karakterindex geeft in stappen van 3 weer welke letter, letterindex geeft aan waar we zijn
    ; binnen de letter (loopt van 0 tot 2)
    
    ; letter uit flash rom halen:
    GoSub getchar
    Inc LetterIndex
    ElseIf LetterIndex = 3 Then
    LetterDeel = 0
    LetterIndex = 0
   
    'volgende letter
    KarakterIndex = ERead LetterTeller
        If KarakterIndex < t_EOT  Then ; zolang we nog niet aan het einde zijn (EOT)
        Inc LetterTeller
        Else             ; als we dat wel zijn
        ; opnieuw beginnen
        LetterTeller = 0 ;bij letter 0
        LetterIndex = 3 ; en niet stiekum nog een stukje a.
        End If
   
    EndIf
            
DispRam[0] = DispRam[1]
DispRam[1] = DispRam[2]
DispRam[2] = DispRam[3]
DispRam[3] = DispRam[4]
DispRam[4] = DispRam[5]
DispRam[5] = DispRam[6]
DispRam[6] = LetterDeel 'nieuwe letterdeel. (repeat until nieuwe letterdeel = 255)
'nieuwe letterdeel komt uit LUT met alfabet. Positie aangewezen door pointer uit eeprom
'naar eerste stuk van de leter (letter heeft 3 stukken, daarna komt een lege rij = 0, dan volgende letter.

GoSub screenrefresh

'schakelaars testen.
If sed = 1 Then GoTo sedt ; die dingen zijn actief hoog !?!   
If stby = 1 Then GoTo stdby 

Until 1=0

stdby: ; als stby is ingedrukt
GoSub allesuit
kolom4 = 0
   Repeat
   rij5 = 1
   DelayMS 100
   rij5 = 0
   DelayMS 900
   If sed = 1 Then GoSub pasen
   Until run = 1 ; run wordt geen 1... Maffe switches zijn niet alleen actief hoog,
   ; maar ook nog eens alleen actief als porta.0 (kolom 4) laag is... anders doen ze niks...
   ; Welke gedachte zit daar in vredesnaam achter?
GoTo scrolltekst ; GOTO! AAAAAAAAAAAAARG. Maar werkt wel het beste hier.

pasen: 'easter egg
    Repeat 
    DelayMS 50
    Until sed = 0
'(Game of Life zou gaaf zijn, of dodgeball, 
' maar animatie is makkelijker)
DispRam[0] = $11
DispRam[1] = $0a
DispRam[2] = $11
DispRam[3] = $0a
DispRam[4] = $0a
DispRam[5] = $04
DispRam[6] = $0a    
telbyte = 0    
    Repeat 'animatie
    Inc telbyte
    eitje = DispRam[0]
    DispRam[0] = DispRam[1]
    DispRam[1] = DispRam[2]
    DispRam[2] = DispRam[3]
    DispRam[3] = DispRam[4]
    DispRam[4] = DispRam[5]
    DispRam[5] = DispRam[6]
    DispRam[6] = eitje
    GoSub screenrefresh   
    Until sed = 1 Or telbyte = 65 Or run = 1
    If sed = 1 Then   
        Repeat
        DelayMS 50
        Until sed = 0
    Return
    End If
DispRam[0] = 1
DispRam[1] = 0
DispRam[2] = 0
DispRam[3] = 0
DispRam[4] = 0
DispRam[5] = 0
telbyte = 0
DispRam[6] = %11001
    Repeat 'dodgeball
    eitje = DispRam[1]
    DispRam[1] = DispRam[2]
    DispRam[2] = DispRam[3]
    DispRam[3] = DispRam[4]
    DispRam[4] = DispRam[5]
    DispRam[5] = DispRam[6]
   ' Random DispRam[6]
   '     if dispram[6] < 224 then ;87% kans op lege ruimte 
   '     dispram [6] = 0
   '     end if  
    'afvangen dat er geen doorgang is?
    'nee, das voor watjes...
    
    'random wil niet echt. Dan maar zo:
    Inc telbyte    
        If telbyte = 32 Then
        DispRam[6] = %01010
        telbyte = 0
        ElseIf telbyte = 5 Then
        DispRam[6] = %10101
        ElseIf telbyte = 9 Then
        DispRam[6] = %00111
        ElseIf telbyte = 15 Then
        DispRam[6] = %11100
        ElseIf telbyte = 20 Then
        DispRam[6] = %11011
        ElseIf telbyte = 26 Then
        DispRam[6] = %01101
        Else
        DispRam[6] = 0
        End If
    GoSub screenrefresh   
        If stby = 1 Then
        DispRam[0] = DispRam[0] >> 1
            If DispRam[0] = 0 Then
            DispRam[0] = 1
            End If
         End If
        If run = 1 Then
        DispRam[0] = DispRam[0] << 1
            If DispRam[0] > 16 Then
            DispRam[0] = 16
            End If
         End If
     eitje = (eitje & DispRam[0]) 'botsingdetectie
            If eitje > 0 Then
            Return
            End If 
    ' Pixel op rij 0 kun je up/down bewegen met stby/run
    ' set sluit af.
    'op rij 7 komen random dingen die richting rij 1 bewegen
    'die moet ontwijken.
    Until sed = 1 
Return

    
sedt:
   Repeat        ; wachten tot 'ie is losgelaten
   DelayMS 100
   Until sed = 0 
editindex = 0   
DispRam[3] = 0
e_letter_vorig = T_sp ; beginnen met spatie als vorige letter.

; bugje: Deze spatie wordt er ook (onwijzigbaar) voorgezet in eeprom...
; bugfix: E_letter_nu wegschrijven ipv vorig. Scheelt nog een if-then ook.

    Repeat
    e_letter_nu = ERead editindex
       
       Repeat
       LetterPointer = e_letter_nu
       GoSub getchar
       DispRam[4]=LetterDeel
       Inc LetterPointer
       GoSub getchar
       DispRam[5]=LetterDeel
       Inc LetterPointer
       GoSub getchar
       DispRam[6]=LetterDeel
       
       LetterPointer = e_letter_vorig
       GoSub getchar
       DispRam[0]=LetterDeel
       Inc LetterPointer
       GoSub getchar
       DispRam[1]=LetterDeel
       Inc LetterPointer
       GoSub getchar
       DispRam[2]=LetterDeel
       
            If stby = 1 Then ; letter "up"           
            e_letter_nu = e_letter_nu + 3 
            End If
            
            If run = 1 Then ; letter "down"
            e_letter_nu = e_letter_nu - 3 
            End If
        ; voorkomen dat we  buiten tabel komen    
        If e_letter_nu > (t_EOT + 3) Then e_letter_nu = t_EOT ; (Eigenlijk: indien < 0)
        If e_letter_nu > t_EOT Then e_letter_nu = 0   ; hier staat wel wat er staat
        
        If editindex > 126 Then e_letter_nu = t_EOT ; bij laatste eepromadres verplicht EOT
            
       GoSub screenrefresh
                 
       Until sed = 1
       
       Repeat
       DelayMS 100
       Until sed = 0        
             
    EWrite editindex, [e_letter_nu]
    
    e_letter_vorig = e_letter_nu
    Inc editindex     
    Until e_letter_nu = t_EOT

GoTo scrolltekst
    
    
        
getchar:;
; letter uit flash rom halen:
;                                       A          B               C           D
LetterDeel = LookUp LetterPointer, [$1e,$05,$1e, $1f,$15,$0A, $0e,$11,$11, $1f,$11,$0e,_
;  E             F           G            H             I            J            K
$1f,$15,$11, $1f,$05,$05, $0e,$11,$1d, $1f,$04,$1f, $00,$1d,$00, $08,$10,$0f, $1f,$04,$1b,_
; L             M            N             O            P             Q             R
$1f,$10,$18, $1f,$02,$1f, $1f,$01,$1e, $0e,$11,$0e, $1f,$09,$06, $06,$09,$1f, $1f,$05,$1a,_
;S            T             U            V            W             X             y
$12,$15,$09, $01,$1f,$01, $1f,$10,$1f, $0f,$10,$0f, $1f,$08,$1f, $1b,$04,$1b, $03,$1c,$03,_
;Z             0            1            2              3              4           5
$19,$15,$13, $1f,$11,$1f, $12,$1f,$10, $12,$19,$16, $11,$15,$0a, $07,$04,$1f, $17,$15,$09,_
;      6     7             8             9                !           ?            .
$0e,$15,$08, $01,$05,$1f, $0a,$15,$0a, $02,$15,$0e, $00,$17,$00, $01,$15,$02, $00,$18,$18,_
;     ,         @              -          _              ~            /          <spatie>    
$00,$08,$18, $0e,$11,$06, $04,$04,$04, $10,$10,$10, $06,$02,$03, $10,$0e,$01, 0,%00000000,0,_
;     (        )              *             \           =          <3             ->     
$0e,$11,$0, $00,$11,$0e, $15,$0e,$15, $01,$0e,$10, $0a,$0a,$0a, $06,$0c,$06, $04,$0e,$1f,_
;   <-           +            :          ;            a         b        
$1f,$0e,$04, $04,$0e,$04, $00,$0a,$00, $00,$1a,$00 ,$09,$15,$1e, $1f,$14,$08,_
;    c            d             e         f          g               h         j(I=i)
$08,$14,$00, $08,$14,$1e, $0c,$1a,$14, $1e,$05,$00, $12,$15,$0f, $1f,$04,$18, $10,$0d,$00,_
;  k            l           m           n            o              p           q
$1f,$08,$14, $1f,$00,$00, $1e,$04,$1e, $1c,$04,$18, $08,$14,$08, $1f,$05,$02 ,$02,$05,$1f,_
; r            s           t               u            v            w              x
$1e,$02,$04, $14,$16,$0a, $0f,$12,$00, $0c,$10,$1c, $1c,$10,$0c, $1e,$08,$1e, $14,$08,$14,_
; y,           z,          EOT
$13,$14,$0f, $14,$1c,$14 ,$04,$0A,$11]
' een spatie is geen verspild geheugen, het is het vaakst gebruikte karakter... 
'(het anders oplossen had trouwens meer geheugen gekost)

Return

screenrefresh:
TRISB = 0 ; alles output
For MuxTel = 0 To muxtijd
    For Kolom = 0 To 6
    kolom7 = 1 ; kolom uit voor je de rijen veranderd, anders ghosting.
    kolom1 = 1
    kolom2 = 1
    kolom3 = 1
    kolom4 = 1
    kolom5 = 1
    kolom6 = 1
    
    ' als 'ie rij1 = dispram[kolom].x niet slikt dan met andmask doen:
    'moet zelfs via tussenwaarde...
    RijReg = DispRam[Kolom] 
    rij1 = RijReg.0
    rij2 = RijReg.1
    rij3 = RijReg.2
    rij4 = RijReg.3
    rij5 = RijReg.4
        If Kolom = 0 Then
        kolom1 = 0
        ElseIf Kolom = 1 Then
        kolom2 = 0
        ElseIf Kolom = 2 Then
        kolom3 = 0
        ElseIf Kolom = 3 Then
        kolom4 = 0
        ElseIf Kolom = 4 Then
        kolom5 = 0
        ElseIf Kolom = 5 Then
        kolom6 = 0
        ElseIf Kolom = 6 Then
        kolom7 = 0
        EndIf
    DelayMS 3
    Next
Next
TRISB = %00111000'stby,sed,en run als input
Return

allesuit:
rij1 = 0
rij2 = 0
rij3 = 0
rij4 = 0
rij5 = 0

kolom1 = 1
kolom2 = 1
kolom3 = 1
kolom4 = 1
kolom5 = 1
kolom6 = 1
kolom7 = 1
Return


;EData 57,21,12,132,48,60,24,6,30,132,3,51,42,66,39,132,_
;    15,42,69,132,27,60,36,45,54,132,42,63,12,51,132,0,132,33,0,75,72,132,9,42,18,135
;    ;THE QUICK BROWN FOX JUMPS OVER A LAZY DOG.


EData t_V,t_M,t_K,T_1,T_2,T_4,T_sp,t_H,t_A,t_C,t_K,T_sp,T_hs,T_sp,t_T,t_O,t_T,T_sp,T_1,T_2,_
T_8,T_sp,t_T,t_E,t_K,t_E,t_N,t_S,T_sp,t_I,t_N,T_sp,t_P,t_L,t_A,t_A,t_T,t_S,T_sp,t_V,t_A,t_N,T_1,_
T_6,T_Ex,T_sp,t_K,t_I,t_J,t_K,T_sp,t_O,t_P,T_sp,t_H,t_O,t_M,t_E,T_pnt,t_D,t_E,t_D,t_S,T_pnt,_
t_N,t_L,T_slash,T_til,t_E,t_L,t_E,t_K,t_T,t_R,t_O,t_N,t_I,t_C,t_A,T_sp,T_sp,t_EOT
 ;vmk124 hack - tot 128 tekens in plaats van 16! kijk op home.deds.nl/~elektronica 
 
 
 
 'EASTER EGG SPOILER:
 'in standby op set drukken levert een animatie op. Na even wachten (of op run drukken)
 'kun je dodgeball spelen. Stby voor omhoog, run voor omlaag, set om af te sluiten.
 'En als je geraakt wordt of afsluit ga je weer naar standby. Met run zie je weer de tekst.
 
 '890 program words, 32 vars. 
 
 
