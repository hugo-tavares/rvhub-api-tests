@topups
Feature: Recarga de celular
    Background:
		* def authRequest = call read('classpath:aplic/rvhub/shared/auth-registered-store.feature')
        * def jwt = authRequest.response.access_token
        * def paths = read('classpath:aplic/rvhub/cellphonetopups/cellphone-topups-paths.json')
        * def idempotencyKey = Math.floor(Date.now()) + java.util.UUID.randomUUID()

	Scenario: Solicitação e confirmação de recarga com valor variável
		# Solicitando
        Given url baseUrl
        And path paths.transactions
		And header Authorization = jwt
        And header X-Idempotency-Key = idempotencyKey
		Given request { "product_id": "2", "area_code": "11", "cell_phone_number": "994145350", "amount": 3000 }
		When method POST
		Then status 201
        And assert response.product_id =="2"
        And assert response.area_code == "11"
        And assert response.cell_phone_number == "994145350"
        And assert response.amount == 3000
        And assert response.face_amount == 3000
        * def transactionId = response.id

        # Confirmando
        * def idempotencyKey2 = Math.floor(Date.now())
         Given url baseUrl
        And path paths.transactions + '/' + transactionId + paths.capture
		And header Authorization = jwt
        And header X-Idempotency-Key = idempotencyKey2
		Given request {}
		When method POST
		Then status 200
        And assert response.status == "captured"
        And assert response.product_id =="2"
        And assert response.area_code == "11"
        And assert response.cell_phone_number == "994145350"
        And assert response.amount == 3000
        And assert response.face_amount == 3000
        

    Scenario Outline: Erro tratado: <message>
        Given url baseUrl
        And path paths.transactions
        And header Authorization = jwt
        And header X-Idempotency-Key = idempotencyKey
        Given request { "product_id": "2", "area_code": #(areaCode), "cell_phone_number": #(phoneNumber), "amount": 3000 }
        When method POST
        Then status 201
        And assert response.status == "denied"
        And assert response.status_reason == <message>
        Examples: 
            | areaCode | phoneNumber | message                                   | 
            | 11       | 9941453     | "incomplete_or_invalid_cell_phone_number" | 
            | 99       | 999990002   | "insufficient_credit_limit"               | 
            | 99       | 999990003   | "insufficient_inventory"                  | 
            | 99       | 999990004   | "unauthorized_cell_phone_number"          | 
            | 99       | 999990005   | "invalid_password"                        | 
            | 99       | 999990006   | "maximum_number_of_connections_reached"   | 
            | 99       | 999990007   | "system_in_maintenance"                   | 
            | 99       | 999990011   | "timeout"                                 | 
            | 99       | 999990013   | "expired_purchase"                        | 
            | 99       | 999990014   | "nonexistent_purchase"                    |
    # TODO: invalid amount, user or store not found, provider or product not found
            
