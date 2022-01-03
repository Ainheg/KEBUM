from collections import defaultdict
from typing import Any, Union
import numpy as np
import numpy.random as rnd

class SubDungeon:
    
    SPLIT_MIN = 0.4
    SPLIT_MAX = 0.6
    
    # vertical split == vertical splitting line
    
    def __init__(self, extents : Union[tuple, None], parent : Any = None):
        
        self.left = None
        self.right = None
        self.parent = None
        self.extents = extents
        xmin, xmax, ymin, ymax = extents
        self.vertical_split = True
        if xmax - xmin < ymax - ymin:
            self.vertical_split = False
        if parent:
            self.parent = parent
        
    def split(self):
        if not self.extents:
            return []
        xmin, xmax, ymin, ymax = self.extents
        left_extents = None
        right_extents = None
        if self.vertical_split:
            minrange = xmin + int((xmax - xmin) * self.SPLIT_MIN)
            maxrange = xmin + int((xmax - xmin) * self.SPLIT_MAX)
            xrange = list(range(minrange, maxrange))
            if len(xrange) >= 3:
                split_x = rnd.choice(xrange)
                left_extents = (xmin, split_x, ymin, ymax)
                right_extents = (split_x, xmax, ymin, ymax)
        else:
            minrange = ymin + int((ymax - ymin) * self.SPLIT_MIN)
            maxrange = ymin + int((ymax - ymin) * self.SPLIT_MAX)
            yrange = list(range(minrange, maxrange))
            if len(yrange) >= 3:
                split_y = rnd.choice(yrange)
                left_extents = (xmin, xmax, ymin, split_y)
                right_extents = (xmin, xmax, split_y, ymax)   
        if left_extents and right_extents:
            self.left = SubDungeon(left_extents, self)
            self.right = SubDungeon(right_extents, self)
            return [self.left, self.right]
        return []
    
    def get_connector(self):
        connector = [(None, None)]
        if not self.left or not self.right:
            return connector
        xmin, xmax, ymin, ymax = self.right.extents
        if self.vertical_split:
            minrange = ymin + 1
            maxrange = ymax - 1
            yrange = list(range(minrange, maxrange))
            
            # I don't want to have connectors on walls, so I'll make them
            # 2 cells wide and remove the immediate cindren' wall coordinates
            # the 2 wide doors will actually create passages between multiple rooms
            # if they land on a corner
            if not self.right.vertical_split and self.right.right:
                yrange.remove(self.right.right.extents[2])
            if not self.left.vertical_split and self.left.right:
                try:
                    yrange.remove(self.left.right.extents[2])
                except ValueError:
                    # It is possible that both children' walls will be at the same level
                    pass
            
            conn_y = rnd.choice(yrange)
            connector = [(xmin, conn_y), (xmin, conn_y - 1)]
        else:
            minrange = xmin + 1
            maxrange = xmax - 1
            xrange = list(range(minrange, maxrange))
            
            if self.right.vertical_split and self.right.right:
                xrange.remove(self.right.right.extents[0])
            if self.left.vertical_split and self.left.right:
                try:
                    xrange.remove(self.left.right.extents[0])
                except ValueError:
                    pass
            
            conn_x = rnd.choice(xrange)
            connector = [(conn_x - 1, ymin), (conn_x, ymin)]
        return connector
    
    def get_possible_spawn_point(self):
        xmin, xmax, ymin, ymax = self.extents
        xcenter = xmin + int((xmax - xmin)/2)
        ycenter = ymin + int((ymax - ymin)/2)
        return (int(ycenter), int(xcenter))
    
    def get_possible_treasure_locations(self):
        xmin, xmax, ymin, ymax = self.extents
        tl = (int(ymin + 1), int(xmin + 1))
        tr = (int(ymin + 1), int(xmax - 1))
        bl = (int(ymax - 1), int(xmin + 1))
        br = (int(ymax - 1), int(xmax - 1))
        return (tl, tr, bl, br)
               
    def print_tree(self):
        if self.left:
            self.left.print_tree()
        print(str(self))
        if self.right:
            self.right.print_tree()
        
    def __repr__(self):
        return (f"Vsplit: {self.vertical_split}, extents: {self.extents}, "
                f"parent: {self.parent.extents if self.parent else 'None'}")

class IndoorMap:
    
    N_SPLITS = 6
    
    def __init__(self, width : int, height : int, seed : Any):
        self.MAP_WIDTH = width
        self.MAP_HEIGHT = height
        self.spawn_points = []
        self.treasure_locations = []
        self.entrance = None
        self.exit = None
        self.hint_location = None
        self.seed = seed
        
        rnd.seed(self.seed)
        self.grid = np.zeros((self.MAP_HEIGHT, self.MAP_WIDTH), dtype=int)
        self.root = SubDungeon(extents = (0, self.MAP_WIDTH - 1, 0, self.MAP_HEIGHT - 1))
        self.tree_layers = defaultdict(list)
        self.tree_layers[0].append(self.root)
        
    def create_map(self):
        self.__split_rooms()
        self.__add_rooms_to_grid()
        self.__add_border()
        self.__add_spawn_points()
        self.__add_treasure_locations()
        
    def __split_rooms(self):
        # Perform  `N_SPLITS` splits starting from root node
        for n in range(self.N_SPLITS):
            for sub_dungeon in self.tree_layers[n]:
                self.tree_layers[n+1].extend(sub_dungeon.split())
        
    def __add_rooms_to_grid(self):
        
        # Draw walls of leaf subdungeons
        for sub_dungeon in self.tree_layers[self.N_SPLITS]:
            xmin, xmax, ymin, ymax = sub_dungeon.extents
            for x in range(xmin, xmax):
                self.grid[x][ymin] = 1
                self.grid[x][ymax] = 1
            for y in range(ymin, ymax):
                self.grid[xmin][y] = 1
                self.grid[xmax][y] = 1
        
        # Make connectors between rooms
        for n in sorted(list(range(self.N_SPLITS)), reverse = True):
            for sub_dungeon in self.tree_layers[n]:
                connectors = sub_dungeon.get_connector()
                for connector in connectors:
                    x, y = connector
                    if x != None and y != None:
                        self.grid[x][y] = 0

    def __add_spawn_points(self):
        
        self.spawn_points = [leaf.get_possible_spawn_point() for leaf in self.tree_layers[self.N_SPLITS] if rnd.choice([True, False], p=[0.7, 0.3])]
        self.spawn_points = sorted(self.spawn_points, key = lambda x: (x[0], x[1]))
        self.entrance = self.spawn_points.pop(0)
        self.exit = self.spawn_points.pop()
    
    def __add_treasure_locations(self):
        
        for leaf in self.tree_layers[self.N_SPLITS]:
            # The treasure doesn't have to be in every single room
            if rnd.choice([True, False], p=[0.7, 0.3]):
                # Random corner of the room
                corner_no = rnd.choice(4)
                self.treasure_locations.append(leaf.get_possible_treasure_locations()[corner_no])
        self.hint_location = self.treasure_locations.pop(rnd.choice(len(self.treasure_locations)))
    
    def __add_border(self):
        for y, row in enumerate(self.grid):
            for x, _ in enumerate(row):
                # I'd like the boundary of the map to stay as walls :D
                if x == 0 or x == self.MAP_WIDTH-1 or y == 0 or y == self.MAP_HEIGHT -1:
                    self.grid[y][x] = 99
        
    def get_map_dict(self) -> dict:
        return { 
            "grid" : self.grid.tolist(),
            "spawn_points" : self.spawn_points,
            "treasure_locations" : self.treasure_locations,
            "hint_location" : self.hint_location,
            "map_type" : "indoor",
            "entrance" : self.entrance,
            "exit" : self.exit,                 
        }     