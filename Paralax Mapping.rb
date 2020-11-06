# encoding: utf8
# Script 51598340: Paralax Mapping
# Paralax Mapping V.0.1
# To use set up paralax as normal in map properties, however to apply a
# overhead layer list the name of the file in the map notes with square
# brackets (ie; [overhead name]).
#
# To use normal paralax scrolling, turn on paralax looping
# To not use an overlay, do not reference a overhead within the map notes.
#______________________________________________________________________________

#==============================================================================
# ** Cache
#------------------------------------------------------------------------------
#  This module loads graphics, creates bitmap objects, and retains them.
# To speed up load times and conserve memory, this module holds the
# created bitmap object in the internal hash, allowing the program to
# return preexisting objects when the same bitmap is requested again.
#==============================================================================
module Cache
  #--------------------------------------------------------------------------
  # * Get Overhead Graphic
  #--------------------------------------------------------------------------
  def self.overhead(filename)
    load_bitmap("Graphics/Overheads/", filename)
  end
end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :overhead_name            # overhead background filename
  
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  alias evk_pm_gm_setup_42069 setup
  def setup(map_id)
    @map_id = map_id
    @map = load_data(sprintf("Data/Map%03d.rvdata2", @map_id))
    @tileset_id = @map.tileset_id
    @display_x = 0
    @display_y = 0
    referesh_vehicles
    setup_events
    setup_scroll
    setup_parallax
    setup_overhead
    setup_battleback
    @need_refresh = false
  end
  #--------------------------------------------------------------------------
  # * Overhead Setup
  #--------------------------------------------------------------------------
  def setup_overhead
    if @map.note[/\[(.+)\]/]
      @overhead_name = $1
    else
      @overhead_name = nil
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate X Coordinate of Parallax Display Origin
  #--------------------------------------------------------------------------
  alias evk_pm_gm_paraOX_42069 parallax_ox
  def parallax_ox(bitmap)
    if @parallax_loop_x
      @parallax_x * 16
    else
      w1 = [bitmap.width - Graphics.width, 0].max
      w2 = [width * 32 - Graphics.width, 1].max
      @parallax_x * 32 * w1 / w2
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate Y Coordinate of Parallax Display Origin
  #--------------------------------------------------------------------------
  alias evk_pm_gm_paraOY_42069 parallax_oy
  def parallax_oy(bitmap)
    if @parallax_loop_y
      @parallax_y * 16
    else
      h1 = [bitmap.height - Graphics.height, 0].max
      h2 = [height * 32 - Graphics.height, 1].max
      @parallax_y * 32 * h1 / h2
    end
  end
end

#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  This class brings together map screen sprites, tilemaps, etc. It's used
# within the Scene_Map class.
#==============================================================================
class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias evk_pm_sm_new_42069 initialize
  def initialize
    create_viewports
    create_tilemap
    create_parallax
    create_characters
    create_shadow
    create_overhead
    create_weather
    create_pictures
    create_timer
    update
  end
  #--------------------------------------------------------------------------
  # * Create Overhead
  #--------------------------------------------------------------------------
  def create_overhead
    @overhead = Plane.new(@viewport1)
    @overhead.z = 190
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias evk_pm_sm_update_42069 update
  def update
    update_tileset
    update_tilemap
    update_parallax
    update_characters
    update_shadow
    update_overhead
    update_weather
    update_pictures
    update_timer
    update_viewports
  end
  #--------------------------------------------------------------------------
  # * Update Overhead
  #--------------------------------------------------------------------------
  def update_overhead
    if @overhead_name != $game_map.overhead_name
      @overhead_name = $game_map.overhead_name
      @overhead.bitmap.dispose if @overhead.bitmap
      @overhead.bitmap = Cache.overhead(@overhead_name) if @overhead_name
      Graphics.frame_reset
    end
    @overhead.ox = $game_map.parallax_ox(@parallax.bitmap)
    @overhead.oy = $game_map.parallax_oy(@parallax.bitmap)
  end
end