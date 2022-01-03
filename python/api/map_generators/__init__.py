from map_generators.cave_map import CaveMap
from map_generators.outdoor_map import OutdoorMap
from map_generators.indoor_map import IndoorMap

SUPPORTED_GENERATORS = {"cave", "outdoor", "indoor"}

__all__ = [
    "SUPPORTED_GENERATORS",
    "CaveMap",
    "OutdoorMap",
    "IndoorMap"
    ]
