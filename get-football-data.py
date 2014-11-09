import urllib.request
import urllib.error
import re
from bs4 import BeautifulSoup


f = open("2013-2014.txt", "a")
for i in range(1483409,1483726):  
    f = open("2013-2014.txt", "a")
    print("Getting data for " + str(int(i-1484308))) 
    url = "http://ru.soccerway.com/matches/2011/05/22/england/premier-league/aston-villa-football-club/liverpool-fc/" + str(i) + "/"
    page = urllib.request.urlopen(url)
    soup = BeautifulSoup(page)
    check = soup.findAll('title')
    if check[0].string == "Soccerway":
        continue
    cards = soup.findAll(attrs={"class":"bookings"})
    if int(len(cards)) == 40:
        f.write(check[0].string + "\t")
        f.write(soup.findAll('dd')[2].string + "\t")
        f.write(soup.findAll('dd')[4].string + "\t")
        f.write(soup.findAll('dd')[5].string + "\t")
        urlchart = "http://ru.soccerway.com/charts/statsplus/" + str(i) + "/"
        pagechart = urllib.request.urlopen(urlchart)
        soupchart = BeautifulSoup(pagechart)
        f.write(soupchart.findAll(attrs={"class":"legend left value"})[0].string + "\t")
        f.write(soupchart.findAll(attrs={"class":"legend left value"})[1].string + "\t")
        f.write(soupchart.findAll(attrs={"class":"legend left value"})[2].string + "\t")
        f.write(soupchart.findAll(attrs={"class":"legend right value"})[0].string + "\t")
        f.write(soupchart.findAll(attrs={"class":"legend right value"})[1].string + "\t")
        f.write(soupchart.findAll(attrs={"class":"legend right value"})[2].string + "\t")
        counter1 = 0
        counter2 = 0
        counter3 = 0
        counter4 = 0
        counter5 = 0
        counter6 = 0
    
    
        for j in range(1,12):
            if re.search("http://s1.swimg.net/gsmf/466/img/events/YC.png",ascii(cards[j])) != None:
                counter1 += 1
            if re.search("http://s1.swimg.net/gsmf/466/img/events/Y2C.png",ascii(cards[j])) != None:
                counter2 += 1
            if re.search("http://s1.swimg.net/gsmf/466/img/events/RC.png",ascii(cards[j])) != None:
                counter3 += 1
        for j in range(26,33):
            if re.search("http://s1.swimg.net/gsmf/466/img/events/YC.png",ascii(cards[j])) != None:
                counter1 += 1
            if re.search("http://s1.swimg.net/gsmf/466/img/events/Y2C.png",ascii(cards[j])) != None:
                counter2 += 1
            if re.search("http://s1.swimg.net/gsmf/466/img/events/RC.png",ascii(cards[j])) != None:
                counter3 += 1

        for j in range(13,25):
            if re.search("http://s1.swimg.net/gsmf/466/img/events/YC.png",ascii(cards[j])) != None:
                counter4 += 1
            if re.search("http://s1.swimg.net/gsmf/466/img/events/Y2C.png",ascii(cards[j])) != None:
                counter5 += 1
            if re.search("http://s1.swimg.net/gsmf/466/img/events/RC.png",ascii(cards[j])) != None:
                counter6 += 1 
        for j in range(33,int(len(cards))):
            if re.search("http://s1.swimg.net/gsmf/466/img/events/YC.png",ascii(cards[j])) != None:
                counter4 += 1
            if re.search("http://s1.swimg.net/gsmf/466/img/events/Y2C.png",ascii(cards[j])) != None:
                counter5 += 1
            if re.search("http://s1.swimg.net/gsmf/466/img/events/RC.png",ascii(cards[j])) != None:
                counter6 += 1
                
        f.write(str(counter1) + "\t")
        f.write(str(counter2) + "\t")
        f.write(str(counter3) + "\t")
        f.write(str(counter4) + "\t")
        f.write(str(counter5) + "\t")
        f.write(str(counter6) + "\n")
    else:
        print("!!!!!!!!!!!!!!Incorrect player's number in " + str(i) + " !!!!!!!!!!!!!!")
    f.close()



#f.write(soupchart.findAll('script')[6].string)


#url = "http://ru.soccerway.com/charts/statsplus/943750/"

#page = urllib.request.urlopen(url)
#soup = BeautifulSoup(page)
#shoot = soup.findAll(attrs={"class":"bookings"})
#testesteron = re.search("http://s1.swimg.net/gsmf/466/img/events/YC.png",ascii(shoot[4]))





#test = re.search("q", "abcdef")

#if test == None:
#    print("ypa")
#else:
#    print("blin")
#print(p)




#f = open("test.txt","w")
#f.write(shoot)
#f.close
####

#for m in range(1,2):
#    for d in range(1,32):
#        if(m == 2 and d > 28):
#            break
#        elif(m in [4,6,9,11] and d >30):
#            break
#        timestamp = "2009" + str(m) + str(d)
#        print ("Getting data for " + timestamp)
#        url = "http://www.wunderground.com/history/airport/KBUF/2009/" + str(m) + "/" + str(d) + "/DailyHistory.html"
####url = "http://www.wunderground.com/history/airport/KBUF/2009/12/5/DailyHistory.html"
#        page = urllib.request.urlopen(url)
#        soup = BeautifulSoup(page)
#        dayTemp = soup.findAll(attrs={"class":"nobr"})[5].span.string
#        if len(str(m))<2:
#            mStamp='0' + str(m)
#        else:	
#            mStamp = str(m)
#        if len(str(d)) <2:
#            dStamp = '0' +str(d)
#        else:
#            dStamp = str(d)
#        timestamp = '2009' +mStamp + dStamp
####timestamp = '20091201'
#        f.write(timestamp+","+dayTemp + '\n')
#f.close()
