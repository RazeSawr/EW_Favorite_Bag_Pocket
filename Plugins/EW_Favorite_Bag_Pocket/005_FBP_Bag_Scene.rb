#===============================================================================
# this part of the code is the bag scene logic wich allows the favorite pocket to be displayed
# while the base code take care of the majority of stuff there is a purple dot i just could not get rid of, so i had to overwrite the pbRefresh so it does not load the purple dot when the favorite pocket is selected
#... if anyone knows how to get rid of the purple dot without overwriting the pbRefresh method please tell me, T_T 
#===============================================================================
class PokemonBag_Scene
  alias ew_fbp_pbRefresh pbRefresh

  def pbRefresh
    pocket = @sprites["itemlist"].pocket
    favorite_pocket = EW_Favorite_Bag_Pocket_Settings::FAVORITE_POCKET_NUMBER
    return ew_fbp_pbRefresh if pocket != favorite_pocket

    ew_fbp_pbRefreshFavoritePocket
  end

  def ew_fbp_pbRefreshFavoritePocket
    favorite_pocket = EW_Favorite_Bag_Pocket_Settings::FAVORITE_POCKET_NUMBER
    @sprites["background"].setBitmap("Graphics/UI/Bag/bg_#{@bag.last_viewed_pocket}")
    female_bag = "Graphics/UI/Bag/bag_#{@bag.last_viewed_pocket}_f"
    bag_image = "Graphics/UI/Bag/bag_#{@bag.last_viewed_pocket}"
    @sprites["bagsprite"].setBitmap($player.female? && pbResolveBitmap(female_bag) ? female_bag : bag_image)

    @sprites["pocketicon"].bitmap.clear
    if @choosing && @filterlist
      (1...@bag.pockets.length).each do |i|
        next if @filterlist[i].length > 0
        next if i == favorite_pocket
        @sprites["pocketicon"].bitmap.blt(
          6 + ((i - 1) * 22), 6, @pocketbitmap.bitmap, Rect.new((i - 1) * 20, 28, 20, 20)
        )
      end
    end
    @sprites["itemlist"].refresh
    pbRefreshIndexChanged
    pbRefreshParty if respond_to?(:pbRefreshParty)
    if defined?(BagScreenWiInParty) &&
       BagScreenWiInParty.const_defined?(:BGSTYLE) &&
       BagScreenWiInParty::BGSTYLE == 2 && respond_to?(:pbPocketColor)
      pbPocketColor
    end
  end
end
