'***************************************************************************************
'Programa para realizar correlaciones din�micas 

'Elaborado por DPEM
'***************************************************************************************
'***************************************************************************************
'Creaci�n del workfile y determinaci�n de ruta de la base de datos

wf wf4_inv q 1980.1 2019.4

%ruta="F:\Complementariedad de la inversi�n p�blica con la inversi�n privada\Eviews\Complementariedad IP e IG"
CD "F:\Complementariedad de la inversi�n p�blica con la inversi�n privada\Eviews\Complementariedad IP e IG"
read(t=xls) "DB_inversi�n" 8

smpl 1980.1 2019.2

'***************************************************************************************
'Creaci�n los grupos de variables y correlaci�n din�mica

for !i=1 to X

group g!i  var1 var!i
g!i.cross(15)

next


