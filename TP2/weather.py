import requests
import os
#Import Flask
from flask import Flask, jsonify, request

#Initialize Flask by creating an application instance
app = Flask(__name__)

#bhjbhjhjs
@app.route('/')
def wrapper():
    lat= request.args.get("LAT")
    lon = request.args.get("LONG")
    apikey = os.getenv("API_KEY") #we give this parameter when calling the command so no need for request.args.get
    """
    #If the user doesn't enter all the parameters required
    if lat == None or lon == None or apikey == "":
        #Exit with an error message
        #print("You didn't enter all the parameters required!!")
        #exit(1)
        lat= 30.000
        lon = 29.45
        apikey = "9e518e1b1b5a0288918557d8a16255bb"
    """
    #The url of the API from where we acquire the data
    url = f"https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={apikey}"
    res = requests.get(url)
    data = res.json()
    
    #temp = data['main']['temp']
    #f'In the city at latitude {lat} and longitude {lon} the temperature will be {temp}°C'
    msg = jsonify(data)

    return msg


if __name__ == "__main__":
    #Run the Flask application 
    app.run(debug =True, host='localhost', port=8080)
    


