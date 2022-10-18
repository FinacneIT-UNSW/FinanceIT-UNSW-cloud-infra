from dataclasses import dataclass

from src import _TreeElement, _TreeRoot


@dataclass(kw_only=True)
class _BaseModule(_TreeRoot):
    _root: str = "module"
    _ref: str
    source: str
    tags: str = "${local.tags}"
    name_suffix: str = "${local.name_suffix}"
