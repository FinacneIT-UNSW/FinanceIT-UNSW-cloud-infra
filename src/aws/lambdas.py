from enum import Enum


class AWSLambdasRuntime(Enum):
    """
    AWS Dynamo DB stream type enumeration:
    - KEYS_ONLY: Only the key attributes of the modified item.
    - NEW_IMAGE: The entire item, as it appears after it was modified.
    - OLD_IMAGE: The entire item, as it appeared before it was modified.
    - NEW_AND_OLD_IMAGES: Both the new and the old images of the item.

    Reference: 'https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html'
    """
    PY10 = 'python3.10'
    PY39 = 'python3.9'
    PY38 = 'python3.8'
    PY37 = 'python3.7'
    PY36 = 'python3.6'