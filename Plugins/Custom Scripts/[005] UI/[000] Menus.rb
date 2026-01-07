# Options Menu
MenuHandlers.add(:options_menu, :exp_all_toggle, {
  "name"        => _INTL("Exp. All"),
  "order"       => 61,
  "type"        => EnumOption,
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

MenuHandlers.add(:pokegear_menu, :quests, {
  "name"      =>  _INTL("Mission Log"),
  "icon_name" => "quests",
  "order"     => 60,
  "condition" => proc { next hasAnyQuests? },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn {
      scene = QuestList_Scene.new
      screen = QuestList_Screen.new(scene)
      screen.pbStartScreen
    }
    next false
  }
})