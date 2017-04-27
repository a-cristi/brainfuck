import macros
import streams


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


proc readCharEOF(input: Stream): char =
  ## Streams reutrn 0 as EOF, but we expect a -1
  result = input.readChar
  if result == '\0':
    result = '\255'


proc Interpret*(code: string, input, output: Stream) =
  ## Interprets the brainfuck `code` string.
  ## The interpreted code reads from `input` and writes to `output`
  ##
  ## Example:
  ##
  ## .. code:: nim
  ##   var in = newStringStream("Hi there :)!\n")
  ##   var out = newFileStream(stdout)
  ##   Interpret(readFile("examples/rot13.b"), in, out)
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
        of '.': output.write tape[tapePos]
        of ',': tape[tapePos] = input.readCharEOF
        else: discard

      inc codePos

  discard run()


proc Interpret*(code, input: string): string =
  ## Interprets the brainfuck `code` string, reading from `input` and returning
  ## the output it produced.
  var outStream = newStringStream()
  Interpret(code, input.newStringStream, outStream)
  result = outStream.data


proc Interpret*(code: string) =
  ## Interprets the brainfuck `code` string, reading from stdin and writing to
  ## stdout.
  Interpret(code, stdin.newFileStream, stdout.newFileStream)


when isMainModule:
  import docopt, tables, strutils

  let doc = """
brainfuck

Usage:
  brainfuck mandelbrot
  brainfuck hello
  brainfuck rot13
  brainfuck interpret [<file.b>]
  brainfuck (-h | --help)
  brainfuck (-v | --version)

Options:
  -h --help     Show this screen.
  -v --version  Show version.
"""

  let args = docopt(doc, version = "brainfuck 1.0")
  if args["mandelbrot"]:
    proc mandelbrot = CompileFile("../examples/mandelbrot.b")
    mandelbrot()
  elif args["hello"]:
    proc hello = CompileFile("../examples/helloworld.b")
    hello()
  elif args["rot13"]:
    proc rot13 = CompileFile("../examples/rot13.b")
    rot13()
  elif args["interpret"]:
    let code = if args["<file.b>"]: readFile($args["<file.b>"])
               else: readAll stdin
    Interpret(code)
  else:
    stdout.write "ceplm"