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

hex

| --- Defining words
: create-code ( "--) create here 4 - to here here last-xt @ ! ;

| --- Variables  for holding parts of opcode
variable op-reg
variable op-mod
variable op-r/m
variable op-sib
variable op-sib?
variable op-disp
variable op-disp-size
variable op-immed
variable op-immed-size

| --- Register codes
: eax 0 ;
: ecx 1 ;
: edx 2 ;
: ebx 3 ;
: esp 4 ;
: ebp 5 ;
: esi 6 ;
: edi 7 ;

| --- Helper words
| -- ModR/M-byte
: mod-rm ( --c) op-r/m @  op-reg @ 3 lshift +  op-mod @ 6 lshift + ;
| -- SIB-byte
: sib ( ccc-c) swap 3 lshift +  swap 6 lshift + ;
: sib, ( ---) op-sib? @ if op-sib @ c, endif ;
: disp, ( ---) op-disp-size @
    dup 1 = if op-disp @ c, endif
    dup 2 = if op-disp @ w, endif
        3 = if op-disp @ , endif ;
: rest,  mod-rm c, sib, disp, ;

| All register words have the same signature
| ---
| Where SIB? is a boolean indicating the need for SIB in opcode
: [eax] 0 op-mod !  0 op-r/m !  0 op-sib? !  0 op-disp-size ! ;
: [ecx] 0 op-mod !  1 op-r/m !  0 op-sib? !  0 op-disp-size ! ;
: [edx] 0 op-mod !  2 op-r/m !  0 op-sib? !  0 op-disp-size ! ;
: [ebx] 0 op-mod !  3 op-r/m !  0 op-sib? !  0 op-disp-size ! ;
: [esp] 0 op-mod !  4 op-r/m !  -1 op-sib? !  24 op-sib !  0 op-disp-size ! ;
: [ebp] 1 op-mod !  5 op-r/m !  0 op-sib? !  1 op-disp-size !  0 op-disp ! ;
: [esi] 0 op-mod !  6 op-r/m !  0 op-sib? !  0 op-disp-size ! ;
: [edi] 0 op-mod !  7 op-r/m !  0 op-sib? !  0 op-disp-size ! ;

| disp8 --
: [b+eax] op-disp !  1 op-mod !  0 op-r/m !  0 op-sib? !  1 op-disp-size ! ;
: [b+ecx] op-disp !  1 op-mod !  1 op-r/m !  0 op-sib? !  1 op-disp-size ! ;
: [b+edx] op-disp !  1 op-mod !  2 op-r/m !  0 op-sib? !  1 op-disp-size ! ;
: [b+ebx] op-disp !  1 op-mod !  3 op-r/m !  0 op-sib? !  1 op-disp-size ! ;
: [b+esp] op-disp !  1 op-mod !  4 op-r/m !  -1 op-sib? !  24 op-sib !
    1 op-disp-size ! ;
: [b+ebp] op-disp !  1 op-mod !  5 op-r/m !  0 op-sib? !  1 op-disp-size ! ;
: [b+esi] op-disp !  1 op-mod !  6 op-r/m !  0 op-sib? !  1 op-disp-size ! ;
: [b+edi] op-disp !  1 op-mod !  7 op-r/m !  0 op-sib? !  1 op-disp-size ! ;

| --- Instructions
| --
: pushd-reg ( c--) 50 + c, ;
| --
: movd-reg-mem ( c--) op-reg !  8b c,  rest, ;
: movd-reg-reg ( cc--) op-r/m !  op-reg !  3 op-mod !  0 op-sib? !
    0 op-disp-size !  8b c,  rest, ;
: movd-mem-reg ( c--) op-reg !  89 c,  rest, ;
: lea ( c--) op-reg !  8d c,  rest, ;
: jmp-near-mem ( --)  4 op-reg !  ff c,  rest, ;
: jmp-near-reg ( c--)  op-r/m !  3 op-mod !  0 op-sib? !  0 op-disp-size !
    4 op-reg !  ff c,  rest, ;
