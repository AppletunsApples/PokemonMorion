Battle::ItemEffects::DamageCalcFromUser.add(:DECIDUEYESCARF,
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
    return if user.pokemon.isSpecies?(:EMBOAR) && user.item == :EMBOARSCARF
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

Battle::ItemEffects::ModifyMoveBaseType.add(:INTELEONSCARF,
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

Battle::ItemEffects::ModifyMoveBaseType.add(:MORPEKOSCARF,
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
  Aight I see. Since you have it defined as "Crest-like items I suppose you plan to add more later. In that case tdef pbSpeed
    return 1 if fainted?
    speed_stat = :SPEED

    if itemActive?
      case self.species
      when :BEAUTIFLY
        speed_stat = :SPECIAL_ATTACK if self.item == :BEAUTIFLYSCALE
      when :DUSTOX
        speed_stat = :SPECIAL_DEFENSE if self.item == :DUSTOXSCALE
      end
    end

      # Base stat
    base_speed = case speed_stat
          when :SPECIAL_ATTACK  then @spatk
          when :SPECIAL_DEFENSE then @spdef
          else                      @speed
          end
    stage = @stages[speed_stat] + STAT_STAGE_MAXIMUM
    speed = base_speed * STAT_STAGE_MULTIPLIERS[stage] / STAT_STAGE_DIVISORS[stage]
    speedMult = 1.0    ```

Haven't tested it but it should let you just add the species, with the crest item and what stat it will increase, and then latter at "base_speed" you just define what stat will utilize

Keep in mind, as you wanted, this will make the speed stat for that pokemon fully irrelevant, as all stat changes to the speed will just be ignored. Paralyzis, Tail Wind, abilities and held items still affect it tho, as those are calculated later, but stat stages are ignored.

Similarly, items and effects that increase/decrease spAtk and SpDef don't affect speed. If you want to you'll need to modify the code further

...or maybe they do, don't have time to test the code sadly, but I guess this should do the trick
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

Battle::ItemEffects::AccuracyCalcFromUser.add(:DUSTOXSCARF,
  proc { |ability, user, target, move, modifiers|
    next unless user.isSpecies?(:DUSTOX)
    modifiers[:accuracy_multiplier] *= 1.3
  }
)

Battle::ItemEffects::AccuracyCalcFromUser.add(:BEAUTIFLYSCARF,
  proc { |ability, user, target, move, modifiers|
    next unless user.isSpecies?(:BEAUTIFLY)
    modifiers[:accuracy_multiplier] *= 1.3
  }
)
