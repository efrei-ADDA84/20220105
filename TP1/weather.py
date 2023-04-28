import requests
import os

def wrapper():
    #os.getenv() is used to retrieve the values of the LAT, LONG, and API_KEY environment variables
    #It returns the value of the environment variable if it is set, or "None" if the variable is not set
    lat= os.getenv("LAT")
    lon = os.getenv("LONG")
    apikey = os.getenv("API_KEY")

    #If the user doesn't enter all the parameters required
    if lat == None or lon == None or apikey == "":
        #Exit with an error message
        print("You didn't enter all the parameters required!!")
        exit(1)
        #lat= 30.000
        #lon = 29.45
        #apikey = "9e518e1b1b5a0288918557d8a16255bb"

    #The url of the API from where we acquire the data
    url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={apikey}"
    res = requests.get(url)
    data = res.json()
    
    temp = data['main']['temp']
    
    return f'In the city at latitude {lat} and longitude {lon} the temperature will be {temp}°F'


if __name__ == "__main__":
    print(wrapper())



