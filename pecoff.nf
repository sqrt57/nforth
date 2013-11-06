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
variable image          | Address of final image
variable old-here       | Old value of here
: image-length ( -- u) here image @ - ;

: alloc-image ( --) 10000 alloc dup pecoff-mem ! image ! ;
: init-here ( --) here old-here !  image @ to here ;
: mz-header ( --) 5a4d w,  3a allot 40 , ;
: pe-header ( --)
    [c'] P c, [c'] E c, 0 w,    | PE signature
    14c w,                      | IMAGE_FILE_MACHINE_I386
;

| Allocates memory structures for constructing PE/COFF file.
: pecoff-init ( --) alloc-image init-here mz-header pe-header ;

: open ( addr u -- handle) zero-str sys-open-rw-overwrite ;
: write ( handle --) image @ image-length rot sys-write ;
| Writes PE/COFF image to file with specified filename.
: pecoff-write ( addr u --) open dup write sys-close ;

| Frees memory structures allocated for PE/COFF image.
: pecoff-done ( --) pecoff-mem @ free  old-here @ to here ;
