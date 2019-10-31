import math
import json
import tables
import strutils
import hashes
import itertools
import sequtils
import sugar
import lists
import algorithm
import os
    
type
    City* = object
        name*, capitalCity*: string
        latitude, longitude: string

type CachedObject* = object
    # city1, city2: City
    distance: float
      

var lookupDistanceCache = initTable[string, CachedObject]()

proc getKmBetweenCoords(lat1: float, long1: float, lat2: float, long2: float): float =
    var phi1 = degToRad(lat1)
    var phi2 = degToRad(lat2)
    var delta_lambda = degToRad(long2 - long1)
    var r = 6371e3
    var d = arccos(sin(phi1) * sin(phi2) + cos(phi1) * cos(phi2) * cos(delta_lambda)) * r
    return d / 1000

proc getCachedDistance(startingCountry: City, country: City): float =
    var newIndex: string = startingCountry.name & country.name

    if not lookupDistanceCache.hasKey(newIndex):
        var cachedObject = CachedObject()
        var distance = getKmBetweenCoords(parseFloat(startingCountry.latitude), parseFloat(startingCountry.longitude), parseFloat(country.latitude), parseFloat(country.longitude))
        cachedObject.distance = distance
        lookupDistanceCache[newIndex] = cachedObject
        return cachedObject.distance
    else:
        return lookupDistanceCache[newIndex].distance


proc getCountriesInsideRange(startingCountry: City, countriesTable: Table[string, City], maxDistance: float): Table[string, City] =
    var countriesInRange: Table[string, City] = initTable[string, City]()

    for country, countryObject in countriesTable:
        if startingCountry.name != countryObject.name:
            var distance = getCachedDistance(startingCountry, countryObject)

            if distance <= maxDistance:
                countriesInRange[country] = countryObject

    return countriesInRange

proc keithUnmarshallJson(jsonNode: JsonNode): City =
    var city: City = to(jsonNode, City)
    return city

proc loadCountries(): Table[string, City] =
    let jsonNode = parseFile("sexy_countries.json")
    var countriesTable: Table[string, City] = initTable[string, City]()

    for city in jsonNode:
        if city["capitalCity"].getStr() != "":
            var cityStruct = keithUnmarshallJson(city)
            countriesTable[cityStruct.name] = cityStruct

    return countriesTable

proc calcDistanceTaken(subset: seq[string], startingCountry: City, maxDistance: float, possibleCountries: Table[string, City]): float =
    var distance: float = 0
    var country1: City = startingCountry
    for country2name in subset:
        var country2: City = possibleCountries[country2name]
        distance += getCachedDistance(country1, country2)
        country1 = country2
        if distance > maxDistance:
            return -1
    return distance

proc getSequenceOfCapitals(subset: seq[string], possibleCountries: Table[string, City]): seq[string] =
    var returned: seq[string]

    for country in subset:
        returned.add(possibleCountries[country].capitalCity)
    return returned

proc getLongestRoute(subsetLength: int, startingCountry: City, maxDistance: float, possibleCountries: Table[string, City]): seq[string] =
    var possibleQueue: seq[string]
    var subsetKeys: seq[string]

    for k,v in possibleCountries:
        subsetKeys.add(k)

    for subset in combinations(subsetKeys, subsetLength + 1):
        var distance: float = calcDistanceTaken(subset, startingCountry, maxDistance, possibleCountries)
        if distance > -1:
            possible_queue.add(getSequenceOfCapitals(subset, possibleCountries))
            break
    return possibleQueue

var input = paramStr(1).split("|")
var stringDistance: string = input[0]
var stringCountry: string = input[1]

var countries: Table[string, City] = loadCountries()
var maxDistance: float = parseFloat(stringDistance)
var startingCountry: City = countries[stringCountry]
var countriesInsideRange: Table[string, City] = getCountriesInsideRange(startingCountry, countries, maxDistance)

var count = 0
var results: seq[seq[string]]
while count < len(countriesInsideRange) + 1:
    var longest: seq[string] = getLongestRoute(count, startingCountry, 1000, countriesInsideRange)
    results.add(longest)
    count = count + 1

var longest: seq[string]
var longestLength: int

for sequence in results:
    if len(sequence) > longestLength:
        longest = sequence
        longestLength = len(sequence)

var final: string

final = intToStr(longestLength + 1) & " " & startingCountry.capitalCity

for capital in longest:
    final = final & "," & capital

echo final
