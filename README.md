# Luftkatze's Standalone BASIC

Current version: v1.25

### Variables
LK-BASIC does **not** give you any way to declare normal 'variables'. Instead, it gives you memory from VAR_OFFSET (0xB000) to 0xFFFF. To access this memory you use `$`. $xx returns word (2 bytes, 0 to 65535 (FFFF hex)) from xx+VAR_OFFSET. If xx+VAR_OFFSET is bigger than 0xFFFF program returns memory error. To set variable's value you use `VAR` or `PTR`(PTR == VAR) keywords, eg. `VAR 0=12`, that translates to C's `*(0+VAR_OFFSET)=12`. `VAR $0=12` coresponds to C's `*(*(0+VAR_OFFSET))=12`.
### Program lines
LK-BASIC can interpret statements just after you press enter, or save statements to memory. To save statement to memory just type line number before statement, for example:
```
10 PRINT "Hello World!"
20 STOP
```
It is good to use numbers dividable by 10, if you do that you can insert lines between 10 and 20 without rewritting entire program. Statements are saved in `[line_number*LINE_SIZE+CODE_START]`, where LINE_SIZE is 40 and CODE_START is 0x2000.
### Statements
LK-BASIC supports 18 (plus 3 synonyms and 1 not working) statements ( [] is optional parameter, <> is required parameter):
- `PRINT ["string"] [,] [variable [+|-|*] ] [;]` - prints text on screen, for example `PRINT "Hello World! Content of 0=",$0`.
- `REM [comment]` - comment.
- `VAR <address> = <value>` - sets `[number+VAR_OFFSET]` to value, for example `VAR 5=123`.
- `INPUT <address>[;]` - sets `[address]` to user input (only number), for example `INPUT 12`. Without `;` it prints `? ` before input.
- `STOP` - Stops program.
- `IF <number> < == | != | \< | \> > <number> STATEMENT` - does `STATEMENT` if condition is true, for example `IF $0==12 GOTO 10`.
- `RND <address>,<number>` - returns pseudo-random number in range 0-`number` in `[address]`.
- `++<address>` - adds one to `[address]`, for example `++0`.
- `--<address>` - subtracts one from `[address]`, for example `--0`.
- `INSTR <address>` - reads line to `address`.
- `CLS` - clears screen.
- `NEW` - deletes program.
- `LIST [line number]` - lists program lines.
- `GOTO <line number>` - sets next line pointer to `line number`, for example `GOTO 10` will go to 10th line of your code.
- `BACK` - returns to executing program after `STOP` statement.
- `RUN` - runs your program from line `1` until it reaches MAX_CODEOF or `STOP` instruction.
- `GOSUB <line number>` - same as GOTO, but saves next line number and is able to return to it using...
- `RETURN` - returns to last `GOSUB` statement.
- `XY <x>,<y>` - sets cursor position to x,y (x can be 0 to 79 and y 0 to 24 (80x25 screen)).
- `PTR <address> = <value>` - see: `VAR`.
- `? ["string"] [,] [variable [+|-|*] ] [;]` - see: `PRINT`.
- `IN <address>[;]` - see: `INPUT`.
- `GETCH <address>` - gets character from keyboard buffer and saves in <address> (high = ASCII low = BIOS scancode), for example `GETCH 0`.
- `GETCHASYNC <address>` - same as above but without waiting for keystroke (if buffer is empty returns 65535), for example `GETCHASYNC 0`.
- `PUTARR <number [number [,] ...] >` - puts char array on screen, for example `PUTARR 65,66,67,13,10`.
- `POKE <address>,<value>` - sets `[address]` to `value`, for example `POKE 1025,0`.
- `INC <address>` - see: `++`.
- `DEC <address>` - see: `--`.

### Error messages
BASIC can return ***3*** errors:
- `?Number too big error` - returned for example in `PUTARR` if character code is greater than 255.
- `?Syntax error` - basically every error.
- `?Memory error` - returned if xx+VAR_OFFSET is bigger than 65535 (FFFF hex).
### Other stuff
#### What IS NOT supported yet?
- Separating statements by `:`.
- any form of loop.
#### Why is your code so bad?
tbh idk.
### "Help! I'm stuck in infinite GOTO! How do I stop executing?!"
Ctrl+C is life Ctrl+C is love.
