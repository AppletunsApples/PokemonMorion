# Calculated
Battle::AbilityEffects::DamageCalcFromUser.add(:CALCULATED,
  proc { |ability, user, target, move, mults, power, type|
    mults[:attack_multiplier] *= 2 if move.specialMove?
  }
)

# Sparkling Snow
Battle::AbilityEffects::OnSwitchIn.add(:SPARKLINGSNOW,
proc { |ability, battler, battle, switch_in|
      battle.pbStartWeatherAbility(:Snow, battler)
      next if battler.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
      battler.pbOwnSide.effects[PBEffects::AuroraVeil] = 5
      battler.pbOwnSide.effects[PBEffects::AuroraVeil] = 8 if battler.hasActiveItem?(:LIGHTCLAY)
    battle.pbDisplay(_INTL("{1} made {2} stronger against physical and special moves!",
                            battler.name, battler.pbTeam(true)))
    }
)

# Static Shield
class Battle::Move::ProtectUserFromDamagingMovesStaticShield < Battle::Move::ProtectMove
  def initialize(battle, move)
    super
    @effect = PBEffects::StaticShield
  end
end
