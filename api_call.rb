require 'httparty'
require 'json'

require_relative 'summoner.rb'

CONFIG = File.read('config.json')
API_KEY = JSON.parse(CONFIG)['api_key']
BASE_URL = "api.riotgames.com"
HTTPS = "https://"
REGIONS = {
  0 => "eun1.",
  1 => "tr1."
}


# GET SUMMONER INFO VIA API WITH THE NAME
def getSummoner summoner_name, region
  response = HTTParty.get( HTTPS + region + BASE_URL + "/lol/summoner/v4/summoners/by-name/#{summoner_name}?api_key=#{API_KEY}" )
  if(response.code == 200)
    return response
  elsif(response.code == 404)
    return "Summoner isnt present!"
  else
    raise "Error !Response code -> #{response.code}"
  end
end

# GET CURRENT MATCH PARTICIPANTS WITH ENCRYPTED ACOOUNT ID
def getCurrentMatchParticipants id, region
  response = HTTParty.get(HTTPS + region + BASE_URL + "/lol/spectator/v4/active-games/by-summoner/#{id}?api_key=#{API_KEY}")
  if(response.code == 200)
    return response['participants']
  elsif(response.code == 404)
    return response.code
  else 
    raise "Error !Response code -> #{response.code}"
  end
end

# GET MATCH TIMELINE WITH ENCRYPTED ID AND SELECT LAST MATCH
def getMatchId accountId, region
  response = HTTParty.get( HTTPS + region + BASE_URL + "/lol/match/v4/matchlists/by-account/#{accountId}?api_key=#{API_KEY}" )
  if(response.code == 200)
    return response['matches'][0]['gameId']
  else
    raise "Error !Response code -> #{response.code}"
  end
end

# GET SUMMONER NAMES OF ALL THE PLAYERS
def getMatchParticipants matchId, region
  response = HTTParty.get( HTTPS + region + BASE_URL + "/lol/match/v4/matches/#{matchId}?api_key=#{API_KEY}")
  if(response.code == 200)
    return response['participantIdentities']
  else
    raise "Error !Response code -> #{response.code}"
  end
end

def getRank id, region
  response = HTTParty.get( HTTPS + region + BASE_URL + "/lol/league/v4/entries/by-summoner/#{id}?api_key=#{API_KEY}")
end

def displayRanks summoners
  summoners.each do |summoner|
    puts summoner
  end
end

def main
  summoner_id = JSON.parse(CONFIG)['username']
  region_selection = REGIONS[1]

  summoners = []

  summoner_response =  getSummoner(summoner_id, region_selection)

  participants = getCurrentMatchParticipants(summoner_response['id'], region_selection)
  
  if(participants != 404)
    participants.each do |participant|
      summoner = Summoner.new(participant['summonerId'], participant['summonerName'])
      response = getRank(participant['summonerId'], region_selection)
      response.each do |x|
        summoner.rank[x['queueType']] = [x['tier'], x['rank']]
      end
      summoners << summoner
    end
  else
    puts "No match present!"
  end
  displayRanks summoners
end

main
