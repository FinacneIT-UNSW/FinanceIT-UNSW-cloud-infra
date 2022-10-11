from dataclasses import dataclass
from typing import Literal

from src import _TreeElement, _TreeRoot
from src.modules.base import _BaseModule


@dataclass(kw_only=True)
class DynamoDB(_BaseModule):
    _ref: str = "db_dynamo"
    source: str = "./modules/db_dynamo"

    table_name: str
    read_capacity: int
    write_capacity: int
    hash_key_name: int
    hash_key_type: Literal["S", "N", "B"]
    sort_key_name: int
    sort_key_type: Literal["S", "N", "B"]
    isstream: bool = False
    stream_type: Literal[
        "KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"
    ] = None

    def table(self):
        return f"${{module.{self._ref}.table}}"
