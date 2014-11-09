import urllib.request
import urllib.error
import re
from bs4 import BeautifulSoup

f = open("13-14 pie-chart.txt", "a")
for i in range(1483409,1483726):
    print("Getting data for pie " + str(int(i-1483408))) 
    f = open("13-14 pie-chart.txt", "a")
    url = "http://ru.soccerway.com/matches/2011/05/22/england/premier-league/aston-villa-football-club/liverpool-fc/" + str(i) + "/"
    k = 0
    while k != 1:
        try:
            page = urllib.request.urlopen(url)
        except urllib.request.HTTPError:
            k += -1
            print("Mistake")
        k +=1
    soup = BeautifulSoup(page)
    check = soup.findAll('title')
    if check[0].string == "Soccerway":
        continue
    if soup.findAll('dd')[0].string != "Премьер-Лига":
        print("Not EPL")
        continue
    f.write("\t" + soup.findAll('dd')[2].string + "\n")
    urlchart = "http://ru.soccerway.com/charts/statsplus/" + str(i) +"/"
    k = 0
    while k != 1:
        try:
            pagechart = urllib.request.urlopen(urlchart)
        except urllib.request.HTTPError:
            k += -1
            print("Mistake Chart")
        k +=1
    soupchart = BeautifulSoup(pagechart)
    chart = soupchart.findAll(attrs={"type":"text/javascript"})
    f.write(chart[6].string)
    f.close()
