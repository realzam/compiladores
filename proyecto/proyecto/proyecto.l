%{
    #include <string.h>
    #include "proyecto.tab.h"
    #include "tabla.h"
    extern void yyerror(char *s);

    //El analizador lexico es el encargado de inicializar la lista
    Lista lista = {NULL,0};
%}
letras   [a-z] 
digito   [0-9]
espacios [ \n\t]

%%
"Lienzo"                        {return Token_Lienzo;}
"Fondo"                         {return Token_Fondo;}
"print"                         {return print;}
"exit"                          {return exit_command;}
"posicion"                      {return OP_posicion;}
"contorno"                      {return OP_contorno;}
"rotacion"                      {return OP_rotacion;}
"relleno"                       {return OP_relleno;}
"mover"                         {return OP_mover;}
"Cuadrado"                      {return Fig_Cuadrado;}
"Rectangulo"                    {return Fig_Rectangulo;}
"Triangulo"                     {return Fig_Triangulo;}
"Circulo"                       {return Fig_Circulo;}
"Linea"                         {return Fig_Linea;}
{digito}+                       {yylval.num = atoi(yytext); return number;}
{letras}({letras}|{digito})*    {
                                    strcpy(yylval.id,yytext);
                                    Figura *buscado=buscar(&lista,yytext);
                                    if(buscado!=NULL)
                                    {
                                        if(buscado->tipo=="Linea")
                                            return Tok_Linea_id;
                                        return identifier;
                                    }
                                    return identifier_null;
                                }
{espacios}                      ;
[-+=;]                          {return yytext[0];}
.                               {ECHO; yyerror("caracter no esperado");}
%%