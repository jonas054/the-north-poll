module PollHelper
  def to_number(string)
    digits = string[/\d+\.?\d*/]
    Integer(digits)
  rescue StandardError
    digits ? Float(digits) : 0
  end
end
