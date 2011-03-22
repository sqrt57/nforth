variable file
string: filename +s" Makefile" 0 +c
filename drop sys-open-ro file !
pad 200 file @ sys-read
pad swap sys-print
file @ sys-close
bye
