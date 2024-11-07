from typing import List, Callable

def dir_filter(path: str) -> bool:
  return path.find("cvxif_example_coprocessor.sv") == -1 and path.find("jinja_gen") == -1 and path.find("groups.sv") == -1

def warn_filter(path: str) -> bool:
  return path.startswith("%Warning-TIMESCALEMOD")

def extractWarning(filters: List[Callable[[str], bool]]):
  should_skip = True
  while True:
    try:
      line = input()
    except:
      break
    if line.startswith("%Warning-"):
      for filter in filters:
        if filter(line):
          should_skip=True
          break
      else:
        should_skip=False
        print(line)
    elif not should_skip:
      print(line)

extractWarning([warn_filter, dir_filter])