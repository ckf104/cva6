import yaml
import argparse
import os

from typing import List

class Inst:
    InputWidth = 64  # bit width of input operands
    OutputWidth = 64  # bit width of instruction output
    MaxOpcode = 15  # 4 bits
    MaxInputNumber = 16  # 3 bits, since only even input index
    MaxOutputNumber = 8  # 3 bits

    def __init__(self, name: str, input_number: int, output_number: int):
        self.name = name
        self.input_number = input_number
        self.output_number = output_number

        self.compatiblity_check()

    def __repr__(self):
        return (
            f"Inst(name={self.name}, "
            f"input_number={self.input_number}, output_number={self.output_number})"
        )

    def compatiblity_check(self):
        assert (
            self.input_number <= self.MaxInputNumber
        ), f"Input number {self.input_number} exceeds maximum value {self.MaxInputNumber}"
        assert (
            self.output_number <= self.MaxOutputNumber
        ), f"Output number {self.output_number} exceeds maximum value {self.MaxOutputNumber}"


class Group:
    SupportedInputProtocol = ["ap_none"]
    SupportedOutputProtocol = ["ap_none"]
    SupportedBlockProtocol = ["ap_ctrl_hs"]
    SupportedResetProtocol = ["async_low"]

    def __init__(
        self,
        name: str,
        input_protocol: str,
        output_protocol: str,
        block_protocol: str,
        reset_protocol: str,
        verilog_files: list,
        top_module: str,
        input_number: int,
        output_number: int
    ):
        self.name = name
        self.input_protocol = input_protocol
        self.output_protocol = output_protocol
        self.block_protocol = block_protocol
        self.reset_protocol = reset_protocol
        self.verilog_files = verilog_files
        self.top_module = top_module
        self.input_number = input_number
        self.output_number =  output_number

        self.compatiblity_check()

    def __repr__(self):
        return (
            f"Group(name={self.name}, input_protocol={self.input_protocol}, "
            f"output_protocol={self.output_protocol}, block_protocol={self.block_protocol}, "
            f"reset_protocol={self.reset_protocol}, verilog_files={self.verilog_files}, "
            f"top_module={self.top_module}, input_number={self.input_number}, output_number={self.output_number}")

    def compatiblity_check(self):
        assert (
            self.input_protocol in self.SupportedInputProtocol
        ), f"Input protocol {self.input_protocol} not supported"

        assert (
            self.output_protocol in self.SupportedOutputProtocol
        ), f"Output protocol {self.output_protocol} not supported"

        assert (
            self.block_protocol in self.SupportedBlockProtocol
        ), f"Block protocol {self.block_protocol} not supported"

        assert (
            self.reset_protocol in self.SupportedResetProtocol
        ), f"Reset protocol {self.reset_protocol} not supported"


import math


class JinjaVariable:
    comments = f"// Generated by {os.path.basename(__file__)}"

    def __init__(self, groups: List[Group]):
        self.groups = groups
        self.inputWidth = Inst.InputWidth
        self.outputWidth = Inst.OutputWidth
        self.opocdeWidth = math.ceil(math.log2(Inst.MaxOpcode + 1))
        self.inputIndexWidth = math.ceil(math.log2((Inst.MaxInputNumber + 1) // 2))
        self.outputIndexWidth = math.ceil(math.log2(Inst.MaxOutputNumber))
        self.numGroup = len(groups)
        self.groupNames = [f"jinja_gen_{g.name}" for g in groups]

        # self.opcodeToGroup = self.getOpcodeToGroupArray(groups)
        self.groupInputRegs = self.getInputRegsArray(groups)
        self.groupOutputRegs = self.getOutputRegsArray(groups)

    # def getOpcodeToGroupArray(self, groups: List[Group]):
    #     cur_op = 0
    #     ret = [cur_op]
    #     for g in groups:
    #         for i in g.insts:
    #             assert i.opcode == cur_op, f"{i} Opcode {i.opcode} does not match"
    #             cur_op += 1
    #         ret.append(cur_op)
    #     return "'{" + ", ".join([str(x) for x in reversed(ret)]) + "}"

    def getInputRegsArray(self, groups: List[Group]):
        inputRegsArray = [g.input_number for g in groups]
        return "'{" + ", ".join([str(x) for x in reversed(inputRegsArray)]) + "}"

    def getOutputRegsArray(self, groups: List[Group]):
        outputRegsArray = [g.output_number for g in groups]
        return "'{" + ", ".join([str(x) for x in reversed(outputRegsArray)]) + "}"

    def renderGroups(self, output_dir: str, temp_path: str):
        import jinja2

        env = jinja2.Environment(
            loader=jinja2.FileSystemLoader(temp_path),
        )
        template = env.get_template("groups.temp.sv")
        with open(os.path.join(output_dir, "groups.sv"), "w") as f:
            f.write(template.render(var=self, comments=self.comments))

        template = env.get_template("single_group.temp.sv")
        for name, g in zip(self.groupNames, self.groups):
            inputRegs = g.input_number
            outputRegs = g.output_number
            with open(os.path.join(output_dir, f"{name}.sv"), "w") as f:
                f.write(
                    template.render(
                        comments=self.comments,
                        group_name=name,
                        numInputReg=inputRegs,
                        numOutputReg=outputRegs,
                        top_module_name=g.top_module,
                    )
                )


def compatiblity_check(data):
    assert data["version"] == 1.0, f"Version {data['version']} not supported"


# Function to parse the YAML file
def parse_yaml(file_path):
    with open(file_path, "r") as file:
        data = yaml.safe_load(file)
    compatiblity_check(data)
    return data


def parse_inst(inst) -> Inst:
    return Inst(
        name=inst["name"],
        input_number=inst["input-number"],
        output_number=inst["output-number"],
    )


def parse_group(data) -> List[Group]:
    groups = [
        Group(
            name=group["name"],
            input_protocol=group["input-protocol"],
            output_protocol=group["output-protocol"],
            block_protocol=group["block-protocol"],
            reset_protocol=group["reset-protocol"],
            verilog_files=group["verilog-files"],
            top_module=group["top-module"],
            input_number=group["input-number"],
            output_number=group["output-number"]
        )
        for group in data["group"]
    ]
    return groups


def extract_zip(groups: List[Group], config_dir: str, output_dir: str):
    import zipfile
    import tempfile
    import shutil

    for g in groups:
        for f in g.verilog_files:
            assert f.endswith(".zip"), f"File {f} is not a zip file"
            if not os.path.isabs(f):
                f = os.path.join(config_dir, f)

            tmp_dir = tempfile.TemporaryDirectory()
            with zipfile.ZipFile(f, "r") as zip_ref:
                zip_ref.extractall(tmp_dir.name)

            verilog_dir = os.path.join(tmp_dir.name, "hdl/verilog")
            for file in os.listdir(verilog_dir):
                if file.endswith(".v"):
                    shutil.copyfile(os.path.join(verilog_dir, file), os.path.join(output_dir, file))
            tmp_dir.cleanup()


from typing import TextIO


# Main function to handle command line arguments and process the YAML file
def main():
    parser = argparse.ArgumentParser(
        description="Parse a YAML config file and generate corresponding systemverilog code."
    )
    parser.add_argument("yaml_file_path", type=str, help="Path to the YAML config file")
    parser.add_argument(
        "--output-dir",
        type=str,
        default=os.path.join(os.path.dirname(__file__), "cust_inst"),
        help="Directory to save the output files (default: <file_directory>/cust_inst)",
    )
    parser.add_argument(
        "--temp-dir",
        type=str,
        default=os.path.dirname(__file__),
        help="Directory to the template file (default: the directory of this script)",
    )
    parser.add_argument(
        "--disable-copy-verilog",
        type=bool,
        default=False,
        help="Disable copying verilog files, development only(default: false)",
    )
    parser.add_argument(
        "--disable-jinja-render",
        type=bool,
        default=False,
        help="Disable rendering jinja files, development only(default: false)",
    )

    args = parser.parse_args()

    yaml_file_path = args.yaml_file_path
    if not os.path.isabs(yaml_file_path):
        yaml_dir = os.getcwd()
        yaml_file_path = os.path.join(yaml_dir, yaml_file_path)
    else:
        yaml_dir = os.path.dirname(yaml_file_path)

    # Parse the YAML file
    parsed_data = parse_yaml(args.yaml_file_path)

    # Create the output directory if it doesn't exist
    os.makedirs(args.output_dir, exist_ok=True)

    # Define the output file path
    output_file_path = os.path.join(args.output_dir, "custom_inst_config.gen.svh")

    # Write the parsed data to the output file
    # write_output(parsed_data, output_file_path)

    groups = parse_group(parsed_data)
    if not args.disable_copy_verilog: 
        extract_zip(groups, yaml_dir, args.output_dir)
    if not args.disable_jinja_render:
        var = JinjaVariable(groups)
        var.renderGroups(args.output_dir, args.temp_dir)


if __name__ == "__main__":
    main()
