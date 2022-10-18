from dataclasses import dataclass
from typing import Literal

from src import _TreeElement, _TreeRoot
from src.resources import LambdasConfig
from src.modules.base import _BaseModule


@dataclass(kw_only=True)
class WebsocketApi(_BaseModule):
    _ref: str = "websocket"
    source: str = "./modules/websocket"

    table: str
    stage_name: str
    manager: LambdasConfig
    message: LambdasConfig
