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

| x --
create-code drop
    edx             popd-reg
    next

| x -- x x
create-code dup
    edx             pushd-reg
    next

| x1 x2 -- x1 x2 x1
create-code over
    edx             pushd-reg
    edx  4 [b+esp]  movd-reg-mem
    next

| x1 x2 x3 -- x1 x2 x3 x1
create-code over2
    edx             pushd-reg
    edx  8 [b+esp]  movd-reg-mem
    next
    
| x1 x2 x3 -- x2 x3 x1
create-code rot
    edx  [esp]       xchgd-reg-mem  | x1 x3 x2
    edx  4 [b+esp]   xchgd-reg-mem  | x2 x3 x1
    next

| x -- ; R: -- x
create-code >r
    ebp  -4 [b+ebp]  lead           | Add one cell on top of return stack
    [ebp]  edx       movd-mem-reg   | Push TOS on return stack
    edx              popd-reg       | Fetch new TOS
    next

| -- x ; R: x --
create-code r>
    edx             pushd-reg       | Store old TOS
    edx  [ebp]      movd-reg-mem    | Pop TOS from return stack
    ebp  4 [b+ebp]  lead            | Remove one cell from return cell
    next

| -- x; R: x -- x
create-code r@
    edx             pushd-reg       | Store old TOS
    edx  [ebp]      movd-reg-mem    | Fetch TOS from return stack
    next

| addr -- x
create-code @
    edx  [edx]      movd-reg-mem    | Get X from ADDR
    next

| x addr --
create-code !
    ebx             popd-reg        | Get X value
    [edx]  ebx      movd-mem-reg    | Store X at ADDR
    edx             popd-reg        | Get new TOS
    next

| addr -- byte
create-code c@
    edx  [edx]      movzx-regd-memb | Get BYTE from ADDR
    next

| byte addr --
create-code c!
    ebx             popd-reg        | Get BYTE value
    [edx]  bl       movb-mem-reg    | Store WORD at ADDR
    edx             popd-reg        | Get new TOS
    next

| addr -- word
create-code w@
    edx  [edx]      movzx-regd-memw | Get WORD from ADDR
    next
    
| word addr --
create-code w!
    ebx             popd-reg        | Get WORD value
    [edx]  bx       movw-mem-reg    | Store WORD at ADDR
    edx             popd-reg        | Get new TOS
    next

