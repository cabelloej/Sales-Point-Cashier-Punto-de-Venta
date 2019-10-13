HIDE MENU MENUMAIN
@ 5,0 CLEAR
SAVE SCRE TO SCREMAIN

do opelin
do opeart
do opevtag
do opevtad
define wind winrep from 5,0 to 12,60 title " VENTAS POR ARTICULO "

do while .t.
   RESTORE SCREEN FROM SCREMAIN
   activate wind winrep
   
   store 0        to wpagina
   store 0        to wlinea

   store space(10) to wrupart

   store 0        to wtotartc
   store 0        to wtotarte
   store 0        to wtotartn
   store 0        to wtotarti
   store 0        to wtotartg

   store 0        to wtotrepc
   store 0        to wtotrepe
   store 0        to wtotrepn
   store 0        to wtotrepi
   store 0        to wtotrepg

   store date()   to wdesde
   store date()   to whasta

   @ 1,1 say "Fecha inicial  :"
   @ 2,1 say "Fecha final    :"
   @ 3,1 say "Salida         :"
   @ 4,1 say "Opciones       :"
   @ 01,18 GET WDESDE
   @ 02,18 GET WHASTA
   READ
   IF LASTKEY()=27
      EXIT
   ENDIF
   IF WDESDE>WHASTA
      STORE "ERROR EN FECHAS, VERIFIQUE." TO WTEXT
      DO AVISO WITH WTEXT
      LOOP
   ENDIF
   store "Monitor" to wop
   do while .t.
      @ 03,18  get wop pict "@*H Monitor   ;Impresora" defa wop
      read
      if lastkey()=13
         exit
      endif
   enddo
   STORE WOP TO WSALIDA
   IF ALLTRIM(WSALIDA) = "Impresora"
      STORE 55          TO WSALTO
      STORE "Impresora" TO WSALIDES
      STORE "I"         TO WSALIDA
   ELSE
      STORE 22          TO WSALTO
      STORE "Monitor"   TO WSALIDES
      STORE "M"         TO WSALIDA
   ENDIF
   @ 03,18 SAY SPACE(24)
   @ 03,18 SAY WSALIDES
   store 1 to wop
   do while .t.
      @ 04,18 get wop pict "@*H Aceptar  ;Cancelar" defa wop
      read
      if lastkey()=13
         exit
      endif
   enddo
   deact wind all
   IF WOP = 2
      LOOP
   ENDIF
   IF WSALIDA = "I"
      SET DEVI TO PRINT
   ELSE
      SET DEVI TO SCRE
   ENDIF

   SELECT SYSART
   SET ORDER TO SYSART1
   GO TOP
   DO TITULOS
   DO WHILE .NOT. EOF()
      SELECT SYSVTAD
      SET ORDER TO SYSVTAD3
      STORE STR(YEAR(WDESDE),4)   TO WYEAR
      STORE STR(MONTH(WDESDE),2)  TO WMONTH
      STORE STR(DAY(WDESDE),2)    TO WDAY
      IF DTOC(WDESDE)="  -  -  "
         SEEK SYSART.CODIGO
         IF FOUND()
            STORE RECNO()            TO WRECSTART
         ELSE
            SELECT SYSART
            SKIP
            LOOP
         ENDIF
      ELSE
         SEEK SYSART.CODIGO+WYEAR
         IF FOUND()
            STORE RECNO()            TO WRECSTART
            SEEK SYSART.CODIGO+WYEAR+WMONTH
            IF FOUND()
               STORE RECNO()         TO WRECSTART
               SEEK SYSART.CODIGO+WYEAR+WMONTH+WDAY
               IF FOUND()
                 STORE RECNO()       TO WRECSTART
               ENDIF
            ENDIF
         ELSE
            SELECT SYSART
            SKIP
            LOOP
         ENDIF
      ENDIF
      GO WRECSTART
      DO WHILE .NOT. EOF() .AND. CODIGO=SYSART.CODIGO
         IF WDESDE<>CTOD("  -  -  ").AND.(FECHA<WDESDE)
            SELECT SYSVTAD
            SKIP
            LOOP
         ENDIF
         IF WHASTA<>CTOD("  -  -  ").AND.(FECHA>WHASTA)
            EXIT
         ENDIF
         DO CALTOT
         SELECT SYSVTAD
         SKIP
      ENDDO
      DO TOTART
      SELECT SYSART
      SKIP
   ENDDO
   DO TOTREP
   IF WSALIDA = "M"
      STORE "OPRIMA <ENTER> PARA FINALIZAR" TO WTEXT
      DO AVISO WITH WTEXT
   ELSE
      EJECT
      SET DEVI TO SCRE
   ENDIF
ENDDO
DEACT WIND WINREP
RESTORE SCRE FROM SCREMAIN
SHOW MENU MENUMAIN
CLOSE DATA
CLOSE INDEX
RETURN

*****************
PROCEDURE TITULOS
*****************
IF WSALIDA = "M"
   @ 0,0 clear
   @ 0,0 SAY QQWW
ELSE
  @ 0,0 SAY CHR(14)+QQWW
ENDIF
STORE WPAGINA+1 TO WPAGINA
@ 1,00 SAY wtopfac1
@ 1,60 SAY "PAGINA:"+STR(WPAGINA,4)
@ 2,00 SAY wtopfac2
@ 2,60 SAY "FECHA :"+DTOC(DATE())
@ 4,00 SAY "VENTAS POR ARTICULO DESDE :"+DTOC(WDESDE)+" HASTA :"+DTOC(WHASTA)

@ 6,00 SAY "CODIGO    "
@ 6,11 SAY "CANTID."
@ 6,20 SAY "     EXENTOS"
@ 6,33 SAY "  NO EXENTOS"
@ 6,46 SAY "   IMPUESTOS"
@ 6,59 SAY "       TOTAL"
@ 7,00 SAY "----------"
@ 7,11 SAY "-------"
@ 7,20 SAY "------------"
@ 7,33 SAY "------------"
@ 7,46 SAY "------------"
@ 7,59 SAY "------------"
STORE 7 TO WLINEA
RETURN
***********
PROC CALTOT
***********
IF IMPUESTO1+IMPUESTO2=0
   STORE WTOTARTE+TOTAL                                          TO WTOTARTE
   STORE WTOTREPE+TOTAL                                          TO WTOTREPE
ELSE
   STORE WTOTARTN+TOTAL                                          TO WTOTARTN
   STORE WTOTREPN+TOTAL                                          TO WTOTREPN
   STORE (TOTAL*(IMPUESTO1+IMPUESTO2))/(100+IMPUESTO1+IMPUESTO2) TO WFACIMP
   STORE WTOTARTI+WFACIMP                                        TO WTOTARTI
   STORE WTOTREPI+WFACIMP                                        TO WTOTREPI
ENDIF
STORE WTOTARTG+TOTAL                                             TO WTOTARTG
STORE WTOTREPG+TOTAL                                             TO WTOTREPG
STORE WTOTARTC+CANTIDAD                                          TO WTOTARTC
STORE WTOTREPC+CANTIDAD                                          TO WTOTREPC
RETURN
****************
PROCEDURE TOTART
****************
IF WTOTARTG<>0
   STORE WLINEA+1 TO WLINEA
   IF WLINEA >=WSALTO
      IF WSALIDA = "M"
         if WPAGINA > 0
            STORE "OPRIMA <ENTER> PARA CONTINUAR o <ESC> PARA SALIR" TO WTEXT
            DO AVISO WITH WTEXT
            IF LASTKEY()=27
               EXIT
            ENDIF
         endif
      ENDIF
      DO TITULOS
   ENDIF
   @ WLINEA,00 SAY SYSART.CODIGO
   @ WLINEA,10 SAY WTOTARTC PICTURE "999999.99"
   @ WLINEA,20 SAY WTOTARTE PICTURE "99999,999.99"
   @ WLINEA,33 SAY WTOTARTN PICTURE "99999,999.99"
   @ WLINEA,46 SAY WTOTARTI PICTURE "99999,999.99"
   @ WLINEA,59 SAY WTOTARTG PICTURE "99999,999.99"
ENDIF
STORE 0 TO WTOTARTC
STORE 0 TO WTOTARTE
STORE 0 TO WTOTARTN
STORE 0 TO WTOTARTI
STORE 0 TO WTOTARTG
RETURN
******
****************
PROCEDURE TOTREP
****************
IF WTOTREPG<>0
   STORE WLINEA+1 TO WLINEA
   IF WLINEA >=WSALTO
      IF WSALIDA = "M"
         if WPAGINA > 0
            STORE "OPRIMA <ENTER> PARA CONTINUAR o <ESC> PARA SALIR" TO WTEXT
            DO AVISO WITH WTEXT
            IF LASTKEY()=27
               EXIT
            ENDIF
         endif
      ENDIF
      DO TITULOS
   ENDIF
   @ WLINEA,00 SAY REPLICATE("-",80)
   STORE WLINEA+1 TO WLINEA
   @ WLINEA,00 SAY "TOTAL REPORTE"
   @ WLINEA,10 SAY WTOTREPC PICTURE "999999.99"
   @ WLINEA,20 SAY WTOTREPE PICTURE "99999,999.99"
   @ WLINEA,33 SAY WTOTREPN PICTURE "99999,999.99"
   @ WLINEA,46 SAY WTOTREPI PICTURE "99999,999.99"
   @ WLINEA,59 SAY WTOTREPG PICTURE "99999,999.99"
ENDIF
RETURN
******
