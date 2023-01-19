# determines whether a character is contained in a string
# Catherine Seymour

  .data
MAX_CHARS:
  .word 10
str_message:
  .asciiz "Please enter a string: "
char_message:
  .asciiz "\nPlease enter a character: "
string:
  .space 10
character:
  .space 1
char_found:
  .asciiz " contains "
char_not_found:
  .asciiz " does not contain "
newline:
  .asciiz "\n"

  .text
  .globl main

main:
  li    $v0, 4              # print string call code
  la    $a0, str_message    # tell user to enter a string
  syscall

  li    $v0, 8              # read string call code
  la    $a0, string         # buffer for string input
  la    $a1, MAX_CHARS      # max length of string input
  syscall

  li    $v0, 4              # print string call code
  la    $a0, char_message   # tell user to enter a character
  syscall

  li    $v0, 8              # read string call code
  la    $a0, character      # read a single character
  la    $a1, 1              # char length = 1
  syscall

m_if:
  jal strcontainsi          # a0 = input string, a1 = input char
                            # v0 = 1 = char found in str, 0 = not

  beq   $v0, $zero, m_else  # go to m_else label if char not found in str

  li    $v0, 4              # print string call code
  la    $a0, string         # print input string
  syscall

  li    $v0, 4              # print string call code
  la    $a0, char_found     # prints " contains "
  syscall

  li    $v0, 4              # print string call code
  la    $a0, character      # print input character
  syscall

  li    $v0, 4              # print string call code
  la    $a0, newline        # print newline character
  syscall                   # result: prints "[input string] contains
                            #         [input character]\n"

  j main_exit               # jump to main_exit label

m_else:
  li    $v0, 4              # print string call code
  la    $a0, string         # print input string
  syscall

  li    $v0, 4              # print string call code
  la    $a0, char_not_found # prints " does not contain "
  syscall

  li    $v0, 11             # print string call code
  la    $a0, character      # print input character
  syscall

  li    $v0, 4              # print string call code
  la    $a0, newline        # print newline character
  syscall                   # result: prints "[input string] does not
                            #         contain [input character]\n"
  
main_exit:
  li    $v0, 10             # terminate call code
  syscall

  .end main


# -------------------------------------------------------------------
# Tests if a string contains a character, case insensitive
# Arguments
#   string - global address of input string
#   character - global input character
# Return
#   $v0 - 0 = char not found, 1 = char found

  .globl strcontainsi
strcontainsi:
  addu  $t0, $zero, 0       # done = t0 = 0
  addu  $v0, $zero, 0       # found = v0 = 0
  addu  $t1, $zero, 0       # i = t1 = 0

sci_loop:
  bne   $t0, 0, sci_exit    # go to sci_exit if t0 != 0

sci_null:
  sll   $t2, $t1, 2         # t2 = 4i
  addu  $t2, $t2, string    # t2 = &string[i]
  lw    $t2, 0($t2)         # t2 = string[i]

  bne   $t2, 0x0, sci_test  # go to sci_test if string[i] != '\0'
  addu  $t0, $t0, 1         # done = t0 = 1
  j     sci_loop            # jump to sci_loop label

sci_test:
  sw    $t2, $a0            # store t2 = string[i] in a0
  jal   toupper             # to_upper(string[i])
  sw    $v0, $t4            # store uppercase string[i] in t4

  sw    character, $a0      # store character in a0
  jal   toupper             # to_upper(character)
  sw    $v0, $t5            # store uppercase character in t5
  sw    $zero, $v0          # reset done = v0 = 0

  bne   $t4, $t5, sci_incr  # go to sci_incr if to_upper(string[i]) != 
                            #    to_upper(character)
  addu  $v0, $v0, 1         # found = v0 = 1
  addu  $t0, $t0, 1         # done = t0 = 1
  j     sci_loop            # jump to sci_loop label

sci_incr:
  addu  $t1, $t1, 1         # i = t1++
  j     sci_loop            # jump to sci_loop label

sci_exit:
  jr    $ra

.end strcontainsi


# -------------------------------------------------------------------
# Converts a character to uppercase

  .globl toupper
toupper:
  # a0: the character parameter
  # v0: the return value

  addu  $v0, $a0, $zero     # copy a0 to v0
  blt   $v0, 0x61, tu_end   # 0x61 = 'a'; ignore chars less than
  bgt   $v0, 0x7a, tu_end   # 0x7a = 'z'; ignore chars greater than
  subu  $v0, $v0, 0x20      # 0x20 = 'a' - 'A'

tu_end:
  jr    $ra

.end toupper 

