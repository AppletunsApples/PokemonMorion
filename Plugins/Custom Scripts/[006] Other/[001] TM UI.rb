  class PokemonMartAdapter
    
    def getDisplayName(item)
        item_name = GameData::Item.get(item).name
        return item_name
    end
end