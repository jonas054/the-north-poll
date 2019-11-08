module PollHelper
  def to_number(string)
    Integer(string)
  rescue StandardError
    Float(string)
  end
end
