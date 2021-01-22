%{ 
  #include<stdio.h>
%}
%%
2D|3D                                              {printf("<contexto dibujo>");}
cuadrado|triangulo|circulo|rectangulo              {printf("<figura 2D>");}
cubo|cono|esfera                                   {printf("<figura 3D>");}
linea                                              {printf("<linea>");}
rotar|escalar|trasladar|contorno|mover             {printf("<operacion>");}
negro|azul|verde|cian                              {printf("<color>");}
rojo|rosa|amarillo|blanco                          {printf("<color>");}
(_?[a-zA-Z])(_?[a-zA-Z0-9])*                       {printf("<identificador>");}
[1-9][0-9]{0,3}x[1-9][0-9]{0,3}                    {printf("<dimesion del area de trabajo");}
[0-9]*                                             {printf("<numero>");}
"."                                                {printf("<operador punto>");}
";"                                                {printf("<separador>");}
","                                                {printf("<,>");}
"("			                                           {printf("<(>");}
")"			                                           {printf("<)>");}
"//"|"#"                                           {printf("<comentario>");}
"/*"                                               {printf("<inicio de comentario por bloque>");}
"*/"                                               {printf("<fin de comentario por bloque>");}
%% 


