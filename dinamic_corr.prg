'***************************************************************************************
'Programa para realizar correlaciones dinámicas 

'Elaborado por DPEM
'***************************************************************************************
'***************************************************************************************
'Creación del workfile y determinación de ruta de la base de datos

wf wf4_inv q 1980.1 2019.4

%ruta="F:\Complementariedad de la inversión pública con la inversión privada\Eviews\Complementariedad IP e IG"
CD "F:\Complementariedad de la inversión pública con la inversión privada\Eviews\Complementariedad IP e IG"
read(t=xls) "DB_inversión" 8

smpl 1980.1 2019.2

'***************************************************************************************
'Creación los grupos de variables y correlación dinámica

for !i=1 to X

group g!i  var1 var!i
g!i.cross(15)

next


