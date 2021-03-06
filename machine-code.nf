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

create-code asm-dup
    edx pushd-reg
    eax  [esi] movd-reg-mem
    esi  4 [b+esi] lead
    edi  [eax] movd-reg-mem
    edi  jmpd-near-reg

esi [esp] movd-reg-mem
edi [ebp] movd-reg-mem

eax [esi] movd-mem-reg
esi [esp] movd-mem-reg
edi [ebp] movd-mem-reg

eax ebx movd-reg-reg

eax [esi] lead
esi [esp] lead
edi [ebp] lead
eax  4 [b+esp] lead
ecx  4 [b+ebp] lead

45 my-dup . .
48 asm-dup . .
newline

' my-dup 4 + 32 dump
' asm-dup 4 + 48 dump
