.text

.globl _start



_start:

    li s0, 12      # Paleta izquierda (y)

    li s1, 12      # Paleta derecha (y)

    li s2, 17      # Bola x

    li s3, 12      # Bola y

    li s4, 1       # dx

    li s5, 1       # dy



    li a1, LED_MATRIX_0_WIDTH

    li a2, LED_MATRIX_0_HEIGHT



loop:

    # === Leer D-Pad ===

    li t0, D_PAD_0_UP

    lb t1, 0(t0)

    beqz t1, check_p1_down

    addi s0, s0, -1

check_p1_down:

    li t0, D_PAD_0_LEFT

    lb t1, 0(t0)

    beqz t1, check_p2_up

    addi s0, s0, 1

check_p2_up:

    li t0, D_PAD_0_DOWN

    lb t1, 0(t0)

    beqz t1, check_p2_down

    addi s1, s1, 1

check_p2_down:  

    li t0, D_PAD_0_RIGHT

    lb t1, 0(t0)

    beqz t1, move_ball

    addi s1, s1, -1



# === Movimiento de la bola ===

move_ball:

    add s2, s2, s4    # x += dx

    add s3, s3, s5    # y += dy



    # Rebote vertical

    li t0, 0

    blt s3, t0, reverse_dy

    li t0, 24

    bgt s3, t0, reverse_dy

    j check_colision



reverse_dy:

    neg s5, s5

    j check_colision



# === Colisiones con paletas ===

check_colision:

    li t0, 0

    beq s2, t0, check_left

    li t0, 34

    beq s2, t0, check_right

    j draw



check_left:

    addi t1, s0, -1             

    addi t2, s0, 5              

    bge s3, t1, cl2             # Si bola est� por encima del l�mite inferior

    j reset

cl2:

    ble s3, t2, reflect_x       # Si bola est� dentro del rango de la paleta

    j reset



check_right:

    addi t1, s1, -1             

    addi t2, s1, 5              

    bge s3, t1, cr2             # Si bola est� por encima del l�mite inferior

    j reset

cr2:

    ble s3, t2, reflect_x       # Si bola est� dentro del rango de la paleta

    j reset



reflect_x:

    neg s4, s4

    j draw



# === Dibujo en LED_MATRIX ===

draw:

    li t0, 0                     # y (fila)

draw_rows:

    li t1, 0                     # x (columna)

draw_cols:

    li t2, LED_MATRIX_0_BASE

    mul t3, t0, a1               # y * ancho

    add t3, t3, t1               # + x

    slli t3, t3, 2               # 4 bytes por p�xel

    add t2, t2, t3               # direcci�n final



    # Por defecto: p�xel negro

    li t4, 0x00000000



    # Paleta izquierda (x == 0)

    li t5, 0

    beq t1, t5, check_paddle_left

    li t5, 34

    beq t1, t5, check_paddle_right

    j check_ball



check_paddle_left:

    addi t6, s0, -1             

    ble t0, t6, check_ball       

    addi t6, s0, 5               

    bge t0, t6, check_ball       
    li t4, 0x0000FF00            # Verde para la paleta izquierda

    j store_pixel



check_paddle_right:

    addi t6, s1, -1              

    ble t0, t6, check_ball       

    addi t6, s1, 5               

    bge t0, t6, check_ball       

    li t4, 0x000000FF            # Azul para la paleta derecha

    j store_pixel



check_ball:

    bne s2, t1, not_ball_x

    bne s3, t0, not_ball_x

    li t4, 0x00FF00FF            # Magenta para la bola

    j store_pixel

not_ball_x:

store_pixel:

    sw t4, 0(t2)



    addi t1, t1, 1

    blt t1, a1, draw_cols

    addi t0, t0, 1

    blt t0, a2, draw_rows



# === Delay ===

    li t0, 40000

wait:

    addi t0, t0, -1

    bnez t0, wait



    j loop



# === Reset posici�n ===

reset:

    li s2, 17

    li s3, 12

    li s4, 1

    li s5, 1

    j loop