module PollHelper
  def to_number(string)
    digits = string[/\d+\.?\d*/]
    Integer(digits)
  rescue StandardError
    Float(digits)
  end
end
