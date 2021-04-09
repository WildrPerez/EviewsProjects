'***************************************************************************************
'Programa para regresiones ols de la programación financiera

'Elaborado por DPEM

'*******************************************************************************************************************
'*******************************************************************************************************************

'Creación del workfile y determinación de ruta de la base de datos

wf wf1 q 1980.1 2019.4

%ruta="C:\Users\enriq\Dropbox\Complementariedad de la inversión pública con la inversión privada\Eviews\Complementariedad IP e IG"
CD "C:\Users\enriq\Dropbox\Complementariedad de la inversión pública con la inversión privada\Eviews\Complementariedad IP e IG"
read(t=xls) "DB_inversión" 8

smpl 1980.1 2019.4

		group gr1 Inversion_privada Inversion_publica 

'*******************************************************************************************************************
		smpl 1980.1 1999.4
		freeze(cointeg1) gr1.coint(method=eg, lag=5)
		smpl 1980.1 2019.2
		
		smpl 2000.1 2019.2
		freeze(cointeg2) gr1.coint(method=eg, lag=5)
		smpl 1980.1 2019.2

'*******************************************************************************************************************
		smpl 1980.1 2019.2
		group gr1 Inversion_privada Inversion_publica 
		
		smpl 1980.1 1999.4
		freeze(cointeg1J) gr1.coint(b, lag=5)
		smpl 1980.1 2019.2
		
		smpl 2000.1 2019.2
		freeze(cointeg2J) gr1.coint(b, lag=5)
		smpl 1980.1 2019.2

'*******************************************************************************************************************'
'Inspección gráfica 
'*******************************************************************************************************************	
	
smpl 2003.1 2019.4

		group c1  Inversion_privada EI6M IPX Inversion_publica EMBIsinP pbi socios
		c1.line(m)
		
			group g1  Inversion_privada EI6M
			group g2  Inversion_privada IPX 
			group g3  Inversion_privada Inversion_publica 
			group g4  Inversion_privada EMBIsinP
			group g5  Inversion_privada pbi
			group g6  Inversion_privada socios
			group g7  Inversion_privada r
			
		for !i=1 to 7

		g!i.cross(12) 

		next

'*******************************************************************************************************************
'Dummies
'*******************************************************************************************************************
		
		series d_2006q1=@year=2006 and @quarter=1
		series d_2013q4 =@year=2013 and @quarter=4
		
		genr ln_embigsinpe = log(EMBIsinP)

'*******************************************************************************************************************
'Regresiones ols
'*******************************************************************************************************************

'Mejor modelo:

equation inversion_4.ls(cov=hac) inversion_privada EI6M(-2) IPX(-2) ln_embigsinpe(-1) inversion_publica(-1) pbi socios(-1) r

			freeze(t_autoinversion_4) inversion_4.auto
			freeze(g_ninversion_4) inversion_4.hist
			freeze(g_rinversion_4) inversion_4.resids(g)
			freeze(q_rinversion_4) inversion_4.rls(r,s)

equation inversion_5.ls(cov=hac) inversion_privada EI6M(-2) IPX(-2) ln_embigsinpe(-1) inversion_publica(-1) pbi socios(-1) r d_2013q4 d_2006q1

'*******************************************************************************************************************
'Demeaning
'series g_vix = vix - @mean(vix)

'*******************************************************************************************************************
'Pruebas de estacionariedad

freeze(test_ur1) inversion_privada.uroot(adf,exog=const,lag=2,save=mout)
freeze(test_ur2) EI6M.uroot(adf,exog=const,lag=2,save=mout)
freeze(test_ur3) IPX.uroot(adf,exog=const,lag=2,save=mout)
freeze(test_ur4) inversion_publica.uroot(adf,exog=const,lag=2,save=mout)
freeze(test_ur5) pbi.uroot(adf,exog=const,lag=2,save=mout)
freeze(test_ur6) socios.uroot(adf,exog=const,lag=2,save=mout)
freeze(test_ur7) r.uroot(adf,exog=const,lag=2,save=mout)

'*******************************************************************************************************************
'Creación del VAR 

var var11.ls 1 4  socios IPX ln_embigsinpe d(r) EI6M inversion_publica pbi inversion_privada @ d_2013q4 d_2006q1

var var1.ls 1 4  socios(-1) IPX(-2) ln_embigsinpe(-1) d(r) EI6M(-2) inversion_publica(-1) pbi inversion_privada @ d_2013q4 d_2006q1

'*******************************************************************************************************************
'Criterio de información sobre rezagos
freeze(test_lag1) var1.laglen(4)
freeze(test_lag11) var11.laglen(4)

'*******************************************************************************************************************
'Reestimaciòn de VAR


var var23.ls(noconst) 1 1  socios IPX ln_embigsinpe d(r) EI6M inversion_publica pbi inversion_privada @ d_2013q4 d_2006q1
 
var var24.ls(noconst) 1 1 inversion_publica  socios IPX ln_embigsinpe d(r) EI6M  pbi inversion_privada @ d_2013q4 d_2006q1

var var25.bvar(prior=sznf, noconst) 1 1  socios IPX ln_embigsinpe d(r) EI6M inversion_publica pbi inversion_privada @ d_2013q4 d_2006q1

var var25.ec(noconst) 1 1  socios IPX ln_embigsinpe d(r) EI6M inversion_publica pbi inversion_privada @ d_2013q4 d_2006q1


















