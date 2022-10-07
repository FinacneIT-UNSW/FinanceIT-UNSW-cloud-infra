from dataclasses import dataclass
from enum import Enum


from src import TerraformModule
from src.aws.lambdas import AWSLambdasRuntime


@dataclass
class AWSAPILambdasIntegration:
    file_path: str
    handler: str
    runtime: AWSLambdasRuntime
    memory_size: int = 128
    timeout: int = 5


@dataclass
class AWSRestApi(TerraformModule):
    """
    AWS REST API Gateway module for main database

    Attributes:
    ----------
        

    Raises:
    -------
        
    """

    ressource_name: str
    stage_name: str
    get_lambda_integration: AWSAPILambdasIntegration
    post_lambda_integration: AWSAPILambdasIntegration
    _prefix: str = 'api_db_rest_'
    
    def __post_init__(self) -> None:

        self._explode_attribute('get_lambda_integration', 'get_')
        self._explode_attribute('post_lambda_integration', 'post_')
        