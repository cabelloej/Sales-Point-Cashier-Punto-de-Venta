close data
close index
close all
clear all
release all
*** Inicio del setup de foxpro
set alternate off
set ansi on
set autosave on
set bell on
set blink on
set blocksize to 32
set border to single
set brstatus off
set carry off
set century on
set clear on
set clock off
set color to
set compatible foxplus
set confirm off
set console off
set currency to
set cursor on
set date italian
*set debug off
set decimal to 2
set default to
set delete on
set delimiters off
set development on
set device to screen
*set display to    (no usar)
set dohistory off
set echo off
set escape off
set exact off
set exclusive off
set fields off
set fixed on
*set format to     (no usar, primero verifique)
set fullpath on
*set funtion       (muy interesante, primero verificar)
set heading on
set help off
set hours to 24
set intensity on
set keycomp to dos
set lock off
set message to
set mouse on
set multilocks on
set near off
set notify off
set odometer to
set optimize off
set palette off
set point to
set printer to
set procedure to sysproc
set readborder off
set refresh to 0
set reprocess to 2 seconds
*set resource off
set safety off
set scoreboard off
set separator to
set shadows on
*set skip (one to many relation)
set space on
set status off
set status bar off
set step off
set sticky on
set sysmenu off
set talk off
*set textmerge off
set typeahead to 5
set unique off
*** fin del setup del foxpro

****************************************************************************
SELECT 1
USE SYSUSER  INDEX SYSUSER
SELECT 2
USE SYSUSERD INDEX SYSUSERD
CLEAR
STORE 0 TO WCONTERR
STORE .T. TO WACCCHK
DO WHILE WACCCHK
   STORE SPACE(8) TO WUSERCODE
   @ 09,10 CLEAR TO 15,70
   SET COLOR TO GR+/B
   @ 12,10       TO 15,70 DOUBLE
   SET COLOR TO GR+/B
   @ 09,25 SAY "LIC. LOS CANARIOS, C.A.       "
   SET COLOR TO
   @ 11,31 SAY "CONTROL DE ACCESO"
   @ 13,15 SAY "INGRESE SU CODIGO:"
   @ 13,34 GET WUSERCODE
   READ
   IF LASTKEY()=27.OR.WUSERCODE=SPACE(10)
      STORE .F. TO WACCCHK
      EXIT
   ENDIF
   SELECT 1
   SEEK WUSERCODE
   IF .NOT. FOUND()
      STORE "Codigo de usuario no registrdado, reintente" TO WTEXT
      DO AVISO WITH WTEXT
      STORE WCONTERR+1 TO WCONTERR
      LOOP
   ENDIF
   @ 13,45 SAY USERDESC
   @ 14,15 SAY "INGRESE SU CLAVE :"
   STORE SPACE(10) TO WUSERACC
   SET COLOR TO B/B,B/B,B/B,B/B,B/B,B/B,B/B,B/B/B/B
   @ 14,34 GET WUSERACC
   READ
   SET COLOR TO
   IF USERACC=WUSERACC
      STORE USERUBI TO WUSERUBI
      STORE USERNOM TO WUSERNOM
      EXIT
   ELSE
      IF WCONTERR>=3
         STORE .F. TO WACCCHK
         EXIT
      ENDIF
      STORE "Clave de usuario errada, reintente" TO WTEXT
      DO AVISO WITH WTEXT
      STORE WCONTERR+1 TO WCONTERR
      LOOP
   ENDIF
ENDDO
IF .NOT. WACCCHK
   IF LASTKEY()<>27
      STORE "Acceso denegado, favor verifique su codigo y clave" to wtext
      do aviso with wtext
   ENDIF
   QUIT
ENDIF
SET COLOR TO
*** INI CONTROL DE ACCESO
STORE "SYSMENU" TO WPROGRAMA
STORE SPACE(1)  TO WACCESO
STORE SPACE(1)  TO WFILTRO
DO CHKACC WITH WUSERCODE,WPROGRAMA,WACCESO,WFILTRO
*** FIN CONTROL DE ACCESO
select 3
use ptodata
store topfac1 to wtopfac1
store topfac2 to wtopfac2
store topfac3 to wtopfac3
store piefac1 to wpiefac1
store piefac2 to wpiefac2
store piefac3 to wpiefac3
CLOSE DATA
CLOSE INDEX
**************************************************************************
STORE "LIC. LOS CANARIOS, C.A.        " TO QQWW
clear
on escape
SET COLOR TO GR+/B
@ 0,30 say "Punto de venta Ver. 1.0"
SET COLOR TO
@ 1,00 SAY QQWW
@ 2,00 SAY "Modulo:                        "
@ 2,61 SAY "por Eduardo Cabello"
defi wind winmes from 22,0 to 24,79
*define menu menumain bar at line 3 shadow
define menu menumain bar at line 3
       define pad  pad00 of menumain prompt "\<Archivos     "
       define pad  pad01 of menumain prompt "\<Ventas       "
       define pad  pad02 of menumain prompt "\<Reportes     "
       define pad  pad03 of menumain prompt "\<Otros        "
       define pad  pad04 of menumain prompt "\<Salida       "
       on pad      pad00 of menumain activate popup sub00
       on sele pad pad01 of menumain do syspto
       on pad      pad02 of menumain activate popup sub02
       on pad      pad03 of menumain activate popup sub03
       on sele pad pad04 of menumain do salida
       *** archivos
       DEFINE POPUP SUB00 FROM 4,0 shadow
          DEFINE BAR 01 OF SUB00 PROMPT "\<Operadores          "
          DEFINE BAR 02 OF SUB00 PROMPT "\<Lineas de articulos "
          DEFINE BAR 03 OF SUB00 PROMPT "\<Articulos           "
          ON SELECTION POPUP sub00 DO PROSUB00 WITH BAR()
       *** REPORTES
       DEFINE POPUP SUB02 FROM 4,10 shadow
          DEFINE BAR 01 OF SUB02 PROMPT "ventas por \<Factura  "
          DEFINE BAR 02 OF SUB02 PROMPT "ventas por \<Articulo "
          DEFINE BAR 03 OF SUB02 PROMPT "ventas por \<Impuesto "
          DEFINE BAR 04 OF SUB02 PROMPT "listado de \<Lineas   "
          DEFINE BAR 05 OF SUB02 PROMPT "listado de ar\<Ticulos"
          ON SELECTION POPUP sub02 DO PROSUB02 WITH BAR()
       *** OTROS
       DEFINE POPUP SUB03 FROM 4,20 shadow
          DEFINE BAR 01 OF SUB03 PROMPT "\<Reorganizar indices "
          DEFINE BAR 02 OF SUB03 PROMPT "\<Anular facturas     "
          ON SELECTION POPUP sub03 DO PROSUB03 WITH BAR()
*** ACTIVACION DEL MENU PRINCIPAL
do while .t.
   ACTIVATE MENU menumain 
enddo
*** RUTINAS
******************
PROCEDURE PROSUB00
******************
PARAMETERS SELBAR
*** INI CONTROL DE ACCESO
SELECT 20
USE SYSUSERD INDEX SYSUSERD
STORE "SYSMENU" TO WPROGRAMA
STORE SPACE(1)  TO WACCESO
STORE SPACE(1)  TO WFILTRO
DO CHKACC WITH WUSERCODE,WPROGRAMA,WACCESO,WFILTRO
SELECT 20
USE
*** FIN CONTROL DE ACCESO
DO CASE
   CASE SELBAR = 1
   IF WACCESO="A"
      select 1
      use SYSUSER INDEX SYSUSER
      SELECT 2
      USE SYSUSERD INDEX SYSUSERD
      SELECT 3
      USE SYSPRG INDEX SYSPRG
      librUSR=5
      cibrUSR=0
      do sysuser
      close data
      close index
   ENDIF
   CASE SELBAR = 2
     IF WACCESO="A"
        do opelin
        librlin=5
        cibrlin=0
        do syslin
        close data
        close index
     ENDIF
   CASE SELBAR = 3
IF WACCESO="A"
        do opeart
        librart=5
        cibrart=0
        do sysart
        close data
        close index
     ENDIF
ENDCASE
ON KEY LABEL F1
ON KEY LABEL F2
ON KEY LABEL F3
ON KEY LABEL F4
ON KEY LABEL F5
ON KEY LABEL F6
ON KEY LABEL F7
ON KEY LABEL F8
ON KEY LABEL F9
ON KEY LABEL F10
ON KEY LABEL F11
ON KEY LABEL F12
RETURN
*** 
******************
PROCEDURE PROSUB02
******************
PARAMETERS SELBAR
*** INI CONTROL DE ACCESO
SELECT 20
USE SYSUSERD INDEX SYSUSERD
STORE "SYSREP"  TO WPROGRAMA
STORE SPACE(1)  TO WACCESO
STORE SPACE(1)  TO WFILTRO
DO CHKACC WITH WUSERCODE,WPROGRAMA,WACCESO,WFILTRO
SELECT 20
USE
*** FIN CONTROL DE ACCESO
DO CASE
   CASE SELBAR = 1
   IF WACCESO="A"
      DO SYSREP1
   ENDIF
   CASE SELBAR = 2
   IF WACCESO="A"
      DO SYSREP2
   ENDIF
   CASE SELBAR = 3
   IF WACCESO="A"
      DO SYSREP3
   ENDIF
   CASE SELBAR = 4
   IF WACCESO="A"
      DO SYSREP4
   ENDIF
   CASE SELBAR = 5
   IF WACCESO="A"
      DO SYSREP5
   ENDIF
ENDCASE
ON KEY LABEL F1
ON KEY LABEL F2
ON KEY LABEL F3
ON KEY LABEL F4
ON KEY LABEL F5
ON KEY LABEL F6
ON KEY LABEL F7
ON KEY LABEL F8
ON KEY LABEL F9
ON KEY LABEL F10
ON KEY LABEL F11
ON KEY LABEL F12
RETURN
******************
PROCEDURE PROSUB03
******************
PARAMETERS SELBAR
*** FIN CONTROL DE ACCESO
DO CASE
   CASE SELBAR = 1
      DO INDICES
   CASE SELBAR = 2
      DO SYSNUL
ENDCASE
ON KEY LABEL F1
ON KEY LABEL F2
ON KEY LABEL F3
ON KEY LABEL F4
ON KEY LABEL F5
ON KEY LABEL F6
ON KEY LABEL F7
ON KEY LABEL F8
ON KEY LABEL F9
ON KEY LABEL F10
ON KEY LABEL F11
ON KEY LABEL F12
RETURN
****************
PROCEDURE SALIDA
****************
RELEASE MENUMAIN
CLOSE DATA
CLOSE INDEX
CLOSE ALL
RELEASE ALL
QUIT
******************
PROCEDURE INDICES
******************
DO INDLIN
DO INDART
DO INDVTAG
DO INDVTAD
RETURN








