from map_generators.cave_map import CaveMap
from map_generators.outdoor_map import OutdoorMap

SUPPORTED_GENERATORS = {"cave", "outdoor"}

__all__ = [
    "SUPPORTED_GENERATORS",
    "CaveMap",
    "OutdoorMap"
    ]
