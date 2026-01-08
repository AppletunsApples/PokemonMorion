Battle::ItemEffects::DamageCalc.add(:DECIDUEYEQUILL,
  proc { |item, user, target, move, mults, power|
    next if !user || !user.pokemon
    next if user.item != item
    next if !user.pokemon.isSpecies?(:DECIDUEYE)
    next if !move.contact?
    mults[:power_multiplier] *= 1.3
  }
)