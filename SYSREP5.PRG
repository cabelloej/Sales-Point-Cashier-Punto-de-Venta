DO OPELIN
DO OPEART
SAVE SCRE TO WSCRE04
STORE .T. TO R0201
DO WHILE R0201
   @ 04,0 CLEAR
   @ 04,30 SAY "ARTICULOS"
   @ 05,1 TO 5,78
   STORE SPACE(6) TO WLIN
   @ 08,5 SAY    "LINEA DE VTA.:"
   @ 09,5 SAY    "              "
   @ 10,5 SAY    "* SALIDA *"
   @ 11,5 say    "MONITOR ...1"
   @ 12,5 say    "IMPRESORA..2"
   @ 13,5 say    "          [ ]"
   @ 8,20 GET WLIN
   READ
   IF READKEY() = 12 .OR READKEY() = 268
      EXIT
   ENDIF
   store 1 to wsalida
   @ 13,16 get wsalida picture "#" range 1,2
   read
   SAVE SCRE TO INF1

   store 1 to wop
   do while .t.
      @ 15,18 get wop pict "@*H Aceptar  ;Cancelar" defa wop
      read
      if lastkey()=13
         exit
      endif
   enddo
   deact wind all
   IF WOP = 2
      LOOP
   ENDIF

   STORE 0 TO PAGINA
   STORE 100 TO LINE
   IF WSALIDA = 1
      STORE 18 TO WSALTO
      @ 0,0 CLEAR
   ELSE
      SET DEVI TO PRINT
      STORE 50 TO WSALTO
   ENDIF
   SELECT SYSART
   SET ORDER TO SYSART2
   GO TOP
   HIDE MENU MENUMAIN
   DO WHILE .NOT. EOF() 
      IF WLIN <> SPACE(6) .AND. WLIN <> LINEA
         SELECT SYSART
         SKIP
         LOOP
      ENDIF
      STORE LINE+1 TO LINE
      IF LINE >= WSALTO
         STORE PAGINA + 1 TO PAGINA
         IF WSALIDA=1 .AND. PAGINA<>1
            STORE "OPRIMA ENTER PARA CONTINUAR, ESC PARA SALIR" TO WTEXT
            DO AVISO WITH WTEXT
            IF LASTKEY() = 27
               CLOSE DATA
               CLOSE INDEX
               SET DEVI TO SCRE
               RESTORE SCRE FROM WSCRE04
               SHOW MENU MENUMAIN
               RETURN
            ENDIF
            @ 0,0 CLEAR
         ENDIF
         @ 1,0   SAY QQWW
         @ 1,60  SAY "FECHA :"+DTOC(DATE())
         @ 2,0   SAY  "LISTADO DE ARTICULOS"
         @ 2,60  SAY "PAGINA:"+STR(PAGINA,2)
         @ 04,0  SAY "LINEA"
         @ 04,8  SAY "CODIGO"
         @ 04,20 SAY "DESCRIPCION"
         @ 04,55 SAY "PRECIO"
         @ 04,70 SAY "IMPUESTOS"
         @ 5,0   SAY REPLICATE("-",80)
         STORE 6 TO LINE
      ENDIF
      @ LINE,0 SAY LINEA
      @ LINE,8 SAY CODIGO
      @ LINE,20 SAY DESCRI
      @ LINE,55 SAY PRECIO PICTURE "9999,999.99"
      @ LINE,70 SAY IMPUESTO1+IMPUESTO2 PICTURE "99,999.99"
      SKIP
   ENDDO
   IF WSALIDA = 2
      SET DEVI TO SCRE
      EJECT
   ELSE
      STORE "OPRIMA (Ù) PARA FINALIZAR" TO WTEXT
      DO AVISO WITH WTEXT
      RESTORE SCRE FROM INF1
   ENDIF
ENDDO
CLOSE DATA
CLOSE INDEX
RESTORE SCRE FROM WSCRE04
SHOW MENU MENUMAIN
RETURN
