import macros


{.push overflowchecks: off.}
proc xinc(c: var char) = inc c
proc xdec(c: var char) = dec c
{.pop.}


proc Compile(code: string): PNimrodNode {.compiletime.} =
  var statements = @[newStmtList()]

  template addStmt(text): stmt =
    statements[statements.high].add parseStmt(text)

  addStmt "var tape: array[1_000_000, char]"
  addStmt "var tapePos = 0"

  for c in code:
    case c
    of '+': addStmt "xinc tape[tapePos]"
    of '-': addStmt "xdec tape[tapePos]"
    of '>': addStmt "inc tapePos"
    of '<': addStmt "dec tapePos"
    of '.': addStmt "stdout.write tape[tapePos]"
    of ',': addStmt "tape[tapePos] = stdin.readChar"
    of '[': statements.add newStmtList()
    of ']':
      var loop = newNimNode(nnkWhileStmt)
      loop.add parseExpr("tape[tapePos] != '\\0'")
      loop.add statements.pop
      statements[statements.high].add loop
    else: discard

  result = statements[0]


macro CompileString*(code: string): stmt =
  ## Compiles the brainfuck `code` string into Nim code that reads from stdin
  ## and writes to stdout.
  Compile code.strval

macro CompileFile*(filename: string): stmt =
  ## Compiles the brainfuck code read from `filename` at compile time into Nim
  ## code that reads from stdin and writes to stdout.
  Compile staticRead(filename.strval)


proc Interpret*(code: string) =
  ## Interprets the input string as brainfuck code
  ## Reading is done from stdin, writing is done to stdout 
  var
    tape = newSeq[char]()
    codePos = 0
    tapePos = 0

  proc run(skip = false): bool =
    while codePos >= 0 and codePos < code.len:
      tape.add '\0'

      if code[codePos] == '[':
        inc codePos
        let oldCodePos = codePos
        while run(tape[tapePos] == '\0'):
          codePos = oldCodePos
      elif code[codePos] == ']':
        return tape[tapePos] != '\0'
      elif not skip:
        case code[codePos]
        of '+': xinc tape[tapePos]
        of '-': xdec tape[tapePos]
        of '>': inc tapePos
        of '<': dec tapePos
        of '.': stdout.write tape[tapePos]
        of ',': tape[tapePos] = stdin.readChar
        else: discard

      inc codePos

  discard run()
