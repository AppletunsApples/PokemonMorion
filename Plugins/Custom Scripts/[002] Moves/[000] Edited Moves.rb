#===============================================================================
# Hidden Power
#===============================================================================
class Battle::Move::TypeDependsOnUserIVsCategoryDependsOnHigherDamage < Battle::Move
  def initialize(battle, move)
    super
    @calcCategory = 1
  end

  def physicalMove?(thisType = nil); return (@calcCategory == 0); end
  def specialMove?(thisType = nil);  return (@calcCategory == 1); end

  def pbOnStartUse(user, targets)
    # Calculate user's effective attacking value
    max_stage = Battle::Battler::STAT_STAGE_MAXIMUM
    stageMul = Battle::Battler::STAT_STAGE_MULTIPLIERS
    stageDiv = Battle::Battler::STAT_STAGE_DIVISORS
    atk        = user.attack
    atkStage   = user.stages[:ATTACK] + max_stage
    realAtk    = (atk.to_f * stageMul[atkStage] / stageDiv[atkStage]).floor
    spAtk      = user.spatk
    spAtkStage = user.stages[:SPECIAL_ATTACK] + max_stage
    realSpAtk  = (spAtk.to_f * stageMul[spAtkStage] / stageDiv[spAtkStage]).floor
    # Determine move's category
    @calcCategory = (realAtk > realSpAtk) ? 0 : 1
  end

  def pbBaseType(user)
    hp = pbHiddenPower(user.pokemon)
    return hp[0]
  end

  def pbBaseDamage(baseDmg, user, target)
    return super if Settings::MECHANICS_GENERATION >= 6
    hp = pbHiddenPower(user.pokemon)
    return hp[1]
  end
end

# NOTE: This allows Hidden Power to be Fairy-type (if you have that type in your
#       game). I don't care that the official games don't work like that.
def pbHiddenPower(pkmn)
  iv = pkmn.iv
  idxType = 0
  power = 60
  types = []
  GameData::Type.each do |t|
    types[t.icon_position] ||= []
    types[t.icon_position].push(t.id) if !t.pseudo_type && ![:NORMAL, :SHADOW].include?(t.id)
  end
  types.flatten!.compact!
  idxType |= (iv[:HP] & 1)
  idxType |= (iv[:ATTACK] & 1) << 1
  idxType |= (iv[:DEFENSE] & 1) << 2
  idxType |= (iv[:SPEED] & 1) << 3
  idxType |= (iv[:SPECIAL_ATTACK] & 1) << 4
  idxType |= (iv[:SPECIAL_DEFENSE] & 1) << 5
  idxType = (types.length - 1) * idxType / 63
  type = types[idxType]
  if Settings::MECHANICS_GENERATION <= 5
    powerMin = 30
    powerMax = 70
    power |= (iv[:HP] & 2) >> 1
    power |= (iv[:ATTACK] & 2)
    power |= (iv[:DEFENSE] & 2) << 1
    power |= (iv[:SPEED] & 2) << 2
    power |= (iv[:SPECIAL_ATTACK] & 2) << 3
    power |= (iv[:SPECIAL_DEFENSE] & 2) << 4
    power = powerMin + ((powerMax - powerMin) * power / 63)
  end
  return [type, power]
end