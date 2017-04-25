{.push overflowchecks: off.}
proc xinc(c: var char) = inc c
proc xdec(c: var char) = dec c
{.pop.}

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


when isMainModule:
  import os

  echo "Hello :)"

  let code = if paramCount() > 0: readFile paramStr(1) else: readAll stdin

  Interpret code
