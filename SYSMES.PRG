close data
close index
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


SAVE SCRE TO WSCRENUL
STORE YEAR(DATE())    TO WWANO
STORE MONTH(DATE())-1 TO WWMES
STORE 50              TO WWPOR
STORE "N"             TO WWCON
STORE SPACE(7)        TO WWCLA

@ 04,00 CLEAR TO 10,40
@ 04,00 TO 10,40 DOUBLE
@ 04,11 SAY " REORGANIZA MES "
@ 05,10 SAY "CLAVE       :"
@ 06,10 SAY "A�O         :"
@ 07,10 SAY "MES         :"
@ 08,10 SAY "% DESCUENTO :"
@ 09,10 SAY "CONFORME?   :"

@ 05,25 GET WWCLA
READ
IF LASTKEY()=27 .OR. WWCLA <> "8329720"
   RESTORE SCRE FROM WSCRENUL
   DO SALIDA
ENDIF
@ 06,25 GET WWANO PICTURE "9999"
READ
IF LASTKEY()=27 WWANO = 0
   RESTORE SCRE FROM WSCRENUL
   DO SALIDA
ENDIF
@ 07,25 GET WWMES PICTURE "99"
READ
IF LASTKEY()=27 .OR. WWMES< 1.OR.WWMES>12
   RESTORE SCRE FROM WSCRENUL
   DO SALIDA
ENDIF
@ 08,25 GET WWPOR PICTURE "99.99"
READ
IF LASTKEY()=27 .OR. WWPOR < 1
   RESTORE SCRE FROM WSCRENUL
   DO SALIDA
ENDIF
@ 09,25 GET WWCON
READ
IF LASTKEY()=27 .OR. UPPER(WWCON) <> "S"
   RESTORE SCRE FROM WSCRENUL
   DO SALIDA
ENDIF

SELECT 1
USE SYSVTAG INDEX SYSVTAG3
SELECT 2
USE SYSVTAD INDEX SYSVTAD1

*** DETERMINA EL ULTIMO NUMERO DE FACTURA DEL MES ANTERIOR
STORE "0000000" TO WFACINI
SELECT SYSVTAG
SET ORDER TO SYSVTAG3
SEEK STR(WWANO,4)+STR(WWMES,2)
IF FOUND()
   STORE RECNO()         TO WRECSTART
   SKIP -1
   IF .NOT.EOF()
      STORE FACTURA      TO WFACINI
   ENDIF
ELSE
   STORE "NO HAY VENTAS PARA EL MES SELECCIONADO" TO WTEXT
   DO AVISO WITH WTEXT
   DO SALIDA
ENDIF


SELECT SYSVTAG
GO WRECSTART
STORE 0 TO WDAYRUP
DO WHILE .NOT.EOF().AND.YEAR(FECHA)=WWANO.AND.MONTH(FECHA)=WWMES
   STORE RECNO() TO WRECDAY
   *** CAMBIO DE DIA
   IF WDAYRUP <> DAY(FECHA)
      STORE "REDUCE LA VENTA DEL "+STR(WDAYRUP,2)+" AL NUEVO MONTO" TO WTEXT
      DO COMUNICA
      STORE DAY(FECHA) TO WDAYRUP
      STORE 0 TO WTOTREAL
      DO CALDAY
      STORE (WTOTREAL*WWPOR)/100 TO WTOTFALSO
      STORE 0                    TO WTOTACUM
   ENDIF
   GO WRECDAY

   STORE FACTURA TO WFACTURA
   *** BORRA EL EXESO DE SYSVTAG
   IF WTOTACUM>WTOTFALSO
      IF FILLOC()
         DELETE
         UNLOCK ALL
      ELSE
         STORE "REGISTRO GENERAL BLOQUEADO, FAVOR REINTENTE OPERACION" TO WTEXT
         DO AVISO WITH WTEXT
         DO SALIDA
      ENDIF
   ENDIF
   SELECT SYSVTAD
   SEEK WFACTURA
   DO WHILE .NOT.EOF().AND.FACTURA=WFACTURA
      STORE WTOTACUM+TOTAL TO WTOTACUM
      *** BORRA EL EXESO DE SYSVTAD
      IF WTOTACUM>WTOTFALSO
         IF FILLOC()
            DELETE
            UNLOCK ALL
         ELSE
            STORE "REGISTRO DETALLE BLOQUEADO, FAVOR REINTENTE OPERACION" TO WTEXT
            DO AVISO WITH WTEXT
            DO SALIDA
         ENDIF
      ENDIF
      SELECT SYSVTAD
      SKIP
   ENDDO
   SELECT SYSVTAG
   SKIP
ENDDO

*** ABRE ARCHIVOS TEMPORALES
SELECT SYSVTAG
COPY STRU TO SYSMES1
SELECT 3
USE SYSMES1
SELECT SYSVTAD
COPY STRU TO SYSMES2
SELECT 4
USE SYSMES2

STORE "COPIA LA VENTA RESTANTE AL TEMPORAL CON LA FACTURACION RENUMERADA" TO WTEXT
DO COMUNICA
SELECT SYSVTAG
GO WRECSTART
DO WHILE .NOT.EOF()
   STORE FACTURA TO WFACTURA
   SCAT MEMVAR
   SELECT SYSMES1
   IF FILLOC()
      APPEND BLANK
      DO ARMAFAC
      STORE WFACINI TO M.FACTURA
      GATH MEMVAR
      UNLOCK ALL
   ELSE
      STORE "REGISTRO SYSMES1 BLOQUEADO, FAVOR REINTENTE OPERACION" TO WTEXT
      DO AVISO WITH WTEXT
      DO SALIDA
   ENDIF
   SELECT SYSVTAD
   SEEK WFACTURA
   DO WHILE .NOT.EOF().AND.FACTURA=WFACTURA
      SCAT MEMVAR
      SELECT SYSMES2
      IF FILLOC()
         APPEND BLANK
         STORE WFACINI TO M.FACTURA
         GATH MEMVAR
         UNLOCK ALL
      ELSE
         STORE "REGISTRO SYSMES2 BLOQUEADO, FAVOR REINTENTE OPERACION" TO WTEXT
         DO AVISO WITH WTEXT
         DO SALIDA
      ENDIF
      SELECT SYSVTAD
      SKIP
   ENDDO
   SELECT SYSVTAG
   SKIP
ENDDO

STORE "BORRA LA VENTA RESTANTE DEL SISTEMA" TO WTEXT
DO COMUNICA
SELECT SYSVTAG
DELETE ALL FOR YEAR(FECHA)>=WWANO.AND.MONTH(FECHA)>=WWMES
SELECT SYSVTAD
DELETE ALL FOR YEAR(FECHA)>=WWANO.AND.MONTH(FECHA)>=WWMES

STORE "COPIA LA VENTA DEL TEMPORAL AL SISTEMA" TO WTEXT
DO COMUNICA
SELECT SYSVTAG
APPEND FROM SYSMES1
SELECT SYSVTAD
APPEND FROM SYSMES2

STORE "OPERACION FINALIZADA, OPRIMA ENTER PARA CONTINUAR" TO WTEXT
DO AVISO WITH WTEXT
DO SALIDA

****************
PROCEDURE CALDAY
****************
*** CALCULA EL MONTO VENDIDO DEL DIA
SELECT SYSVTAG
SEEK STR(WWANO,4)+STR(WWMES,2)+STR(WDAYRUP,2)
DO WHILE .NOT.EOF().AND.YEAR(FECHA)=WWANO.AND.MONTH(FECHA)=WWMES.AND.DAY(FECHA)=WDAYRUP
   STORE FACTURA TO WFACTURA
   SELECT SYSVTAD
   SEEK WFACTURA
   DO WHILE .NOT.EOF().AND.FACTURA=WFACTURA
      STORE WTOTREAL+TOTAL TO WTOTREAL
      SKIP
   ENDDO
   SELECT SYSVTAG
   SKIP
ENDDO
RETURN
****************
PROCEDURE SALIDA
****************
CLOSE DATA
CLOSE INDEX
@ 0,0 CLEAR
QUIT
*****************
PROCEDURE ARMAFAC
*****************
STORE VAL(WFACINI)+1                            TO WFACINI
STORE LTRIM(STR(WFACINI,7))                     TO WFACINI
STORE REPLICATE("0",7-LEN(WFACINI))+WFACINI     TO WFACINI
RETURN
******************
PROCEDURE COMUNICA
******************
@ 23,0
@ 23,40-(LEN(WTEXT)/2) SAY WTEXT
RETURN
******************************************************************************

