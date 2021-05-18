;Simple Paint Program using emu8086
printstring macro msg
    push ax
    push dx
    mov ah, 09
    mov dx, offset msg
    int 21h
    pop dx
    pop ax
    endm




_data segment

    cr equ 0dh
    nl equ 0ah
    
    password db "Enter Password: ",13,10,"$" ; 13 is carriage return and 10 is linefeed
    choose_color db "PASSWORD ACCEPTED",13,10,13,10,"Right Click to Stop, then choose from list below...",13,10,13,10,"W = White (Default)",13,10,"C = Cyan",13,10,"R = Red",13,10,"E = Erase",13,10,"ESC = Exit",13,10,"$"
    end_game db "Thanks for playing!", cr, nl, "$"
    current_color_white db "Current color is: White", cr, nl, "$"
    current_color_cyan db "Current color is: Cyan", cr, nl, "$"
    current_color_red db "Current color is: Red", cr, nl, "$"
    wrongmsg db "PASSWORD IS WRONG, TRY AGAIN?",13,10,"T = Try Again",13,10,"ESC = Exit",13,10,"$"
    linespace db "$"

_data ends



_code segment
        assume cs:_code, ds:_data

    start:
    
        ; BUILD BOARD
        
        ;This initializes the screen functionality
        mov ax, _data
        mov ds, ax
        
        ;Standard video mode, graphical mode 40x25. 320x200 pixels
        mov al, 13h
        mov ah, 0
        int 10h

        ;Title of Program, Introduction        
        mov al, 1
        mov bh, 0
        mov bl, 0000_0010b ; First 4 bits is the text color, last text bits are the background color
        mov cx, msg1end - offset msg1 ; calculate message size.
        mov dl, 10  ; Column location
        mov dh, 7   ; Row location
        push cs
        pop es
        mov bp, offset msg1
        mov ah, 13h
        int 10h
        jmp msg1end
         msg1 db "Simple Paint Program" ; PROGRAM TITLE
         msg1end:
        
        mov al, 1
        mov bh, 0
        mov bl, 0000_0010b ; First 4 bits is the text color, last text bits are the background color
        mov cx, msg2end - offset msg2 ; calculate message size.
        mov dl, 11 ; Column location
        mov dh, 8  ; Row location
        push cs
        pop es
        mov bp, offset msg2
        mov ah, 13h
        int 10h
        jmp msg2end
         msg2 db "By: Tommy Swimmer" ; GAME AUTHOR
         msg2end:
         
         
        mov al, 1
        mov bh, 0
        mov bl, 0000_0010b ; First 4 bits is the text color, last text bits are the background color
        mov cx, msg3end - offset msg3 ; calculate message size.
        mov dl, 8  ; Column location
        mov dh, 9  ; Row location
        push cs
        pop es
        mov bp, offset msg3
        mov ah, 13h
        int 10h
        jmp msg3end
         msg3 db " Press Enter to Continue" ; ENTER TO CONTINUE
         msg3end:
         
         ; Interrupt for enter key.
         enter:
         mov ah, 7
         int 21h
         cmp al, 13 ; Comparing al (input) to 13 (enter key). If not equal. Stay in this function.
         je pressed_enter
         jne enter
         
         pressed_enter:
         ; Clear screen
         mov al, 13h
         mov ah, 0
         int 10h
         printstring password ; Prints rules for the game
         
         ; Password Check.-------------------------------------------------------------------------------
         ; Character input with echo
         ccheck:
         mov ah, 01h
         int 21h
         cmp al, 99 ; Compare al (inpute) to 99 ('c'). If not equal move to wrong password jump.
         je echeck
         jne wrong
         
         wrong:
         ; Clear Screen
         mov al, 13h
         mov ah, 0
         int 10h
         printstring wrongmsg ; Prints message for wrong password
         
         ;Check for t
         mov ah, 7
         int 21h
         cmp al, 116
         je pressed_enter
         
         ; Check for ESC
         mov ah, 7
         int 21h
         cmp al, 27
         je endgame
         
         jne wrong ; If neither directive is pressed, continue displaying wrong message.
         
         echeck:
         mov ah, 01h
         int 21h
         cmp al, 101 ; Compare al (input) to 101 ('e'). If not equal move to wrong password jump.
         je fourcheck
         jne wrong
         
         fourcheck:
         mov ah, 01h
         int 21h
         cmp al, 52 ; Compare al (input) to 52 ('4'). If not equal move to wrong password jump.
         je zerocheck
         jne wrong
         
         zerocheck:
         mov ah, 01h
         int 21h
         cmp al, 48 ; Compare with '0'. If not equal move to wrong password message
         je onecheck
         jne wrong
         
         onecheck:
         mov ah, 01h
         int 21h
         cmp al, 49
         je game
         jne wrong
         ; -----------------------------------------------------------------------------------------------
        
        
         ; PROGRAM IS STARTING AFTER THIS ----------------------------------------------------------------
         
         ; The main game code 
         game:
         ; BUILD THE BOARD
         ; Standard video mode
         mov al, 13h
         mov ah, 0
         int 10h
         
         ; Choose Color
         color:
            printstring choose_color
            ; Interrupt for color selection, no echo
            mov ah, 7
            int 21h
            
               ; Check if 'c' is pressed
                cmp al, 99
                je drawpixel_cyan
         
               ; Check if 'w' is pressed
                cmp al, 119
                je drawpixel_white
                
               ; Check if 'r' is pressed
                cmp al, 114
                je drawpixel_red
                
               ; Check if 'ESC' is pressed
               cmp al, 27
               je endgame
                
         color_return:
            ; Interrupt for color selection, no echo
            mov ah, 7
            int 21h
               ; Check if 'c' is pressed
                cmp al, 99
                je drawpixel_cyan
         
               ; Check if 'w' is pressed
                cmp al, 119
                je drawpixel_white
                
               ; Check if 'r' is pressed
                cmp al, 114
                je drawpixel_red
               ; Check if 'e' is pressed
                cmp al, 101
                je drawpixel_erase
               ; Check if 'ESC' is pressed
               cmp al, 27
               je endgame
               ; Check if 's' is pressed
               cmp al, 115
               je save
         
         ; MOUSE INTERACTION SETTING CELLS -------------------------------------------------------------
         
         drawpixel_white:
         ; Show Mouse Pointer
         mov ax, 1
         int 33h 
         
         mov ax, 3 ; get mouse position in cx, dx, if left button is down bx = 1
         int 33h
         shr cx,1 ; x/2 - in this mode the value of cx is doubled
         
         ; Check if right-click is pressed                                                                
         cmp bx, 2 ; If right-click is pressed, start game simulation
         je color_return
         
         ; Check if left-click is pressed
         cmp bx, 1
         je draw_white
         jne drawpixel_white ; just keep waiting for left click and continually check for it.
         
          ; Draw a white pixel
         draw_white:
            mov al, 1111b ; white color
            mov ah, 0ch ; set pixel
            int 10h
            jmp drawpixel_white
         
         drawpixel_cyan:
         ; Show Mouse Pointer
         mov ax, 1
         int 33h 
         
         mov ax, 3 ; get mouse position in cx, dx, if left button is down bx = 1
         int 33h
         shr cx,1 ; x/2 - in this mode the value of cx is doubled
         
         ; Check if right-click is pressed                                                                
         cmp bx, 2 ; If right-click is pressed, start game simulation
         je color_return
         
         ; Check if left-click is pressed
         cmp bx, 1
         je draw_cyan
         jne drawpixel_cyan ; just keep waiting for left click and continually check for it.
         
          ; Draw a cyan pixel
         draw_cyan:
            mov al, 1011b ; cyan color
            mov ah, 0ch ; set pixel
            int 10h
            jmp drawpixel_cyan 
            
         drawpixel_red:         
         ; Show Mouse Pointer
         mov ax, 1
         int 33h 
         
         mov ax, 3 ; get mouse position in cx, dx, if left button is down bx = 1
         int 33h
         shr cx,1 ; x/2 - in this mode the value of cx is doubled
         
         ; Check if right-click is pressed                                                                
         cmp bx, 2 ; If right-click is pressed, start game simulation
         je color_return
         
         ; Check if left-click is pressed
         cmp bx, 1
         je draw_red
         jne drawpixel_red ; just keep waiting for left click and continually check for it.
         
          ; Draw a red pixel
         draw_red:
            mov al, 1100b ; red color
            mov ah, 0ch ; set pixel
            int 10h
            jmp drawpixel_red
            
         ; Draw a black pixel (erase)
         drawpixel_erase:
         ; Show Mouse Pointer
         mov ax, 1
         int 33h 
         
         mov ax, 3 ; get mouse position in cx, dx, if left button is down bx = 1
         int 33h
         shr cx,1 ; x/2 - in this mode the value of cx is doubled
         
         ; Check if right-click is pressed                                                                
         cmp bx, 2 ; If right-click is pressed, start game simulation
         je color_return
         
         ; Check if left-click is pressed
         cmp bx, 1
         je draw_black
         jne drawpixel_erase ; just keep waiting for left click and continually check for it.
         
          ; Draw a black pixel
         draw_black:
            mov al, 0000b ; black color
            mov ah, 0ch ; set pixel
            int 10h
            jmp drawpixel_erase   
         

         ; ---------------------------------------------------------------------------------------------
         
         ; SAVE
         ; Create file
         save:
         mov ah, 3ch
         mov cx, 0
         mov dx, offset filename
         mov ah, 3ch
         int 21h
         jc err
         mov handle, ax
         jmp k
         filename db "testfile.txt", 0
         handle dw ?
         err:
         ; nothing happens
         k:
         ret
         jmp color_return
         
          
             
         ; END GAME
         endgame:
                ; Clear screen
                mov al, 13h
                mov ah, 0
                int 10h
                ; Print end game prompt
                printstring end_game
      
_code ends
end start