#! /usr/bin/env python3

# Usage example: ./parser_helper.py < vadd4_test_gen.txt

# mv.xv a0, v0.0
# mv.vx v0.0, a0
# vadd2 v1, v2, v3  (v1 = v2 + v3)

vname2vnumber = {f"v{i}": i for i in range(32)}
rname2rnumber = {f"x{i}": i for i in range(32)}
aliases = {
    "zero": 0,
    "ra": 1,
    "sp": 2,
    "gp": 3,
    "tp": 4,
    "t0": 5,
    "t1": 6,
    "t2": 7,
    "fp": 8,
    "s1": 9,
    "a0": 10,
    "a1": 11,
    "a2": 12,
    "a3": 13,
    "a4": 14,
    "a5": 15,
    "a6": 16,
    "a7": 17,
    "s2": 18,
    "s3": 19,
    "s4": 20,
    "s5": 21,
    "s6": 22,
    "s7": 23,
    "s8": 24,
    "s9": 25,
    "s10": 26,
    "s11": 27,
    "t3": 28,
    "t4": 29,
    "t5": 30,
    "t6": 31
}
rname2rnumber.update(aliases)


def concateHelper(func7: int, func3: int, rd: int, rs1: int, rs2: int, opcode: int):
    return (func7 << 25) | (rs2 << 20) | (rs1 << 15) | (func3 << 12) | (rd << 7) | opcode


def parseVecNumber(vec: str):
    assert vec[0] == "v"
    assert "." in vec
    number, word = map(int, vec[1:].split("."))
    return number, word

# mv vec -> scalar: mv.vx v0.0, a0


def mvvxParser(instr: list[str]):
    func7 = 0b0000000
    func3 = 0b000
    opcode = 0b0001011
    assert len(instr) == 2
    assert instr[1] in rname2rnumber

    vec_number, vec_word = parseVecNumber(instr[0])
    reg_number = rname2rnumber[instr[1]]

    rs1 = vec_number
    rs2 = vec_word
    rd = reg_number

    return concateHelper(func7, func3, rd, rs1, rs2, opcode)

# mv scalar -> vec: mv.xv a0, v0.0


def mvxvParser(instr: list[str]):
    func7 = 0b0000000
    func3 = 0b001
    opcode = 0b0001011
    assert len(instr) == 2
    assert instr[0] in rname2rnumber

    vec_number, vec_word = parseVecNumber(instr[1])
    reg_number = rname2rnumber[instr[0]]

    rs1 = reg_number
    rs2 = vec_word
    rd = vec_number

    return concateHelper(func7, func3, rd, rs1, rs2, opcode)

# vadd2 v1, v2, v3  (v1 = v2 + v3)


def vadd1Parser(instr: list[str]):
    func7 = 0b0000001
    func3 = 0b000
    opcode = 0b0001011
    assert len(instr) == 3
    assert instr[0] in vname2vnumber
    assert instr[1] in vname2vnumber
    assert instr[2] in vname2vnumber

    rd = vname2vnumber[instr[0]]
    rs1 = vname2vnumber[instr[1]]
    rs2 = vname2vnumber[instr[2]]

    return concateHelper(func7, func3, rd, rs1, rs2, opcode)


# name -> func7, func3,
inst_list = {
    "mv.vx": mvvxParser,
    "mv.xv": mvxvParser,
    "vadd2": vadd2Parser
}

def preProcess(instr: str):
    instr = instr.replace(",", " ")
    instr = instr.split()
    return instr

def postProcess(instr: int):
    return f".word {instr:032b}"

while True:
    try:
      instr = input()
    except:
      break
    if instr == "":
      continue
    instr = preProcess(instr)
    assert instr[0] in inst_list
    
    binary_inst = inst_list[instr[0]](instr[1:])
    print(postProcess(binary_inst))