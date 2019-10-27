module PollHelper
  def to_number(s)
    Integer(s) rescue Float(s)
  end
end
