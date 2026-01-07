#==============================================================================
# Being able to specify respawns
#==============================================================================
  def pbSetPokemonCenter(map_id = nil, x = nil, y = nil, direction = 2)
    if map_id && x && y
      $PokemonGlobal.pokecenterMapId     = map_id
      $PokemonGlobal.pokecenterX         = x
      $PokemonGlobal.pokecenterY         = y
      $PokemonGlobal.pokecenterDirection = direction
    else
      $PokemonGlobal.pokecenterMapId     = $game_map.map_id
      $PokemonGlobal.pokecenterX         = $game_player.x
      $PokemonGlobal.pokecenterY         = $game_player.y
      $PokemonGlobal.pokecenterDirection = $game_player.direction
    end
  end

#==============================================================================
# Screenshotting
#==============================================================================
  def pbScreenCapture
  t = Time.now
  filestart = t.strftime("[%Y-%m-%d] %H_%M_%S.%L")
  begin
    folder_name = "Screenshots"
    Dir.create(folder_name) if !Dir.safe?(folder_name)
    capturefile = folder_name + "/" + sprintf("%s.png", filestart)
    Graphics.screenshot(capturefile)
  rescue
    capturefile = RTP.getSaveFileName(sprintf("%s.png", filestart))
    Graphics.screenshot(capturefile)
  end
    pbSEPlay("Screenshot") if FileTest.audio_exist?("Audio/SE/Screenshot")
  end

#==============================================================================
# Screenshotting
#==============================================================================
  # @return [Integer] the maximum HP of this Pokémon
  def calcHP(base, level, iv, ev)
    return 1 if base == 1   # For Shedinja
    iv = 31 if $game_switches[67]
    return (((base * 2) + iv + (ev / 4)) * level / 100).floor + level + 10
  end

  # @return [Integer] the specified stat of this Pokémon (not used for total HP)
  def calcStat(base, level, iv, ev, nat)
    iv = 31 if $game_switches[67]
    return (((((base * 2) + iv + (ev / 4)) * level / 100).floor + 5) * nat / 100).floor
  end