import argparse
import datetime
from utils.utils import generate_season
import os
import pandas as pd
import random
import requests
from time import gmtime, strftime
import time

BASE_URL= 'https://stats.nba.com/stats/leaguedashplayerstats?'
EXPORT_PATH = f'data/intermediate/player.raw-{datetime.date.today()}.csv'

# Generate GMT time in the past by subracting a random number of minutes (from 15 - 40)
GMT_TIME = time.gmtime(time.time() - random.randrange(start= 900, stop= 2400))
IF_MODIFIED_TIME = time.strftime('%a, %d %b %Y %I:%M:%S GMT', GMT_TIME)

class DataFetcher(object):
    def __init__(self):
        self.data = None

    def get_player_data(self, season):
        """Requests player data from nba.com stats page.

        Args:
            season (int): 2 or 4-digit year representation.
        """

        # Dynamically generate the season format for the API and pass in as query param arg
        this_season = generate_season(season)
        headers = {
            'Host': 'stats.nba.com',
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:89.0) Gecko/20100101 Firefox/89.0',
            'Accept': 'application/json, text/plain, */*',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate, br',
            'x-nba-stats-origin': 'stats',
            'x-nba-stats-token': 'true',
            'Origin': 'https://www.nba.com',
            'Connection': 'keep-alive',
            'Referer': 'https://www.nba.com/',
            'If-Modified-Since': IF_MODIFIED_TIME,
            'Cache-Control': 'max-age=0'
        }
        params = (
            f'College=&Conference=&Country=&DateFrom=&DateTo=&Division=&DraftPick=&DraftYear=&'
            f'GameScope=&GameSegment=&Height=&LastNGames=0&LeagueID=00&Location=&MeasureType=Base&'
            f'Month=0&OpponentTeamID=0&Outcome=&PORound=0&PaceAdjust=N&PerMode=PerGame&Period=0&'
            f'PlayerExperience=&PlayerPosition=&PlusMinus=N&Rank=N&Season={this_season}&'
            f'SeasonSegment=&SeasonType=Regular Season&ShotClockRange=&StarterBench=&TeamID=0&'
            f'TwoWay=0&VsConference=&VsDivision=&Weight=')

        # Update class attribute if request succeeds
        try:
            resp = requests.get(url= BASE_URL, params= params, headers= headers)
            if resp.status_code == 200:
                if resp.json()['resultSets'][0]['rowSet']:
                    self.data = resp.json()
                else:
                    return None
        except requests.exceptions.RequestException as e:
            return None

    def export_player_data(self):
        """ Exports player data to CSV. """
        
        # Check that the data exists before exporting
        if not self.data:
            return None
        else:
            if not os.path.exists(f'data/intermediate'):
                os.mkdir('data/intermediate')
            
            if not os.path.exists(EXPORT_PATH):
                # Extract column headings and rows of player data and export to CSV
                try:
                    player_data = pd.DataFrame(
                        self.data['resultSets'][0]['rowSet'], 
                        columns= self.data['resultSets'][0]['headers'])
                    player_data.to_csv(f'data/intermediate/player.raw-{datetime.date.today()}.csv')
                except Exception as e:
                    print('Something catastrophic happened. Doing nothing')
                    return None
            else:
                return None

def main():
    parser = argparse.ArgumentParser(description= 'Fetch and export NBA player stats')
    parser.add_argument('season', 
        help= 'season year for filtering API results -- 2 or 4 digit',
        metavar= 'season',
        type= int,
        default= 2020)
    args = parser.parse_args()

    # Execute get and export
    fetcher = DataFetcher()
    fetcher.get_player_data(args.season)
    fetcher.export_player_data()

if __name__ == '__main__':
    main()