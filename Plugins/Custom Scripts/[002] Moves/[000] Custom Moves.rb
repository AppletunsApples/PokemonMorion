#===============================================================================
# Spirit Slam
#===============================================================================
class Battle::Move::UseUserSpDefenseInsteadOfUserSpAttack < Battle::Move
  def pbGetAttackStats(user, target)
    return user.defense, user.stages[:SPECIAL_DEFENSE] + Battle::Battler::STAT_STAGE_MAXIMUM
  end
end

#===============================================================================
# Psychoblast
#===============================================================================
class Battle::Move::LowerUserSpAtkSpDef1 < Battle::Move::StatDownMove
  def initialize(battle, move)
    super
    @statDown = [:SPECIAL_ATTACK, 1, :SPECIAL_DEFENSE, 1]
  end
end
