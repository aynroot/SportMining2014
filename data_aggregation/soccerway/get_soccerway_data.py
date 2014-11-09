import argparse

from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


def get_all_games_urls_per_season(season_year):
    url = "http://uk.soccerway.com/national/england/premier-league/%d-%d/regular-season/matches/" % (season_year, season_year + 1)
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


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Gets all games statistics for a given season')
    parser.add_argument('-y', '--year', help='year of the season start', type=int, required=True)
    parser.add_argument('-o', '--output-filename', help='output file, where all games data will be stored', required=True)
    args = parser.parse_args()

    games_urls = get_all_games_urls_per_season(args.year)
    with open(args.output_filename, 'w') as f_out:
        for url in games_urls:
            print >> f_out, url