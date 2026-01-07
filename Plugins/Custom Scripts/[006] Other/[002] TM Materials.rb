module GameData
class Item
    def self.icon_filename(item)
      return "Graphics/Items/back" if item.nil?
      item_data = self.try_get(item)
      return "Graphics/Items/000" if item_data.nil?
      # Check for files
      ret = sprintf("Graphics/Items/%s", item_data.id)
      return ret if pbResolveBitmap(ret)
      # Check for TM/HM type icons
      if item_data.is_machine?
        prefix = "machine"
        if item_data.is_HM?
          prefix = "machine_hm"
        elsif item_data.is_TR?
          prefix = "machine_tr"
        end
        move_type = GameData::Move.get(item_data.move).type
        type_data = GameData::Type.get(move_type)
        ret = sprintf("Graphics/Items/%s_%s", prefix, type_data.id)
        return ret if pbResolveBitmap(ret)
        if !item_data.is_TM?
          ret = sprintf("Graphics/Items/machine_%s", type_data.id)
          return ret if pbResolveBitmap(ret)
        end
      end
        # TM Materials
        if item_data.has_flag?("TMMaterial")
          ret = sprintf("Graphics/Items/TMMaterial")
          return ret if pbResolveBitmap(ret)
        end
        return "Graphics/Items/000"
      end
    end
end