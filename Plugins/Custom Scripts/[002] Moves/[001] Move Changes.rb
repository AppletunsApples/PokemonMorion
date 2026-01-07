class Battle::Move::DoublePowerIfUserLostHPThisTurn < Battle::Move
  def pbBaseDamage(baseDmg, user, target)
    baseDmg *= 2 if user.lastAttacker.include?(target.index) || target.effectiveWeather == :Hail
    return baseDmg
  end
end