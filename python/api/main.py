from flask import Flask, request
from map_generators import *
from item import Item
from boss import Boss

app = Flask(__name__)

@app.route("/map", methods = ['GET'])
def get_map():
    in_json = request.json
    try:
        map_type = in_json["map_type"]
        map_w = in_json["map_width"]
        map_h = in_json["map_height"]
        seed = in_json["seed"]
    except KeyError:
        return { "error": "invalid request.json"}, 400
    if not map_type in SUPPORTED_GENERATORS:
        return { "error": "map type not supported"}, 400
    if not type(map_w) == int or not type(map_h) == int:
        return { "error": "map dimensions weren't provided as integers"}, 400
    
    if map_type == "cave":
        mapgen = CaveMap(map_w, map_h, seed)
    if map_type == "outdoor":
        mapgen = OutdoorMap(map_w, map_h, seed)
    if map_type == "indoor":
        mapgen = IndoorMap(map_w, map_h, seed)
    
    mapgen.create_map()
    print(mapgen.get_map_dict())
    return mapgen.get_map_dict(), 200

@app.route("/item", methods = ['GET'])
def get_item():
    in_json = request.json
    try:
        level = in_json["level"]
        luck = in_json["luck"]
        seed = in_json["seed"]
        # item_type = in_json["item_type"]
        # item_type in item generation not used in game atm
    except KeyError:
        return { "error": "invalid request.json"}, 400
    if not type(level) == int or not type(luck) == int:
        return { "error": "luck and/or level weren't provided as integers"}, 400
    itemgen = Item(level, luck, seed)
    print(itemgen.to_dict())
    return itemgen.to_dict(), 200

@app.route("/boss", methods = ['GET'])
def get_boss():
    in_json = request.json
    try:
        level = in_json["level"]
        seed = in_json["seed"]
    except KeyError:
        return { "error": "invalid request.json"}, 400
    if not type(level) == int:
        return { "error": "level wasn't provided as integer"}, 400
    bossgen = Boss(level, seed).generate()
    print(bossgen.to_dict())
    return bossgen.to_dict(), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port = 5000)