.text
    .global _start

_start:

.data
x: .quad 0
.text
.data
y: .quad 0
.text
.data
z: .quad 0
.text
.data
t: .quad 0
.text
	pushq 	$-999

	pushq 	$-999

	pushq 	$1

	popq 	%rbx
	popq 	%rax
	subq 	%rbx, %rax
	pushq 	%rax

	popq 	%rax
	popq 	%rbx
	addq 	%rbx, %rax
	pushq 	%rax

	popq 	%rbx
    movq    $1, %rax
    int     $0x80

