from dataclasses import dataclass
from typing import Literal

from src import _TreeElement, _TreeRoot


@dataclass(kw_only=True)
class LambdasConfig(_TreeElement):
    file_path: str
    handler: str
    runtime: str
    memory_size: int
    timeout: int
