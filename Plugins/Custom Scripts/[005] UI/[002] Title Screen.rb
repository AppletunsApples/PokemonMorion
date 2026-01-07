# Title Screen Cry
  def fade_out_title_screen(scene)
    onUpdate.clear
    onCTrigger.clear
    # Play special cry
    species_keys = GameData::Species.keys
    species_data = GameData::Species.get(species_keys.sample)
    Pokemon.play_cry(:EEVEE)
    @pic.moveXY(0, 20, 0, 0)   # Adds 20 ticks (1 second) pause
    pictureWait
    # Fade out
    @pic.moveOpacity(0, FADE_TICKS, 0)
    @pic2.clearProcesses
    @pic2.moveOpacity(0, FADE_TICKS, 0)
    pbBGMStop(1.0)
    pictureWait
    scene.dispose   # Close the scene
  end