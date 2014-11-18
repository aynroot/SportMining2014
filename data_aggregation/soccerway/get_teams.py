import urllib.request
import urllib.error
import re
from bs4 import BeautifulSoup

# Создаем шаблон регулярного выражения, который понадобится в конце.
reg = re.compile('\S[a-z A-Z]*')

# Создаем/открываем файл куда будем записывать инфу
f = open("Teams.csv", "a")

# Цикл для страничек с разных сезонов
for y_1 in range(2000,2015):
    f = open("Teams.csv", "a")
    print("Getting data for " + str(y_1) + "/" + str(y_1+1))
    # Т.к. ссылка отличается в зависимости от сезона делаем условие
    if y_1 < 2012:
        url = "http://uk.soccerway.com/national/england/premier-league/" + str(y_1) + "-" + str(y_1+1) + "/"
    else:
        url = "http://uk.soccerway.com/national/england/premier-league/" + str(y_1) + str(y_1+1) + "/"
    # Обрабатываем два вида ошибок. Первый, сайт не прогрузился; Второй, сайт выдал пустую страничку
    p = 0
    k = 0
    while p != 1:
        while k != 1:
                try:
                    page = urllib.request.urlopen(url)
                except urllib.request.HTTPError:
                    k += -1
                    print("Mistake")
                k +=1
        soup = BeautifulSoup(page)
        if soup.findAll('h2') == []:
            p += -1
        p += +1

    # Собираем инфу о командах сезона в две переменные (такая уж структура на сайте)
    teams_1 = soup.findAll(attrs={"class":"team team-a "})
    teams_2 = soup.findAll(attrs={"class":"team team-b "})

    # Записываем в файл названия всех команд, используя шаблон регулярного выражения из начала
    for n in range(0,len(teams_1)):
        f.write("Season " + str(y_1) + "/" + str(y_1+1) + '\t' + reg.findall(teams_1[n].a.string)[0] + '\n')
    for n in range(0,len(teams_2)):
        f.write("Season " + str(y_1) + "/" + str(y_1+1) + '\t' +  reg.findall(teams_2[n].a.string)[0] + '\n')

# Обязательно нужно закрыть файл, чтобы он сохранился
f.close()
