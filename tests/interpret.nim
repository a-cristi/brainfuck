## Interpreter test suite

import unittest, ../src/brainfuck


suite "brainfuck interpreter":
  test "interpret helloworld":
    let helloworld = readFile("../examples/helloworld.b")
    # We are actually returning "Hello World!\n", represented as "Hello World!\x0A",
    # but using "Hello World!\n" as the test strings creates "Hello World!\r\n" (ending in \x0D\x0A)
    # This might have another behaviour on non-Windows operating systems
    check Interpret(helloworld, input = "") == "Hello World!\xA"


  test "interpret rot13":
    let rot13 = readFile("../examples/rot13.b")
    let conv = Interpret(rot13, "Secret\n")
    check conv == "Frperg\n"
    check Interpret(rot13, conv) == "Secret\n"
