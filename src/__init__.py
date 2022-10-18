from dataclasses import dataclass
import json


@dataclass(kw_only=True)
class _TreeElement:
    def __post_init__(self):
        self._argument_names: list = self._get_arguments()

    def _get_arguments(self) -> list:
        return [
            a
            for a in dir(self)
            if not a.startswith("_")
            and not callable(getattr(self, a))
            and getattr(self, a) is not None
        ]

    def __iter__(self):

        for arg_name in self._argument_names:
            arg = getattr(self, arg_name)

            if self.__class__.mro()[-2] == arg.__class__.mro()[-2]:
                yield (arg_name, dict(arg))
            else:
                yield (arg_name, arg)


@dataclass(kw_only=True)
class _TreeRoot(_TreeElement):
    _root: str
    _ref: str = None

    def as_dict(self):
        return (
            {self._root: dict(self)}
            if self._ref is None
            else {self._root: {self._ref: dict(self)}}
        )
