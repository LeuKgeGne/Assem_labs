.model small
.stack 100h

.data

string_input_request db "Enter  your string:", 0dh, 0ah, '$'
string_of_symbols db "Enter your string of symbols:", 0dh, 0ah, '$'
result_string db "Our result:", 0dh, 0ah, '$'

tabs db ' ', 0dh, 0ah, '$'

main_string db 200, 201 dup('$'), '$'
symbols_string db 200, 201 dup('$'), '$'


.code

mov ax, @data 
mov ds, ax
mov es, ax
          
print_str macro out_str
mov ah, 9
mov dx, offset out_str
int 21h
endm

input_str macro in_str
mov dx, offset in_str
mov ah, 0ah
int 21h
endm

START:
    print_str string_input_request
    input_str main_string
    print_str tabs
    
    print_str string_of_symbols
    input_str symbols_string
    print_str tabs
    
    lea di, symbols_string + 2
    cmp [di], 13
    je PROGRAM_END
    cmp [di], '$'
    je PROGRAM_END
    
    lea si, main_string + 1                                
    lea di, main_string + 2
    skip_spaces:
    inc si    
    cmp [si], ' '
    je skip_spaces
    cmp [si], '$'
    je PROGRAM_END
    mov di, si
      
    check_symbol:
    cmp [si], '$'
    je equal
    cmp [si], ' '
    je equal
    
    inc si
    jmp check_symbol
   
    ;if equal______________-
    
    equal:
    push si
    push di
    mov bx, di
    lea si, symbols_string+2
    
    search_cycle:
    mov di, bx
    
    cmp [si], '$'
    je delete_word
    cmp [si], 13
    je delete_word
    cmp [si], ' '
    je delete_word
    
    second_searching:

    mov al, [di]
    cmp [si], al
    je inc_count
                 
    cmp [di], '$'
    je nothing
    
    cmp [di], ' '
    je nothing
                         
    inc di
    jmp second_searching
    
    inc_count:
    inc si
    jmp search_cycle
    
    nothing:
    pop di
    pop si
    mov di, si
    dec si
    jmp skip_spaces
    
    delete_word:
    pop di
    pop si
    
    push di
    write_cycle:
    mov al,[si]
    mov [di], al
    cmp [si], '$'
    je delete_end
    inc si
    inc di
    jmp write_cycle
    
    delete_end:
    pop di
    mov si, di
    dec si
    jmp skip_spaces
        
PROGRAM_END:
    print_str result_string
    print_str main_string+2
    mov ah, 4ch
    int 21h