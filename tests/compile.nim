## Compiler test suite


import unittest, ../src/brainfuck, streams


suite "brainfuck compiler":
  test "compile helloworld":
    proc helloworld: string =
      CompileFile("../examples/helloworld.b", "", result)
    # See tests/interpret.nim
    check helloworld() == "Hello World!\x0A"

  test "compile rot13":
    proc rot13(input: string): string =
      CompileFile("../examples/rot13.b", input, result)
    let conv = rot13("How I Start\n")
    check conv == "Ubj V Fgneg\n"
    check rot13(conv) == "How I Start\n"