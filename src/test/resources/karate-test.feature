Feature: Pruebas de la Marvel Characters API

  Background:
    * configure ssl = true
    * def baseUrl = karate.config.baseUrl
    * def username = karate.config.username
    * url baseUrl + '/' + username + '/api/characters'
    * header Content-Type = 'application/json'

  Scenario: Obtener todos los personajes
    Given path ''
    When method get
    Then status 200
    And match response == [] || response == '#[0]'

  Scenario: Obtener personaje por ID (exitoso)
    Given path '1'
    When method get
    Then status 200
    And match response.id == 1
    And match response.name == 'Iron Man'

  Scenario: Obtener personaje por ID (no existe)
    Given path '999'
    When method get
    Then status 404
    And match response.error == 'Character not found'

  Scenario: Crear personaje (exitoso)
    * def newCharacter =
      """
      {
        "name": "Iron Man",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    Given request newCharacter
    When method post
    Then status 201
    And match response.name == 'Iron Man'

  Scenario: Crear personaje (nombre duplicado)
    * def duplicatedCharacter =
      """
      {
        "name": "Iron Man",
        "alterego": "Otro",
        "description": "Otro",
        "powers": ["Armor"]
      }
      """
    Given request duplicatedCharacter
    When method post
    Then status 400
    And match response.error == 'Character name already exists'

  Scenario: Crear personaje (faltan campos requeridos)
    * def invalidCharacter =
      """
      {
        "name": "",
        "alterego": "",
        "description": "",
        "powers": []
      }
      """
    Given request invalidCharacter
    When method post
    Then status 400
    And match response.name == 'Name is required'
    And match response.alterego == 'Alterego is required'
    And match response.description == 'Description is required'
    And match response.powers == 'Powers are required'

  Scenario: Actualizar personaje (exitoso)
    * def updatedCharacter =
      """
      {
        "name": "Iron Man",
        "alterego": "Tony Stark",
        "description": "Updated description",
        "powers": ["Armor", "Flight"]
      }
      """
    Given path '1'
    And request updatedCharacter
    When method put
    Then status 200
    And match response.description == 'Updated description'

  Scenario: Actualizar personaje (no existe)
    * def updatedCharacter =
      """
      {
        "name": "Iron Man",
        "alterego": "Tony Stark",
        "description": "Updated description",
        "powers": ["Armor", "Flight"]
      }
      """
    Given path '999'
    And request updatedCharacter
    When method put
    Then status 404
    And match response.error == 'Character not found'

  Scenario: Eliminar personaje (exitoso)
    Given path '1'
    When method delete
    Then status 204

  Scenario: Eliminar personaje (no existe)
    Given path '999'
    When method delete
    Then status 404
    And match response.error == 'Character not found'