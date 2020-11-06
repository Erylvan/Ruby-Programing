# encoding: utf8
# Script 17801190: SaveRework
# Save Rework V.0.1
# Manages unlocked items, save updating and death counter

#==============================================================================
# ** ScriptCalls
#------------------------------------------------------------------------------
#  This module holds methods for managing simple functions
#==============================================================================
module ScriptCalls
  #--------------------------------------------------------------------------
  # * Logs log to be stored in array
  #--------------------------------------------------------------------------
  def self.unlock_log(id)
    $game_logs[id] = 1
    $game_map.need_refresh = true
  end
  #------------------------------------------------------------------------
  # * Gets stored logs
  #------------------------------------------------------------------------
  def self.get_logs
    $game_logs.keys
  end
  #------------------------------------------------------------------------
  # * Gets stored logs
  #------------------------------------------------------------------------
  def self.get_death_counter
    $game_death_counter
  end
  #------------------------------------------------------------------------
  # * Handles game over
  #------------------------------------------------------------------------
  def self.game_over
    $game_death_counter += 1
    DataManager.update_save_contents
    SceneManager.goto(Scene_Gameover)
  end
end

#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
#  This module manages the database and game objects. Almost all of the 
# global variables used by the game are initialized by this module.
#==============================================================================
module DataManager
  class << self
    #------------------------------------------------------------------------
    # * Create Game Objects
    #------------------------------------------------------------------------
    alias evk_SSaveRework_dm_cgo_42069  create_game_objects
    def create_game_objects
      evk_SSaveRework_dm_cgo_42069
      $game_logs          = {}
      $game_death_counter = 0
    end
    #------------------------------------------------------------------------
    # * Set Up New Game
    #------------------------------------------------------------------------
    alias evk_SSaveRework_dm_sng_42069  setup_new_game
    def setup_new_game
      create_game_objects
      $game_party.setup_starting_members
      @last_savefile_index = -1
      $game_map.setup($data_system.start_map_id)
      $game_player.moveto($data_system.start_x, $data_system.start_y)
      $game_player.refresh
      Graphics.frame_count = 0
    end
    #------------------------------------------------------------------------
    # * Create Save Contents
    #------------------------------------------------------------------------
    alias evk_SSaveRework_dm_msc_42069  make_save_contents
    def make_save_contents
      contents = {}
      contents[:system]        = $game_system
      contents[:timer]         = $game_timer
      contents[:message]       = $game_message
      contents[:switches]      = $game_switches
      contents[:variables]     = $game_variables
      contents[:self_switches] = $game_self_switches
      contents[:actors]        = $game_actors
      contents[:party]         = $game_party
      contents[:troop]         = $game_troop
      contents[:map]           = $game_map
      contents[:player]        = $game_player
      contents[:logs]          = $game_logs
      contents[:deaths]        = $game_death_counter
      contents
    end
    #------------------------------------------------------------------------
    # * Extract Save Contents
    #------------------------------------------------------------------------
    alias evk_SSaveRework_dm_esc_42069  extract_save_contents
    def extract_save_contents(contents)
      $game_system        = contents[:system]
      $game_timer         = contents[:timer]
      $game_message       = contents[:message]
      $game_switches      = contents[:switches]
      $game_variables     = contents[:variables]
      $game_self_switches = contents[:self_switches]
      $game_actors        = contents[:actors]
      $game_party         = contents[:party]
      $game_troop         = contents[:troop]
      $game_map           = contents[:map]
      $game_player        = contents[:player]
      $game_logs          = contents[:logs]
      $game_death_counter = contents[:deaths]
    end
    #------------------------------------------------------------------------
    # * Update Save Contents
    #------------------------------------------------------------------------
    def update_save_contents
      if @last_savefile_index != -1
        File.open(make_filename(@last_savefile_index), "rb") do |file|
          Marshal.load(file)
          evk_SSaveRework_dm_esc_42069(Marshal.load(file))
          reload_map_if_updated
        end
        File.open(make_filename(@last_savefile_index), "wb") do |file|
          $game_system.on_before_save
          Marshal.dump(make_save_header, file)
          Marshal.dump(make_save_contents, file)
        end
      end
    end
    #--------------------------------------------------------------------------
    # * Get Index of File Most Recently Accessed
    #--------------------------------------------------------------------------
    alias evk_SSaveRework_dm_lsi_42069  last_savefile_index
    def last_savefile_index
      @last_savefile_index == -1 ? 0 : @last_savefile_index
    end
  end
end