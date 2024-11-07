#! /usr/bin/env python3

# Usage example: ./parser_helper.py < vadd4_test.S

# mv.xv a0, v0.0
# mv.vx v0.0, a0
# vadd2 v1, v2, v3  (v1 = v2 + v3)
# v2 is rs1, v3 is rs2

from functools import wraps

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
    "t6": 31,
}
rname2rnumber.update(aliases)


def concateHelper(func7: int, func3: int, rd: int, rs1: int, rs2: int, opcode: int):
    return (func7 << 25) | (rs2 << 20) | (rs1 << 15) | (func3 << 12) | (rd << 7) | opcode


def parseVecNumber(vec: str):
    assert vec[0] == "v"
    assert "." in vec
    number, word = map(int, vec[1:].split("."))
    return number, word


def preProcess(instr: str):
    instr = instr[3:]  # drop "///"
    instr = instr.replace(",", " ")
    instr = instr.split()
    return instr


def postAddWord(f):
    def addWord(instr: int):
        return f".word 0b{instr:032b}"

    @wraps(f)
    def wrapper(instr):
        return addWord(f(instr))

    return wrapper


# mv vec -> scalar: mv.vx v0.0, a0


@postAddWord
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


@postAddWord
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


@postAddWord
def vadd2Parser(instr: list[str]):
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


@postAddWord
def nv2cgaParser(instr: list[str]):
    func7 = 0b0000010
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


@postAddWord
def cga2rgbParser(instr: list[str]):
    func7 = 0b0000011
    func3 = 0b000
    opcode = 0b0001011
    assert len(instr) == 2
    assert instr[0] in vname2vnumber
    assert instr[1] in vname2vnumber

    rd = vname2vnumber[instr[0]]
    rs1 = vname2vnumber[instr[1]]
    rs2 = vname2vnumber["v0"]

    return concateHelper(func7, func3, rd, rs1, rs2, opcode)


# Pesudo instruction
def echoParser(instr: list[str]):
    return ", ".join(instr)


# example format:
# exec.p.f/exec.f.p/pick.f/fill.p, rdIdx, rd, rsIdx, rs1, rs2, opcode
# pick, rdIdx, rd, opcode
# fill, rsIdx, rs1, rs2, opcode
def pickFillExecParser(instr: list[str], has_pick: bool, has_fill: bool, has_exec: bool):
    if has_exec:
        assert has_pick and has_fill, "exec must have pick and fill"
    assert has_pick or has_fill, "must have pick or fill"
    assert len(instr) == 6

    custom0 = 0b00_010_11
    custom1 = 0b01_010_11
    custom2 = 0b10_110_11
    custom3 = 0b11_110_11

    opcode = (
        custom0
        if has_exec
        else custom1 if has_pick and has_fill else custom2 if has_pick else custom3
    )
    rdIdx = int(instr[0])
    rd = rname2rnumber[instr[1]]
    rsIdx = int(instr[2])
    rs1 = rname2rnumber[instr[3]]
    rs2 = rname2rnumber[instr[4]]
    instr_op = int(instr[5])

    assert rsIdx < 16, "rsIdx must be less than 16"
    assert rsIdx % 2 == 0, "rsIdx must be even"
    rsIdx = rsIdx // 2

    assert rdIdx < 8, "rdIdx must be less than 8"
    assert instr_op < 16, "instr_op must be less than 16"
    if not has_fill:
        assert rs1 == 0 and rs2 == 0, "rs1 and rs2 must be zero if no fill"
    if not has_pick:
        assert rd == 0, "rd must be zero if no pick"

    func7 = (rsIdx << 4) | instr_op
    func3 = rdIdx
    return concateHelper(func7, func3, rd, rs1, rs2, opcode)


# pick
@postAddWord
def pickParser(instr: list[str]):
    assert len(instr) == 3, "pick must have 3 arguments"
    instr.insert(2, "0")  # insert rsIdx
    instr.insert(3, "x0")  # insert rs1
    instr.insert(4, "x0")  # insert rs2
    return pickFillExecParser(instr, True, False, False)


# fill
@postAddWord
def fillParser(instr: list[str]):
    assert len(instr) == 4, "fill must have 4 arguments"
    instr.insert(0, "0")  # insert rdIdx
    instr.insert(1, "x0")  # insert rd
    return pickFillExecParser(instr, False, True, False)


# pick.f, fill.p
@postAddWord
def pickFillParser(instr: list[str]):
    return pickFillExecParser(instr, True, True, False)


# exec.p.f
@postAddWord
def execParser(instr: list[str]):
    return pickFillExecParser(instr, True, True, True)


# name -> func7, func3,
inst_list = {
    "mv.vx": mvvxParser,
    "mv.xv": mvxvParser,
    "vadd2": vadd2Parser,
    "nv2cag": nv2cgaParser,
    "cag2rgb": cga2rgbParser,
    "echo": echoParser,
    "pick": pickParser,
    "fill": fillParser,
    "pick.f": pickFillParser,
    "fill.p": fillParser,
    "exec.p.f": execParser,
    "exec.f.p": execParser,
}


while True:
    try:
        instr = input()
    except:
        break
    if not instr.startswith("///"):
        continue
    instr = preProcess(instr)
    assert instr[0] in inst_list

    binary_inst = inst_list[instr[0]](instr[1:])
    print(binary_inst)
