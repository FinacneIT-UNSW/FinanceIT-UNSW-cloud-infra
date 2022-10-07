from dataclasses import dataclass
from enum import Enum

from src import TerraformModule


class AWSDynamoStreamType(Enum):
    """
    AWS Dynamo DB stream type enumeration:
    - KEYS_ONLY: Only the key attributes of the modified item.
    - NEW_IMAGE: The entire item, as it appears after it was modified.
    - OLD_IMAGE: The entire item, as it appeared before it was modified.
    - NEW_AND_OLD_IMAGES: Both the new and the old images of the item.

    Reference: 'https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html'
    """

    KEYS_ONLY = "KEYS_ONLY"
    NEW_IMAGE = "NEW_IMAGE"
    OLD_IMAGE = "OLD_IMAGE"
    NEW_AND_OLD_IMAGES = "NEW_AND_OLD_IMAGES"


class AWSDynamoAttributeType(Enum):
    """
    AWS Dynamo DB attribute type enumeration:
    - STRING
    - NUMBER
    - BINARY
    """

    STRING = "S"
    NUMBER = "N"
    BINARY = "B"


@dataclass
class AWSDynamoSchema:
    """
    AWS Dynamo DB Table Schema definition of hash and sort key

    Attributes:
    ----------
        hash_key_name: str
            Name of the hash key attribute
        hash_key_type: AWSDynamoAttributeType
            Type of the hash key attribute
        sort_key_name: str
            Name of the sort key attribute
        sort_key_type: AWSDynamoAttributeType
            Type of the sort key attribute
    """

    hash_key_name: str
    hash_key_type: AWSDynamoAttributeType
    sort_key_name: str
    sort_key_type: AWSDynamoAttributeType


@dataclass
class AWSDynamoTable(TerraformModule):
    """
    AWS Dynamo DB Table module for main database

    Attributes:
    ----------
        name: str
            Name of the table
        read_capacity: int
            Read capacity of provision mode
        write_capacity: int
            Write capacity of provision mode
        schema: AWSDynamoSchema
            Schema definition of hash and sort key
        stream: bool = False
            Activate stream on the table (for websocket APIs)
        stream_type: AWSDynamoStreamType = None
            Stream type

    Raises:
    -------
        ValueError: No stream type provided but stream enabled
    """

    table_name: str
    read_capacity: int
    write_capacity: int
    schema: AWSDynamoSchema
    stream: bool = False
    stream_type: AWSDynamoStreamType = None
    _prefix: str = "db_dynamo_"

    def __post_init__(self) -> None:

        if self.stream and not self.stream_type:
            raise ValueError(
                "AWSDynamoTable stream is set to True but no stream type provided."
            )

        schema_attributes = [
            a
            for a in dir(self.schema)
            if not a.startswith("_") and not callable(getattr(self.schema, a))
        ]

        for att in schema_attributes:
            setattr(self, att, getattr(self.schema, att))

        delattr(self, "schema")
