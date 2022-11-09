; Autor reseni: Onegen (xkrame00)

; Projekt 2 - INP 2022
; Vernamova sifra na architekture MIPS64

; Moje registre
;  R0  ($zero) - nulova konstanta
;  R1  ($at)   - assembler temp.
;  R4  ($a0)   - function arg.
;  R10 ($t2)   - temporary reg.
;  R20 ($s4)   - saved reg.
;  R29 ($sp)   - stack pointer

; DATA SEGMENT
                .data
login:          .asciiz         "xkrame00"                  ; login
key:            .asciiz         "on"                        ; sifrovaci kluc
cipher:         .space          17                          ; miesto pre sifrovany login
params_sys5:    .space          8                           ; miesto pre adresu pociatku retazca

; CODE SEGMENT
                .text
main:
                DADDI           R20, R0, 0                  ; R20 = index v retazci (pocitadlo)

encryptLoop:
                ; Ulozenie adresy retazca
                DADDI           R4, R0, login               ; R4 = adresa retazca na sifrovanie
                DADD            R4, R4, R20
                LB              R10, 0(R4)                  ; R10 = ASCII znak na aktualnej pozicii

                ; Ak znak nie je male pismeno, koniec cyklu
                SLTI            R1, R10, 96                 ; R1 = 1 ak je ASCII znak < 96, inak R1 = 0
                BNEZ            R1, encryptEnd              ; Ak R1 = 1, koniec sifrovania
                DADDI           R10, R10, -96               ; R10 = hodnota znaku

                ; Ziskanie hodnoty kluca pre aktualny index a zasifrovanie znaku
                DADDI           R4, R0, key                 ; R4 = adresa kluca
                ANDI            R1, R20, 1                  ; R1 = 0 ak je index parny, inak R1 = 1
                DADD            R4, R4, R1
                LB              R4, 0(R4)                   ; R4 = ASCII znak kluca na pozicii R1
                DADDI           R4, R4, -96                 ; R4 = hodnota kluca
                DADD            R10, R10, R4                ; R10 = hodnota sifrovaneho znaku

                ; Posunutie znaku ak je vysledok mimo rozsah malych pismen (1-26)
                ; Znak je mensi ako 'a'
                SLTI            R4, R10, 1                  ; R4 = 1 ak je hodnota menej ako 'a', inak R1 = 0
                DADDI           R1, R0, 26
                DMULT           R4, R1
                MFLO            R4                          ; R4 = 26 ak je hodnota menej ako 'a', inak R1 = 0
                DADD            R10, R10, R4
                ; Znak je vacsi ako 'z'
                SLTI            R4, R10, 27
                XORI            R4, R4, 1                   ; R4 = 1 ak je hodnota vacsia ako 'z', inak R1 = 0
                DADDI           R1, R0, -26
                DMULT           R4, R1
                MFLO            R4                          ; R4 = -26 ak je hodnota vacsia ako 'z', inak R1 = 0
                DADD            R10, R10, R4

                ; Vlozenie sifrovaneho znaku do vystupneho retazca
                DADDI           R10, R10, 96                ; R10 = ASCII hodnota sifrovaneho znaku
                DADDI           R4, R0, cipher              ; R4 = adresa vystupneho retazca
                ADD             R4, R4, R20
                SB              R10, 0(R4)                  ; vlozenie sifrovaneho znaku do vystupneho retazca

                ; Pokracovanie cyklu
                DADDI           R20, R20, 1                 ; R20 = index + 1
                B               encryptLoop

encryptEnd:
                ; Vlozenie vyslednej sifry do R4
                DADDI           R4, R0, cipher
                JAL             print_string
                SYSCALL         0

print_string:
                SW              R4, params_sys5(r0)
                DADDI           R14, R0, params_sys5
                SYSCALL         5
                JR              R31
