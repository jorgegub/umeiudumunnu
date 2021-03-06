/*Fuente: CASFIM. Actualizado a agosto de 2016.*/
proc format cntlout=bancos_sofomes;
	value bancos_sofomes
		040002 = 'BANAMEX'
		040012 = 'BANCOMER'
		040014 = 'SANTANDER'
		040021 = 'HSBC'
		040030 = 'BAJIO'
		040032 = 'BANORTE' /*Antes IXE*/
		040036 = 'INBURSA'
		040037 = 'INTERACCIONES'
		040042 = 'MIFEL'
		040044 = 'SCOTIA'
		040058 = 'BANREGIO'
		040059 = 'INVEX'
		040060 = 'BANSI'
		040062 = 'AFIRME'
		040072 = 'BANORTE'
		040102 = 'INVESTA BANK'
		040103 = 'AMERICAN EXPRESS'
		040106 = 'BANK OF AMERICA'
		040108 = 'BANK OF TOKIO'
		040110 = 'JPMORGAN'
		040112 = 'MONEX'
		040113 = 'VE POR MAS'
		040116 = 'ING BANK'
		040117 = 'JPMORGAN'
		040124 = 'DEUTSCHE BANK'
		040126 = 'CREDIT SUISSE'
		040127 = 'AZTECA'
		040128 = 'AUTOFIN'
		040129 = 'BARCLAYS BANK'
		040130 = 'COMPARTAMOS'
		040131 = 'FAMSA'
		040132 = 'MULTIVA'
		040133 = 'ACTINVER'
		040134 = 'WAL-MART'
		040136 = 'INTER BANCO'
		040137 = 'BANCOPPEL'
		040138 = 'ABC CAPITAL'
		040139 = 'UBS BANK'
		040140 = 'CONSUBANCO'
		040141 = 'VOLKSWAGEN BANK'
		040143 = 'CI BANCO'
		040145 = 'BANCO BASE'
		040146 = 'BANCO BICENTENARIO'
		040147 = 'BANKAOOL'
		040148 = 'PAGATODO'
		040149 = 'FORJADORES'
		040150 = 'INMOBILIARIO MEXICANO'
		040151 = 'FUNDACION DONDÉ'
		040152 = 'BANCREA'
		040154 = 'BANCO FINTERRA'
		040156 = 'BANCO SABADELL'
		040300 = 'BANAMEX'/*'TARJETAS BANAMEX, SA DE CV, SOFOM ENTIDAD REGULADA'*/
		040301 = 'SANTANDER'/*'SANTANDER CONSUMO, S.A. DE C.V., SOFOM, E.R.'*/
		040302 = 'SANTANDER'/*'SANTANDER HIPOTECARIO SACV SOFOM ER'*/
		040303 = 'BANORTE'/*'BANORTE-IXE TARJETAS-SOFOM ER'*/
		040304 = 'SANTANDER'/*'SANTANDER VIVIENDA SACV SOFOM ER'*/
		040305 = 'INBURSA'/*'SOC FIN INBURSA - SOFOM ER'*/
		040306 = 'INBURSA'/*'CF CREDIT SERVICES SACV SOFOM ER'*/
		040307 = 'BANAMEX'/*'SERVICIOS FINANCIEROS SORIANA - SOFOM ER'*/
		067000 - 067999 = 'SOFOLES'
		068001 = 'BANORTE'/*'FINCASA HIPOTECARIA, SA DE CV, SOFOM, IXE GRUPO FINANCIERO'*/
		068002 = 'BANORTE'/*'IXE SOLUCIONES, SA DE CV, SOFOM, IXE GRUPO FINANCIERO'*/
		068003 = 'BANCOMER'/*'FINANCIERA AYUDAMOS, SA DE CV, SOFOM, GRUPO FINANCIERO BBVA BANCOMER'*/
		068004 = 'BANREGIO'/*'AF BANREGIO, SA DE CV, SOFOM, BANREGIO GRUPO FINANCIERO'*/
		068005 = 'BANORTE'/*'IXE AUTOMOTRIZ, SA DE CV, SOFOM, IXE GRUPO FINANCIERO'*/
		068006 = 'BANREGIO'/*'VIVIR SOLUCIONES FINANCIERAS, SA DE CV, SOFOM, BANREGIO GRUPO FINANCIERO'*/
		068007 = 'BANORTE'/*'ARRENDADORA BANORTE, SA DE CV, SOFOM, ENTIDAD REGULADA, GF BANORTE'*/
		068008 = 'BAJIO'/*'FACTOR BAJIO, SA DE CV, SOFOM, ENTIDAD REGULADA'*/
		068009 = 'INBURSA'/*'ARRENDADORA FINANCIERA INBURSA, SA DE CV, SOFOM, ENTIDAD REGULADA, GF INBURSA'*/
		068010 = 'BANAMEX'/*'FONDO ACCION BANAMEX, SA DE CV, SOFOM ENTIDAD REGULADA, GF BANAMEX'*/
		068011 = 'BANAMEX'/*'CREDITO FAMILIAR, SA DE CV, SOFOM ENTIDAD REGULADA, GRUPO FINANCIERO BANAMEX'*/
		068012 = 'SCOTIA'/*'GLOBALCARD, SA DE CV, SOFOM ENTIDAD REGULADA'*/
		068013 = 'BAJIO'/*'FINANCIERA BAJIO, SA DE CV'*/
		068014 = 'BANAMEX'/*'TARJETAS BANAMEX, SA DE CV, SOFOM ENTIDAD REGULADA'*/
		068015 = 'SANTANDER'/*'FINANCIERA ALCANZA, S.A. DE C.V, SOFOM, ENTIDAD REGULADA'*/
		068016 = 'CREDITO FIRME, S.A. DE C.V., SOFOM, ENTIDAD REGULADA'
		068017 = 'ARRENDADORA BANOBRAS, S.A. DE C.V., SOFOM, E.R.'
		068018 = 'SANTANDER'/*'SANTANDER CONSUMO, S.A. DE C.V., SOFOM, E.R.'*/
		068019 = 'IXE TARJETAS, S.A. DE C.V., SOFOM E.R.'
		068020 = 'BANCOMER'/*'HIPOTECARIA NACIONAL, SA DE CV, SOFOM, ER'*/
		068023 = 'MIFEL'/*'Mifel 3, S.A. de C.V., Sociedad Financiera de Objeto Múltiple'*/
		068024 = 'MIFEL'
		068026 = 'SANTANDER'/*'Santander Hipotecario, S.A. de C.V.'*/
		068027 = 'BANREGIO' /*FINANCIERA BANREGIO*/
		068028 = 'INBURSA' /*CF CREDIT SERVICES*/
		068029 = 'CI BANCO' /*FINANMADRID*/
		068030 = 'SCOTIA'/*'CREDITO FAMILIAR ER SCOTIABANK INVERLAT'*/
		068031 = 'BANAMEX'/*'Arrendadora Banamex, S.A. de C.V., Sociedad Financiera de Objeto Múltiple'*/
		068032 = 'VE POR MAS'/*'Arrendadora Ve por Más, S.A. de C.V., Sociedad Financiera de Objeto Múltiple'*/
		068033 = 'AFIRME'/*'ARRENDADORA AFIRME'*/
		068034 = 'AFIRME'/*'Factoraje Afirme, S.A. de C.V'*/
		068035 = 'CONSUBANCO'/*'CONSUPAGO ER'*/
		068036 = 'SANTANDER' /*SANTANDER VIVIENDA*/
		068037 = 'CONSUBANCO'/*'OPCIPRES ER'*/
		068038 = 'PAGATODO'/*'SOM COMERCIOS AFILIADOS ER'*/
		068039 = 'BANCO SABADELL' /*'Sabcapital, S.A. de C.V., SOFOM, E.R.'*/
		068063 = 'BANREGIO'/*The Capita Corporation de México*/
		068064 = 'INBURSA'/*FC Financial, S.A. de C.V., Sociedad Financiera de Objeto*/
		068040 - 068062 = 'SOFOMES DE EMPRESAS'
		068065 = 'SOFOMES DE EMPRESAS'
		068999 = 'CNBV (SOFOM DE PRUEBA)'
		. = "SISTEMA"
		other = [6.]
;
run;
