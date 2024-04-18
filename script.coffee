class LocationModel extends Backbone.Model
  defaults:
    name: ""
    temperature: ""
    description: ""

class LocationCollection extends Backbone.Collection
  model: LocationModel

class LocationView extends Backbone.View
  tagName: "li"
  template: _.template(document.getElementById("cardTemplate").innerHTML)
  events:
    "click .edit": "editLocation"
    "click .remove": "removeLocation"
  initialize: ->
    @listenTo @model, "change", @render
    @listenTo @model, "destroy", @remove
  render: ->
    @$el.html @template(@model.toJSON())
    return this
  editLocation: ->
    newName = prompt "Enter new name:", @model.get("name")
    if newName
      @model.set "name", newName.charAt(0).toUpperCase() + newName.slice(1)
      units = $("#units").val()
      @fetchWeather newName, units
  removeLocation: ->
    @model.destroy()
  fetchWeather: (locationName, units) ->
    apiKey = "e70ef23b1712076b76b6018202d93967"
    apiUrl = "https://api.openweathermap.org/data/2.5/weather?q=#{locationName}&units=#{units}&appid=#{apiKey}"
    $.getJSON apiUrl, (data) =>
      temperature = data.main.temp
      description = data.weather[0].main
      if units is "metric"
        @model.set "temperature", "#{temperature}\u00B0C"
      else if units is "imperial"
        @model.set "temperature", "#{temperature}\u00B0F"
      else
        @model.set "temperature", "#{temperature}K"
      @model.set "description", description

class AppView extends Backbone.View
  el: "#app"
  events:
    "click #add-location": "addLocation"
  initialize: ->
    @locationCollection = new LocationCollection
    @listenTo @locationCollection, "add", @renderLocation
  addLocation: ->
    locationName = @$("#location").val().trim()
    if locationName
      units = @$("#units").val()
      @fetchWeather locationName, units
  fetchWeather: (locationName, units) ->
    apiKey = "e70ef23b1712076b76b6018202d93967"
    apiUrl = "https://api.openweathermap.org/data/2.5/weather?q=#{locationName}&units=#{units}&appid=#{apiKey}"
    $.getJSON apiUrl, (data) =>
      temperature = data.main.temp
      description = data.weather[0].main
      if units is "metric"
        temperature = "#{temperature}\u00B0C"
      else if units is "imperial"
        temperature = "#{temperature}\u00B0F"
      else
        temperature = "#{temperature}K"
      @locationCollection.add
        name: locationName.charAt(0).toUpperCase() + locationName.slice(1)
        temperature: temperature
        description: description
  renderLocation: (locationModel) ->
    locationView = new LocationView model: locationModel
    @$("#location-list").append locationView.render().el

app = new AppView
