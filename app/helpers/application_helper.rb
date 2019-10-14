module ApplicationHelper
  def plural_s(singular, count)
    singular + (count == 1 ? '' : 's')
  end
end
