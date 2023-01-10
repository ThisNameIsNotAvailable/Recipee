# Recipee

Recipee is an app for finding recipes. It uses Spoonacular API to get data. 
In this app you can find a recipe using complex search, also there are tutorials on how to cook meals that you found. Another feature is a shopping list.
You can add the recipe to the shopping list and all ingredients that you need to cook a particular meal will be on a separate screen, so you can easily 
access all ingredients you need to buy. Recipes can be added to the favourites folder as well as to folders you will create yourself, 
so you do not lose recipes you like. However to use this feature you need to be logged in with eather Facebook or Google. 
In addition there are a possibility to find recipes by ingredients that you have at home.

# Installation Guide

To install this app you must have a machine running MacOS and a device/simulator with iOS. If both conditions are met after downloading repository on your computer,
you need to run terminal, go to repository's directory and run `pod install`, also you need to create an account on https://spoonacular.com/food-api/ and 
put your API key in a variable called `apiKey` inside `APICaller.swift`. After doing that you can press play button in Xcode and run the app 
on the simulator or connected device.
