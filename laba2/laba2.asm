data segment 
    AND_result db "AND result:", 0dh, 0ah, '$'
    OR_result db "OR result:", 0dh, 0ah, '$'
    
    XOR_result db "XOR:", 0dh, 0ah, '$'
    
    NOT_res_num1 db "NOT number #1:", 0dh, 0ah, '$'
    NOT_res_num2 db "NOT number #2:", 0dh, 0ah, '$'
    
    tab db 0dh, 0ah, '$'
    
    buffer db '0'
    number_1 dw 0
    number_2 dw 0
    
    number_1_str db "Enter #1 number:", 0dh, 0ah, '$'
    number_2_str db "Enter #2 number:", 0dh, 0ah, '$'
    
    ;flags
    isSign dw 0
    isMinus dw 0
    
    RESULT_of_operation db 10 dup("0")
ends

stack segment
    dw 128 dup(0)
ends

code segment       
    
printBuffer proc

	push cx
	push dx
	push bx
	cmp ax,0
	jl less 
	jmp setDivider 
	
less: 
    mov [di], '-'
    inc di
    neg ax
	 
setDivider:	
	mov bx,10	
	xor cx,cx 
	
divCycle:	
    xor dx,dx    
	div bx		
	push dx	
	inc cx		
	test ax,ax	
	jnz divCycle
		
toStringCycle:	
    pop AX		
	add AL,'0'	
	stosb
	loop toStringCycle
	
	;end of result string 		
	pop bx		
	pop dx
	pop cx 
	mov [di],'$'
	ret
printBuffer endp
                     
    ;PRINTER
    PRINT_STR macro out_str
    mov ah, 9
    mov dx, offset out_str
    int 21h
    endm 
    
    proc CHECK_INPUT
        lea si, buffer
        mov [si], '0'
        mov isSign, 0
        xor ax, ax
        xor bx, bx
        mov di, 10              
        
        CHECK_CHAR:
        
            mov ah, 01           
            int 21h
            
            cmp isSign, 0
            je analyze_a_sign
            
            cmp al, 0dh
            je end_it
            
            FIRST_CYCLE:
            cmp al, '0'
            jl delete_symbol
            
            cmp al, '9'
            jg delete_symbol
            
            cmp isSign, 0
            je looksPositive
            
            SECOND_CYCLE:
            sub al, '0'
            xor ah, ah
            mov cx, ax
            mov ax, bx
            
            imul di
            jo delete_symbol
            cmp isMinus, 0
            je positive
            
            negative:
                neg cx
            positive:
                add ax, cx
                jo delete_symbol
                mov bx, ax
                inc [si]
            
            jmp CHECK_CHAR
            
    delete_symbol:
        mov ah, 02h
        mov dl, 08h
        int 21h
        
        mov ah, 02h
        mov dl, 20h
        int 21h
        
        mov ah, 02h
        mov dl, 08h
        int 21h
        
        jmp CHECK_CHAR
        
    analyze_a_sign:
        cmp al, '-'
        jne first_cycle
        
    looksNegative:
        mov isSign, 1
        mov isMinus, 1
        jmp check_char
        
    looksPositive:
        mov isMinus, 0
        mov isSign, 1
        jmp second_cycle
        
    end_it:
        cmp isMinus, 1
        je analyze_min
        jmp the_end
        analyze_min:
            cmp [si], '0'
            je minus_is_here
            jmp the_end
            minus_is_here:
                mov ah, 02h
                mov dl, '-'
                int 21h
                jmp check_char
    THE_END:
    ret
    CHECK_INPUT endp    
    
    START:
        mov ax, data
        mov ds, ax
        mov es, ax
        
        print_str number_1_str
        call check_input
        mov number_1, bx             
        print_str tab
    
        print_str number_2_str  
        call check_input
        mov number_2, bx
        print_str tab 
        mov ax, number_1 
        mov bx, number_2 
        ;AND      
        print_str AND_result   
        lea di, RESULT_of_operation
        mov ax, number_1 
        and ax,bx            
        call printBuffer
        print_str RESULT_of_operation 
        print_str tab 
        ;OR
        print_str OR_result 
        lea di,RESULT_of_operation 
        mov ax, number_1
        or ax,bx            
        call printBuffer
        print_str RESULT_of_operation 
        print_str tab
        ;XOR
        print_str XOR_result  
        lea di,RESULT_of_operation 
        mov ax, number_1
        xor ax,bx             
        call printBuffer
        print_str RESULT_of_operation 
        print_str tab
        ;NOT1
        print_str NOT_res_num1
        lea di, RESULT_of_operation 
        mov ax, number_1
        not ax             
        call printBuffer
        print_str RESULT_of_operation 
        print_str tab
        ;NOT2
        print_str NOT_res_num2   
        lea di,RESULT_of_operation 
        mov ax,bx
        not ax            
        call printBuffer
        print_str RESULT_of_operation 
        print_str tab

    
    mov ax, 4c00h
    int 21h    
ends

end start
    