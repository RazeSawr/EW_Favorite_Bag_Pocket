
#===============================================================================
# this part of the code is what adds the Favorite pocket to the bag
#===============================================================================
module Settings
  singleton_class.alias_method :ew_fbp_bag_pocket_names, :bag_pocket_names

  def self.bag_pocket_names
    names = self.ew_fbp_bag_pocket_names
    names.push(EW_Favorite_Bag_Pocket_Settings::FAVORITE_POCKET_NAME)
    return names
  end

  BAG_MAX_POCKET_SIZE.push(-1)
  BAG_POCKET_AUTO_SORT.push(true)
end

#===============================================================================
# Bag mechanics
# this part of the code is what adds the Favorite/Unfavorite option to the selection menu when you select an item in the bag
# by overwriting the pbStartScreen method in the PokemonBagScreen class, if you have a diffrent bag system that overwrites this method
# you might need to edit either this part of the code or that part of the code to make it compatible with your bag system
#===============================================================================
class PokemonBagScreen

  def pbStartScreen
    @scene.pbStartScene(@bag)
    item = nil
    loop do
      item = @scene.pbChooseItem
      break if !item
      itm = GameData::Item.get(item)
      cmdRead     = -1
      cmdUse      = -1
      cmdRegister = -1
      cmdGive     = -1
      cmdToss     = -1
      cmdFavorite = -1 #adding the option to favorite/unfavorite items in the bag
      cmdDebug    = -1
      commands = []
      # Generate command list
      commands[cmdRead = commands.length] = _INTL("Read") if itm.is_mail?
      if ItemHandlers.hasOutHandler(item) || (itm.is_machine? && $player.party.length > 0)
        if ItemHandlers.hasUseText(item)
          commands[cmdUse = commands.length]    = ItemHandlers.getUseText(item)
        else
          commands[cmdUse = commands.length]    = _INTL("Use")
        end
      end
      commands[cmdGive = commands.length]       = _INTL("Give") if $player.pokemon_party.length > 0 && itm.can_hold?
      commands[cmdToss = commands.length]       = _INTL("Toss") if !itm.is_important? || $DEBUG
      if @bag.registered?(item)
        commands[cmdRegister = commands.length] = _INTL("Deselect")
      elsif pbCanRegisterItem?(item)
        commands[cmdRegister = commands.length] = _INTL("Register")
      end
      #making the Favorite/Unfavorite option appear in the bag menu when you select an item, and also showing the correct option depending on if the item is already favorited or not
      commands[cmdFavorite = commands.length]   = _INTL("Favorite") if !$player.favoriteItemArray.include?(item)
      commands[cmdFavorite = commands.length]   = _INTL("Unfavorite") if $player.favoriteItemArray.include?(item)

      commands[cmdDebug = commands.length]      = _INTL("Debug") if $DEBUG
      commands[commands.length]                 = _INTL("Cancel")
      # Show commands generated above
      itemname = itm.name
      command = @scene.pbShowCommands(_INTL("{1} is selected.", itemname), commands)
      if cmdRead >= 0 && command == cmdRead   # Read mail
        pbFadeOutIn {
          pbDisplayMail(Mail.new(item, "", ""))
        }
      elsif cmdUse >= 0 && command == cmdUse   # Use item
        ret = pbUseItem(@bag, item, @scene)
        # ret: 0=Item wasn't used; 1=Item used; 2=Close Bag to use in field
        break if ret == 2   # End screen
        @scene.pbRefresh
        next
      elsif cmdGive >= 0 && command == cmdGive   # Give item to Pokémon
        if $player.pokemon_count == 0
          @scene.pbDisplay(_INTL("There is no Pokémon."))
        elsif itm.is_important?
          @scene.pbDisplay(_INTL("The {1} can't be held.", itemname))
        else
          pbFadeOutIn {
            sscene = PokemonParty_Scene.new
            sscreen = PokemonPartyScreen.new(sscene, $player.party)
            sscreen.pbPokemonGiveScreen(item)
            @scene.pbRefresh
          }
        end
      elsif cmdToss >= 0 && command == cmdToss   # Toss item
        qty = @bag.quantity(item)
        if qty > 1
          helptext = _INTL("Toss out how many {1}?", itm.name_plural)
          qty = @scene.pbChooseNumber(helptext, qty)
        end
        if qty > 0
          itemname = itm.name_plural if qty > 1
          if pbConfirm(_INTL("Is it OK to throw away {1} {2}?", qty, itemname))
            pbDisplay(_INTL("Threw away {1} {2}.", qty, itemname))
            qty.times { @bag.remove(item) }
            @scene.pbRefresh
          end
        end
      elsif cmdFavorite >= 0 && command == cmdFavorite 
        didItWork = $player.toggleFavoriteItem(item) #change the status of the item to either favorited or unfavorited depending on if it was already favorited or not
        @bag.Move_Favorite(item) if didItWork #move the item to the Favorite pocket if it was favorited, or move it back to the original pocket if it was unfavorited or do nothing if the item was blacklisted
        @scene.pbRefresh
      elsif cmdRegister >= 0 && command == cmdRegister   # Register item
        if @bag.registered?(item)
          @bag.unregister(item)
        else
          @bag.register(item)
        end
        @scene.pbRefresh
      elsif cmdDebug >= 0 && command == cmdDebug   # Debug
        command = 0
        loop do
          command = @scene.pbShowCommands(_INTL("Do what with {1}?", itemname),
                                          [_INTL("Change quantity"),
                                           _INTL("Make Mystery Gift"),
                                           _INTL("Cancel")], command)
          case command
          ### Cancel ###
          when -1, 2
            break
          ### Change quantity ###
          when 0
            qty = @bag.quantity(item)
            itemplural = itm.name_plural
            params = ChooseNumberParams.new
            params.setRange(0, Settings::BAG_MAX_PER_SLOT)
            params.setDefaultValue(qty)
            newqty = pbMessageChooseNumber(
              _INTL("Choose new quantity of {1} (max. #{Settings::BAG_MAX_PER_SLOT}).", itemplural), params
            ) { @scene.pbUpdate }
            if newqty > qty
              @bag.add(item, newqty - qty)
            elsif newqty < qty
              @bag.remove(item, qty - newqty)
            end
            @scene.pbRefresh
            break if newqty == 0
          ### Make Mystery Gift ###
          when 1
            pbCreateMysteryGift(1, item)
          end
        end
      end
    end
    ($game_temp.fly_destination) ? @scene.dispose : @scene.pbEndScene
    return item
  end
end
