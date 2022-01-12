import numpy.random as rnd
import numpy as np

class Item:  

    RARITIES = [
        "Common",
        "Rare",
        "Epic",
        "Legendary"
    ]

    RARITIES_VARIANTS = {
        "Common" : [ (1, 0) ],
        "Rare" : [ (2, 0), (1, 1) ],
        "Epic" : [ (2, 1), (1, 2) ],
        "Legendary" : [ (2, 2), (3, 1), (1, 3) ]       
    }
    
    TYPES = {
        "Headgear" : {
            "stats+" : ["DEF", "CST"],
            "stats-" : ["STR", "PER"],
            "bonuses+" : ["%_ARMOR", "ARMOR"],
            "bonuses-" : ["%_ATK_PWR", "ATK_PWR", "CRIT_DMG", "CRIT_CHANCE"]            
        },
        "Armor" : {
            "stats+" : ["DEF", "CST"],
            "stats-" : ["STR", "PER"],
            "bonuses+" : ["%_ARMOR", "ARMOR"],
            "bonuses-" : ["%_ATK_PWR", "ATK_PWR", "CRIT_DMG", "CRIT_CHANCE"]            
        },
        "Weapon" : {
            "stats+" : ["STR", "AGI"],
            "stats-" : ["DEF", "CST"],
            "bonuses+" : ["%_ATK_PWR", "ATK_PWR", "CRIT_DMG", "CRIT_CHANCE"],
            "bonuses-" : ["%_ARMOR", "ARMOR"]
        },
        "Charm" : {
            "stats+" : ["LCK", "PER"],
            "stats-" : ["AGI", "CST"],
            "bonuses+" : ["%_ATK_PWR", "ATK_PWR", "CRIT_DMG", "CRIT_CHANCE"],
            "bonuses-" : ["%_ARMOR", "ARMOR"]            
        }
    }

    NAMES = {
        "Headgear" : ["Helmet", "Hard Hat", "Fedora", "Beret", "Top Hat"],
        "Armor" : ["Chestplate", "Bulletproof Vest", "T-Shirt", "Tank Top", "Coat"],
        "Weapon" : ["Dagger", "Sword", "Screwdriver", "Butter Knife", "Chopsticks"],
        "Charm" : ["Katsumori", "Shiawase", "Kaiun", "Yakuyoke", "Kenko"]
    }

    STATS_FULL = {
        "STR" : "Strength",
        "AGI" : "Agility",
        "PER" : "Perception",
        "DEF" : "Defense",
        "LCK" : "Luck",
        "CST" : "Constitution"
    }
       
    def __init__(self, level : int, luck : int, seed : int = None, item_type : str = None):
 
        self.stats = {
            "STR" : 0,
            "AGI" : 0,
            "PER" : 0,
            "DEF" : 0,
            "LCK" : 0,
            "CST" : 0
        }
        
        self.bonuses = {
            "ATK_PWR" : 0,
            "ARMOR" : 0,
            "CRIT_DMG" : 0,
            "CRIT_CHANCE" : 0,
            "%_ATK_PWR" : 1.0,
            "%_ARMOR" : 1.0,
        }

        self.rarity = None
        self.item_type = None
        self.level = level
        self.luck = luck

        if seed:
            self.seed = seed
            rnd.seed(seed)            
        # Get item_type:
        if not item_type:
            self.item_type = rnd.choice(list(self.TYPES.keys()))
        else:
            self.item_type = item_type
        
    def generate(self):
        # Get rarity:
        rarity_chances = self._get_rarity_chances(self.luck)
        self.rarity = rnd.choice(
            self.RARITIES,
            p=rarity_chances,
            size = 1
        )[0]
        
        # Get variant of item according to rarity:
        variant = self.RARITIES_VARIANTS[self.rarity][rnd.choice(len(self.RARITIES_VARIANTS[self.rarity]))]
        stats_to_gen, bonuses_to_gen = variant
        
        # Generate stats according to variant
        stats_chances = []
        base_chance = 1/len(self.stats)
        for key in self.stats:
            if key in self.TYPES[self.item_type]["stats+"]:
                stats_chances.append(base_chance * 1.5)
                continue
            if key in self.TYPES[self.item_type]["stats-"]:
                stats_chances.append(base_chance * 0.67)
                continue
            stats_chances.append(base_chance)
        
        stats_chances = np.array(stats_chances)
        stats_chances /= stats_chances.sum()
        
        stats_to_gen = list(rnd.choice(list(self.stats.keys()), size = stats_to_gen, replace = False, p = stats_chances))
        
        for stat in stats_to_gen:
            self.stats[stat] += max(1, round(rnd.normal(loc = self.level * 3 / 10, scale = 2.2)))
            
        # Generate bonuses according to variant
        if bonuses_to_gen:
            bonuses_chances = []
            base_chance = 1/len(self.bonuses)
            for key in self.bonuses:
                if key in self.TYPES[self.item_type]["bonuses+"]:
                    bonuses_chances.append(base_chance * 1.5)
                    continue
                if key in self.TYPES[self.item_type]["bonuses-"]:
                    bonuses_chances.append(base_chance * 0.67)
                    continue
                bonuses_chances.append(base_chance)
        
            bonuses_chances = np.array(bonuses_chances)
            bonuses_chances /= bonuses_chances.sum()
            
            bonuses_to_gen = list(rnd.choice(list(self.bonuses.keys()), size = bonuses_to_gen, replace = False, p = bonuses_chances))
        
            for bonus in bonuses_to_gen:
                if "%" in bonus or "CRIT" in bonus:
                    self.bonuses[bonus] += max(10, round(rnd.normal(loc = self.level*3, scale = self.level/3)))/100
                    continue
                self.bonuses[bonus] += max(10, round(rnd.normal(loc = self.level, scale = 5)))
                # if "CRIT" in bonus:
                #     self.bonuses[bonus] /= 10
        
        # Generate name
        self.name = rnd.choice(self.NAMES[self.item_type])
        self.name += " of "
        self.name += self.STATS_FULL[max(self.stats, key=self.stats.get)]


    def _get_rarity_chances(self, luck):
        legendary_chance = 0.05 + luck / 100
        epic_chance = max(0.0, min(0.10 + luck / 100, 1.0 - legendary_chance))
        rare_chance = max(0.0, min(0.25 + luck / 100, 1.0 - legendary_chance - epic_chance))
        common_chance = max(0.0, 1.0 - legendary_chance - epic_chance - rare_chance)
        rarity_chances = np.array([common_chance, rare_chance, epic_chance, legendary_chance])
        rarity_chances /= rarity_chances.sum()
        return rarity_chances

    def to_dict(self):
        return {
            "name" : self.name,
            "type" : self.item_type,
            "rarity" : self.rarity,
            "stats" : { k:v for k, v in self.stats.items() if v != 0},
            "bonuses" : { k:v for k, v in self.bonuses.items() if ("%" in k and v != 1.0) or (not "%" in k and v != 0) }
        }