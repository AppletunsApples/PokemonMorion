Battle::ItemEffects::DamageCalcFromUser.add(:DECIDUEYEQUILL,
  proc { |item, user, target, move, mults, power|
    next unless user.isSpecies?(:DECIDUEYE)
    mults[:power_multiplier] *= 1.3 unless move.contactMove?
  }
)

class Battle::Move::RecoilMove < Battle::Move
  def recoilMove?;                  return true; end
  def pbRecoilDamage(user, target); return 1;    end

  def pbEffectAfterAllHits(user, target)
    return if target.damageState.unaffected
    return if !user.takesIndirectDamage?
    return if user.hasActiveAbility?(:ROCKHEAD)
    return if user.pokemon.isSpecies?(:EMBOAR) && user.item == :EMBOARPUFF
    amt = pbRecoilDamage(user, target)
    amt = 1 if amt < 1
    if user.pokemon.isSpecies?(:BASCULIN) && [2, 3].include?(user.pokemon.form)
      user.pokemon.evolution_counter += amt
    end
    user.pbReduceHP(amt, false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
    user.pbItemHPHealCheck
  end
end

Battle::ItemEffects::ModifyMoveBaseType.add(:INTELEONSCALE,
  proc { |item, user, move, type|
    next unless user.isSpecies?(:INTELEON)
    next if move.callsAnotherMove? || move.snatched
    next unless user.pbHasOtherType?(move.calcType) && !GameData::Type.get(move.calcType).pseudo_type

    @battle.pbShowAbilitySplash(user) if @battle.respond_to?(:pbShowAbilitySplash)
    user.pbChangeTypes(move.calcType)
    type_name = GameData::Type.get(move.calcType).name
    @battle.pbDisplay(_INTL("{1}'s type changed to {2}!", user.pbThis, type_name))
    @battle.pbHideAbilitySplash(user) if @battle.respond_to?(:pbHideAbilitySplash)
  }
)

Battle::ItemEffects::ModifyMoveBaseType.add(:MORPEKOFUR,
  proc { |item, user, move, type|
    next unless user.isSpecies?(:MORPEKO)
    next if move.type != :NORMAL
    form = user.pokemon.form
    return :DARK if form == 0
    return :ELECTRIC if form == 1
    return type
  }
)

# Wurmple Evolutions
  def pbSpeed
    return 1 if fainted?
    speed = stat_with_stages(:SPEED)
    speedMult = 1.0
    # Ability effects that alter calculated Speed
    if abilityActive?
      speedMult = Battle::AbilityEffects.triggerSpeedCalc(self.ability, self, speedMult)
    end
    # Item effects that alter calculated Speed
    if itemActive?
      speedMult = Battle::ItemEffects.triggerSpeedCalc(self.item, self, speedMult)
    end
    # Other effects
    speedMult *= 2 if pbOwnSide.effects[PBEffects::Tailwind] > 0
    speedMult /= 2 if pbOwnSide.effects[PBEffects::Swamp] > 0
    # Paralysis
    if status == :PARALYSIS && !hasActiveAbility?(:QUICKFEET)
      speedMult /= (Settings::MECHANICS_GENERATION >= 7) ? 2 : 4
    end
    # Crest-likes
    if item == :BEAUTIFLYSCALE && user.isSpecies?(:BEAUTIFLY)
      speed = @spatk
    else 
      speed = @speed
    end
    if item == :DUSTOXSCALE && user.isSpecies?(:DUSTOX)
      speed = @spdef
    else
      speed = @speed
    end
    # Badge multiplier
    if @battle.internalBattle && pbOwnedByPlayer? &&
       @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPEED
      speedMult *= 1.1
    end
    # Calculation
    return [(speed * speedMult).round, 1].max
  end

Battle::ItemEffects::AccuracyCalcFromUser.add(:DUSTOXSCALE,
  proc { |ability, user, target, move, modifiers|
    next unless user.isSpecies?(:DUSTOX)
    modifiers[:accuracy_multiplier] *= 1.3
  }
)

Battle::ItemEffects::AccuracyCalcFromUser.add(:BEAUTIFLYSCALE,
  proc { |ability, user, target, move, modifiers|
    next unless user.isSpecies?(:BEAUTIFLY)
    modifiers[:accuracy_multiplier] *= 1.3
  }
)