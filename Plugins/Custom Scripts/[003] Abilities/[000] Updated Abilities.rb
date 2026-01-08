Battle::AbilityEffects::DamageCalcFromTarget.add(:SANDVEIL,
  proc { |ability, mods, weather, user, target, type|
    if target.effectiveWeather == :Sandstorm
      mods[:defense_multiplier] *= 1.25
    end
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:SNOWCLOAK,
  proc { |ability, mods, weather, user, target, type|
    if [:Hail, :Snow].include?(target.effectiveWeather)
      mods[:special_defense_multiplier] *= 1.25
    end
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:RIVALRY,
  proc { |ability, user, target, move, mults, power, type|
    next if user.gender != 2 && target.gender != 2
      if user.gender == target.gender
        mults[:power_multiplier] *= 1.25
      end
  }
)