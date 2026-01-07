# Hopo Berry+
ItemHandlers::UseOnPokemon.add(:ELIXIR, proc { |item, qty, pkmn, scene|
  pprestored = 0
  pkmn.moves.length.times do |i|
    pprestored += pbRestorePP(pkmn, i, 10)
  end
  if pprestored == 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pbSEPlay("Use item in party")
  scene.pbDisplay(_INTL("PP was restored."))
  next true
})

ItemHandlers::CanUseInBattle.add(:ELIXIR, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !pokemon.able?
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  canRestore = false
  pokemon.moves.each do |m|
    next if m.id == 0
    next if m.total_pp <= 0 || m.pp == m.total_pp
    canRestore = true
    break
  end
  if !canRestore
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  next true
})

ItemHandlers::CanUseInBattle.copy(:ELIXIR, :MAXELIXIR, :HOPOBERRY)

# Poke Balls
Battle::PokeBallEffects::ModifyCatchRate.add(:DREAMBALL, proc { |ball, catchRate, battle, battler|
  catchRate *= 4 if battler.asleep?
  next catchRate
})

Battle::PokeBallEffects::ModifyCatchRate.add(:DUSKBALL, proc { |ball, catchRate, battle, battler|
  multiplier = (Settings::NEW_POKE_BALL_CATCH_RATES) ? 3 : 3.5
  catchRate *= multiplier if battle.time == 2   # Night or in cave
  next catchRate
})

# Training Wheels
Battle::ItemEffects::SpeedCalc.add(:TRAININGWHEELS,
  proc { |item, battler, mult|
    if battler.pokemon.species_data.get_evolutions(true).length > 0
      next mult * 1.5
    end
  }
)

# Chocolates
ItemHandlers::UseOnPokemonMaximum.add(:HEALTHCHOCOLATE, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:HP, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:HEALTHCHOCOLATE, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:HP, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:ALLURINGCHOCOLATE, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:ATTACK, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:STRONGCHOCOLATE, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:ATTACK, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:ALLURINGCHOCOLATE, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:DEFENSE, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:ALLURINGCHOCOLATE, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:DEFENSE, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:SMARTCHOCOLATE, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:SPECIAL_ATTACK, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:SMARTCHOCOLATE, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:SPECIAL_ATTACK, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:SWEETCHOCOLATE, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:SPECIAL_DEFENSE, 1, pkmn)
})

ItemHandlers::UseOnPokemon.add(:SWEETCHOCOLATE, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:SPECIAL_DEFENSE, 1, qty, pkmn, "wing", scene)
})

ItemHandlers::UseOnPokemonMaximum.add(:HASTYCHOCOLATE, proc { |item, pkmn|
  next pbMaxUsesOfIVRaisingItem(:SPEED, 1, pkmn)
})


ItemHandlers::UseOnPokemon.add(:HASTYCHOCOLATE, proc { |item, qty, pkmn, scene|
  next pbUseIVRaisingItem(:SPEED, 1, qty, pkmn, "wing", scene)
})

# Stale Candy
ItemHandlers::UseOnPokemonMaximum.add(:STALECANDY, proc { |item, pkmn|
  next GameData::GrowthRate.max_level - pkmn.level
})

ItemHandlers::UseOnPokemon.add(:STALECANDY, proc { |item, qty, pkmn, scene|
  if pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if pkmn.level >= GameData::GrowthRate.max_level
    new_species = pkmn.check_evolution_on_level_up
    if !Settings::RARE_CANDY_USABLE_AT_MAX_LEVEL || !new_species
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    # Check for evolution
    pbFadeOutInWithMusic {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pkmn, new_species)
      evo.pbEvolution
      evo.pbEndScreen
      scene.pbRefresh if scene.is_a?(PokemonPartyScreen)
    }
    next true
  end
  # Level down
  pbSEPlay("Pkmn level up")
  pbChangeLevel(pkmn, pkmn.level - qty, scene)
  scene.pbHardRefresh
  next true
})

# Good Luck Charm

# Ability Vial
ItemHandlers::UseOnPokemon.add(:ABILITYVIAL, proc { |item, qty, pkmn, scene|
  if scene.pbConfirm(_INTL("Do you want to change {1}'s Ability?", pkmn.name))
    abils = pkmn.getAbilityList
    ability_commands = []
    abil_cmd = 0
    abil1 = nil
    abil2 = nil
    abils.each do |i|
      abil1 = i[0] if i[1] == 0
      abil2 = i[0] if i[1] == 1
    end
    for i in abils
      ability_commands.push(((i[1] < 2) ? "" : "(H) ") + GameData::Ability.get(i[0]).name)
    end
    if abil1.nil? || abil2.nil? || pkmn.isSpecies?(:ZYGARDE)
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    cmd = pbMessage("Which ability do you want for your Pokémon?", ability_commands, 0, nil, 0)
    pkmn.ability = abils[cmd][0]
    pkmn.ability_index = abils[abil_cmd][1]
    pkmn.ability = nil
    scene.pbDisplay(_INTL("{1}'s ability changed to {2}!", pkmn.name, pkmn.ability.name))
  next true
  end
})

# Box Link
ItemHandlers::UseFromBag.add(:POKEMONBOXLINK, proc { |item|
    pbFadeOutIn do
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene, $PokemonStorage)
      screen.pbStartScreen(0)
    end
  next 1
})
