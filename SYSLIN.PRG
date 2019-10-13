SELECT SYSLIN
DEFI WIND BRLIN FROM LIBRLIN,CIBRLIN TO LIBRLIN+10,CIBRLIN+40 ;
                TITLE "<LINEAS DE ARTICULOS>";
                FOOTER " F1=Inc,F2=Mod,F3=Eli,F4=Bus,ESC=Sel ";
                DOUBLE NOFLOAT NOZOOM NOGROW SHADOW COLOR SCHEME 10
ACTI WIND BRLIN
ON KEY LABEL F1 DO BRINC
ON KEY LABEL F2 DO BRMOD
ON KEY LABEL F3 DO BRELI
ON KEY LABEL F4 DO BRBUS
BROWSE FIELDS CODIGO:H="CODIGO", DESCRI:H="DESCRIPCION";
              NOAPPEND NODELETE NOEDIT NOMENU NOOPTIMIZE REST SAVE IN WINDOW BRLIN
RELEASE WIND BRLIN
ON KEY LABEL F1
ON KEY LABEL F2
ON KEY LABEL F3
ON KEY LABEL F4
RETURN
***********************
***                 ***
***RUTINAS DE BRLIN ***
***                 ***
***********************
PROCEDURE BRINC
DEFI WIND WINCCAM FROM liBRLIN+5,ciBRLIN+10 TO liBRLIN+10,ciBRLIN+56;
                  TITLE "<INCLUIR>" DOUBLE NOFLOAT NOZOOM NOGROW SHADOW COLOR SCHEME 10
ACTI WIND WINCCAM
DO WHILE .T.
   SCAT MEMV BLANK
   @ 00,00 CLEAR
   @ 00,01 SAY "CODIGO      :"
   @ 01,01 SAY "DESCRIPCION :"
   @ 00,15 GET M.CODIGO
   READ
   IF LASTKEY()=27
      EXIT
   ENDIF
   IF LEN(ALLTRIM(M.CODIGO))=0
      LOOP
   ENDIF
   SEEK M.CODIGO
   IF FOUND()
      @ 01,15 SAY DESCRI
      STORE "YA EXISTE, VERIFIQUE" TO WTEXT
      DO AVISO WITH WTEXT
      LOOP
   ELSE
      @ 01,15 GET M.DESCRI
      READ
      *** INICIO RUTINA DE ACEPTAR-CANCELAR
      store 1 to wop
      do while .t.
         @ 03,12  get wop pict "@*H Aceptar;Cancelar" defa wop
         read
         if lastkey()=13
            exit
         endif
      enddo
      *** FIN  RUTINA ACEPTAR-CANCELAR
      if wop=1
         if filloc()
            append blank
            gath memvar
            unlock all
         else
            store "OPERACION CANCELADA, REINTENTE" to wtext
            do aviso with wtext
         endif
      endif
   ENDIF
ENDDO
RELEASE WIND WINCCAM
RETURN
***
PROCEDURE BRMOD
DEFI WIND WMODLIN FROM liBRLIN+5,ciBRLIN+10 TO liBRLIN+10,ciBRLIN+56;
                  TITLE "<MODIFICAR>" DOUBLE NOFLOAT NOZOOM NOGROW SHADOW COLOR SCHEME 10
ACTI WIND WMODLIN
SCAT MEMVAR
@ 00,01 SAY "CODIGO      :"
@ 01,01 SAY "DESCRIPCION :"
@ 00,15 SAY M.CODIGO
@ 01,15 GET M.DESCRI
READ
*** INICIO RUTINA DE ACEPTAR-CANCELAR
store 1 to wop
do while .t.
   @ 03,12  get wop pict "@*H Aceptar;Cancelar" defa wop
   read
   if lastkey()=13
      exit
   endif
enddo
*** FIN  RUTINA ACEPTAR-CANCELAR
if wop=1
   if recloc()
      gath memvar
      unlock all
   else
      store "OPERACION CANCELADA, REINTENTE" to wtext
      do aviso with wtext
   endif
endif
RELEASE WIND WMODLIN
RETURN
***
PROCEDURE BRELI
DEFI WIND WELILIN FROM liBRLIN+5,ciBRLIN+10 TO liBRLIN+10,ciBRLIN+56;
                  TITLE "<ELIMINAR>" DOUBLE NOFLOAT NOZOOM NOGROW SHADOW COLOR SCHEME 10
ACTI WIND WELILIN
SCAT MEMVAR
@ 00,01 SAY "CODIGO      :"
@ 01,01 SAY "DESCRIPCION :"
@ 00,15 SAY M.CODIGO
@ 01,15 SAY M.DESCRI
*** INICIO RUTINA DE ACEPTAR-CANCELAR
store 2 to wop
do while .t.
   @ 03,12  get wop pict "@*H Aceptar;Cancelar" defa wop
   read
   if lastkey()=13
      exit
   endif
enddo
*** FIN  RUTINA ACEPTAR-CANCELAR
if wop=1
   if recloc()
      delete
      unlock all
   else
      store "OPERACION CANCELADA, REINTENTE" to wtext
      do aviso with wtext
   endif
endif
RELEASE WIND WELILIN
RETURN
***
PROCEDURE BRBUS
DEFI WIND WBUSLIN FROM liBRLIN+5,ciBRLIN+10 TO liBRLIN+10,ciBRLIN+56;
                  TITLE "<BUSCAR>" DOUBLE NOFLOAT NOZOOM NOGROW SHADOW COLOR SCHEME 10
ACTI WIND WBUSLIN
DO WHILE .T.
   SCAT MEMV BLANK
   @ 00,01 SAY "CODIGO      :"
   @ 01,01 SAY "DESCRIPCION :"
   @ 00,15 GET M.CODIGO
   READ
   IF LASTKEY()=27
      EXIT
   ENDIF
   IF LEN(ALLTRIM(M.CODIGO))=0
      LOOP
   ENDIF
   SEEK M.CODIGO
   IF FOUND()
      EXIT
   ELSE
      STORE "NO REGISTRADO, VERIFIQUE" TO WTEXT
      DO AVISO WITH WTEXT
   ENDIF
ENDDO
RELEASE WIND WBUSLIN
RETURN
***

