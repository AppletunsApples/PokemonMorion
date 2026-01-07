# Calculated
Battle::AbilityEffects::DamageCalcFromUser.add(:CALCULATED,
  proc { |ability, user, target, move, mults, power, type|
    mults[:attack_multiplier] *= 2 if move.specialMove?
  }
)

# Valor
Battle::AbilityEffects::OnEndOfUsingMove.add(:VALOR,
  proc { |ability, user, targets, move, battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0 || !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user)
    user.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, numFainted, user)
  }
)

# Bone Muscle
Battle::AbilityEffects::DamageCalcFromUser.add(:BONEMUSCLE,
  proc { |ability, user, target, move, mults, power, type|
    mults[:power_multiplier] *= 1.3 if move.boneMove?
  }
)

# Symphonic Strength
Battle::AbilityEffects::DamageCalcFromUser.add(:SYMPHONICSTRENGTH,
  proc { |ability, user, target, move, mults, power, type|
    if move.soundMove?
      mults[:attack_multiplier] *= 1.2
    end

    met = 1 + (0.2 * [user.effects[PBEffects::Metronome], 5].min)
    mults[:final_damage_multiplier] *= met
  }
)

# Cuteness Proximity
Battle::AbilityEffects::OnSwitchIn.add(:CUTENESSPROXIMITY,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is emitting adorable energy!", battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)
