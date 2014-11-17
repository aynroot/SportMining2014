import urllib.request
import urllib.error
import re
from bs4 import BeautifulSoup

f = open("Players.csv", "ab")
reg = re.compile('\S[a-z A-Z]*')
for y_1 in range(2000,2014):
    print("Getting data for season " + str(y_1) + "/" + str(y_1+1))
    url_1 = "http://www.footballsquads.co.uk/eng/" + str(y_1) + "-" + str(y_1+1) + "/faprem.htm"
    page_1 = urllib.request.urlopen(url_1)
    soup_1 = BeautifulSoup(page_1)
    teams = soup_1.findAll('h5')
    for m in range(0,len(teams)):
        f = open("Players.csv", "ab")
        url_2 = "http://www.footballsquads.co.uk/eng/2000-2001/" + str(teams[m].a.get('href'))
        print("Getting data for team " + str(m+1))
        page_2 = urllib.request.urlopen(url_2)
        soup_2 = BeautifulSoup(page_2)
        players = soup_2.findAll('td')
        for n in range(9,len(players),8):
            if players[n].string != None and players[n+1].string != None:
                try:
                    int(players[n].string)
                except ValueError:
                    f.write(b"Season" + str(y_1).encode('utf8') + b"/" + str(y_1+1).encode('utf8') + b"\t" + ' '.join(reg.findall(players[n].string)).encode('utf8') + b"\t" + ' '.join(reg.findall(players[n+1].string)).encode('utf8') + b"\t" + str(players[n+4].string).encode('utf8')+ b"\n")
f.close()

