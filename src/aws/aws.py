from dataclasses import dataclass, field
from enum import Enum
import logging

LOGGER = logging.getLogger(__file__)
LOGGER.setLevel(logging.INFO)

from src import TerraformModule
from src.aws.databases import DATABASES


class AWSRegion(Enum):
    """AWS Region enum"""
    STDNEY = "ap-southeast-2"


@dataclass
class AWSProjectConfig(TerraformModule):

    aws_region: AWSRegion
    aws_profil: str
    terraform_dir: str
    project_name: str
    environment: str
    _terraform_dir: str

    def __post_init__(self) -> None:

        if self.environment not in [
            "prod",
            "production",
            "stg",
            "staging",
            "dev",
            "developement",
            "qa",
            "testing",
        ]:
            LOGGER.warning(f"{self.environment} is an uncomon environement name.")


class AWSProject:
    
    def __new__(cls, aws_config: AWSProjectConfig, db: TerraformModule):
        if not type(db) in DATABASES:
            raise TypeError("The database provided is not of a valid type")
        obj = object.__new__(cls)
        return obj
    
    def __init__(self, aws_config: AWSProjectConfig, db: TerraformModule, api=TerraformModule) -> None:
        
        self._aws_config = aws_config
