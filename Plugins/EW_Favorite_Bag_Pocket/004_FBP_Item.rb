#===============================================================================
# this part of the code is the item logic wich works how the items are added and removed from the bag, and also how the favorite pocket works
#===============================================================================

class PokemonBag
  
  #this three methods are overwrites of the add, remove and replace_item methods in the PokemonBag class, this is to make sure that the items are added and removed from the correct pocket depending on if they are favorited or not
  def add(item, qty = 1)
    item_data = GameData::Item.try_get(item)
    return false if !item_data
    pockets = favorite_item_pockets(item_data, $player.favoriteItemArray.include?(item_data.id)) #check if the item is favorited or not and return the correct pocket(s) to add the item to
    pockets.each do |pocket| #loop trough the pockets and add the item to each pocket, this is to make sure that the item is added to both pockets if clone mode is on
      return false if !add_to_pocket(item_data, pocket, qty)
    end
    return true
  end

  #remove works the same way as add, it checks if the item is favorited or not and removes it from the correct pocket(s)
  def remove(item, qty = 1)
    item_data = GameData::Item.try_get(item)
    return false if !item_data
    pockets = favorite_item_pockets(item_data, $player.favoriteItemArray.include?(item_data.id))
    ret = true
    pockets.each do |pocket|
      @pockets[pocket] ||= []
      ret = false if !ItemStorageHelper.remove(@pockets[pocket], item_data.id, qty)
    end
    return ret
  end

  #replace has the added functionality of favoriting the new item if the old item was favorited, and unfavoriting the new item if the old item was unfavorited, this is to make sure that the favorite pocket stays in sync with the original pocket
  def replace_item(old_item, new_item)
    old_item_data = GameData::Item.try_get(old_item)
    new_item_data = GameData::Item.try_get(new_item)
    return false if !old_item_data || !new_item_data
    old_id = old_item_data.id
    new_id = new_item_data.id

    old_is_favorite = $player.favoriteItemArray.include?(old_id)
    new_is_favorite = $player.favoriteItemArray.include?(new_id)
    
    # if the old item was favorited and the new item is not, then the code will add the new item to the favorite pocket, and if the old item was not favorited and the new item is, then the code will remove the new item from the favorite pocket, 
    #so they stay in sync
    if old_is_favorite
      $player.addFavoriteItem(new_id) if !new_is_favorite
    elsif new_is_favorite
      $player.removeFavoriteItem(new_id)
    end  
    ret = false
    pockets = favorite_item_pockets(old_item_data, $player.favoriteItemArray.include?(old_item_data.id)) #both items are in the same pocket, so we can just use the old item to get the pocket(s) to loop trough
    pockets.each do |pocket|
      @pockets[pocket].each do |item|
        next if !item || item[0] != old_id
        item[0] = new_id
        ret = true
      end
    end
    return ret
  end

  # this method moves an item between the favorite pocket and its original pocket, depending on whether it is being favorited or unfavorited/ or if clone mode is on clone it instead
  def Move_Favorite(item)
    item_data = GameData::Item.try_get(item)
    return false if !item_data

    favorite = $player.favoriteItemArray.include?(item_data.id)
    favorite_pocket = EW_Favorite_Bag_Pocket_Settings::FAVORITE_POCKET_NUMBER

    source_pocket = favorite ? item_data.pocket : favorite_pocket
    target_pocket = favorite ? favorite_pocket : item_data.pocket

    @pockets[source_pocket] ||= []
    @pockets[target_pocket] ||= []
    quantity = ItemStorageHelper.quantity(@pockets[source_pocket], item_data.id)
    return true if quantity == 0
    return false if !add_to_pocket(item_data, target_pocket, quantity)
    if EW_Favorite_Bag_Pocket_Settings::FAVORITE_POCKET_SYSTEM_MOVE #if clone mode is on, it will not remove the item from the source pocket, but if clone mode is off, it will remove the item from the source pocket
      return false if !ItemStorageHelper.remove(@pockets[source_pocket], item_data.id, quantity)
    end
    return true
  end

  #this method is an sort of overwrite method, wich overwrites wich pocket the item is in, if the item is favorited it will return the favorite pocket, if not it will return the original pocket
  #and if it's in clone mode it will return both pockets, so it can loop trough them and do the add and remove methods for both pockets, this is to make sure that the item in both pockets stays in sync with each other
  def favorite_item_pockets(item_data, favorite)
    return [item_data.pocket] if !favorite
    favorite_pocket = EW_Favorite_Bag_Pocket_Settings::FAVORITE_POCKET_NUMBER
    return [favorite_pocket] if EW_Favorite_Bag_Pocket_Settings::FAVORITE_POCKET_SYSTEM_MOVE
    return [item_data.pocket, favorite_pocket].uniq
  end

  # This is a helper method that adds an item to a specific pocket, mainely for the loop's use
  def add_to_pocket(item_data, pocket, qty)
    @pockets[pocket] ||= []
    max_size = max_pocket_size(pocket)
    max_size = @pockets[pocket].length + 1 if max_size < 0   # Infinite size
    ret = ItemStorageHelper.add(
      @pockets[pocket], max_size, Settings::BAG_MAX_PER_SLOT, item_data.id, qty
    )
    if ret && Settings::BAG_POCKET_AUTO_SORT[pocket - 1]
      @pockets[pocket].sort! do |a, b|
        GameData::Item.keys.index(a[0]) <=> GameData::Item.keys.index(b[0])
      end
    end
    return ret
  end


end
