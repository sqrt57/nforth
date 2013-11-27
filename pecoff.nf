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

variable pecoff-mem     | Whole allocated memory block
variable image          | Address of final image (64K)
variable import-refs    | Address of import structures (16K)
variable import-names   | Address of hint-name table (16K)
variable old-here       | Old value of here

variable image-pos
variable image-length
variable import-refs-length
variable import-names-length

148 constant section-file-pointer

: image-here ( -- addr) image @ image-pos @ + ;
: import-refs-here ( -- addr) import-refs @ import-refs-length @ + ;
: import-names-here ( -- addr) import-names @ import-names-length @ + ;

: i, ( u --) image-here !  4 image-pos +! ;
: iw, ( u --) image-here w!  2 image-pos +! ;
: ic, ( u --) image-here c!  1 image-pos +! ;
: image-align ( u --) image-pos @ aligned image-pos ! ;
: r, ( u --) import-refs-here !  4 import-refs-length +! ;

: alloc-image ( --) 18000 alloc dup pecoff-mem !
    dup image !
    dup 10000 + import-refs !
    14000 + import-names !
    0 image-pos !
    0 import-refs-length !
    0 import-names-length !
;

: init-here ( --) here old-here !  image @ to here ;
: pe-header-mz ( --) 5a4d iw,  3a image-pos +!  40 i, ;
| * means the field must be filled with meaningful value
| COFF header
: pe-header-coff ( --)
    14c iw,     | IMAGE_FILE_MACHINE_I386
    1 iw,       | NumberOfSections
    0 i,        | TimeDateStamp
    0 i,        | PointerToSymbolTable
    0 i,        | NumberOfSymbols
    0    iw,    | * SizeOfOptionalHeader
    0103 iw,    | Characteristics = IMAGE_FILE_RELOCS_STRIPPED
                | | IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
;
| Optional header
: pe-header-opt ( --)
    10 iw,      | PE32 magic number
    0 ic, 1 ic, | Major and minor linker version
    0 i,        | * SizeOfCode
    0 i,        | * SizeOfInitializedData
    0 i,        | * SizeOfUninitializedData
    0 i,        | * AddressOfEntryPoint
    0 i,        | * BaseOfCode
    0 i,        | * BaseOfData
;
| Optional header Windows-specific fields
: pe-header-opt-win ( --)
    00400000 i, | ImageBase
    00000200 i, | SectionAlignment
    00000200 i, | FileAlignment
    5 iw, 0 iw, | Major and minor OS version = 5.0 (Windows 2000)
    0 iw, 1 iw, | Major and minor image version
    0 iw, 1 iw, | Major and minor subsystem version
    0 i,        | Win32VersionValue, reserved
    0 i,        | * SizeOfImage
    0 i,        | * SizeOfHeaders
    0 i,        | * CheckSum
    3 iw,       | Subsystem = IMAGE_SUBSYSTEM_WINDOWS_CUI
    0 iw,       | DllCharacteristics
    0 i,        | * SizeOfStackReserve
    0 i,        | * SizeOfStackCommit
    0 i,        | * SizeOfHeapReserve
    0 i,        | * SizeOfHeapCommit
    0 i,        | LoaderFlags, reserved
    0d i,       | NumberOfRvaAndSizes
;
: pe-header-data-dict ( --)
    0 i, 0 i,   | Export Table
    0 i, 0 i,   | * Import Lookup Table
    0 i, 0 i,   | Resource Table
    0 i, 0 i,   | Exception Table
    0 i, 0 i,   | Certificate Table
    0 i, 0 i,   | Base Relocation Table
    0 i, 0 i,   | Debug
    0 i, 0 i,   | Architecture
    0 i, 0 i,   | Global Ptr
    0 i, 0 i,   | TLS Table
    0 i, 0 i,   | Load Config Table
    0 i, 0 i,   | Bound Import
    0 i, 0 i,   | * Import Address Table
;

: section-table ( --)
    | There is just one entry in section table
    7865742e i, 00000074 i, | Name = ".text\0\0\0"
    0 i,        | * VirtualSize
    0 i,        | * VirtualAddress
    0 i,        | * SizeOfRawData
    0 i,        | * PointerToRawData
    0 i,        | PointerToRelocations
    0 i,        | PointerToLinenumbers
    0 iw,       | NumberOfRelocations
    0 iw,       | NumberOfLinenumbers
    e00000e0 i, | Characteristics = IMAGE_SCN_CNT_CODE
                | | IMAGE_SCN_CNT_INITIALIZED_DATA
                | | IMAGE_SCN_CNT_UNINITIALIZED_ DATA
                | | IMAGE_SCN_MEM_EXECUTE
                | | IMAGE_SCN_MEM_READ | IMAGE_SCN_MEM_WRITE
;

| PE header
: pe-header ( --)
    pe-header-mz 
    0004550 i,  | PE signature
    pe-header-coff pe-header-opt pe-header-opt-win
    pe-header-data-dict section-table ;

| Allocates memory structures for constructing PE/COFF file.
: pecoff-init ( --) alloc-image section-file-pointer image-pos ! ;

: open ( addr u -- handle) zero-str sys-open-rw-overwrite ;
: write ( handle --) image @ image-length @ rot sys-write ;
: set-length ( --) image-pos @ image-length ! ;
| Writes PE/COFF image to file with specified filename.
: pecoff-write ( addr u --) set-length 0 image-pos ! pe-header
    open dup write sys-close ;

| Frees memory structures allocated for PE/COFF image.
: pecoff-done ( --) pecoff-mem @ free ;

| Format of import structures is as follows.
| Address of library 1 name
| Number of symbols imported from library 1
|   (Address of memory cell for storing symbol rva
|   Address of symbol name) * N
| Address of library 2 name
| Number of symbols imported from library 2
|   ...
: dll-name ( addr -- addr) @ ;
: dll-num ( addr -- u) 4 + @ ;
: dll-ilts-length ( addr -- u) dll-num 4 * 4 + ;
: symbol-name ( addr -- addr) 4 + @ ;
: symbol-cell ( addr -- addr) @ ;

| Takes dll name as input, imports that library
: zero-and-move ( u --) 1 + import-names-length +!  0 import-names-here 1 - c! ;
: copy-name ( addr u -- addr) swap import-names-here over2 cmove
    import-names-here swap zero-and-move ;
variable dll-count  0 dll-count !
variable symbol-count  0 symbol-count !
variable local-symbol-counter
: import-dll ( addr u --) 1 dll-count +!  copy-name r,
    import-refs-here local-symbol-counter !  0 r, ;
| Takes symbol name as input, imports the symbol. Creates word with name
| from input stream and makes it return rva of imported symbol.
: import-symbol: ( addr u "word"--) 1 local-symbol-counter @ +!
    1 symbol-count +!
    create here r, 0 ,  import-names-here r,  copy-name  does> @ ;
variable section-base
: calc-section-base ( --) image @ section-file-pointer + section-base ! ;
variable ilts-base
: calc-ilts-base ( --) section-base @  dll-count @ 14 * +  14 +  ilts-base ! ;
variable names-base
: calc-names-base ( --) section-base @  dll-count @ 1c * +
    symbol-count @ 8 * +  14 +  names-base ! ;
variable dt-addr
variable ilt-addr
: dt, ( u --) dt-addr @ !  4 dt-addr +! ;
: ilt, ( u --) ilt-addr @ !  4 ilt-addr +! ;
: rva ( addr -- u) section-base @ - ;
: nrva ( addr -- u) import-names @ -  names-base @ +  rva ;
: dt-entry ( addr --) ilt-addr @ rva dt,  0 dt,  0 dt,  dup dll-name nrva dt,
    ilt-addr @ over dll-ilts-length + rva  dt,  drop ;
: dt-zero ( --) 0 dt, 0 dt, 0 dt, 0 dt, 0 dt, ;
: next-symbol ( addr -- addr) 8 + ;
: symbol-rva, ( addr --) ilt-addr @ rva swap symbol-cell ! ;
: fill-symbol ( addr --) dup symbol-rva, symbol-name nrva ilt, ;
: process-symbols ( addr u --) begin dup 0 = if 0 ilt, drop drop exit endif 1 -
    swap dup fill-symbol next-symbol swap again ;
: next-dll ( addr -- addr) dup dll-num 8 * + 8 + ;
: fill-dll ( addr --) dup dt-entry 8 + dup 8 - dll-num 2dup
    process-symbols process-symbols ;
: process-imports ( addr u --) begin dup 0 = if drop drop exit endif 1 -
    swap dup fill-dll next-dll swap again ;
: fill-image-imports ( --) 
    image-here dt-addr !
    ilts-base @  ilt-addr !
    import-refs @ dll-count @ process-imports ;
: copy-names ( --) import-names @  names-base @  import-names-length @  cmove ;
: update-image-pos ( --) names-base @ import-names-length @ +
    image @ -  image-pos ! ;
: import-done ( --) calc-section-base calc-names-base calc-ilts-base
    fill-image-imports copy-names update-image-pos ;
