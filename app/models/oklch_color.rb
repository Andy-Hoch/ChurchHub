# Converts between sRGB hex colors (as delivered by <input type="color">) and
# CSS oklch() strings, which is how colors are stored and rendered.
module OklchColor
  HEX = /\A#?(\h{2})(\h{2})(\h{2})\z/
  OKLCH = /\Aoklch\(\s*(\d+(?:\.\d+)?)%\s+(\d+(?:\.\d+)?)\s+(\d+(?:\.\d+)?)\s*\)\z/i
  FORMAT = /\Aoklch\(\d{1,3}(?:\.\d{1,2})?% \d(?:\.\d{1,4})? \d{1,3}(?:\.\d{1,2})?\)\z/

  extend self

  # Accepts a hex or oklch() string and returns the canonical oklch() form,
  # or nil if the value can't be parsed.
  def normalize(value)
    value = value.to_s.strip.downcase

    if (match = HEX.match(value))
      from_rgb(*match.captures.map { |channel| channel.to_i(16) / 255.0 })
    elsif (match = OKLCH.match(value))
      format_oklch(*match.captures.map(&:to_f).then { |l, c, h| [ l / 100, c, h ] })
    end
  end

  def to_hex(value)
    match = OKLCH.match(value.to_s.strip) or return
    l, c, h = match.captures.map(&:to_f)

    "#" + to_rgb(l / 100, c, h).map { |channel| (channel.clamp(0, 1) * 255).round.to_s(16).rjust(2, "0") }.join
  end

  private
    def from_rgb(r, g, b)
      r, g, b = [ r, g, b ].map { |channel| channel <= 0.04045 ? channel / 12.92 : ((channel + 0.055) / 1.055)**2.4 }

      l = Math.cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
      m = Math.cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
      s = Math.cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)

      lightness = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
      a = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
      b = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s

      format_oklch(lightness, Math.hypot(a, b), Math.atan2(b, a) * 180 / Math::PI)
    end

    def to_rgb(lightness, chroma, hue)
      a = chroma * Math.cos(hue * Math::PI / 180)
      b = chroma * Math.sin(hue * Math::PI / 180)

      l = (lightness + 0.3963377774 * a + 0.2158037573 * b)**3
      m = (lightness - 0.1055613458 * a - 0.0638541728 * b)**3
      s = (lightness - 0.0894841775 * a - 1.2914855480 * b)**3

      [
        4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
        -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
        -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
      ].map { |channel| channel <= 0.0031308 ? channel * 12.92 : 1.055 * channel.clamp(0, Float::INFINITY)**(1 / 2.4) - 0.055 }
    end

    def format_oklch(lightness, chroma, hue)
      chroma = 0 if chroma.round(4).zero?
      hue = chroma.zero? ? 0 : hue % 360

      "oklch(#{number(lightness.clamp(0, 1) * 100, 2)}% #{number(chroma, 4)} #{number(hue, 2)})"
    end

    def number(value, precision)
      value.round(precision).to_s.sub(/\.?0+\z/, "").then { |string| string.empty? ? "0" : string }
    end
end
