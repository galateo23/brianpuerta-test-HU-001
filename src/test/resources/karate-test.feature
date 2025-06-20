Feature: Validaciones funcionales de la API de personajes de Marvel

  Background:
    * configure ssl = true
    * def random = java.util.UUID.randomUUID().toString()

  @id:1 @ListCharactersSuccess
  Scenario: CA#1 Confirmar respuesta exitosa y formato de lista
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/femsanch/api/characters'
    When method get
    Then status 200
    And match response == '#[]'

  @id:2 @GetCharacterById
  Scenario: CA#2 Registrar un personaje y consultar por su ID
    * def name = 'Iron Man ' + random.substring(0, 5)
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/femsanch/api/characters'
    And request
      """
      {
        "name": "#(name)",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method post
    Then status 201
    * def characterId = response.id

    Given url `http://bp-se-test-cabcd9b246a5.herokuapp.com/femsanch/api/characters/${characterId}`
    When method get
    Then status 200

  @id:3 @GetCharacterByIdNotExists
  Scenario: CA#3 Solicitar un personaje con ID inexistente
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/femsanch/api/characters/4500'
    When method get
    Then status 404
    And match response.error == "Character not found"

  @id:4 @CreateCharacter
  Scenario: CA#4 Crear personaje de prueba con datos válidos
    * def name = 'Iron Man ' + random.substring(0, 5)
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/femsanch/api/characters'
    And request
      """
      {
        "name": "#(name)",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method post
    Then status 201

  @id:5 @CreateCharacterWithNameAlreadyExists
  Scenario: CA#5 Intento de duplicar un personaje con el mismo nombre
    * def name = 'Iron Man ' + random.substring(0, 5)
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/femsanch/api/characters'
    And request
      """
      {
        "name": "#(name)",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method post
    Then status 201

    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/femsanch/api/characters'
    And request
      """
      {
        "name": "#(name)",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method post
    Then status 400
    And match response.error == "Character name already exists"

  @id:6 @CreateCharacterMissingParameters
  Scenario: CA#6 Envío de personaje incompleto sin datos obligatorios
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/femsanch/api/characters'
    And request
      """
      {
        "name": "",
        "alterego": "",
        "description": "",
        "powers": []
      }
      """
    When method post
    Then status 400
    And match response.name == "Name is required"
    And match response.description == "Description is required"
    And match response.alterego == "Alterego is required"
    And match response.powers == "Powers are required"

  @id:7 @UpdateCharacter
  Scenario: CA#7 Modificar los datos de un personaje existente
    * def name = 'Iron Man ' + random.substring(0, 5)
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/femsanch/api/characters'
    And request
      """
      {
        "name": "#(name)",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method post
    Then status 201
    * def characterId = response.id

    Given url `http://bp-se-test-cabcd9b246a5.herokuapp.com/femsanch/api/characters/${characterId}`
    And request
      """
      {
        "name": "Iron Man Avengers Updated",
        "alterego": "Tony Stark",
        "description": "Updated description",
        "powers": ["Armor", "Flight"]
      }
      """
    When method put
    Then status 200
    And match response.name == "Iron Man Avengers Updated"

  @id:8 @UpdateCharacterNotExists
  Scenario: CA#8 Intentar editar un personaje no registrado
    * def name = 'Iron Man ' + random.substring(0, 5)
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/femsanch/api/characters/83919'
    And request
      """
      {
        "name": "Iron Man Avengers Updated",
        "alterego": "Tony Stark",
        "description": "Updated description",
        "powers": ["Armor", "Flight"]
      }
      """
    When method put
    Then status 404
    And match response.error == "Character not found"

  @id:9 @DeleteCharacter
  Scenario: CA#9 Crear un personaje y eliminarlo luego
    * def name = 'Iron Man ' + random.substring(0, 5)
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/femsanch/api/characters'
    And request
      """
      {
        "name": "#(name)",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method post
    Then status 201
    * def characterId = response.id

    Given url `http://bp-se-test-cabcd9b246a5.herokuapp.com/femsanch/api/characters/${characterId}`
    When method delete
    Then status 204

  @id:10 @DeleteCharacterNotExists
  Scenario: CA#10 Eliminar un personaje con ID que no existe
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/femsanch/api/characters/231232'
    When method delete
    Then status 404
    And match response.error == "Character not found"