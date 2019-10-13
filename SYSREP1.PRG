HIDE MENU MENUMAIN
@ 5,0 CLEAR
SAVE SCRE TO SCREMAIN

do opelin
do opeart
do opevtag
do opevtad
define wind winrep from 5,0 to 12,60 title " VENTAS POR FACTURA "

do while .t.
   RESTORE SCREEN FROM SCREMAIN
   activate wind winrep
   
   store 0        to wpagina
   store 0        to wlinea

   store space(2) to wrupdia
   store space(2) to wrupmes
   store space(4) to wrupano
   store space(2) to wfecano
   store space(2) to wfecmes
   store space(4) to wfecdia
   store 0        to wtotface
   store 0        to wtotfacn
   store 0        to wtotfaci1
   store 0        to wtotfaci2
   store 0        to wtotfacg

   store 0        to wtotdiae
   store 0        to wtotdian
   store 0        to wtotdiai1
   store 0        to wtotdiai2
   store 0        to wtotdiag

   store 0        to wtotmese
   store 0        to wtotmesn
   store 0        to wtotmesi1
   store 0        to wtotmesi2
   store 0        to wtotmesg

   store 0        to wtotrepe
   store 0        to wtotrepn
   store 0        to wtotrepi1
   store 0        to wtotrepi2
   store 0        to wtotrepg

   store date()   to wdesde
   store date()   to whasta

   @ 1,1 say "Fecha inicial  :"
   @ 2,1 say "Fecha final    :"
   @ 3,1 say "Forma          :"
   @ 4,1 say "Salida         :"
   @ 5,1 say "Opciones       :"
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
   store 1 to wcond
   do while .t.
      @ 03,18  get wcond pict "@*H Detallado ;Resumido " defa wcond
      read
      if lastkey()=13
         exit
      endif
   enddo
   if wcond = 1
      STORE 1                                 TO WFORMAOP
      STORE "Detallado                      " TO WFORMA
   else
      STORE 2                                 TO WFORMAOP
      STORE "Resumido                       " TO WFORMA
   endif
   @ 3,18 say WFORMA
   store "Monitor" to wop
   do while .t.
      @ 04,18  get wop pict "@*H Monitor   ;Impresora" defa wop
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
   @ 04,18 SAY SPACE(24)
   @ 04,18 SAY WSALIDES
   store 1 to wop
   do while .t.
      @ 05,18 get wop pict "@*H Aceptar  ;Cancelar" defa wop
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
   SELECT SYSVTAG
   SET ORDER TO SYSVTAG3
   STORE STR(YEAR(WDESDE),4)   TO WYEAR
   STORE STR(MONTH(WDESDE),2)  TO WMONTH
   STORE STR(DAY(WDESDE),2)    TO WDAY
   IF DTOC(WDESDE)="  -  -  "
      GO TOP
      STORE RECNO()            TO WRECSTART
   ELSE
      SEEK WYEAR
      IF FOUND()
         STORE RECNO()            TO WRECSTART
         SEEK WYEAR+WMONTH
         IF FOUND()
            STORE RECNO()         TO WRECSTART
            SEEK WYEAR+WMONTH+WDAY
            IF FOUND()
              STORE RECNO()       TO WRECSTART
            ENDIF
         ENDIF
      ELSE
         GO TOP
         STORE RECNO()            TO WRECSTART
      ENDIF
   ENDIF


   DO TITULOS
   GO WRECSTART
   DO WHILE .NOT. EOF()
      IF WDESDE<>CTOD("  -  -  ").AND.(FECHA<WDESDE)
         SELECT SYSVTAG
         SKIP
         LOOP
      ENDIF
      IF WHASTA<>CTOD("  -  -  ").AND.(FECHA>WHASTA)
         EXIT
      ENDIF
      store str(year(fecha),4)  to wfecano
      store str(month(fecha),2) to wfecmes
      store str(day(fecha),2)   to wfecdia
      if wfecano<>wrupano
         do totdia
         do totmes
         do totano
      else
         if wfecmes<>wrupmes
            do totdia
            do totmes
         else
            if wfecdia<>wrupdia
               do totdia
            endif
         endif
      endif
      do caltot
      do totfac
      SELECT SYSVTAG
      SKIP
   ENDDO
   DO TOTDIA
   DO TOTMES
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
@ 1,00 SAY wtotfac1
@ 1,60 SAY "PAGINA:"+STR(WPAGINA,4)
@ 2,00 SAY topfac2
@ 2,60 SAY "FECHA :"+DTOC(DATE())

@ 3,00 SAY "VENTAS POR FACTURA  FORMATO "+WFORMA
@ 4,00 SAY "DESDE :"+DTOC(WDESDE)
@ 4,20 SAY "HASTA :"+DTOC(WHASTA)

@ 6,00 SAY CHR(15)
@ 6,00 SAY "FECHA     "
@ 6,11 SAY "FACTURA"
@ 6,20 SAY "   EXENTOS"
@ 6,31 SAY "NO EXENTOS"
@ 6,42 SAY " IMPUESTO1"
@ 6,54 SAY " IMPUESTO2"
@ 6,66 SAY "     TOTAL"
@ 7,00 SAY "----------"
@ 7,11 SAY "-------"
@ 7,20 SAY "----------"
@ 7,31 SAY "----------"
@ 7,42 SAY "----------"
@ 7,54 SAY "----------"
@ 7,66 SAY "----------"
STORE 7 TO WLINEA
RETURN
***********
PROC CALTOT
***********
store 0        to wtotface
store 0        to wtotfacn
store 0        to wtotfaci1
store 0        to wtotfaci2
store 0        to wtotfacg
SELECT SYSVTAD
SEEK SYSVTAG.FACTURA
DO WHILE .NOT. EOF() .AND. SYSVTAG.FACTURA=SYSVTAD.FACTURA
   IF IMPUESTO1+IMPUESTO2=0
      STORE WTOTFACE+TOTAL                                          TO WTOTFACE
      STORE WTOTDIAE+TOTAL                                          TO WTOTDIAE
      STORE WTOTMESE+TOTAL                                          TO WTOTMESE
      STORE WTOTREPE+TOTAL                                          TO WTOTREPE
   ELSE
      STORE WTOTFACN+TOTAL                                          TO WTOTFACN
      STORE WTOTDIAN+TOTAL                                          TO WTOTDIAN
      STORE WTOTMESN+TOTAL                                          TO WTOTMESN
      STORE WTOTREPN+TOTAL                                          TO WTOTREPN
      STORE (TOTAL*IMPUESTO1)/(100+IMPUESTO1) TO WFACIMP1
      STORE WTOTFACI1+WFACIMP1                                      TO WTOTFACI1
      STORE WTOTDIAI1+WFACIMP1                                      TO WTOTDIAI1
      STORE WTOTMESI1+WFACIMP1                                      TO WTOTMESI1
      STORE WTOTREPI1+WFACIMP1                                      TO WTOTREPI1
      STORE (TOTAL*IMPUESTO2)/(100+IMPUESTO2) TO WFACIMP2
      STORE WTOTFACI2+WFACIMP2                                      TO WTOTFACI2
      STORE WTOTDIAI2+WFACIMP2                                      TO WTOTDIAI2
      STORE WTOTMESI2+WFACIMP2                                      TO WTOTMESI2
      STORE WTOTREPI2+WFACIMP2                                      TO WTOTREPI2
   ENDIF
   STORE WTOTFACG+TOTAL                                             TO WTOTFACG
   STORE WTOTDIAG+TOTAL                                             TO WTOTDIAG
   STORE WTOTMESG+TOTAL                                             TO WTOTMESG
   STORE WTOTREPG+TOTAL                                             TO WTOTREPG
   SKIP
ENDDO
SELECT SYSVTAG
RETURN
****************
PROCEDURE TOTFAC
****************
if wformaop=1
   STORE WLINEA+1 TO WLINEA
   IF WLINEA >=WSALTO
      IF WSALIDA = "M"
         if WPAGINA > 0
            STORE "OPRIMA <ENTER> PARA CONTINUAR o <ESC> PARA SALIR" TO WTEXT
            DO AVISO WITH WTEXT
            IF LASTKEY()=27
               close data
               close index
               release all
               return to master
            ENDIF
         endif
      ENDIF
      DO TITULOS
   ENDIF
   @ WLINEA,00 SAY FECHA
   @ WLINEA,11 SAY FACTURA
   @ WLINEA,20 SAY WTOTFACE  PICTURE "9999999.99"
   @ WLINEA,31 SAY WTOTFACN  PICTURE "9999999.99"
   @ WLINEA,42 SAY WTOTFACI1 PICTURE "9999999.99"
   @ WLINEA,54 SAY WTOTFACI2 PICTURE "9999999.99"
   @ WLINEA,66 SAY WTOTFACG  PICTURE "9999999.99"
endif
RETURN
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
   @ WLINEA,00 SAY REPLICATE("+",80)
   STORE WLINEA+1 TO WLINEA
   @ WLINEA,00 SAY "TOTAL REPORTE"
   @ WLINEA,20 SAY WTOTREPE  PICTURE "99999999.99"
   @ WLINEA,31 SAY WTOTREPN  PICTURE "99999999.99"
   @ WLINEA,42 SAY WTOTREPI1 PICTURE "99999999.99"
   @ WLINEA,54 SAY WTOTREPI2 PICTURE "99999999.99"
   @ WLINEA,66 SAY WTOTREPG  PICTURE "99999999.99"
ENDIF
RETURN
****************
****************
PROCEDURE TOTANO
****************
STORE WFECANO TO WRUPANO
RETURN
****************
PROCEDURE TOTMES
****************
IF WTOTMESG<>0
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
   @ WLINEA,00 SAY "TOTAL MES"
   @ WLINEA,10 SAY ALLTRIM(WRUPMES)+"-"+ALLTRIM(WRUPANO)
   @ WLINEA,20 SAY WTOTMESE  PICTURE "99999999.99"
   @ WLINEA,31 SAY WTOTMESN  PICTURE "99999999.99"
   @ WLINEA,42 SAY WTOTMESI1 PICTURE "99999999.99"
   @ WLINEA,54 SAY WTOTMESI2 PICTURE "99999999.99"
   @ WLINEA,66 SAY WTOTMESG  PICTURE "99999999.99"
ENDIF
STORE 0 TO WTOTMESE
STORE 0 TO WTOTMESN
STORE 0 TO WTOTMESI1
STORE 0 TO WTOTMESI2
STORE 0 TO WTOTMESG
STORE WFECMES TO WRUPMES
RETURN
****************
PROCEDURE TOTDIA
****************
IF WTOTDIAG<>0
   STORE WLINEA+1 TO WLINEA
   IF WLINEA >=WSALTO
      IF WSALIDA = "M"
         if WPAGINA > 0
            STORE "OPRIMA <ENTER> PARA CONTINUAR o <ESC> PARA SALIR" TO WTEXT
            DO AVISO WITH WTEXT
            IF LASTKEY()=27
               close data
               close index
               return to master
            ENDIF
         endif
      ENDIF
      DO TITULOS
   ENDIF
   @ WLINEA,00 SAY "TOTAL DIA"
   @ WLINEA,10 SAY ALLTRIM(WRUPDIA)+"-"+ALLTRIM(WRUPMES)+"-"+ALLTRIM(WRUPANO)
   @ WLINEA,20 SAY WTOTDIAE  PICTURE "9999999.99"
   @ WLINEA,33 SAY WTOTDIAN  PICTURE "9999999.99"
   @ WLINEA,46 SAY WTOTDIAI1 PICTURE "9999999.99"
   @ WLINEA,60 SAY WTOTDIAI2 PICTURE "9999999.99"
   @ WLINEA,74 SAY WTOTDIAG  PICTURE "9999999.99"
ENDIF
STORE 0 TO WTOTDIAE
STORE 0 TO WTOTDIAN
STORE 0 TO WTOTDIAI1
STORE 0 TO WTOTDIAI2
STORE 0 TO WTOTDIAG
STORE WFECDIA TO WRUPDIA
RETURN
******
