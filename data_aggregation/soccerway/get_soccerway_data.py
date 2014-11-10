import argparse
import urllib2
from urlparse import urljoin
import json
import traceback
from time import sleep

import pandas as pd
from bs4 import BeautifulSoup

from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


def prettify_key(key):
    return ''.join(x for x in key.title() if not x.isspace() and not x == '-')


def get_all_games_urls_per_season(season_year):
    if season_year < 2012:
        url = "http://uk.soccerway.com/national/england/premier-league/%d-%d/regular-season/matches/" % (season_year, season_year + 1)
    else:
        url = "http://uk.soccerway.com/national/england/premier-league/%d%d/regular-season/matches/" % (season_year, season_year + 1)
    final_games_urls = []
    driver = webdriver.Firefox()
    try:
        driver.get(url)
        print 'Getting games urls...'
        while True:
            links = driver.find_elements_by_xpath('//a[text()="More info"]')
            for link in links:
                final_games_urls.append(link.get_attribute("href"))

            previous_link = driver.find_element_by_id("page_competition_1_block_competition_matches_6_previous")
            if 'disabled' in previous_link.get_attribute("class"):
                break
            previous_link.click()
            WebDriverWait(driver, 10).until(EC.staleness_of(links[0]))
    finally:
        driver.close()
    print 'got %d urls' % len(final_games_urls)
    return final_games_urls


def process_game(game_url):
    html = urllib2.urlopen(game_url).read()
    soup = BeautifulSoup(html)

    # getting game info
    game_info_div = soup.find(id="page_match_1_block_match_info_4")
    details = game_info_div.find_all(class_="details clearfix")
    game_details = {
        u"TeamA": game_info_div.find(class_="container left").h3.a.text,
        u"TeamB": game_info_div.find(class_="container right").h3.a.text
    }
    for details_block in details[:3]:
        for dt, dd in zip(details_block.dl.find_all('dt'), details_block.dl.find_all('dd')):
            game_details[prettify_key(dt.text)] = dd.text.strip()

    # getting game statistics from charts
    game_chart_src = soup.find(id="page_match_1_block_match_stats_plus_chart_10").iframe['src']
    game_chart_src = urljoin(game_url, game_chart_src)
    chart_soup = BeautifulSoup(urllib2.urlopen(game_chart_src).read())
    left_chart = chart_soup.find(id="page_chart_1_chart_statsplus_1-wrapper")
    for legend_left, legend_title, legend_right in zip(left_chart.find_all(class_="legend left value"),
                                                       left_chart.find_all(class_="legend title"),
                                                       left_chart.find_all(class_="legend right value")):
        game_details[prettify_key(legend_title.text) + 'A'] = legend_left.text
        game_details[prettify_key(legend_title.text) + 'B'] = legend_right.text

    right_chart_js = chart_soup.find_all('script')[-1].string
    stats_json = json.loads(right_chart_js[right_chart_js.find("[{"):right_chart_js.find("}]);")] + '}]')
    for stat in stats_json:
        if stat['name'].startswith(game_details["TeamA"]):
            game_details[u"PosessionA"] = stat["y"]
        elif stat['name'].startswith(game_details["TeamB"]):
            game_details[u"PosessionB"] = stat["y"]
        else:
            assert(False)  # should not reach this part
    return game_details


def get_games_statistics(games_urls):
    games = []
    for index, game_url in enumerate(games_urls):
        if index % 20 == 0:
            print '%d urls processed' % index
        for i in xrange(3):
            try:
                games.append(process_game(game_url))
                break
            except:
                traceback.print_exc()
                print 'Error at url: %s' % game_url
                sleep(3)

    columns_list = ['TeamA', 'TeamB', 'Date', 'GameWeek', 'Venue',
                    'Attendance', 'HalfTime', 'FullTime', 'KickOff',
                    'PosessionA', 'PosessionB', 'CornersA', 'CornersB',
                    'FoulsA', 'FoulsB', 'ShotsOnTargetA', 'ShotsOnTargetB',
                    'ShotsWideA', 'ShotsWideB', 'OffsidesA', 'OffsidesB']
    games_df = pd.DataFrame(games, columns=columns_list)
    return games_df


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Gets all games statistics for a given season')
    parser.add_argument('-y', '--year', help='year of the season start', type=int)
    parser.add_argument('-o', '--output-filename', help='output file, where all games data will be stored', required=True)
    parser.add_argument('--games-links-filename', help='file with games links (if exists)')
    args = parser.parse_args()

    if not args.games_links_filename:
        assert(args.year)
        games_urls = get_all_games_urls_per_season(args.year)
    else:
        with open(args.games_links_filename) as f:
            games_urls = [line.strip() for line in f if line.strip()]
    games_df = get_games_statistics(games_urls)
    games_df.to_csv(path_or_buf=args.output_filename, header=True, index=False)