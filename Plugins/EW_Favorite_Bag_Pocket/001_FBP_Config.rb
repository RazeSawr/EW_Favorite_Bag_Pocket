#===============================================================================
# EW Favorite Bag Pocket system
# this is a quality of life improvement for the bag, allowing players to favorite items and have them in a separate pocket for easy access
#
# this plugin runs mostly on it's own, once added so you don't need to do anything else, but if you want to change the settings, you can do so in the EW_Favorite_Bag_Pocket_Settings module below 
#===============================================================================
# Things you can currently customise without editing the scripts themselves
#===============================================================================

module EW_Favorite_Bag_Pocket_Settings
  # this setting changes the display name of the Favorite pocket to whatever you want, for example "Faves"
  FAVORITE_POCKET_NAME = _INTL("Favorite pocket")

  #This is an array wich you can input Item IDs that you don't want the player to be able to favorite, for example: [:POTION, :ANTIDOTE].
  BLACKLIST_ITEMS = []
  #this is the message that will be displayed when the player tries to favorite a blacklisted item
  BLACKLIST_ERROR_MESSAGE = _INTL("This item cannot be favorited.")

  # this setting changes the maximum number of different item types that can be favorited.
  # -1 stands for no limit of item types, 0 stands for no items at all, and any positive number is the maximum number of different item types allowed.
  FAVORITE_POCKET_MAX_ITEM_TYPES = -1

  # this is the message that will be displayed when the player tries to favorite an item when they have already favorited the maximum number of different item types.
  FAVORITE_POCKET_MAX_ITEMS_ERROR_MESSAGE = _INTL("You can only favorite up to (Insert Items number here) different item types.")

  # this setting slighty changes how the system works
  # if set to true, then when you favorite an item, it will be moved to the Favorite pocket, and when you unfavorite an item, it will be moved back to the pocket it was in before.
  # if set to false, then when you favorite an item, it will stay in the pocket it was in before, and a copy of that item will be added to the Favorite pocket, and when you unfavorite an item, it will be removed from the Favorite pocket
  FAVORITE_POCKET_SYSTEM_MOVE = true

  # This is the index of the Favorite pocket in the bag, this is in case you have multiple pockets, plugins/addons 
  # if you do you might need to change this to the correct pocket number, (key items is 8 so add 1 everytime you press right until you get to the Favorite pocket) 
  # you are also gonna need to change the graphics in Graphics/UI/Bag/ to match the new index
  FAVORITE_POCKET_NUMBER = 9

  #Background colour at the top of the screen, and uses Hex codes values, default is #9B02F0
  GRADIENT_TOP = "#9B02F0"
  # Background colour at the bottom of the screen, and uses Hex codes values, default is #00137F
  GRADIENT_BOTTOM = "#00137F"

  #together the Gradient top and bottom colours create a gradient effect, aka it gradually changes from the top colour to the bottom colour, 
  #if you want a solid colour, just set both to the same colour

  #Number of tiny round dots on screen aka small stars default is 30
  FAR_COUNT = 30

  #Number of sparkly stars on screen aka big stars default is 10
  SPARKLE_COUNT = 10

  #the stars randomy picks colors from this array, and uses Hex codes values, default is ["#ffea00", "#1aff00", "#0011ff"]
  STAR_COLORS = ["#FFFFFF", "#DCEBFF", "#FFF0C8"]

  # PS THIS SCRIPT DOES NOT SORT THE ITEM, SO IF YOU REMOVE AN ITEM FROM THE FAVORITE POCKET, IT WILL NOT BE SORTED BACK INTO ITS ORIGINAL POSITION BUT AT THE BOTTOM OF IT'S ORIGINAL POCKET
  # this plugin is not made with the thoughts of other bag plugins in mind, so if you have other bag plugins that change the way the bag works, this plugin might not work with them, and you might need to edit the code to make it work with them.
end
