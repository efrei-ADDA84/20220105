import requests
import os
#Import Flask
from flask import Flask, jsonify, request

#Initialize Flask by creating an application instance
app = Flask(__name__)

#Define /weather as the endpoint of the URL path for the route
@app.route('/weather')
def wrapper():
    lat= request.args.get("LAT")
    lon = request.args.get("LONG")
    apikey = os.getenv("API_KEY") #we give this parameter when calling the command so no need for request.args.get
    """
        apikey = "44bb37ac5b6c0dbac2b353484a53499d"
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
    app.run(debug=True, host='0.0.0.0', port=8080)
    


