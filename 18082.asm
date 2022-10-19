# ABAD HERNÁNDEZ, JAVIER
# CASTRO GARCÍA, JAIME
# GRUPO 508

# PRACTICA FINAL (SISTEMAS)
.data

.align 2
solucion: .space 42
.align 2
ecuacion1: .space 24
.align 2
ecuacion2: .space 24



.text
# FUNCIÓN ResuelveSistema:
# Resuelve un sistema de ecuaciones y produce el resultado como una cadena de caracteres.
# Parametros de entrada:
# 	-$a0: Cadena de entrada de la primera ecuación.
# 	-$a1: Cadena de entrada de la segunda ecuación.
# 	-$a2: Salida de la solucion en modo String.
# Parametros de retorno:
#	-$v0: Salida de error:
#		0: Sistema de ecuaciones correcto.
#		1: Sintaxis incorrecta.
# 		2: Overflow en término a coeficiente.
# 		3: Overflow al reducir en terminos a coeficientes.
#		4: Número de incognitas incorrectas.
#		5: Sistema de ecuaciones no valido.
ResuelveSistema:
		addi $sp,$sp,-16
		sw $ra,12($sp)
		sw $s2,8($sp)
		sw $s1,4($sp)
		sw $s0,0($sp)
				
		move $s0, $a0 		#guardo la direccion el primer string en s0
		move $s1, $a1
		move $s2, $a2
		move $v1, $zero
		
		
		
		la $a1, ecuacion1
		jal String2Ecuacion
		bnez $v0, salidars
		
		move $s0, $a1	#guardo la direccion el primer string en s0 ya en forma de ecuacion
		move $a0, $s1	#muevo la direccion de cadena del segundo string a a0
		la $a1, ecuacion2	
		jal String2Ecuacion
		bnez $v0, salidars
		
		move $s1, $a1	#guardo la direccion el segundo string en s1 ya en forma de ecuacion
		
		
		move $a0, $s0

				
		
		lw $t0, 12($a0) #posicion 4 de la 1 ecuacion
		lw $t1, 12($a1) #posicion 4 de la 2 ecuacion
		lw $t2, 16($a0) #posicion 5 de la 1 ecuacion
		lw $t3, 16($a1) #posicion 5 de la 2 ecuacion
		bne $t0, $t1, cambiadas
		bne $t2, $t3, cambiadas
		j saltoCramer
	
	cambiadas:
		lw $t0, 12($a1)
		lw $t1, 16($a1)
		sw $t0, 16($a1)
		sw $t1, 12($a1)
		lw $t0, 12($a0) #posicion 4 de la 1 ecuacion
		lw $t1, 12($a1) #posicion 4 de la 2 ecuacion
		lw $t2, 16($a0) #posicion 5 de la 1 ecuacion
		lw $t3, 16($a1) #posicion 5 de la 2 ecuacion
		bne $t0, $t1, incognitasDiferentes
		bne $t2, $t3, incognitasDiferentes
		lw $t0, 0($a1) #se intercambian los numeros
		lw $t1, 4($a1)
		sw $t0, 4($a1)
		sw $t1, 0($a1)
		
	saltoCramer: 			#Se entra a Cramer donde se resuelve el sistema.
		move $a0, $s0
		move $a1, $s1
		la $a2, solucion
		jal Cramer
		

		la $a0, solucion
		move $a1, $s2
		jal Solucion2String 	#Se transforma el sistema a formato String.
		j salidars
	
	incognitasDiferentes:		
		addi $v0, $zero, 5
	salidars:
		lw $s0,0($sp)
		lw $s1,4($sp)
		lw $s2,8($sp)
		lw $ra,12($sp)
		addi $sp,$sp,16 #recuperamos el valor de retorno de la pila.
		jr $ra



# FUNCIÓN String2Ecuacion:
# Pasa una ecuación introducida en el tipo de datos Cadena(String) a tipo Ecuacion.
# Parametros de entrada:
# 	-$a0: Cadena de entrada.
# 	-$a1: Salida de tipo Ecuacion.
# Parametros de retorno:
#	-$v0: Salida de error:
#		0: Ecuacion correcta.
#		1: Sintaxis incorrecta.
# 		2: Overflow en término a coeficiente.
# 		3: Overflow al reducir en terminos a coeficientes.
#		4: Número de incognitas incorrectas.
String2Ecuacion:
		addi $sp,$sp,-24
		sw $ra,20($sp) #guardamos en pila.
		sw $s0,16($sp)
		sw $s1,12($sp)
		sw $s2,8($sp)
		sw $s3,4($sp)
		sw $s4,0($sp)
		move $s0, $zero		# inicio a 0 los valores que voy a necesitar que inicialmente sean 0
		move $s2, $zero
		move $s3, $zero
		move $s1, $a1		# copio el apuntado de a1 a s1
		move $a2, $zero
	flasheo:
		sw $zero, 0($s1)	# inicio todos las posiciones del vector a 0.
		sw $zero, 4($s1)
		sw $zero, 8($s1)
		sw $zero, 12($s1)
		sw $zero, 16($s1)
		move $s1, $zero
		
	bucleS2E:			# se transforma valor a valor cada numero que se encuentra como acompañante de incognitas
		jal atoi		# o termino independiente
		bnez $v1, errorS2E
		move $s4, $v0
		move $v0, $v1

		jal busquedaIncognitas		# se busca si hay una incognita y se guarda 
		bnez $v1, errorS2E
		move $s2, $v0
		move $v0, $v1

		jal busquedaSimbolo		# se busca si hay un simbolo despues de las incognitas o termino independiente
		bne $v0, $zero, guardarS2E
		lw $t0, 12($a1)
		lw $t1, 16($a1)
		beq $s2, $zero, independiente
		beq $t0, $zero, primeraIncognita
		beq $t0, $s2, primeraIncognita
		beq $t1, $zero, segundaIncognita
		beq $t1, $s2, segundaIncognita
		j errorIncognitas
		
	primeraIncognita:			# se actualiza el valor de la primera incognita
		slt $t2, $s0, $zero
		addu $s0, $s0, $s4
		slt $t4, $s4, $zero
		slt $t3, $s0, $zero
		sw $s2, 12($a1)			# se guarda la incognita en su posicion del vector
		bne $t2, $t4, anadoPos
		bne $t2, $t3, errorReduccion
		j anadoPos
	segundaIncognita:			# se actualiza el valor de la segunda incognita
		slt $t2, $s1, $zero
		addu $s1, $s1, $s4
		slt $t3, $s1, $zero
		slt $t4, $s4, $zero
		sw $s2, 16($a1)			# se guarda la incognita en su posicion del vector
		bne $t2, $t4, anadoPos
		bne $t2, $t3, errorReduccion
		j anadoPos
	independiente:				# se actualiza el valor del termino independiente
		slt $t2, $s3, $zero
		subu $s3, $s3, $s4
		slt $t3, $s3, $zero
		slt $t4, $s4, $zero
		bne $t2, $t3, anadoPos
		bne $t2, $t3, errorReduccion

	
				
	anadoPos:			#se suma una posicon
		addi $a0, $a0, 1
		lb $t0, 0($a0)
		addi $t6, $zero, '='
		addi $t5, $zero, 32
		beq $t0, $zero, errorFormato #si hay final de cadena es que no hay un igual y es incorrecto
		beq $t0, $t6, cambioLado     #si hay un igual cambio de lado
		beq $t0, $t5, anadoPos	     #si hay un espacio añado una nueva posicion.
		j bucleS2E
		
		
	cambioLado:
		addi $a0, $a0, 1
		# es todo igual que con bucleS2E pero con el lado derecho (las operaciones de incognitas se guardan al orden inverso)
	bucleS2EDere:
		jal atoi
		bnez $v1, errorS2E
		move $s4, $v0
		move $v0, $v1
		jal busquedaIncognitas
		bnez $v1, errorS2E
		move $s2, $v0
		move $v0, $v1
		jal busquedaSimbolo
		bne $v0, $zero, guardarS2E
		lw $t0, 12($a1)
		lw $t1, 16($a1)
		beq $s2, $zero, independienteDerecha
		beq $t0, $zero, primeraIncognitaDerecha
		beq $t0, $s2, primeraIncognitaDerecha
		beq $t1, $zero, segundaIncognitaDerecha
		beq $t1, $s2, segundaIncognitaDerecha
		j errorIncognitas
		
		
		
	primeraIncognitaDerecha:
		slt $t2, $s0, $zero
		subu $s0, $s0, $s4
		slt $t3, $s0, $zero
		slt $t4, $s4, $zero
		sw $s2, 12($a1)
		bne $t3, $t4, anadoPos2
		bne $t2, $t3, errorReduccion
		j anadoPos2
	segundaIncognitaDerecha:
		slt $t2, $s1, $zero
		subu $s1, $s1, $s4
		slt $t3, $s1, $zero
		slt $t4, $s4, $zero
		sw $s2, 16($a1)
		bne $t3, $t4, anadoPos2
		bne $t2, $t3, errorReduccion
		j anadoPos2
	independienteDerecha:
		slt $t2, $s3, $zero
		addu $s3, $s3, $s4
		slt $t4, $s4, $zero
		slt $t3, $s3, $zero
		bne $t2, $t4, anadoPos2
		bne $t2, $t3, errorReduccion
		j anadoPos2
		
		
	anadoPos2:
		addi $a0, $a0, 1
		lb $t0, 0($a0)
		addi $t5, $zero, 32
		beq $t0, $zero, salidaS2E
		beq $t0, $t5, anadoPos2
		j bucleS2EDere
		
	errorReduccion:
		addi $v0, $zero, 3
		j guardarS2E
	errorIncognitas:
		addi $v0, $zero, 4
		j guardarS2E
		
	errorFormato:
		addi $v0, $zero, 1
		j guardarS2E
	errorS2E:
		move $v0, $v1
		j guardarS2E
		
	salidaS2E:
		lw $t0, 12($a1)
		beqz $t0, errorIncognitas
		sw $s0, 0($a1)
		sw $s1, 4($a1)
		sw $s3, 8($a1)
	guardarS2E:
		lw $s4,0($sp)
		lw $s3,4($sp)
		lw $s2,8($sp)
		lw $s1,12($sp)
		lw $s0,16($sp)
		lw $ra,20($sp)
		addi $sp,$sp,24 #recuperamos el valor de retorno de la pila.
		jr $ra



# FUNCIÓN ATOI:
# Transforma un numero en formato de cadena a decimal. 
# Parametros de entrada:
# 	-$a0: Apuntador de la cadena.
# Parametros de salida:
#	-$v0: Numero en decimal devuelto.
#	-$v1: Error. Si es por cararcter incorrecto, $v1=1 si es por desbordamiento $v1=2
atoi:

addi $t3, $zero, '0'
addi $t4, $zero, 10

move $v0, $zero

li $t1, ' '
li $t8, '-'
li $t9, '+'

inicioBucle:	
	lb $t0, 0($a0)			# si el primer signo es un + o - lo guardo en t0
	
	beq $t0, $t9, comprueboSigno
	beq $t0, $t8, comprueboSigno
	beq $t0, $t1, continuoEspacios
	slti $t2, $t0, 123		# si es mayor que z
	slti $t5, $t0 ,96	# mayor que a
	beq $t2, $zero, error
	beq $t5, $zero, letra	
	slti $t2, $t0, 91	# mayor que Z
	slti $t5, $t0, 64 	# mayor que A
	beq $t2, $zero, error	
	beq $t5, $zero, letra
	slti $t2, $t0, 58	# mayor que 9
	slti $t5, $t0, '0'
	beq $t2, $zero, error
	bne $t5 $zero , error

	j numeros
	
	
comprueboSigno:
	addi $a0, $a0, 1		# en t1 guardo el segundo caracter si en t0 hay + o - 
	lb $t1, 0($a0)
	slti $t2, $t1, 123		# si es mayor que z
	slti $t5, $t1 ,96	# mayor que a
	beq $t2, $zero, error
	beq $t5, $zero, letra	
	slti $t2, $t1, 91	# mayor que Z
	slti $t5, $t1, 64 	# mayor que A
	beq $t2, $zero, error	
	beq $t5, $zero, letra
	slti $t2, $t1, 58	# mayor que 9
	slti $t5, $t1, '0'
	beq $t2, $zero, error
	bne $t5 $zero , error

	j numeros

continuoEspacios:
	addi $a0, $a0, 1		
	j inicioBucle
	
numeros:
	beq $t0, $t9 , sumaPositivo     # Si hay un + se va a sumaPositivo si hay un - se va a sumaNegativo
	beq $t0, $t8 sumaNegativo
	sumaPositivo:
		addi $t2, $zero, 1
		
	buclePositivo:
		lb $t0, 0($a0)
		sub $t5, $t0, $t3
		addu $v0, $v0, $t5
		addi $a0, $a0, 1		
		bltz $v0, overflow

		lb $t0, 0($a0)
		slti $t8, $t0, 58	# mayor que 9
		slti $t9, $t0, '0'
		beq $t8, $zero, correcto
		bne $t9 $zero , correcto
		mult $v0, $t4
		mflo $v0
		mfhi $t8
		bnez $t8, overflow
		bltz $v0, overflow

		j buclePositivo	
		
		
		
	sumaNegativo:
		addi $t2, $zero, -1
	bucleNegativo:			# hago la primera operación para multiplicar x(-1)
		lb $t0, 0($a0)
		addi $a0, $a0, 1
		sub $t5, $t0, $t3
		addu $v0, $v0, $t5
		sub $v0, $zero, $t5
		j lecturaCaracter
	bucleNegativoContinua:		# bucle de operaciones
		lb $t0, 0($a0)
		sub $t5, $t0, $t3
		subu $v0, $v0, $t5
		addi $a0, $a0, 1
		bgez $v0, overflow
	lecturaCaracter:		# bucle de comprobación de caracter correcto y operaciones necesarias
		
		lb $t0, 0($a0)
		slti $t8, $t0, 58	# mayor que 9
		slti $t9, $t0, '0'	
		beq $t8, $zero, correcto
		bne $t9 $zero, correcto
		mult $v0, $t4
		mflo $v0
		mfhi $t7
		bgez $v0, overflow
		bne $t7, $t2, overflow
		j bucleNegativoContinua
		
	
correcto: 	
	move $v1, $zero
salirAtoi: 
	jr $ra		
	
		
letra:	# si me encuntro una incognita en lugar de un numero directamente guardare 1 o -1 dependiendo del signo.
	beq $t0, $t9, letraPositivo
	beq $t0, $t8, letraNegativo
	letraPositivo:
		addi $v0, $zero, 1
		jr $ra
	letraNegativo:
		addi $v0, $zero, -1
		jr $ra
	
	
error: 		# error de caracter invalido o entrada invalida.
	addi $v1, $zero, 1
	jr $ra
	
overflow:	# error por overflow
	addi $v1, $zero, 2
	jr $ra
	
	

	
	
	
	
	
	
	
	
# FUNCIÓN busquedaIncognitas:
# Función que busca una incognita en ascii y la devuelve.
# Parametros de entrada:
# 	-$a0: Apuntador de la cadena.
# Parametros de salida:
#	-$v0: Incognita si la hay, 0 si no la hay.
#	-$v1: Error. Si $v1 es 1, significa que despues de la incognita hay otra o algun caracter no valido (solo +, -, =, ' ')
busquedaIncognitas:
	li $t6, '='
	li $t7, ' '
	li $t8, '-'
	li $t9, '+'
	
	lb $t0, 0($a0)
	letraSalida:
		slti $t2, $t0, 123		# si es mayor que z
		slti $t3, $t0 ,96	# mayor que a
		beq $t2, $zero, errorLetra
		beq $t3, $zero, guardoLetra	
		slti $t2, $t0, 91	# mayor que Z
		slti $t3, $t0, 64 	# mayor que A
		slti $t4, $t0, 'A'
		beq $t2, $zero, errorLetra	
		beq $t3, $zero, guardoLetra
		bne $t4, $zero , siguienteCorrecto
		
		
		
		
		j siguienteLetra
	guardoLetra:
		add $v0, $zero, $t0
	siguienteLetra:
		addi $a0, $a0, 1
		lb $t0, 0($a0)
	siguienteCorrecto:
		beq $t0, $t7, correctoLetra #beq ' '
		beq $t0, $t9, correctoLetra #beq '+'
		beq $t0, $t8, correctoLetra #beq '-'
		beq $t0, $t6, correctoLetra #beq '='
		beqz $t0, correctoLetra
	errorLetra:
		addi $v1, $zero, 1
		addi $a0, $a0, -1
		jr $ra

	correctoLetra:
		addi $a0, $a0, -1
		jr $ra
	
	
	
	
	
	
	
	
	
	
# FUNCIÓN busquedaSimbolo:
# Función que busca un simbolo valido despues de los espacios en blanco.
# Parametros de entrada:
# 	-$a0: Apuntador de la cadena.
# Parametros de salida:
#	-$v0: 1: si el caracter no es valido.

busquedaSimbolo:
	addi $t1, $a0, 1
	lecturaSimbolo:
		lb $t0, 0($t1)
		beq $t0, '+', salidaBS
		beq $t0, '-', salidaBS
		beq $t0, '=', salidaBS
		beqz $t0, salidaBS
		beq $t0, 32, siguienteCaracter
	errorBS:
		addi $v0, $zero, 1
	salidaBS:
		jr $ra
		
	siguienteCaracter:
		addi $t1, $t1, 1
		j lecturaSimbolo
	

.data
indeterminado: .asciiz "INDETERMINADO"
incompatible: .asciiz "INCOMPATIBLE"
.text



# FUNCIÓN Solucion2String:
# Función que transforma un objeto de tipo Solucion a formato String.
# Parametros de entrada:
# 	-$a0: Dirección de cadena que contiene un elemento de tipo Solucion.
# 	-$a1: Dirección de cadena en la que se guardara la solucion transformada a formato String.
	
Solucion2String:
		addi $sp,$sp,-4
		sw $ra,0($sp) #guardamos en pila.
		move $t9, $a0
		li $t1, 1
		li $t2, 2
		
	
		lw $t0, 0($t9)
		beq $t0, $t1, esIndeterminado 	# si el primer dato de Solcuion es 1 el sistema S.C.I
		beq $t0, $t2, esIncopatible	# si el primer dato de Solcuion es 2 el sistema S.I
		
		# primera incognita
		
		lb $t0, 28($t9) 	#se lee de la posicion 7 del vector la primera incognita
		sb $t0, 0($a1)		#se guarda la incognita como primer dato
		addi $t0, $zero, '='	
		sb $t0, 1($a1)		#se guarda el igual
		addi $a1, $a1, 2
		
		lw $a0, 4($t9)  	#se lee el valor del primer numero a la izquierda de los decimales y se pasa a string
		jal itoa
		
		lb $t0, 0($a1)		
		beqz $t0, aniadoNumero
		addi $a1, $a1, 1
		
	aniadoNumero:
		
		lw $t0, 12($t9)
		beqz $t0, segundaEcuacion
		addi $t0, $zero, '.'
		sb $t0, 0($a1)
		addi $a1, $a1, 1
		lw $t0, 8($t9)
		addi $t1, $zero, '0'
		beqz $t0, hayDecimales
	hayCeros:		# si hay ceros despues del punto se añaden.
		sb $t1, 0($a1)
		addi $t0, $t0, -1
		addi $a1, $a1, 1
		bnez $t0, hayCeros
	hayDecimales:		# se carga el decimal que hay despues de los posibles ceros
		lw $a0, 12($t9)
		jal itoa

	# Es exactamente igual que con la primera ecuacion pero en sus respectivas posiciones
	segundaEcuacion:

		addi $t0, $zero, ' '
		sb $t0, 0($a1)
		addi $a1, $a1, 1
		lb $t0, 32($t9)
		sb $t0, 0($a1)

		addi $t0, $zero, '='
		
		sb $t0, 1($a1)
		addi $a1, $a1, 2
		
		lw $a0, 16($t9)
		jal itoa
		
		lb $t0, 0($a1)
		beqz $t0, aniadoNumero2
		addi $a1, $a1, 1
		
		
		
		
	aniadoNumero2:
		lw $t0, 24($t9)
		beqz $t0, salidaSolu2String
		addi $t0, $zero, '.'
		sb $t0, 0($a1)
		addi $a1, $a1, 1
		lw $t0, 20($t9)
		li $t1, '0'
		beqz $t0, decimales2
		
	hayCeros2: 
		sb $t1, 0($a1)
		addi $t0, $t0, -1
		addi $a1, $a1, 1
		bnez $t0, hayCeros2
	decimales2:
		lw $a0, 24($t9)
		jal itoa
	salidaSolu2String:

		sb $zero, 1($a1)
		lw $ra,0($sp)
		addi $sp,$sp,4 #recuperamos el valor de retorno de la pila.
		jr $ra
		
	esIndeterminado:
		la $a0, indeterminado
		j strcpy
	
	esIncopatible:
		la $a0, incompatible
	strcpy:				# bucle que copia una cadena que se encuentra en a0 a a1.
		lb $t0, 0($a0)
		addi $a1, $a1, 1
		addi $a0, $a0, 1
		beqz $t0, salidaStrcpy
		sb $t0, -1($a1)
		j strcpy
		
	
	salidaStrcpy:
		sb $zero, -1($a1)
		j salidaSolu2String
	
	


# FUNCION ITOA:
# Convierte 
# Parametros de entrada:
#	-$a0: numero decimal.
#	-$a1: Cadena de salida que contendrá el valor decimal en ASCII.
# Parametros de salida:
#	-$a1: Cadena de salida que contendrá el valor decimal en ASCII.
itoa:
	addi $sp,$sp,-4
	sw $ra,0($sp) #guardamos en pila.
	addi $t5, $zero, 10
	move $t1, $a1
	lui $t7, 32768
	beq $a0, $t7, menosCero
	beqz $a0, esCero
	bgtz $a0, esPositivo
	li $t4, -1

	esNegativo:	
		li $t3, -1		
		sub $a0, $zero, $a0	#Transformo el numero decimal en su negativo.
	esPositivo:
		divu $a0, $t5		# Hago las operaciones de multiplicar x10
		mflo $a0
		mfhi $t2
		addi $t2, $t2, '0'	# añado al numero su valor en ascii
		sb $t2, 0($t1)
		addi $t1, $t1, 1
		bnez $a0, esPositivo
		addi $t1, $t1, -1
			
	salidaItoa:
		beq $t3, $t4, aniadoMenos	#si es negativo añado el menos a la cadena
	
	continuoSalida:
		addi $t1, $t1, 1
		sb $zero, 0($t1)
		move $a0, $a1		
		move $t3, $t1
		move $a1, $t1
		jal invertirCadena	#Invierto la cadena.
		move $a1, $t3
		lw $ra,0($sp)
		addi $sp,$sp,4 #recuperamos el valor de retorno de la pila.
		jr $ra
	esCero:
		addi $a0, $a0, '0'
		sb $a0, 0($t1)		#guardo el valor de 0 en ascii.
		j continuoSalida
	aniadoMenos:
		addi $t1, $t1, 1
		addi $t0, $zero, '-'
		sb $t0, 0($t1)		
		j continuoSalida
	menosCero:			#se ejecuta si recibimos como entrada -2147483648 y guarda -0
		addi $t0, $zero,'0'
		sb $t0, 0($t1)
		addi $t1, $t1, 1
		addi $t0, $zero,'-'
		sb $t0, 0($t1)
		j continuoSalida
	
	
# FUNCIÓN INVERTIR CADENA:
# Invierte la cadena
# Parametros de entrada:
#	-$a0: Direccion de la cadena.
#	-$a1: Dirección de la cadena con apuntador al final
# Parametros de salida:
#	-$a0: Cadena invertida.
invertirCadena:
		addi $t0, $a1, -1		# Copio el apuntador de la cadena a una temporal 
		
	intercambiar:
		lb $t2, 0($a0)			# Voy intercambiando constantemente los elementos entre los apuntadores hasta que el apuntador del principio sea mayor que el final.						
		lb $t1, 0($t0)			
		sb $t2, 0($t0)
		sb $t1, 0($a0)
		addi $t0, $t0, -1		# Aumentando y disminuyendo respectivamente los apuntadores que comienzan desde principio y fin de cadena
		addi $a0, $a0, 1
		slt $t4, $a0, $t0
		bne $t4, $zero, intercambiar
		
		
		jr $ra					

 					

			