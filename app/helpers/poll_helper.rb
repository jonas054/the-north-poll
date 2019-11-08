module PollHelper
  def to_number(s)
    Integer(s)
  rescue StandardError
    Float(s)
  end
end
