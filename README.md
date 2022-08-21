# Luftkatze's Standalone BASIC

### Variables
LK-BASIC does NOT give you any way to declare variables. Instead, it gives you memory from VAR_OFFSET (0xB000) to 0xFFFF. To access this memory you use `$`. $xx returns word (2 bytes, 0 to 65535 (FFFF hex)) from xx+VAR_OFFSET. If xx+VAR_OFFSET is bigger than 0xFFFF program returns memory error. To set variable's value you use `VAR` or `PTR`(PTR == VAR) keywords, eg. `VAR 0=12`, that translates to C's `*(0+VAR_OFFSET)=12`. `VAR $0=12` coresponds to C's `*(*(0+VAR_OFFSET))=12`.
### Program lines
LK-BASIC can interpret statements just after you press enter, or save statements to memory. To save statement to memory just type line number before statement, for example:
```
10 PRINT "Hello World!"
20 STOP
```
It is good to use numbers dividable by 10, if you do that you can insert lines between 10 and 20 without rewritting entire program.
### Statements
LK-BASIC supports 18 (plus 3 synonyms and 1 not working) statements ( [] is optional parameter, <> is required parameter):
- `PRINT ["string"] [,] [variable [+|-|*] ] [;]`, for example `PRINT "Hello World! Content of 0=",$0`.
- `REM [comment]` - comment.
- `VAR <address> = <value>` - set `[number+VAR_OFFSET]` to value, for example `VAR 5=123`.
- `INPUT <address>[;]` - set `[address]` to user input (only number), for example `INPUT 12`. Without `;` it prints `? ` before input.
- `STOP` - Stop program.
- `IF <number> < == | != | \\< | \\> > <number> STATEMENT` - does `STATEMENT` if condition is true, for example `IF $0==12 GOTO 10`.
- `RND <address>` - does nothing.
- `++<address>` - adds one to `[address]`, for example `++0`.
- `--<address>` - subtracts one from `[address]`, for example `--0`.
- `INSTR <address>` - reads line to `address`.
- `CLS` - clears screen.
- `NEW` - clears program.
- `LIST [line number]` - lists program lines.
- `GOTO <line number>` - sets next line pointer to `<line number>`, for example `GOTO 10` will go to 10th line of your code.
- `BACK` - return to executing program after `STOP` statement.
- `RUN` - run your program from line `0` until it reaches MAX_CODEOF or `STOP` instruction.
- `GOSUB <line number>` - same as GOTO, but saves next line number and is able to return to it using...
- `RETURN` - returns to last `GOSUB` statement.
- `XY <x>,<y>` - sets cursor position to x,y (x can be 0 to 79 and y 0 to 24 (80x25 screen)).
- `PTR <address> = <value>` - see: `VAR`.
- `? ["string"] [,] [variable [+|-|*] ] [;]` - see: `PRINT`.
- `IN <address>[;]` - see: `INPUT`.

### Error messages
BASIC can return ***3*** errors:
- `?Number too big error` - guess.
- `?Syntax error` - basically every error.
- `?Memory error` - returned if xx+VAR_OFFSET returns number bigger than 65535 (FFFF hex).
### Other stuff
#### What IS NOT supported yet?
- Separating statements by `:`.
- RND statement.
- any form of loop.
#### Why is your code so bad?
tbh idk.
### "Help! I'm stuck in infinite GOTO! How do I stop executing?!"
Ctrl+C stops execution.
