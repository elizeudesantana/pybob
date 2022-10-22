from rocketry import Rocketry
from rocketry.conds import minutely, every

app = Rocketry()

@app.task(every('2s'))  
def a_cada_segundo():
    print("a cada 2 segundo")

@app.task('minutely after 10')
def restricoes():
    print('minuto depois do 10 segundos')


app.run()