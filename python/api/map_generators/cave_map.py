import random
from typing import Any
from numpy import array, zeros_like, sum, mean
from queue import SimpleQueue
import scipy.cluster.hierarchy as hcluster

class CaveMap:

    STARVATION = 4
    BIRTH = 1
    ITERATIONS = 3
    WEIGHTS = [0.55, 0.45]

    def __init__(self, width : int, height : int, seed : Any):
        print("Generate cave map")
        self.MAP_WIDTH = width
        self.MAP_HEIGHT = height
        self.spawn_points = []
        self.treasure_locations = []
        self.__initialize_grid()
        self.seed = seed
        random.seed(seed)
        

    def to_dict(self):
        return { 
            "grid" : self.grid.tolist(),
            "spawn_points" : self.spawn_points,
            "treasure_locations" : self.treasure_locations,
            "hint_location" : self.hint_location,
            "map_type" : "cave",
            "entrance" : self.entrance,
            "exit" : self.exit,                 
        }

    def generate(self):
        """Creates a map (cave-style)"""
        try:
            self.__initialize_grid()
            for _ in range(self.ITERATIONS):
                self.__do_step()
            x, y = self.__find_starting_spot_for_flood_fill()
            tmp_grid = array(self.grid, copy=True)
            self.__flood_fill(x, y, tmp_grid, self.grid, self.treasure_locations, self.spawn_points)
            self.__fill_not_accessible_areas(tmp_grid)
            self.__add_border()
            self.__filter_treasure_locations()
            self.__filter_spawn_points()
        except Exception:
            random.seed(self.seed * 123)
            self.generate()

    def __initialize_grid(self):
        grid = []
        for _ in range(self.MAP_WIDTH):
            row = [random.choices([0, 1], self.WEIGHTS)[0] for _ in range(self.MAP_HEIGHT)]
            grid.append(row)
        self.grid = grid

    def __count_alive_neighbors(self, grid, x : int, y : int, n : int):
        """Sums the value of a 2D array's slice n-steps in every direction from P(x,y)"""
        try:
            value = grid[y][x]
        except IndexError:
            return None
        grid_slice = [row[max(x-n, 0):min(x+n+1, self.MAP_WIDTH)] for row in grid[max(0, y-n):min(y+n+1, self.MAP_HEIGHT)]]
        return sum(grid_slice) - value

    def __calculate_new_state(self, old_value, alive_neighbors_1, alive_neighbors_2):
        if old_value:
            if alive_neighbors_1 <= self.STARVATION:
                return 0
            else:
                return 1
        else:
            if alive_neighbors_2 <= self.BIRTH:
                return 1
            else:
                return 0

    def __do_step(self):
        new_grid = zeros_like(self.grid)
        for y, row in enumerate(new_grid):
            for x, _ in enumerate(row):
                old_element = self.grid[y][x]
                alive_neighbors_1 = self.__count_alive_neighbors(self.grid, x, y, 1)
                alive_neighbors_2 = self.__count_alive_neighbors(self.grid, x, y, 2)
                new_grid[y][x] = self.__calculate_new_state(old_element, alive_neighbors_1, alive_neighbors_2)    
        self.grid = new_grid

    def __find_starting_spot_for_flood_fill(self):
        x = random.randrange(int(0.3*self.MAP_WIDTH), int(0.7*self.MAP_WIDTH))
        y = random.randrange(int(0.3*self.MAP_WIDTH), int(0.7*self.MAP_WIDTH))
        while self.grid[y][x] != 0:
            x = random.randrange(int(0.3*self.MAP_WIDTH), int(0.7*self.MAP_WIDTH))
            y = random.randrange(int(0.3*self.MAP_WIDTH), int(0.7*self.MAP_WIDTH))
        return x, y

    def __flood_fill(self, x : int, y : int, grid, real_grid, treasure_locations, spawn_points):
        q = SimpleQueue()
        q.put((x, y))
        while not q.empty():
            x, y = q.get()
            if grid[y][x] == 0:
                if self.__count_alive_neighbors(real_grid, x, y, 1) > 4:
                    treasure_locations.append((x, y))
                elif self.__count_alive_neighbors(real_grid, x, y, 2) < 2:
                    spawn_points.append((x, y))
                grid[y][x] = 99
                if x > 0:
                    q.put((x - 1, y))
                if x < len(grid[0]) - 1:
                    q.put((x + 1, y))
                if y > 0:
                    q.put((x, y - 1))
                if y < len(grid) - 1:
                    q.put((x, y + 1))

    def __fill_not_accessible_areas(self, flood_filled_grid):
        for y, row in enumerate(self.grid):
            for x, _ in enumerate(row):
                if self.grid[y][x] == 0 and self.grid[y][x] == flood_filled_grid[y][x]:
                    self.grid[y][x] = 1
                    continue

    def __filter_treasure_locations(self):
        # I think a 50% chance for each one to be present on the map will be enough for now
        self.treasure_locations = [loc for loc in self.treasure_locations if random.choices([True, False], weights=[0.5, 0.5])[0]]
        self.hint_location = random.choice(self.treasure_locations)
        self.treasure_locations.remove(self.hint_location)
        
    def __filter_spawn_points(self):
        tmp_grid = array(self.grid, copy=True)
        self.__add_spawn_points(tmp_grid, self.spawn_points)
        # I'd like to add all the ones that are separate from the other ones and remove them from the overall group
        # because of how they are initially selected, I can just use the count alive neighbors function
        # the "alone" spawn points will have 0 or 1 "alive neighbors" (a spawn point counts as 4)
        selected_spawn_points = [pt for pt in self.spawn_points if self.__count_alive_neighbors(tmp_grid, *pt, 1) < 2]
        spawn_points = [pt for pt in self.spawn_points if not pt in selected_spawn_points]
        # the remaining spawn points create distinct groups, so I thought I'd use some simple clustering method
        # and then take the cluster's centroids as spawn points
        clusters = hcluster.fclusterdata(spawn_points, 1.5, criterion="distance")
        spawn_points = [mean([spawn_points[i] for i, cl_no in enumerate(clusters) if cl_no == cl], axis=0) for cl in set(clusters)]
        # round coordinates and omit ones that land on a wall
        spawn_points = [(int(x), int(y)) for x, y in spawn_points if self.grid[int(y)][int(x)] == 0]
        selected_spawn_points.extend(spawn_points)
        selected_spawn_points = sorted(selected_spawn_points, key=lambda x: (x[0], x[1]))
        self.entrance = selected_spawn_points.pop(0)
        self.exit = selected_spawn_points.pop()
        self.spawn_points = selected_spawn_points
    
    def __add_spawn_points(self, grid, spawn_spots):
        for x, y in spawn_spots:
            grid[y][x] = 4

    def __add_border(self):
        for y, row in enumerate(self.grid):
            for x, _ in enumerate(row):
                # I'd like the boundary of the map to stay as walls :D
                if x == 0 or x == self.MAP_WIDTH-1 or y == 0 or y == self.MAP_HEIGHT -1:
                    self.grid[y][x] = 99
