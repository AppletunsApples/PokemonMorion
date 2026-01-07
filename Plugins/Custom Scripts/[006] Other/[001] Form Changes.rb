#==============================================================================
# Regional forms
# These species don't have visually different regional forms, but they need to
# evolve into different forms depending on the location where they evolve.
#===============================================================================
# Atmosian Forms
MultipleForms.register(:BAYLEEF, {
  "getForm" => proc { |pkmn|
    next 2
  }
})

MultipleForms.copy(:BAYLEEF, :MARSHTOMP, :BRAIXEN)
