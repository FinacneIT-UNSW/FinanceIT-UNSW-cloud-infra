from enum import Enum


class TerraformModule:
    def conf_lines(self) -> list:
        confs = []
        attributes = [
            a
            for a in dir(self)
            if not a.startswith("_") and not callable(getattr(self, a))
        ]
        for att in attributes:
            val = getattr(self, att)

            if isinstance(val, Enum):
                val = val.value

            if type(val) == str:
                val = f'"{val}"'

            if type(val) == bool:
                val = str(val).lower()
                
            if val is None:
                continue

            conf = f"{self._prefix}{att}={val}\n"
            confs.append(conf)

        return confs
    
    def _explode_attribute(self, attribute_name: str, prefix: str = ''):
        attribute = getattr(self, attribute_name)
        
        attributes = [
            a
            for a in dir(attribute)
            if not a.startswith("_") and not callable(getattr(attribute, a))
        ]

        for att in attributes:
            setattr(self, f"{prefix}{att}", getattr(attribute, att))

        delattr(self, attribute_name)
