
# Python 2.7
import urllib
import re
from bs4 import BeautifulSoup

# Creating regular expression, that will be useful in the end
reg = re.compile('\S[a-z A-Z]*')

# Creating/opening file for saving data
f = open("Teams.csv", "a")

# Cycle for pages from different seasons
for y_1 in range(2000,2001):
    f = open("Teams.csv", "a")
    print "Getting data for " + str(y_1) + "/" + str(y_1+1)
    # Creating different types of links
    if y_1 < 2012:
        url = "http://uk.soccerway.com/national/england/premier-league/" + str(y_1) + "-" + str(y_1+1) + "/"
    else:
    url = "http://uk.soccerway.com/national/england/premier-league/" + str(y_1) + str(y_1+1) + "/"
    # Processing for two types of errors. 1 - site doesn't response; 2 - site gave empty page
    p = 0
    k = 0
    while p != 1:
        while k != 1:
            try:
                page = urllib.urlopen(url)
            except urllib.HTTPError:
                k -= 1
                print "Mistake"
            k += 1
        soup = BeautifulSoup(page)
        if soup.findAll('h2') == []:
            p -= 1
        p += 1

    # Collecting info about teams
    teams_1 = soup.findAll(attrs={"class":"team team-a "})
    teams_2 = soup.findAll(attrs={"class":"team team-b "})

    # Writing names of teams into the csv, using regular expresseion we've mentioned before
    for n in range(0,len(teams_1)):
        f.write("Season " + str(y_1) + "/" + str(y_1+1) + '\t' + reg.findall(teams_1[n].a.string)[0] + '\n')
    for n in range(0,len(teams_2)):
        f.write("Season " + str(y_1) + "/" + str(y_1+1) + '\t' +  reg.findall(teams_2[n].a.string)[0] + '\n')

# It's necessary to close the file, otherwise it won't be saved
f.close()
