from dataclasses import dataclass
from typing import Literal

from src import _TreeElement, _TreeRoot
from src.resources import LambdasConfig
from src.modules.base import _BaseModule


@dataclass(kw_only=True)
class RESTApi(_BaseModule):
    _ref: str = "api"
    source: str = "./modules/api"

    table: str
    ressource_name: str
    stage_name: str
    get: LambdasConfig
    post: LambdasConfig
