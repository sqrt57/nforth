" core.nf" included
" asm.nf" included

create-code my-dup
hex
52 c,                   | push edx
8B c, 06 c,             | mov eax, [esi]
8D c, 76 c, 04 c,       | lea esi, [esi+4]
8B c, 38 c,             | mov edi, [eax]
FF c, E7 c,             | jmp edi
dec

45 my-dup . .
