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

# Covet, Thief
class Battle::Move::UserTakesTargetItem < Battle::Move
  def pbEffectAfterAllHits(user, target)
    return if user.wild?   # Wild Pokémon can't thieve
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item
    return if target.unlosableItem?(target.item)
    return if user.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    user.item = target.item
    # Permanently steal the item from wild Pokémon
    if target.wild? && target.item == target.initialItem
      $bag.add(target.item)
      target.pbRemoveItem
    else
      target.pbRemoveItem(false)
    end
    @battle.pbDisplay(_INTL("{1} stole {2}'s item {3} and sent it to {4}'s bag.", user.pbThis, target.pbThis(true), itemName, $player.name{5}))
    user.pbHeldItemTriggerCheck
  end.name
end
