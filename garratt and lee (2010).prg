' LXIII Curso de Extensi�n Universitaria del BCRP (Marzo 2016)
' ----------------------------------------------------------------------------------------------------------------------
' Automatizaci�n del c�mputo de pruebas de Diebold y Mariano para varias funciones de p�rdida. Asimismo, se estiman la
' "regresi�n de combinaci�n" y se realizan pruebas de hip�tesis sobre "encompassing"
' ----------------------------------------------------------------------------------------------------------------------

'*Estimation of Rolling MSE for Forecasting Evaluation

workfile workfile1 u 305
%ruta = "C:\Users\enriq\Dropbox\University of Nottingham\Module programs\Financial and Macro Econometrics\FME project\Code"
cd  "C:\Users\enriq\Dropbox\University of Nottingham\Module programs\Financial and Macro Econometrics\FME project\Code"
read(t=xls) "GL_3"  11

rndseed(kn) 100

' Par�metros del programa
' Etiqueta (Texto) para los resultados (series f*, e*)
%tag = "f" 

' 1 para actualizar estimaciones, 0 para mantener fijo el modelo de regresi�n
!update = 1

series dm = log(x1)-log(x6)
series dy = log(x4)-log(x9)
series dp = log(x3)-log(x8)
series dr = log(x2)-log(x7)

%modelo1 = "y log(x5) dr" ' Efficient Market Hypothesis [EMH].
%modelo2 = "y dm dy " ' Monetary Fundamentals model [MF].
%modelo3 = "y c dp" ' Purchasing Power Parity [PPP].
%modelo4 = "y y(-1)" ' Autoregressive model of et in differences [AR(p)].

' Muestras y horizontes
!T1 = 259 ' Fin de la muestra de estimaci�n (fin1 es un escalar)
!T2 = 303 ' Fin de la muestra total (fin2 es un escalar)
!maxH = 4 ' M�ximo horizonte de proyecci�n (Hmax es un escalar)

' Estimaci�n del modelo de predicci�n
SMPL 1 !T1 ' Restringe el modelo hasta fin1
EQUATION eq1.LS {%modelo1}  ' Estima el modelo 

' Una �nica proyecci�n
SMPL @ALL
eq1.FORECAST(F=NA) yfull_ sfull_ ' Genera serie y_ y all� pone la predicci�n y s_ d�nde est�n los errores estandar
genr rmse_full = @rmse(yfull_ ,y) ' the square root of the mean of the squared difference between X and Y.

FOR !m = 1 TO 4

'Proyecciones recursivas: se generan las series y{%tag}1, y{%tag}2, ..., y{%tag}{!maxH} 

FOR !t = !T1+1 TO !T2-!maxH
	IF !update = 1 THEN ' Reestimar el modelo y reci�n hacer la predicci�n cu�ndo es cero no lo hace. 
		SMPL 1 !t
 		EQUATION eq.LS {%modelo{!m}} 
	ENDIF

' Se proyecta en el horizonte t+1, t+2, ..., t+!maxH  
	SMPL !t+1 !t+!maxH
	eq.FORECAST temp ' Es d�nde se guarda la proyecci�n, al final se borra
'series rmse_1 = @rmse(temp ,y)

	' Guardamos los resultados para diferentes horizontes en diferentes series
	FOR !h = 1 TO !maxH 
		SMPL !t+!h !t+!h
		SERIES y{!m}{%tag}{!h} = temp ' Guarda la proyecci�n h de la ecuaci�n
		series rmse_{!m}{%tag}{!h} = @rmse(temp ,y)
	NEXT !h

D temp

NEXT !t

' Errores de predicci�n: se generan las series e{%tag}1, e{%tag}2, ..., e{%tag}{!maxH} 
SMPL @ALL
FOR !h = 1 TO !maxH 
	SERIES e{!m}{%tag}{!h}= y - y{!m}{%tag}{!h}
	'series rmse_{%tag}{!h} = @rmse(y{%tag}{!h} ,y) ' the square root of the mean of the squared difference between X and Y.

NEXT !h

NEXT !m




















