.data # se��o de dados

.include "coin.data"
.include "baratinha.data"

imageX:
.word 150
imageY:
.word 110

.text # se��o de execu��o
main:
    # Passando argumentos
    la a0, baratinha
    li a1, 0
    li a2, 0
    jal renderImage
	
    la a0, coin.data
    la t0, imageX
    lw a1, 0(t0)
    la t1, imageY
    lw a2, 0(t1)
    jal le_teclado
    jal renderImage
    j main

le_teclado: 
    li t1, 0xFF200000       # carrega o endere�o de controle do KDMMIO
    lw t0, 0(t1)            # l� bit de controle teclado
    andi t0, t0, 0x0001     # mascara o bit menos significativo
    beq t0, zero, termina   # Se n�o h� tecla pressionada ent�o vai para termina
    lw t2, 4(t1)            # l� o valor da tecla
    sw t2, 12(t1)           # imprime no display tecla pressionada
    
    li t3, 's'              # carrega em t3 o caractere 's'
    beq t2, t3, decrement_y # t2 == t3 ? decrement_y : continue
    li t3, 'w'              # carrega em t3 o caractere 'w'
    beq t2, t3, increment_y # t2 == t3 ? increment_y : continue
    li t3, 'a'              # carrega em t3 o caractere 'a'
    beq t2, t3, decrement_x # t2 == t3 ? decrement_x : continue
    li t3, 'd'              # carrega em t3 o caractere 'd'
    beq t2, t3, increment_x # t2 == t3 ? increment_x : continue
    
    j termina

decrement_x:
    la t4, imageX
    lw t5, 0(t4)
    addi t5, t5, -5
    sw t5, 0(t4)
    j termina

increment_x:
    la t0, imageX
    lw t1, 0(t0)
    addi t1, t1, 5
    sw t1, 0(t0)
    li a7, 1
    ecall
    j termina

decrement_y:
    la t0, imageY
    lw t1, 0(t0)
    addi t1, t1, 5
    sw t1, 0(t0)
    j termina
    
increment_y:
    la t0, imageY
    lw t1, 0(t0)
    addi t1, t1, -5
    sw t1, 0(t0)
    j termina

termina:
    ret

renderImage:
    lw s0, 0(a0) # Guarda em s0 a largura da imagem
    lw s1, 4(a0) # Guarda em s1 a altura da imagem
    
    mv s2, a0    # Copia o endere�o da imagem para s2
    addi s2, s2, 8 # Pula 2 words - s2 agora aponta para o primeiro pixel da imagem
    
    li s3, 0xff000000 # carrega em s3 o endere�o do bitmap display
    
    li t1, 320        # t1 � o tamanho de uma linha no bitmap display
    mul t1, t1, a2    # multiplica t1 pela posi��o Y desejada no bitmap display.
    add t1, t1, a1    # adiciona a posi��o X.
    add s3, s3, t1    # o endere�o em s3 agora representa exatamente a posi��o em que o primeiro pixel da nossa imagem deve ser renderizado.

    blt a1, zero, endRender # se X < 0, n�o renderizar
    blt a2, zero, endRender # se Y < 0, n�o renderizar
    
    li t1, 320
    add t0, s0, a1
    bgt t0, t1, endRender # se X + larg > 320, n�o renderizar
    
    li t1, 240
    add t0, s1, a2
    bgt t0, t1, endRender # se Y + alt > 240, n�o renderizar
    
    li t1, 0 # t1 = Y (linha) atual
lineLoop:
    bge t1, s1, endRender # Se terminamos a �ltima linha da imagem, encerrar
    li t0, 0 # t0 = X (coluna) atual
    
columnLoop:
    bge t0, s0, columnEnd # Se terminamos a linha atual, ir pra pr�xima
    
    lb t2, 0(s2) # Pega o pixel da imagem
    sb t2, 0(s3) # P�e o pixel no display
    
    # Incrementa os endere�os e o contador de coluna
    addi s2, s2, 1
    addi s3, s3, 1
    addi t0, t0, 1
    j columnLoop
    
columnEnd:
    addi s3, s3, 320 # pr�xima linha no bitmap display
    sub s3, s3, s0   # reposiciona o endere�o de coluna no bitmap display
    
    addi t1, t1, 1   # incrementar o contador de altura
    j lineLoop
    
endRender:
    ret
