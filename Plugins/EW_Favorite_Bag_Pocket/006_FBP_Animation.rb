#-----------------
# Background animation for the Favorite pocket.
# ... I will be honest, i diden't write this code, i commisioned it from LackDeJurane/Issei,nce, 
# and i don't know how it works in it's entiery, but it works, 
# so if you want to change the animation, or have some questions/suggestions/concerns you will have to ask him for it (or at the very least most likely i will just forward your questions to him) 
#-----------------
module EW_Favorite_Bag_Animation
  Star = Struct.new(:x, :y, :img, :w, :h, :low, :high, :cur, :step, :left)
end

class PokemonBag_Scene
  alias ew_fbp_anim_pbStartScene pbStartScene
  alias ew_fbp_anim_pbUpdate pbUpdate
  alias ew_fbp_anim_pbEndScene pbEndScene
  alias ew_fbp_anim_dispose dispose

  def pbStartScene(*args)
    ret = ew_fbp_anim_pbStartScene(*args)
    ew_fbp_create_star_layers
    return ret
  end

  def pbUpdate
    ew_fbp_anim_pbUpdate
    ew_fbp_animate_star_layers
  end

  def pbEndScene
    ew_fbp_anim_pbEndScene
    ew_fbp_dispose_star_bitmaps
  end

  def dispose
    ew_fbp_anim_dispose
    ew_fbp_dispose_star_bitmaps
  end

  def ew_fbp_dispose_star_bitmaps
    (@ew_fbp_bitmaps || []).each { |b| b.dispose if b && !b.disposed? }
    @ew_fbp_bitmaps = []
    @ew_fbp_stars = []
  end

  def ew_fbp_create_star_layers
    cfg = EW_Favorite_Bag_Pocket_Settings
    w = Graphics.width
    h = Graphics.height
    @ew_fbp_bitmaps = []
    @sprites["background"].z = -1
    top = ew_fbp_hex_to_rgb(cfg::GRADIENT_TOP)
    bottom = ew_fbp_hex_to_rgb(cfg::GRADIENT_BOTTOM)
    gradient = Bitmap.new(w, h)
    h.times do |y|
      t = y.to_f / (h - 1)
      rgb = (0...3).map { |i| (top[i] + (bottom[i] - top[i]) * t).round }
      gradient.fill_rect(0, y, w, 1, Color.new(rgb[0], rgb[1], rgb[2]))
    end
    gradient_sprite = Sprite.new(@viewport)
    gradient_sprite.bitmap = gradient
    gradient_sprite.z = -3
    gradient_sprite.visible = false
    canvas = Bitmap.new(w, h)
    canvas_sprite = Sprite.new(@viewport)
    canvas_sprite.bitmap = canvas
    canvas_sprite.z = -2
    canvas_sprite.visible = false
    @ew_fbp_bitmaps.push(gradient, canvas)
    @sprites["ew_fbp_gradient"] = gradient_sprite
    @sprites["ew_fbp_stars"] = canvas_sprite
    @ew_fbp_rng = Random.new
    rng = @ew_fbp_rng
    @ew_fbp_stars = []
    ew_fbp_make_stars(rng, cfg::FAR_COUNT, :dot, [2, 3], cfg::STAR_COLORS, 0, 200)
    ew_fbp_make_stars(rng, cfg::SPARKLE_COUNT, :sparkle, [6, 8, 10], cfg::STAR_COLORS, 0, 255)
  end

  # found this function on stackoverflow, and added it here, the script orginally used RGB values, but i wanted to use hex codes instead for simplicity,
  # so this function converts hex codes to RGB values
  def ew_fbp_hex_to_rgb(hex)
    match = hex.match(/\A#?([0-9A-Fa-f]{6})\z/)
    raise ArgumentError, "Invalid hex color: #{hex.inspect}" if !match #this is just to help debug if you put in a wrong hex code, it will tell you that the hex code is invalid
    return hex.match(/^#(..)(..)(..)$/).captures.map(&:hex) #this is the actual conversion from hex to RGB values, it takes the hex code and splits it into 3 parts, and converts each part to a decimal value
  end

  def ew_fbp_make_stars(rng, count, kind, radii, colors, low, high)
    cache = {}
    count.times do
      radius = radii[rng.rand(radii.length)]
      color = ew_fbp_hex_to_rgb(colors[rng.rand(colors.length)])
      key = [radius, color]
      cache[key] ||= ew_fbp_star_bitmap(kind, radius, color)
      img = cache[key]
      @ew_fbp_bitmaps.push(img) if !@ew_fbp_bitmaps.include?(img)
      @ew_fbp_stars.push(
        EW_Favorite_Bag_Animation::Star.new(
          rng.rand * (Graphics.width - img.width), rng.rand * (Graphics.height - img.height),
          img, img.width, img.height, low, high, rng.rand(low..high).to_f, 0.0, rng.rand(1..60)
        )
      )
    end
  end

  def ew_fbp_polygon(tips, radius, inner, scale = 1.0)
    points = []
    (tips * 2).times do |i|
      r = (i.even? ? radius : radius * inner) * scale
      a = -Math::PI / 2 + i * Math::PI / tips
      points.push([r * Math.cos(a), r * Math.sin(a)])
    end
    return points
  end

  def ew_fbp_inside?(px, py, poly)
    inside = false
    j = poly.length - 1
    poly.each_with_index do |pt, i|
      pj = poly[j]
      if (pt[1] > py) != (pj[1] > py) &&
         px < (pj[0] - pt[0]) * (py - pt[1]) / (pj[1] - pt[1]) + pt[0]
        inside = !inside
      end
      j = i
    end
    return inside
  end

  def ew_fbp_star_bitmap(kind, radius, color)
    size = radius * 2 + 4
    bmp = Bitmap.new(size, size)
    center = size / 2.0
    samples = 3
    outer = nil
    highlight = nil
    case kind
    when :star
      outer = ew_fbp_polygon(5, radius, 0.42)
      highlight = ew_fbp_polygon(5, radius, 0.42, 0.5)
    when :sparkle
      outer = ew_fbp_polygon(4, radius, 0.2)
    end
    light = color.map { |c| c + ((255 - c) * 0.55).to_i }
    size.times do |y|
      size.times do |x|
        hits = 0
        lit = 0
        samples.times do |sy|
          samples.times do |sx|
            px = x + (sx + 0.5) / samples - center
            py = y + (sy + 0.5) / samples - center
            if kind == :dot
              hits += 1 if Math.sqrt(px * px + py * py) <= radius * 0.8
            elsif ew_fbp_inside?(px, py, outer)
              hits += 1
              lit += 1 if highlight && ew_fbp_inside?(px, py, highlight)
            end
          end
        end
        next if hits == 0
        total = samples * samples
        mix = lit.to_f / hits
        rgb = (0...3).map { |i| (color[i] + (light[i] - color[i]) * mix).round }
        bmp.set_pixel(x, y, Color.new(rgb[0], rgb[1], rgb[2], 255 * hits / total))
      end
    end
    return bmp
  end

  def ew_fbp_animate_star_layers
    return if !@ew_fbp_stars || @ew_fbp_stars.empty?
    active = @sprites["itemlist"] &&
             @sprites["itemlist"].pocket == EW_Favorite_Bag_Pocket_Settings::FAVORITE_POCKET_NUMBER
    @sprites["ew_fbp_gradient"].visible = active
    @sprites["ew_fbp_stars"].visible = active
    return if !active
    canvas = @sprites["ew_fbp_stars"].bitmap
    canvas.clear
    @ew_fbp_stars.each do |s|
      s.left -= 1
      if s.left <= 0
        s.left = @ew_fbp_rng.rand(12..80)
        if s.cur <= s.low + 2
          s.x = @ew_fbp_rng.rand * (Graphics.width - s.w)
          s.y = @ew_fbp_rng.rand * (Graphics.height - s.h)
          target = @ew_fbp_rng.rand(s.high / 2..s.high)
        elsif @ew_fbp_rng.rand < 0.4
          target = s.low
        else
          target = @ew_fbp_rng.rand(s.low..s.high)
        end
        s.step = (target - s.cur) / s.left
      end
      s.cur = (s.cur + s.step).clamp(s.low, s.high)
      opacity = s.cur.to_i.clamp(0, 255)
      canvas.blt(s.x.to_i, s.y.to_i, s.img, Rect.new(0, 0, s.w, s.h), opacity)
    end
  end
end