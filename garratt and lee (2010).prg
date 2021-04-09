' LXIII Curso de Extensión Universitaria del BCRP (Marzo 2016)
' ----------------------------------------------------------------------------------------------------------------------
' Automatización del cómputo de pruebas de Diebold y Mariano para varias funciones de pérdida. Asimismo, se estiman la
' "regresión de combinación" y se realizan pruebas de hipótesis sobre "encompassing"
' ----------------------------------------------------------------------------------------------------------------------

'*Estimation of Rolling MSE for Forecasting Evaluation

workfile workfile1 u 305
%ruta = "C:\Users\enriq\Dropbox\University of Nottingham\Module programs\Financial and Macro Econometrics\FME project\Code"
cd  "C:\Users\enriq\Dropbox\University of Nottingham\Module programs\Financial and Macro Econometrics\FME project\Code"
read(t=xls) "GL_3"  11

rndseed(kn) 100

' Parámetros del programa
' Etiqueta (Texto) para los resultados (series f*, e*)
%tag = "f" 

' 1 para actualizar estimaciones, 0 para mantener fijo el modelo de regresión
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
!T1 = 259 ' Fin de la muestra de estimación (fin1 es un escalar)
!T2 = 303 ' Fin de la muestra total (fin2 es un escalar)
!maxH = 4 ' Máximo horizonte de proyección (Hmax es un escalar)

' Estimación del modelo de predicción
SMPL 1 !T1 ' Restringe el modelo hasta fin1
EQUATION eq1.LS {%modelo1}  ' Estima el modelo 

' Una única proyección
SMPL @ALL
eq1.FORECAST(F=NA) yfull_ sfull_ ' Genera serie y_ y allì pone la predicción y s_ dónde estén los errores estandar
genr rmse_full = @rmse(yfull_ ,y) ' the square root of the mean of the squared difference between X and Y.

FOR !m = 1 TO 4

'Proyecciones recursivas: se generan las series y{%tag}1, y{%tag}2, ..., y{%tag}{!maxH} 

FOR !t = !T1+1 TO !T2-!maxH
	IF !update = 1 THEN ' Reestimar el modelo y recièn hacer la predicciòn cuàndo es cero no lo hace. 
		SMPL 1 !t
 		EQUATION eq.LS {%modelo{!m}} 
	ENDIF

' Se proyecta en el horizonte t+1, t+2, ..., t+!maxH  
	SMPL !t+1 !t+!maxH
	eq.FORECAST temp ' Es dónde se guarda la proyección, al final se borra
'series rmse_1 = @rmse(temp ,y)

	' Guardamos los resultados para diferentes horizontes en diferentes series
	FOR !h = 1 TO !maxH 
		SMPL !t+!h !t+!h
		SERIES y{!m}{%tag}{!h} = temp ' Guarda la proyección h de la ecuación
		series rmse_{!m}{%tag}{!h} = @rmse(temp ,y)
	NEXT !h

D temp

NEXT !t

' Errores de predicción: se generan las series e{%tag}1, e{%tag}2, ..., e{%tag}{!maxH} 
SMPL @ALL
FOR !h = 1 TO !maxH 
	SERIES e{!m}{%tag}{!h}= y - y{!m}{%tag}{!h}
	'series rmse_{%tag}{!h} = @rmse(y{%tag}{!h} ,y) ' the square root of the mean of the squared difference between X and Y.

NEXT !h

NEXT !m




















