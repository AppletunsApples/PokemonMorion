# Options Menu
MenuHandlers.add(:options_menu, :exp_all_toggle, {
  "name"        => _INTL("Exp. All"),
  "order"       => 61,
  "type"        => :array,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether the entire party gains exp from battle or not."),
  "condition"   => proc { next $player },
  "get_proc"    => proc { next $player.has_exp_all ? 0 : 1},
  "set_proc"    => proc { |value, _sceme| $player.has_exp_all = (value == 0)}
})

# Pause Menu
MenuHandlers.add(:pause_menu, :quit_game, {
  "name"      => _INTL("Quit to Title"),
  "order"     => 90,
  "effect"    => proc { |menu|
    menu.pbHideMenu
    if pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
      scene = PokemonSave_Scene.new
      screen = PokemonSaveScreen.new(scene)
      screen.pbSaveScreen
      menu.pbEndScene
      $scene = Scene_DebugIntro.new
      next true
    end
    menu.pbRefresh
    menu.pbShowMenu
    next false
  }
})

# Pokegear Menu
MenuHandlers.add(:pokegear_menu, :pc, {
  "name"      => _INTL("Portable PC"),
  "icon_name" => "pc",
  "order"     => 40,
  "condition" => proc { !$game_switches[Settings::DISABLE_BOX_LINK_SWITCH] },
  "effect"    => proc { |menu|
    pbFadeOutIn {
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene, $PokemonStorage)
      screen.pbStartScreen(0)
    }
    next false
  }
})
  
# Title Screen Cry
  def fade_out_title_screen(scene)
    onUpdate.clear
    onCTrigger.clear
    # Play random cry
    species_keys = GameData::Species.keys
    species_data = GameData::Species.get(species_keys.sample)
    Pokemon.play_cry(:DARKRAI)
    @pic.moveXY(0, 20, 0, 0)   # Adds 20 ticks (1 second) pause
    pictureWait
    # Fade out
    @pic.moveOpacity(0, FADE_TICKS, 0)
    @pic2.clearProcesses
    @pic2.moveOpacity(0, FADE_TICKS, 0)
    pbBGMStop(1.0)
    pictureWait
    scene.dispose   # Close the scene
  end

module GameData
class Item
# TM Materials
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
    return "Graphics/Items/000"
    end
  end
end