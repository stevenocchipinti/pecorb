# This method was introduced in ruby 2.4, however this patch will allow this
# feature to be available in older versions fo ruby

module Comparable
  def clamp(min, max)
    return min if self < min
    return max if self > max
    self
  end
end
