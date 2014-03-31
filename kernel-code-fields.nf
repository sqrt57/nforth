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

do-const constant odo-const

after

| Code field for enter
align here
    ebp  -4 [b+ebp] lead            | Add one cell on top of return stack
    [ebp]  esi      movd-mem-reg    | Push IP on return stack
    esi  8 [b+eax]  lead            | Set IP to the parameter field
                                    | of current word
    next
constant do-enter

| Code field for var
align here
    edx             pushd-reg       | Push old TOS
    edx  8 [b+eax]  lead            | Get adress of parameter field
    next
constant do-var

| Code field for const
align here
    edx             pushd-reg       | Push old TOS
    edx  8 [b+eax]  movd-reg-mem    | Load TOS from parameter field
    next
constant do-const

| Code field for does>
align here
    ebp  -4 [b+ebp] lead            | Add one cell on top of return stack
    [ebp]  esi      movd-mem-reg    | Push IP on return stack
    edx             pushd-reg       | Push one cell on parameter stack
    esi  4 [b+eax]  movd-reg-mem    | Set IP to DOES> entry for current word
    edx  8 [b+eax]  lead            | Set TOS to the parameter field
                                    | of current word
    next
constant do-does

before
