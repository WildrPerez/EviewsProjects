'--------------------------------------------------------------------------------------------------
'Workshop: Constructing a dialy business cycle indicator
' ref: Aruoba, Diebold, and Scotti (2009)
'--------------------------------------------------------------------------------------------------

'0. Set path directory where the workfile is (this depends on the machine):

workfile wkf2 d(1,7) 3/31/1997 12/31/2019
%ruta = "I:\ADSPerú-2019\Eview files"
cd  "I:\ADSPerú-2019\Eview files"
read(t=xls) "Libro5"  23

'range 5/1/1997 9/27/2019
range 3/23/2006 9/27/2019

rndseed(kn) 1

'Open the m
'Dimeaning de variables spot
series g_embig = embig- @mean(embig)
series g_m = m- @mean(m)

series g_presion = presion - @mean(presion)

series g_cic = cic - @mean(cic)
series g_elec = elec - @mean(elec)
series g_import = import - @mean(import)

series g_pbi = pbi - @mean(pbi)

'Dimeaning de variables last

series g_mlast = mlast- @mean(m)

series g_presionlast = presionlast - @mean(presion)

series g_ciclast = ciclast - @mean(cic)
series g_eleclast = eleclast - @mean(elec)
series g_importlast = importlast - @mean(import)

series g_pbilast = pbilast - @mean(pbi)

'scalar var_pres = @sqrt(@var(g_presion)) 
'scalar var_import = @sqrt(@var(g_import)) 
'scalar var_elec = @sqrt(@var(g_elec)) 
'scalar var_cic = @sqrt(@var(g_cic))  
'scalar var_pbi = @sqrt(@var(g_pbi))  'Backup


'Check for an object’s existence. Returns a “1” if the object exists in the current workfile, and a “0” if it does not exist.
if @isobject("pbi") = 0 or @isobject("cic") = 0  or @isobject("m") = 0 or @isobject("elec") = 0 or @isobject("import") = 0 or @isobject("presion") = 0  then 
	stop
endif

'check if original times series contain observations
'@isna(x) equal to NA takes the value 1 if X is equal to NA and 0 otherwise.
if @isna(@stdev(pbi)) = 1 or  @isna(@stdev(cic)) = 1 or @isna(@stdev(m)) = 1 or @isna(@stdev(elec)) = 1 or @isna(@stdev(import)) = 1 or @isna(@stdev(presion)) = 1  then 
	stop
endif

'--------------------------------------------------------------------------------------------------
'Workshop: Constructing a dialy business cycle indicator
' ref: Aruoba, Diebold, and Scotti (2009)
'--------------------------------------------------------------------------------------------------
sspace aruoba1
'--------------------------------------------------------------------------------------------------
' Observation equations:

		aruoba1.append @signal embig         = c(1)*s1 + s4
		aruoba1.append @signal g_m            = c(20)*s1 + s5

		aruoba1.append @signal g_presion  = c(2)*s2+c(9)*g_presionlast  + [var=c(15)^2]

		aruoba1.append @signal g_import   = c(3)*s1 + c(10)*g_importlast  + [var=c(16)^2]
		aruoba1.append @signal g_elec       = c(4)*s1  + c(11)*g_eleclast     + [var=c(17)^2]
		aruoba1.append @signal g_cic          = c(5)*s1  + c(12)*g_ciclast       + [var=c(18)^2]

		'aruoba1.append @signal g_import   = c(3)*s1 + c(10)*g_importlast  + [var=c(16)^2]

		aruoba1.append @signal g_pbi         = c(6)*s3  + c(13)*g_pbilast       + [var=c(19)^2]

'--------------------------------------------------------------------------------------------------
'--------------------------------------------------------------------------------------------------
' State equations:

		aruoba1.append @state s1 = c(7)*s1(-1) + [var = ((1 - (c(7)^2))*(abs(c(7))<1))+(abs(c(7))=1)]
		aruoba1.append @state s2 = s1(-1) + (1-resetw)*s2(-1)
		aruoba1.append @state s3 = s1(-1) + (1-resetq)*s3(-1)
		aruoba1.append @state s4 = c(8)*s4(-1) + [var = c(14)^2]
		aruoba1.append @state s5 = c(21)*s5(-1) + [var = c(22)^2]
'--------------------------------------------------------------------------------------------------

' Starting values for the Maximum Likelihood Estimation

'Coeficiente ciclo-spread
		aruoba1.append @param  c(1) 0.2312
'Coeficiente actualización semanal
		aruoba1.append @param  c(2)  -10.7692
'Coeficiente autoregresivo de indicadores adelantados
		aruoba1.append @param c(3) 4.7524 c(4) 1.1964 c(5) 12.3711  c(6) -0.0001
'Coeficiente proceso autoregresivo del factor no observable
		aruoba1.append @param  c(7) 0.95 c(8) 0.95
'Coeficiente proceso autoregresivo
		aruoba1.append @param  c(9) 0.2973 c(10) 0.1488 c(11) 0.7301 c(12) 0.5182 c(13) 0.8130
' Scalares = varianza
		aruoba1.append @param c(14) -0.0623 c(15) 0.2024
		aruoba1.append @param c(16) -8.922 c(17) 1.8169 c(18) 5.3348  c(19) -45.6830
		aruoba1.append @param c(20) 0.0421 c(21) 0.9951 c(22) -0.1047

' Maximum Likelihood Estimation
		aruoba1.ml(showopts, c=1e-8)
		show aruoba1.output		

		aruoba1.makestates(t=smooth) s1_smooth1  s2_smooth2  s3_smooth3  s4_smooth4 s5_smooth5

' Generating the smoothed state variables

'range 4/1/1997 9/27/2019

		aruoba1.forecast(i=o,m=s) @state *f
		aruoba1.forecast(i=o,m=s) @signal *f

 'Generating the daily as negative of the state s1. The sign of the state s1 is not defined

		genr xf =s1f
		freeze(graph1) xf.line
		graph1.draw(shade, botton, color(ltgray), width) 2008q2 2009q1
		show graph1

		freeze(graph2) xf.line
		graph2.draw(shade, botton, color(ltgray), width) 2014q3 2015q1
		show graph2

		freeze(graph3) xf.line
		graph3.draw(shade, botton, color(ltgray), width) 2017q1 2017q2
		show graph3

		genr xsmooth =s1_smooth1
		freeze(graph_xsmooth) xsmooth.bar
		graph_xsmooth.draw(shade, botton, color(ltgray), width) 2008q2 2009q1
		show graph_xsmooth

'Si la matriz de covarianzas es igual a la inversa de la matriz de infor-
'mación (Cota de Cramer-Rao) entonces se comprueba que el estimador, que
'asume distribución normal, es de mínima varianza.
'Capturamos la matriz de covarianzas:

'matrix cmatr=aruoba1.@coefcov

'Luego construimos la matriz hessiana, aproximada por el producto externo de los gradientes:
'aruoba1.grads(n=out,t)

'aruoba1.makegrads(n=gradiente) gc1 gc2 gc3 gc4 gc5 gc6 gc7 gc8 gc9 gc10 gc11 gc12 gc13 gc14 gc15 gc16 gc17 gc18 gc19

'aruoba1.makegrads(n=gradiente)

'matrix g1=@convert(gradiente)
'matrix g2=@transpose(g1)
'matrix info=g2*g1
'matrix cmatr_info=@inverse(info)

'Evaluamos la desigualdad de cramer rao:

'matrix cramer_rao=cmatr-cmatr_info

'En caso de cumplir la condición, esta matriz debe ser cercana a cero en
'todos sus elementos. Se recomienda borrar los objetos temporales para un
'mayor orden en el workle:

'd g1 g2 info gradiente gmu grho gsigma2

'El test de wald evalúa las distintas restricciones que se pueden imponer a
'un modelo, evaluando la signi?cancia validez de este conjunto de condiciones.
'Fijamos la hipótesis nula y evaluamos el resultado de este test:
'freeze(wald_test) aruoba1.wald 'mu(1)=0.5, rho(1)=0.8, sigma2(1)=1
'show wald_test


