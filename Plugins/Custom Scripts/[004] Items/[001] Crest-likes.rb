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

Battle::ItemEffects::ModifyMoveBaseType.add(:MORPEKOSCARF,
  proc { |item, user, move, type|
    next type unless user.isSpecies?(:MORPEKO)
    next type if move.type != :NORMAL
    form = user.pokemon.form
    next :DARK if form == 0
    next :ELECTRIC if form == 1
    next type
  }
)

# Wurmple Evolutions
def pbSpeed
    return 1 if fainted?
    speed_stat = :SPEED
    # Scarfs
    if itemActive?
      case self.species
      when :BEAUTIFLY
        speed_stat = :SPECIAL_ATTACK if self.item == :BEAUTIFLYSCARF
      when :DUSTOX
        speed_stat = :SPECIAL_DEFENSE if self.item == :DUSTOXSCARF
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
    speedMult = 1.0 
    # Ability effects that alter calculated Speed
    if abilityActive?
      speedMult = Battle::AbilityEffects.triggerSpeedCalc(self.ability, self, speedMult)
    end
    # Other effects
    speedMult *= 2 if pbOwnSide.effects[PBEffects::Tailwind] > 0
    speedMult /= 2 if pbOwnSide.effects[PBEffects::Swamp] > 0
    # Paralysis
    if status == :PARALYSIS && !hasActiveAbility?(:QUICKFEET)
      speedMult /= (Settings::MECHANICS_GENERATION >= 7) ? 2 : 4
    end
    # Other items
    if itemActive?
      speedMult = Battle::ItemEffects.triggerSpeedCalc(self.item, self, speedMult)
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
