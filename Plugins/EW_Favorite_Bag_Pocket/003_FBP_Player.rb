#===============================================================================
# this part of the code is the player logic wich allows the items to persist after saving and restarting the game
#===============================================================================
class Player < Trainer

  # this is the array that stores the items that the player has favorited
  def favoriteItemArray
    @favoriteItemArray ||= []
  end
  
  # this is the setter for the favoriteItemArray, it allows you to set the array to a new array of items
  def favoriteItemArray=(items)
    @favoriteItemArray = items || []
  end


  # this method adds an item to the favoriteItemArray, it returns true if the item was added, and false if it was not added (aka one of the pockets limits was reached or the item is blacklisted)
  def addFavoriteItem(item)
    if EW_Favorite_Bag_Pocket_Settings::BLACKLIST_ITEMS.include?(item)
      pbMessage(EW_Favorite_Bag_Pocket_Settings::BLACKLIST_ERROR_MESSAGE)
      return false
    end
    if EW_Favorite_Bag_Pocket_Settings::FAVORITE_POCKET_MAX_ITEM_TYPES != -1 && favoriteItemArray.size >= EW_Favorite_Bag_Pocket_Settings::FAVORITE_POCKET_MAX_ITEM_TYPES
        pbMessage(EW_Favorite_Bag_Pocket_Settings::FAVORITE_POCKET_MAX_ITEMS_ERROR_MESSAGE)
        return false
    end
    return false if favoriteItemArray.include?(item)
    favoriteItemArray.push(item)
    return true
  end

  # this method removes an item from the favoriteItemArray, it returns true if the item was removed, and false if it was not removed (aka the item was not in the array)
  def removeFavoriteItem(item)
    return false unless favoriteItemArray.delete(item)
    return true
  end

  # this method toggles an item in the favoriteItemArray, as a shorthand for addFavoriteItem and removeFavoriteItem
  def toggleFavoriteItem(item)
    return removeFavoriteItem(item) if favoriteItemArray.include?(item)
    return addFavoriteItem(item)
  end
end
