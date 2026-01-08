# Options Menu
MenuHandlers.add(:options_menu, :exp_all_toggle, {
  "page"        => :graphics,
  "name"        => _INTL("Exp. All"),
  "order"       => 50,
  "type"        => :array,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Choose whether the entire party gains exp from battle or not."),
  "condition"   => proc { next $player },
  "get_proc"    => proc { next $player.has_exp_all ? 0 : 1},
  "set_proc"    => proc { |value, _sceme| $player.has_exp_all = (value == 0)}
})

MenuHandlers.add(:pokegear_menu, :pc, {
  "name"      => _INTL("Portable PC"),
  "icon_name" => "pc",
  "order"     => 40,
  "condition" => proc {(!$game_switches[Settings::DISABLE_BOX_LINK_SWITCH])},
  "effect"    => proc { |menu|
    pbFadeOutIn {
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene, $PokemonStorage)
      screen.pbStartScreen(0)
    }
    next false
    }
  })