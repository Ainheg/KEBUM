from flask import Flask, request
from map_generators import *

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
        mapgen.create_map()
        return mapgen.get_map_dict(), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port = 5000)