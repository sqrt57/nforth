| Copyright 2010-2013 Dmitry Grigoryev
|
| This file is part of Nforth.
|
| Nforth is free software: you can redistribute it and/or modify
| it under the terms of the GNU Affero General Public License as published by
| the Free Software Foundation, either version 3 of the License, or
| (at your option) any later version.
|
| Nforth is distributed in the hope that it will be useful,
| but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
| GNU Affero General Public License for more details.
|
| You should have received a copy of the GNU Affero General Public License
| along with Nforth.  If not, see <http://www.gnu.org/licenses/>.

| Common part for all code words.
| Executes next word from thread.
: next ( --)
    eax  [esi]      movd-reg-mem    | Get next word address from thread
    esi  4 [b+esi]  lead            | Adjust IP
    edi  [eax]      movd-reg-mem    | EDI points to machine code of next word
    edi             jmpd-near-reg   | Jump to word machine code
    ;

| x1 x2 -- x2 x1
create-code swap
    edx  [esp]      xchgd-reg-mem
    next

create-code drop ( x --)
    edx             popd-reg
    next

create-code dup ( x -- x x)
    edx             pushd-reg
    next

create-code over ( x1 x2 -- x1 x2 x1)
    edx             pushd-reg
    edx  4 [b+esp]  movd-reg-mem
    next

create-code over2 ( x1 x2 x3 -- x1 x2 x3 x1)
    edx             pushd-reg
    edx  8 [b+esp]  movd-reg-mem
    next

create-code rot ( x1 x2 x3 -- x2 x3 x1)
    edx  [esp]       xchgd-reg-mem  | x1 x3 x2
    edx  4 [b+esp]   xchgd-reg-mem  | x2 x3 x1
    next

create-code >r ( x -- ; R: -- x)
    ebp  -4 [b+ebp]  lead           | Add one cell on top of return stack
    [ebp]  edx       movd-mem-reg   | Push TOS on return stack
    edx              popd-reg       | Fetch new TOS
    next

create-code r> ( -- x ; R: x --)
    edx             pushd-reg       | Store old TOS
    edx  [ebp]      movd-reg-mem    | Pop TOS from return stack
    ebp  4 [b+ebp]  lead            | Remove one cell from return cell
    next

create-code r@ ( -- x; R: x -- x)
    edx             pushd-reg       | Store old TOS
    edx  [ebp]      movd-reg-mem    | Fetch TOS from return stack
    next

create-code @ ( addr -- x)
    edx  [edx]      movd-reg-mem    | Get X from ADDR
    next

create-code ! ( x addr --)
    ebx             popd-reg        | Get X value
    [edx]  ebx      movd-mem-reg    | Store X at ADDR
    edx             popd-reg        | Get new TOS
    next

create-code c@ ( addr -- byte)
    edx  [edx]      movzx-regd-memb | Get BYTE from ADDR
    next

create-code c! ( byte addr --)
    ebx             popd-reg        | Get BYTE value
    [edx]  bl       movb-mem-reg    | Store WORD at ADDR
    edx             popd-reg        | Get new TOS
    next

create-code w@ ( addr -- word)
    edx  [edx]      movzx-regd-memw | Get WORD from ADDR
    next

create-code w! ( word addr --)
    ebx             popd-reg        | Get WORD value
    [edx]  bx       movw-mem-reg    | Store WORD at ADDR
    edx             popd-reg        | Get new TOS
    next

create-code lit ( -- x / x from thread)
    edx             pushd-reg       | Store old TOS
    edx  [esi]      movd-reg-mem    | Read X from thread into TOS
    esi  4 [b+esi]  lead            | Adjust IP
    next

create-code jump ( -- / addr from thread)
    esi  [esi]      movd-reg-mem    | Get new IP
    next

create-code jump-if-not ( -- / addr from thread)
    esi  4 [b+esi]  lead            | If we don't take a jump we must skip
                                    | jump address in the thread
    edx 0 cmpd-reg-immb             | Compare TOS to 0
    jnz  |->b                       | If B!=0 we skip updating IP
    esi  -4 [b+esi] movd-reg-mem    | Get new IP (if TOS=0)
    ->|b
    edx             popd-reg        | Get new TOS
    next

create-code execute ( i*x xt -- j*x)
    eax  edx        movd-reg-reg    | Get next word address from TOS
    edi  [eax]      movd-reg-mem    | X now points to machine code of XT
    edx             popd-reg        | Get new TOS
    edi             jmpd-near-reg   | Jump to XT machine code

| bit-and
create-code and ( u1 u2 -- u)
    edx  [esp]      andd-reg-mem    | TOS <- U1 and U2
    esp  4 [b+esp]  lead            | Remove U1 from stack
    next

| bit-or
create-code or ( u1 u2 -- u)
    edx  [esp]      ord-reg-mem     | TOS <- U1 or U2
    esp  4 [b+esp]  lead            | Remove U1 from stack
    next

| bit-not
create-code not ( u -- u)
    edx             notd-reg        | TOS <- not TOS
    next

create-code 0= ( u -- bool)
    eax  eax        xord-reg-reg    | Zero EAX
    edx  eax        cmpd-reg-reg    | Compare TOS to 0
    jnz  |->b                       | If TOS!=0 then EAX=0 is what we need,
                                    | so we skip decrement
    eax             decd-reg        | EAX is now -1
    ->|b
    edx  eax        movd-reg-reg    | Store EAX value to TOS
    next

create-code = ( n1/u1 n2/u2 -- bool)
    eax  eax        xord-reg-reg    | Zero EAX
    [esp]  edx      cmpd-mem-reg    | Compare N1 to TOS=N2
    jne  |->b                       | If not N1=N2 then skip decrement
    eax             decd-reg        | EAX is now -1
    ->|b
    esp  4 [b+esp]  lead            | Remove N1 from parameter stack
    edx  eax        movd-reg-reg    | Store EAX value to TOS
    next

| Signed numbers less-than comparison
create-code < ( n1 n2 -- bool)
    eax  eax        xord-reg-reg    | Zero EAX
    [esp]  edx      cmpd-mem-reg    | Compare N1 to TOS=N2
    jnl  |->b                       | If not N1<N2 then skip decrement
    eax             decd-reg        | EAX is now -1
    ->|b
    esp  4 [b+esp]  lead            | Remove N1 from parameter stack
    edx  eax        movd-reg-reg    | Store EAX value to TOS
    next

| Signed numbers greater-than comparison
create-code > ( n1 n2 -- bool)
    eax  eax        xord-reg-reg    | Zero EAX
    [esp]  edx      cmpd-mem-reg    | Compare N1 to TOS=N2
    jng  |->b                       | If not N1>N2 then skip decrement
    eax             decd-reg        | EAX is now -1
    ->|b
    esp  4 [b+esp]  lead            | Remove N1 from parameter stack
    edx  eax        movd-reg-reg    | Store EAX value to TOS
    next

| Signed numbers less-than-or-equal comparison
create-code <= ( n1 n2 -- bool)
    eax  eax        xord-reg-reg    | Zero EAX
    [esp]  edx      cmpd-mem-reg    | Compare N1 to TOS=N2
    jnle  |->b                      | If not N1<=N2 then skip decrement
    eax             decd-reg        | EAX is now -1
    ->|b
    esp  4 [b+esp]  lead            | Remove N1 from parameter stack
    edx  eax        movd-reg-reg    | Store EAX value to TOS
    next

| Signed numbers greater-than-or-equal comparison
create-code >= ( n1 n2 -- bool)
    eax  eax        xord-reg-reg    | Zero EAX
    [esp]  edx      cmpd-mem-reg    | Compare N1 to TOS=N2
    jnge  |->b                      | If not N1>=N2 then skip decrement
    eax             decd-reg        | EAX is now -1
    ->|b
    esp  4 [b+esp]  lead            | Remove N1 from parameter stack
    edx  eax        movd-reg-reg    | Store EAX value to TOS
    next

| Negate signed number
create-code negate ( n -- n)
    edx             negd-reg        | Negate TOS
    next

| Adds two signed or unsigned numbers
create-code + ( u1/n1 u2/n2 -- u/n)
    ebx             popd-reg        | Get N1 from the stack
    edx  ebx        addd-reg-reg    | Add N1 to TOS=N2
    next

| Subtracts two signed or unsigned numbers
create-code - ( u1/n1 u2/n2 -- u/n)
    ebx             popd-reg        | Get N1 from the stack
    ebx  edx        subd-reg-reg    | Subtract TOS=N2 from N1
    edx  ebx        movd-reg-reg    | Move result to TOS
    next

| Multiplies two signed numbers
create-code * ( n1 n2 -- n)
    eax             popd-reg        | Load N1 into EAX
    edx             imuld-reg       | Multiply N1 by N2
    edx  eax        movd-reg-reg    | Store result into TOS
    next

| Multiplies two unsigned numbers
create-code u* ( u1 u2 -- u)
    eax             popd-reg        | Load U1 into EAX
    edx             muld-reg        | Multiply U1 by U2
    edx  eax        movd-reg-reg    | Store result into TOS
    next

| Divides first signed number by second returning remainder and quotient
create-code /mod ( n1 n2 -- n3 n4)
    ebx  edx        movd-reg-reg    | Store N2 in EBX
    eax             popd-reg        | Store N1 in EAX
    cdq                             | Sign-extend N1 to EDX:EAX
    ebx             idivd-reg       | Signed divide N1 by N2
    edx             pushd-reg       | Store remainder as N3
    edx  eax        movd-reg-reg    | Store quotient as N4
    next

| Divides first unsigned number by second returning remainder and quotient
create-code u/mod ( u1 u2 -- u3 u4)
    ebx  edx        movd-reg-reg    | Store U2 in EBX
    eax             popd-reg        | Store U1 in EAX
    edx edx         xord-reg-reg    | Zero-extend U1 to EDX:EAX
    ebx             divd-reg        | Unsigned divide U1 by U2
    edx             pushd-reg       | Store remainder as U3
    edx  eax        movd-reg-reg    | Store quotient as U4
    next

| Left shifts first argument by number of bits specified in the second argument
create-code lshift ( x1 u -- x2)
    ecx  edx        movd-reg-reg    | Load count from TOS
    edx             popd-reg        | Get new TOS
    edx             shld-reg-cl     | Perform left shift of TOS
    next

| Right shifts first argument by number of bits specified in the second argument
create-code rshift ( x1 u -- x2)
    ecx  edx        movd-reg-reg    | Load count from TOS
    edx             popd-reg        | Get new TOS
    edx             shrd-reg-cl     | Perform left shift of TOS
    next

| Code field for enter
here
    ebp  -4 [b+ebp] lead            | Add one cell on top of return stack
    [ebp]  esi      movd-mem-reg    | Push IP on return stack
    esi  8 [b+eax]  lead            | Set IP to the parameter field
                                    | of current word
    next
constant do-enter

| Code field for var
here
    edx             pushd-reg       | Push old TOS
    edx  8 [b+eax]  lead            | Get adress of parameter field
    next
constant do-var

| Code field for const
here
    edx             pushd-reg       | Push old TOS
    edx  8 [b+eax]  movd-reg-mem    | Load TOS from parameter field
    next
constant do-const

| Code field for does>
here
    ebp  -4 [b+ebp] lead            | Add one cell on top of return stack
    [ebp]  esi      movd-mem-reg    | Push IP on return stack
    edx             pushd-reg       | Push one cell on parameter stack
    esi  4 [b+eax]  movd-reg-mem    | Set IP to DOES> entry for current word
    edx  8 [b+eax]  lead            | Set TOS to the parameter field
                                    | of current word
    next
constant do-does


