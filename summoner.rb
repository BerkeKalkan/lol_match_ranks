class Summoner
  attr_reader :id, :name
  
  attr_accessor :rank

  def initialize id, name
    @id = id
    @name = name
    @rank = {}
  end

  def to_s
    "Summoner : #{@name}  Rank : #{@rank}"
  end

end