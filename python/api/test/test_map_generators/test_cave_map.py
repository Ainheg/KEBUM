import pytest
from map_generators.cave_map import CaveMap

def test_init():
    cm = CaveMap(1, 1, 1)
    assert type(cm) == CaveMap
