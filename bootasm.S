# When the PC starts, the processor is essentially emulating an 8086 processor, i.e. 
# a 16-bit processor.  So our initial boot loader code is 16-bit code that will 
# eventually switch the processor into 32-bit mode.

# This code is linked to assume a starting address of 0x7C00 which is where the BIOS
# will load a boot segment.

.code16                         # Assemble for 16-bit mode
.globl start                    # defines start as a global address lable. tells the system "start from here".
start:
    jmp     real_start

# Because assembly runs top down with no concept of functions
# we need to have a start at the top that jumps to where we really want to start.

# Write to the console using BIOS.
# 
# Input: SI contains the address of the null-terminated string to be displayed

cons_write:
    movb    $0x0e, %ah           # 0x0e is the INT 10h BIOS call to output the value contained in AL to screen

cons_write_rpt:
    movb    (%si), %al          # Load the byte at the location contained in the SI register into AL   
    inc     %si                 # Add 1 to the value in SI
    cmp     $0, %al             # Compare the value in AL with 0
    jz      cons_write_done     # If it is zero, then we are done
    int     $0x10               # Output the character in AL to the screen
    jmp     cons_write_rpt      # and continue

cons_write_done:                # Something that is called will never return 
    ret                         # until a 'ret' instruction is encountered.  Labels do 
                                # not give a program any structure.  They just give a 
                                # memory location a name that we can use in our code. 


cons_writeline:
    # use cons write and cons_write_clrf to display the null terminated string that is in register SL.
    call    cons_write      # calls the pre-existing cons_write.
    call    cons_write_clrf # Sends execution to the write_clrf.
    ret                     # returns to the last place it was called from.

cons_write_clrf:
    # output CR (carige return) 0x0D and LF (line feed) 0x0A
    movb    $0x0e, %ah
    movb    $0x0D, %al      # puts $0x0D into the al register
    int     $0x10
    movb    $0x0A, %al      # puts $0x0A into the al register
    int     $0x10
    ret     # sends execution back to the last place it called from.

real_start:
    cli                         # BIOS enabled interrupts; disable

    # Zero data segment registers DS, ES, and SS.
    xorw    %ax, %ax            # Set %ax to zero
    movw    %ax, %ds            # -> Data Segment
    movw    %ax, %es            # -> Extra Segment
    movw    %ax, %ss            # -> Stack Segment

    movw    $0, %sp             # Set the stack to the top of the segment
    movw    $boot_message, %si  # Display our boot message
    call    cons_write
    call    cons_write_clrf
    movw    $boot_message, %si  # Becuase of how write works (incrementing si, effectively overwriting it), 
                                # si needs to be reset as it at the end of the line after completing the write.
                                # This effectively resets the boot message, but we can set it to anything.
    call    cons_writeline
    movw    $fun_message, %si   # loads my funky new message
    call    cons_writeline

endless_loop:                   # Loop forever more
    jmp     endless_loop    

boot_message:                  # Definition of our boot message 
    .string "Boot Loader V1.0"

fun_message:
    .string "Welcome to a peice of code that does naught but display what you've seen right now.0"

