Battle::ItemEffects::DamageCalcFromUser.add(:DECIDUEYEQUILL,
  proc { |item, user, target, move, mults, power|
    next unless user&.pokemon
    next unless user.item == item
    next unless user.pokemon.isSpecies?(:DECIDUEYE)
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

Battle::ItemEffects::DamageCalcFromUser.add(:INTELEONSCALE,
  proc { |item, user, target, move, mults, power|
    next unless user&.pokemon
    next unless user.item == item
    next unless user.pokemon.isSpecies?(:INTELEON)
    next unless move
    user.pokemon.types = [move.type]
  }
)