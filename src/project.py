from dataclasses import dataclass, field
import json

from src import _TreeElement, _TreeRoot
from src.modules.base import _BaseModule
from src.modules import RESTApi, WebsocketApi
from src.resources import LambdasConfig


@dataclass(kw_only=True)
class RequiredAWS(_TreeElement):
    """AWS Provider to import

    Attributes:
        source (str): The source
        version (str): The version
    """

    source: str = "hashicorp/aws"
    version: str = "~> 4.16"


@dataclass(kw_only=True)
class RequiredProviders(_TreeElement):
    """AWS Provider

    Attributes:
        aws (RequiredAWS): The AWS requirements
    """

    aws: RequiredAWS = RequiredAWS()


@dataclass(kw_only=True)
class TerraformBlock(_TreeRoot):
    """Terraform block

    Attributes:
        required_providers (RequiredProviders): The required providers
        required_version (str): Terraform version
    """

    _root: str = "terraform"
    required_providers: RequiredProviders = RequiredProviders()
    required_version: str = ">= 1.2.0"


@dataclass(kw_only=True)
class AWSProvider(_TreeRoot):
    """AWS Provider block

    Attributes:
        profile (str): AWS Cli profile to use
        region (str): AWS region
    """

    _root: str = "provider"
    _ref: str = "aws"
    profile: str = None
    access_key: str = None
    secret_key: str = None
    region: str

    # TODO
    def __post_init__(self):
        pass

        super().__post_init__()


@dataclass(kw_only=True)
class Locals(_TreeRoot):
    _root: str = "locals"
    tags: dict
    name_suffix: str


class AWSProject:
    def __init__(
        self,
        dir: str,
        project_name: str,
        environement: str,
        aws_region: str,
        aws_profil: str = None,
        access_key: str = None,
        secret_key: str = None,
    ):
        self.dir = dir
        self.project_name = project_name
        self.env = environement

        self.terraform = TerraformBlock()

        self.provider = AWSProvider(
            profile=aws_profil,
            access_key=access_key,
            secret_key=secret_key,
            region=aws_region,
        )

        self.locals = Locals(
            tags={"project": self.project_name, "environement": self.env},
            name_suffix=f"-{self.project_name}-{self.env}",
        )

        self.project = self.terraform.as_dict()
        self.project.update(self.provider.as_dict())
        self.project.update(self.locals.as_dict())

        self.project["module"] = []

        self.project["resource"] = {
            "aws_resourcegroups_group": {
                "indoor-air-rg": {
                    "name": f"RG-{self.project_name}-{self.env}",
                    "resource_query": {
                        "query": json.dumps(
                            {
                                "ResourceTypeFilters": ["AWS::AllSupported"],
                                "TagFilters": [
                                    {
                                        "Key": "project",
                                        "Values": [f"{self.project_name}"],
                                    }
                                ],
                            }
                        )
                    },
                }
            }
        }

        self.db = None
        self.api = None
        self.websocket = None

    def set_database_module(self, module: _BaseModule):
        self.db = module
        self.project["module"].append(self.db.as_dict()["module"])

    def add_api(
        self,
        ressource_name: str,
        get: LambdasConfig,
        post: LambdasConfig,
        stage_name: str = "v1",
    ):
        self.api = RESTApi(
            ressource_name=ressource_name,
            stage_name=stage_name,
            get=get,
            post=post,
            table=self.db.table(),
        )
        self.project["module"].append(self.api.as_dict()["module"])

    def enable_websocket_api(
        self,
        message: LambdasConfig,
        manager: LambdasConfig,
        stage_name: str = "v1",
    ):
        if self.websocket is not None:
            self.websocket = None
            return

        if not self.db.isstream:
            raise ConfigurationError(
                "Cannot enable websocket API as stream is disable on database."
            )

        self.websocket = WebsocketApi(
            stage_name=stage_name,
            message=message,
            manager=manager,
            table=self.db.table(),
        )
        self.project["module"].append(self.websocket.as_dict()["module"])

    def save(self):
        with open(f"{self.dir}/main.tf.json", "w+") as f:
            f.write(json.dumps(self.project))

    def get_outputs(self):
        outputs = {}
        with open(f"{self.dir}/variables.out", "r") as f:
            for line in f.readlines():
                key, val = line.split("=")
                key = key.strip()
                val = val.strip().replace('"', "")
                outputs[key] = val
        with open(f"{self.dir}/ingest.json", "r") as f:
            hided = json.load(f)

        outputs.update(hided)
        return outputs


class ConfigurationError(Exception):
    def __init__(self, message) -> None:
        super().__init__(message)
