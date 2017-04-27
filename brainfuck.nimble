# Package

version       = "0.1.0"
author        = "Cristi Anichitei"
description   = "Brainfuck interpreter based on the How I Start Nim tutorial"
license       = "MIT"

bin           = @["brainfuck"]
binDir        = "/bin"

# Dependencies

requires "nim >= 0.16.0", "docopt >= 0.1.0"

