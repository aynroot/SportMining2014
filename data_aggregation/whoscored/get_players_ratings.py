# Python 2.7
# -*- coding: utf-8 -*-
import urllib
import re
import httplib
import traceback
import time
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


def remove_duplicates(seq, idfun=None): 
   # order preserving
   if idfun is None:
       def idfun(x): return x
   seen = {}
   result = []
   for item in seq:
       marker = idfun(item)
       # in old Python versions:
       # if seen.has_key(marker)
       # but in new ones:
       if marker in seen: continue
       seen[marker] = 1
       result.append(item)
   return result

f_seasons = open("Seasons.csv", "a")
f_teams = open("Teams.csv", "a")
f_players = open("Players.csv", "a")
f_ratings = open("Ratings.csv", "a")

url = "http://www.whoscored.com/Regions/252/Tournaments/2/Seasons/4311"
driver = webdriver.Firefox()
driver.get(url)
season = 1999
season_urls = []
team_urls = []
el = driver.find_element_by_id('seasons')
for i in xrange(len(el.find_elements_by_tag_name('option'))-1):
    el = driver.find_element_by_id('seasons')
    for option in el.find_elements_by_tag_name('option'):
        if option.text == str(season) + "/" + str(season+1):
            option.click() # select() in earlier versions of webdriver
            season_urls.append(str(driver.current_url))
            f_seasons.write(str(driver.current_url) + '\n')
            e = 0
            while e != 1:
              # time.sleep(2)
              try:
                driver.get(driver.current_url)
                teams = driver.find_element_by_css_selector("div.stat-table").find_elements_by_css_selector("a.team-link")
                break
              except:
                e -= 1
                # traceback.print_exc()
                print 'Error at url: %s' % driver.current_url
              e += 1
            for j in xrange(len(teams)):
                team_urls.append(str(teams[j].text))
                team_urls.append(str(teams[j].get_attribute("href")))
                f_teams.write(str(teams[j].text) + "\t"+ str(teams[j].get_attribute("href")) +'\n')
            season += 1
            break
f_seasons.close()
f_teams.close()

team_urls = remove_duplicates(team_urls)

player_urls = []
for team_url in team_urls:
    if not "http" in team_url:
        continue
    else:
      k = 0
      while k != 1:
        # time.sleep(5)
        try:
          driver.get(str(team_url))
          players_temp = driver.find_elements_by_css_selector("a.player-link")
          break
        except:
          k -= 1
          print 'Error at url: temp %s' % team_url
        k += 1       
    for p in xrange(len(players_temp)-1):
        player_urls.append(players_temp[p].text.encode('utf-8'))
        player_urls.append(players_temp[p].get_attribute("href").encode('utf-8'))
        f_players.write(players_temp[p].text.encode('utf-8') + '\t' + players_temp[p].get_attribute("href").encode('utf-8') + '\n')
f_players.close()

player_urls = remove_duplicates(player_urls)

ratings = []
for player_url in player_urls:
  if not "http" in player_url:
    continue
  else:
    d = 0
    while d != 1:
      # time.sleep(5)
      try:
        driver.get(str(player_url) + "/History")
        name = driver.find_element_by_name("title").get_attribute("content")
        seasons = driver.find_elements_by_css_selector("td.rank.tournament")
        links = driver.find_elements_by_css_selector("td.rating")
        break
      except:
        k -= 1
        print 'Error at url: %s' % player_url
      k += 1
    for s in xrange(len(seasons)-1):
      ratings.append(name.encode('utf-8'))
      ratings.append(seasons[s].text.encode('utf-8'))
      ratings.append(links[s].text.encode('utf-8'))
      f_ratings.write(name.encode('utf-8') + '\t' + seasons[s].text.encode('utf-8') + '\t' + links[s].text.encode('utf-8') + '\n')
f_ratings.close()

print season_urls
print team_urls
print player_urls
print ratings


# print name.encode('utf-8')
# for i in xrange(len(seasons)):
#     print seasons[i].text.encode('utf-8')
#     print links[i].text.encode('utf-8')




# print season_urls
# print team_urls
# print player_urls

# print len(season_urls)
# print len(team_urls)
# print len(player_urls)


print "finita"

driver.close()











# *****************Gather info about particular player
# url = "http://www.whoscored.com/Players/70/History/"
# driver = webdriver.Firefox()
# driver.get(url)
# name = driver.find_element_by_name("title").get_attribute("content")
# seasons = driver.find_elements_by_css_selector("td.rank.tournament")
# links = driver.find_elements_by_css_selector("td.rating")
# print name
# for i in xrange(len(seasons)):
#     print seasons[i].text
#     print links[i].text

# *****************Gather list of teams
# url = "http://www.whoscored.com/Regions/252/Tournaments/2/England-Premier-League"
# driver = webdriver.Firefox()
# driver.get(url)
# teams = driver.find_element_by_css_selector("div.stat-table").find_elements_by_css_selector("a.team-link")
# for i in xrange(len(teams)):
#     print teams[i].text
#     print teams[i].get_attribute("href")

# *****************Gather list of players
# url = "http://www.whoscored.com/Teams/15"
# driver = webdriver.Firefox()
# driver.get(url)
# players = driver.find_element_by_css_selector("td.pn").find_elements_by_css_selector("a.player-link")
# for i in xrange(len(players)):
#     print players[i].text
#     print players[i].get_attribute("href")

#******************Script to interact websites
# url = "http://www.whoscored.com/Teams/15/Archive/"
# driver = webdriver.Firefox()
# driver.get(url)
# el = driver.find_element_by_id('stageId')
# for option in el.find_elements_by_tag_name('option'):
#     if option.text == 'Premier League - 2012/2013':
#         option.click() # select() in earlier versions of webdriver
#         print driver.current_url
#         break


