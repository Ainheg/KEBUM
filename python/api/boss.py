from random import shuffle
import numpy as np
import numpy.random as rnd
from item import Item

class Boss:

    BEHAVIORS = {
        "aggressive" : {
            "description" : " is aggressive",
            "stats+" : ["STR", "AGI"],
            "stats-" : ["DEF", "CST"],
            "moveset" : ["attack", "attack", "attack", "attack", "attack",
                       "pierce", "pierce",
                       "block"]
        },
        "defensive" : {
            "description" : " employs defensive tactics",
            "stats+" : ["DEF", "CST"],
            "stats-" : ["STR", "AGI"],
            "moveset" : ["attack",
                       "pierce", "pierce",
                       "block", "block", "block", "block", "block"]
        },
        "perceptive" : {
            "description" : " doesn't know that enemies don't benefit from PER",
            "stats+" : ["PER", "DEF"],
            "stats-" : ["STR", "LCK"],
            "moveset" : ["attack", "attack", "attack",
                       "pierce", "pierce",
                       "block", "block", "block"]
        },
        "gambler" : {
            "description" : " likes to gamble and never defends",
            "stats+" : ["LCK", "AGI"],
            "stats-" : ["DEF", "PER"],
            "moveset" : ["attack", "attack", "attack", "attack",
                       "pierce", "pierce", "pierce", "pierce"]
        },
        "agile" : {
            "description" : "'s fighting style relies on agility",
            "stats+" : ["AGI", "STR"],
            "stats-" : ["DEF", "CST"],
            "moveset" : ["attack", "attack", "attack", "attack", "attack", "attack",
                       "block", "block"]
        },
        "piercer" : {
            "description" : " prefers attacking, especially with heavy attacks",
            "stats+" : ["STR", "CST"],
            "stats-" : ["PER", "AGI"],
            "moveset" : ["attack", "attack",
                       "pierce", "pierce", "pierce", "pierce", "pierce", "pierce"]
        }
    }

    ITEM_DESCRIPTIONS = {
        "Legendary" : " has access to Legendary equipment",
        "Epic" : " uses Epic equipment",
        "Rare" : "'s best equipment is of Rare quality",
        "Common" : " wasn't lucky enough to get rare equipment"
    }

    def __init__(self, level, seed):
        
        self.level = level
        
        if seed:
            rnd.seed(seed)

        # MACRO STATS
        self.stats = {
            "STR" : 0,
            "AGI" : 0,
            "PER" : 0,
            "DEF" : 0,
            "LCK" : 0,
            "CST" : 0
        }

        # EQUIPPED ITEMS
        self.items = {
            "Headgear" : None,
            "Armor" : None,
            "Weapon" : None,
            "Charm" : None
        }
        self.item_rarities = []

        # HINTS
        self.hints = []

        # NAME
        self.name = "Mr Boss"

        # MOVESET
        self.moveset = ["attack", "block", "pierce"]
        
    def generate(self):

        # Random personality
        self.personality = rnd.choice(list(self.BEHAVIORS.keys()))

        # Apply stats
        stats_chances = []
        base_chance = 1/len(self.stats)
        for key in self.stats:
            if key in self.BEHAVIORS[self.personality]["stats+"]:
                stats_chances.append(base_chance * 1.5)
                continue
            if key in self.BEHAVIORS[self.personality]["stats-"]:
                stats_chances.append(base_chance * 0.67)
                continue
            stats_chances.append(base_chance)
        
        stats_chances = np.array(stats_chances)
        stats_chances /= stats_chances.sum()
        
        stats_to_gen = list(rnd.choice(list(self.stats.keys()), size = self.level, replace = True, p = stats_chances))

        for stat in stats_to_gen:
            self.stats[stat] += 1

        # Apply moveset
        self.moveset = self.BEHAVIORS[self.personality]["moveset"]

        # Add random items
        self._add_random_items()

        # Generate hints
        self.hints = self._generate_hints()

        return self

    def _add_random_items(self):
        for key in self.items:
            new_item = Item(self.level, self.stats["LCK"], item_type=key)
            self.items[key] = new_item.to_dict()
            self.item_rarities.append(new_item.rarity)

    def _generate_hints(self):
        hints = []
        # Personality hint
        hints.append(f"{self.name}{self.BEHAVIORS[self.personality]['description']}")
        
        # Best stat hint
        max_stat = max(self.stats, key=self.stats.get)
        hints.append(f"{self.name} invested the most ({self.stats[max_stat]}) in {max_stat}")

        # Items hint
        items_rarity = "Common"
        if "Rare" in self.item_rarities:
            items_rarity = "Rare"
        if "Epic" in self.item_rarities:
            items_rarity = "Epic"
        if "Legendary" in self.item_rarities:
            items_rarity = "Legendary"
        hints.append(f"{self.name}{self.ITEM_DESCRIPTIONS[items_rarity]}") 

        shuffle(hints)

        return hints

    def to_dict(self):
        return {
            "boss_name" : self.name,
            "level" : self.level,
            "stats" : self.stats,
            "items" : self.items,
            "hints" : self.hints,
            "moveset" : self.moveset,
        }